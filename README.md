# Puzzle Picture App

## 📝 App Overview

### Description
An app that creates an image from x people's journal entries and creates an AI image based on these x separate entries. The image is partitioned into x amount of pieces and one piece of the image is given to each group member. Bring them together to build the AI image.

### App Evaluation
* **Category:** Social, Entertainment, Community Building
* **Mobile:** Uniquely mobile experience utilizing push notifications, camera access for image saving, and real-time collaborative assembly.
* **Story:** This app tells the story of how individual perspectives come together to create something meaningful.
* **Market:** Families, Friends, Organizations, Groups, and Various Communities.
* **Habit:** This app can be used however the collective feels it is most beneficial, likely as a daily or weekly bonding ritual.
* **Scope:** Feature-rich with a clear path from MVP (text input and image generation) to expanded collaborative gameplay.

---

## 📋 App Spec

### 1. User Stories

**Required Must-have Stories**
* User can register an account.
* User can log in and log out securely.
* User can create a group or join an existing group via invite code.
* User can write and submit a journal entry for a group session.
* User can view the status of all group members’ submissions.
* User can trigger AI image generation once all entries are submitted.
* User can receive one unique piece of the generated image.
* User can view their assigned puzzle piece.
* User can join a shared group view to assemble the full image.
* User can collaborate with others to reconstruct the full image.
* User can see the completed image once all pieces are assembled.

**Optional Nice-to-have Stories**
* User can edit or delete their journal entry before the submission deadline.
* User can react or comment on the final image.
* User can save or download the completed image.
* User can view past group sessions and images (a “memory gallery”).
* User can customize puzzle difficulty (number of pieces, shuffle level).
* User can receive notifications when others submit entries.
* User can choose a theme or prompt for journal entries (e.g., “childhood memory”).
* User can remain anonymous within the group for more honest entries.
* User can share the final image externally (social media, link, etc.).
* User can use voice-to-text for journal entries.
* User can see a preview hint of the full image before assembly.

---

### 2. Screen Archetypes

* **Login / Sign Up Screen**
    * User can register an account and log in securely.
* **Home Screen (Dashboard)**
    * User can view groups, create a new group, or join an existing group.
* **Create / Join Group Screen**
    * User can create a group or join one using an invite code.
* **Journal Entry Screen**
    * User can write and submit a journal entry for a group session.
* **Submission Status Screen**
    * User can view which group members have submitted their entries.
* **AI Image Generation Screen**
    * User can trigger AI image generation once all entries are submitted.
* **Puzzle Piece Screen**
    * User can view their assigned piece of the generated image.
* **Group Puzzle Assembly Screen**
    * User can collaborate with others to assemble the full image.
* **Final Image Reveal Screen**
    * User can view the completed image once all pieces are assembled.
* **Profile Screen**
    * User can view and manage their account information.

---

### 3. Navigation

**Tab Navigation (Tab to Screen)**
* **Home (Dashboard):** View groups, create or join sessions.
* **Journal:** Write and submit journal entries.
* **Puzzle:** View your puzzle piece and access group assembly.
* **Profile:** View and manage account information.

**Flow Navigation (Screen to Screen)**
* **Login Screen** -> Home
* **Registration Screen** -> Home
* **Home Screen (Dashboard)** -> Create / Join Group Screen OR Group Lobby
* **Group Lobby / Session Screen** -> Journal Entry Screen OR Submission Status Screen
* **Journal Entry Screen** -> Submission Status Screen
* **Submission Status Screen** -> AI Image Generation Screen
* **AI Image Generation Screen** -> Puzzle Piece Screen
* **Puzzle Piece Screen** -> Group Puzzle Assembly Screen
* **Group Puzzle Assembly Screen** -> Final Image Reveal Screen
* **Final Image Reveal Screen** -> Home

---

## 🖼️ Wireframes
<img width="1320" height="1428" alt="figma" src="https://github.com/user-attachments/assets/29ea6da2-129c-4c68-8dda-6a6408683268" />

