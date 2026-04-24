const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const sharp = require("sharp");
const { GoogleGenAI, Modality } = require("@google/genai");

admin.initializeApp();

const db = getFirestore();
const bucket = admin.storage().bucket();

const PROJECT_ID = process.env.GCLOUD_PROJECT;
const LOCATION = process.env.GOOGLE_CLOUD_LOCATION || "global";
const IMAGE_MODEL = "gemini-2.5-flash-image";

exports.generatePuzzleForSession = onCall(
  {
    region: "us-central1",
    timeoutSeconds: 540,
    memory: "1GiB",
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "You must be signed in.");
    }

    const { groupId, sessionId } = request.data || {};
    const callerUid = request.auth.uid;

    if (!groupId || !sessionId) {
      throw new HttpsError("invalid-argument", "groupId and sessionId are required.");
    }

    const groupRef = db.collection("groups").doc(groupId);
    const sessionRef = db.collection("sessions").doc(sessionId);

    const [groupSnap, sessionSnap] = await Promise.all([
      groupRef.get(),
      sessionRef.get(),
    ]);

    if (!groupSnap.exists) {
      throw new HttpsError("not-found", "Group not found.");
    }

    if (!sessionSnap.exists) {
      throw new HttpsError("not-found", "Session not found.");
    }

    const group = groupSnap.data();
    const session = sessionSnap.data();

    if ((group.ownerId || "") !== callerUid) {
      throw new HttpsError("permission-denied", "Only the group creator can generate the image.");
    }

    if (session.status === "generated") {
      return {
        ok: true,
        status: "generated",
        finalImageURL: session.generatedImageURL || "",
        pieceCount: session.pieceCount || 0,
        message: "Image already generated.",
      };
    }

    if (session.status === "generating") {
      return {
        ok: true,
        status: "generating",
        finalImageURL: session.generatedImageURL || "",
        pieceCount: session.pieceCount || 0,
        message: "Generation already in progress.",
      };
    }

    const memberIds = Array.isArray(group.memberIds) ? group.memberIds : [];
    const maxMembers = group.maxMembers || 0;
    const groupName = group.name || "Puzzle Picture Group";
    const promptTheme = session.promptTheme || "How did today feel?";

    if (memberIds.length === 0) {
      throw new HttpsError("failed-precondition", "This group has no members.");
    }

    if (memberIds.length < maxMembers) {
      throw new HttpsError("failed-precondition", "Group is not full yet.");
    }

    const submissionsSnap = await db
      .collection("submissions")
      .where("groupId", "==", groupId)
      .where("sessionId", "==", sessionId)
      .get();

    if (submissionsSnap.size !== memberIds.length) {
      throw new HttpsError("failed-precondition", "All members must submit before generation.");
    }

    try {
      await sessionRef.update({
        status: "generating",
        isGenerating: true,
        statusStep: "Preparing submissions...",
        errorMessage: "",
        groupName,
        generatingStartedAt: FieldValue.serverTimestamp(),
      });

      const submissions = submissionsSnap.docs.map((doc) => doc.data());

      const orderedTexts = memberIds.map((uid) => {
        const item = submissions.find((s) => s.userId === uid);
        return item?.journalText || "";
      });

      const prompt = buildPrompt(groupName, orderedTexts, promptTheme);

      await sessionRef.update({
        statusStep: "Creating artwork...",
      });

      const finalImageBuffer = await generateImageBuffer(prompt);

      await sessionRef.update({
        statusStep: "Uploading final image...",
      });

      const finalStoragePath = `generated/${groupId}/${sessionId}/final.png`;
      await uploadBuffer(finalStoragePath, finalImageBuffer, "image/png");
      const finalImageURL = await publicUrlFor(finalStoragePath);

      await sessionRef.update({
        statusStep: "Splitting puzzle pieces...",
      });

      const pieces = await splitImageIntoPieces(finalImageBuffer, memberIds.length);

      await sessionRef.update({
        statusStep: "Saving puzzle pieces...",
      });

      const batch = db.batch();

      batch.update(sessionRef, {
        status: "generated",
        isGenerating: false,
        statusStep: "Complete",
        generatedImageURL: finalImageURL,
        finalPrompt: prompt,
        groupName,
        errorMessage: "",
        generatedAt: FieldValue.serverTimestamp(),
        pieceCount: memberIds.length,
      });

      for (let i = 0; i < memberIds.length; i++) {
        const uid = memberIds[i];
        const pieceBuffer = pieces[i];
        const piecePath = `generated/${groupId}/${sessionId}/pieces/${uid}.png`;

        await uploadBuffer(piecePath, pieceBuffer, "image/png");
        const pieceURL = await publicUrlFor(piecePath);

        const pieceRef = db.collection("puzzlePieces").doc(`${sessionId}_piece_${uid}`);
        batch.set(
          pieceRef,
          {
            pieceId: `${sessionId}_piece_${uid}`,
            sessionId,
            groupId,
            userId: uid,
            imageURL: pieceURL,
            index: i,
            createdAt: FieldValue.serverTimestamp(),
          },
          { merge: true }
        );

        const historyRef = db
          .collection("users")
          .doc(uid)
          .collection("sessionHistory")
          .doc(sessionId);

        batch.set(
          historyRef,
          {
            sessionId,
            groupId,
            groupName,
            finalImageURL,
            pieceURL,
            promptTheme,
            createdAt: FieldValue.serverTimestamp(),
          },
          { merge: true }
        );
      }

      await batch.commit();

      return {
        ok: true,
        status: "generated",
        finalImageURL,
        pieceCount: memberIds.length,
        message: "Artwork generated successfully.",
      };
    } catch (error) {
      const message =
        error instanceof Error ? error.message : "Unknown generation error";

      await sessionRef.update({
        status: "failed",
        isGenerating: false,
        statusStep: "Generation failed",
        errorMessage: message,
      });

      throw new HttpsError("internal", message);
    }
  }
);

function buildPrompt(groupName, entries, theme) {
  const joined = entries
    .map((text, index) => `Member ${index + 1}: ${text}`)
    .join("\n");

  return `
Create one cohesive, emotionally rich square illustration for a collaborative journaling puzzle app.

Group name: ${groupName}
Theme: ${theme}

Use these member reflections:
${joined}

Visual goals:
- cinematic digital illustration
- dreamy and polished
- emotionally expressive
- visually unified, not collage-like
- warm, premium, social-app friendly
- no text inside the image
- square composition
- suitable for splitting cleanly into puzzle pieces
`.trim();
}

async function generateImageBuffer(prompt) {
  const client = new GoogleGenAI({
    vertexai: true,
    project: PROJECT_ID,
    location: LOCATION,
  });

  const response = await client.models.generateContent({
    model: IMAGE_MODEL,
    contents: prompt,
    config: {
      responseModalities: [Modality.TEXT, Modality.IMAGE],
    },
  });

  const candidate = response.candidates?.[0];
  const parts = candidate?.content?.parts || [];

  for (const part of parts) {
    const inlineData = part.inlineData;
    if (inlineData?.data) {
      return Buffer.from(inlineData.data, "base64");
    }
  }

  throw new Error("Model did not return an image.");
}

async function splitImageIntoPieces(imageBuffer, pieceCount) {
  const resizedBuffer = await sharp(imageBuffer)
    .resize(768, 768, { fit: "cover" })
    .png()
    .toBuffer();

  const image = sharp(resizedBuffer);
  const metadata = await image.metadata();

  const width = metadata.width || 768;
  const height = metadata.height || 768;

  const columns = Math.ceil(Math.sqrt(pieceCount));
  const rows = Math.ceil(pieceCount / columns);

  const pieceWidth = Math.floor(width / columns);
  const pieceHeight = Math.floor(height / rows);

  const pieces = [];

  for (let i = 0; i < pieceCount; i++) {
    const row = Math.floor(i / columns);
    const col = i % columns;

    const left = col * pieceWidth;
    const top = row * pieceHeight;

    const extracted = await sharp(resizedBuffer)
      .extract({
        left,
        top,
        width: col === columns - 1 ? width - left : pieceWidth,
        height: row === rows - 1 ? height - top : pieceHeight,
      })
      .png()
      .toBuffer();

    pieces.push(extracted);
  }

  return pieces;
}

async function uploadBuffer(path, buffer, contentType) {
  const file = bucket.file(path);
  await file.save(buffer, {
    metadata: { contentType },
    resumable: false,
  });
}

async function publicUrlFor(path) {
  const file = bucket.file(path);
  await file.makePublic();
  return `https://storage.googleapis.com/${bucket.name}/${path}`;
}
