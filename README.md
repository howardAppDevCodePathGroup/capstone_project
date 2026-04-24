# Puzzle Picture App

## Table of Contents
1. [Overview](#overview)
2. [Product Spec](#product-spec)
3. [Wireframes](#wireframes)
4. [Build Progress](#build-progress)
5. [Technical Architecture](#technical-architecture)
6. [Schema](#schema)

---

## Overview

### Description
Puzzle Picture is a collaborative journaling and creativity app where multiple users submit reflections, and the app uses AI to generate one shared image inspired by the group’s entries. That image is then split into puzzle pieces, and each group member receives one piece. Members can explore their own piece, view the full artwork, and reconstruct the final image together through assembly mode.

### App Evaluation

- **Category:** Social / Entertainment / Mindfulness
- **Mobile:** Mobile-first collaborative experience built for iPhone using SwiftUI and Firebase.
- **Story:** Individual emotions and reflections come together to create one shared visual story.
- **Market:** Friends, families, student groups, clubs, and communities looking for a creative bonding experience.
- **Habit:** Can be used daily or weekly as a reflective group ritual.
- **Scope:** Medium-to-broad scope with authentication, groups, journaling, AI image generation, puzzle splitting, profile management, history, and collaborative assembly.

---

## Product Spec

### 1. User Stories (Required and Optional)

#### Required Must-have Stories
- [x] User can register an account
- [x] User can verify email and authenticate
- [x] User can log in and log out
- [x] User can create a group
- [x] User can join a group via invite code
- [x] User can view active group lobby and member list
- [x] User can submit one puzzle reflection per group session
- [x] User can write personal journal entries separate from group submissions
- [x] User can view submission status for all members
- [x] Only group creator can trigger AI image generation
- [x] User can view their assigned puzzle piece
- [x] User can view the full generated artwork
- [x] User can view session summary
- [x] User can access session history
- [x] User can open assembly mode and reconstruct the puzzle

#### Optional Nice-to-have Stories
- [x] User can upload profile and cover photos
- [x] User can edit bio and profile details
- [x] User can reorder puzzle pieces in assembly mode
- [ ] Push notifications when generation is complete
- [ ] Save artwork directly to Photos
- [ ] Real-time multi-user assembly sync
- [ ] Voice-to-text journal entries
- [ ] Multiple puzzle rounds in the same group

### 2. Screen Archetypes

- **Login / Sign Up Screen**
  - User can create account, verify email, and log in securely.
- **Home Screen**
  - User can join with invite code, see active group, and access quick actions.
- **Groups Screen**
  - User can create a new group or manage/join existing collaborative sessions.
- **Group Lobby Screen**
  - User can view group details, invite code, member list, and readiness state.
- **Puzzle Submission Screen**
  - User can submit one reflection for the active group session.
- **Submission Status Screen**
  - User can view who has submitted and whether image generation is ready.
- **Final Reveal Screen**
  - User can see that artwork generation is complete and proceed to next steps.
- **Puzzle Piece Screen**
  - User can view their assigned puzzle piece.
- **Full Artwork Screen**
  - User can view and share the completed AI-generated image.
- **Session Summary Screen**
  - User can see group/session metadata and their assigned piece.
- **Assembly Mode Screen**
  - User can place pieces into slots and check whether the puzzle is solved.
- **Journal Screen**
  - User can write and save personal journal entries.
- **Profile Screen**
  - User can manage name, bio, profile image, cover image, and log out.
- **Session History Screen**
  - User can browse past completed sessions.

### 3. Navigation

#### Tab Navigation
- Home
- Groups
- Journal
- Profile

#### Flow Navigation
- Login / Sign Up -> Home
- Home -> Group Lobby
- Home -> Groups
- Group Lobby -> Puzzle Submission
- Group Lobby -> Submission Status
- Submission Status -> Final Reveal
- Final Reveal -> Full Artwork / Puzzle Piece / Session Summary / Assembly Mode
- Profile -> Session History
- Session History -> Session Summary / Full Artwork

---

## Wireframes

<img src="https://github.com/user-attachments/assets/29ea6da2-129c-4c68-8dda-6a6408683268" width="600">

---

## Build Progress

### Unit 8: Milestone 2 (Build Sprint 1)
- [x] Set up GitHub Project Board and Milestones
- [x] Initialized Xcode project and app folder structure
- [x] Built authentication UI flow
- [x] Added Firebase authentication integration
- [x] Created Home, Groups, Journal, and Profile screens
- [x] Created basic journal entry flow
- [x] Implemented profile and logout flow

**Progress Video / GIF:**  
> [https://drive.google.com/file/d/1vUUmEn8M2fRSfVQ23qmspgCBayaEfy7k/view?usp=sharing]

### Unit 9: Milestone 3 (Build Sprint 2)
- [x] Implemented create group and join group via invite code
- [x] Added live group lobby with member count and member list
- [x] Enforced member limit per group
- [x] Added one-time group puzzle submission per user
- [x] Separated personal journal flow from group puzzle submission flow
- [x] Added submission status tracking
- [x] Restricted AI generation to group creator only
- [x] Built Firebase backend for Gemini image generation
- [x] Uploaded generated artwork and puzzle pieces to Firebase Storage
- [x] Saved generated session history to Firestore
- [x] Added Full Artwork, Session Summary, and Final Reveal screens
- [x] Added Assembly Mode
- [x] Added profile photo, cover photo, and bio persistence
- [x] Upgraded app-wide UI with reusable design system and polished cards/buttons
- [x] Recorded Demo Day practice run
- [x] Updated repo and README with current sprint progress

**Build Progress / Demo Video:**  
> [PASTE UNIT 9 DEMO VIDEO LINK HERE]

---

## Technical Architecture

### Frontend
- **Language:** Swift
- **Framework:** SwiftUI
- **Architecture Style:** MVVM
- **UI System:** Reusable design system with shared typography, gradients, cards, buttons, badges, loading and empty states
- **State Management:** `@StateObject`, `@EnvironmentObject`, observable view models

### Backend
- **Platform:** Firebase Functions
- **Runtime:** Node.js
- **AI Model:** Gemini image generation through Vertex AI / Google GenAI SDK
- **Storage:** Firebase Storage for final generated image and puzzle pieces
- **Database:** Cloud Firestore for users, groups, sessions, submissions, journals, pieces, and history
- **Auth:** Firebase Authentication with email/password and email verification

### Core Product Flow
1. User signs up and verifies email.
2. User creates a group or joins using invite code.
3. Group fills up to max member count.
4. Each member submits exactly one puzzle reflection.
5. Group creator triggers image generation.
6. Backend builds a prompt from all member reflections.
7. Gemini generates one shared square artwork.
8. Backend uploads artwork to Firebase Storage.
9. Backend slices image into puzzle pieces.
10. Each member gets one unique piece saved in Firestore and Storage.
11. App unlocks full artwork, piece view, session summary, and assembly mode.
12. Completed sessions are saved in user history.

### AI / Gemini Flow
- The backend collects all group submissions for a session.
- It orders the reflections by member list.
- It builds one unified prompt using the session theme and all entries.
- Gemini generates one emotionally expressive square image.
- The final image is resized and divided into pieces using `sharp`.
- Piece URLs and the final artwork URL are saved back into Firestore.

### Design Flow
- Shared colors, fonts, spacing, gradients, and card styles create a consistent app identity.
- Larger rounded typography and strong CTA buttons were used to make the UI feel more polished and mobile-native.
- The final flow emphasizes emotional payoff:
  - group submission
  - generation
  - reveal
  - piece ownership
  - collaborative reconstruction

### Firebase Collections
- `users`
- `groups`
- `sessions`
- `submissions`
- `puzzlePieces`
- `personalJournals`
- `sessionHistory`

---

## Schema

### Models

#### User
| Property | Type | Description |
| :--- | :--- | :--- |
| userId | String | Firebase Auth user id |
| firstName | String | User first name |
| lastName | String | User last name |
| email | String | User email |
| bio | String | User bio |
| profileImageURL | String | Profile image URL |
| coverImageURL | String | Cover image URL |

#### Group
| Property | Type | Description |
| :--- | :--- | :--- |
| groupId | String | Unique group id |
| name | String | Group name |
| inviteCode | String | Code for joining group |
| ownerId | String | Creator of the group |
| memberIds | [String] | Group members |
| maxMembers | Int | Group size limit |
| currentSessionId | String | Active session id |

#### Session
| Property | Type | Description |
| :--- | :--- | :--- |
| sessionId | String | Unique session id |
| groupId | String | Parent group id |
| groupName | String | Name of group |
| promptTheme | String | Session theme |
| status | String | waiting / collecting / generating / generated / failed |
| statusStep | String | Human-readable generation step |
| isGenerating | Bool | Whether generation is in progress |
| generatedImageURL | String | Final full artwork URL |
| pieceCount | Int | Number of puzzle pieces |

#### Submission
| Property | Type | Description |
| :--- | :--- | :--- |
| submissionId | String | Unique submission id |
| sessionId | String | Related session |
| groupId | String | Related group |
| userId | String | Submitting user |
| journalText | String | Reflection text |

#### Puzzle Piece
| Property | Type | Description |
| :--- | :--- | :--- |
| pieceId | String | Unique piece id |
| sessionId | String | Related session |
| groupId | String | Related group |
| userId | String | Owner of piece |
| imageURL | String | Puzzle piece image URL |
| index | Int | Correct piece order |

#### Personal Journal Entry
| Property | Type | Description |
| :--- | :--- | :--- |
| journalId | String | Unique journal id |
| userId | String | Journal owner |
| text | String | Personal journal content |
| createdAt | Timestamp | Creation date |

#### Session History Entry
| Property | Type | Description |
| :--- | :--- | :--- |
| sessionId | String | Completed session id |
| groupId | String | Related group |
| groupName | String | Group name |
| finalImageURL | String | Final artwork URL |
| pieceURL | String | User's piece URL |
| promptTheme | String | Session theme |
| createdAt | Timestamp | Completion date |

### Networking / Backend Calls

#### Frontend -> Firebase Auth
- Create account
- Sign in
- Sign out
- Verify email

#### Frontend -> Firestore
- Create group
- Join group by invite code
- Load group lobby
- Save profile
- Save personal journal
- Save group submission
- Load session history
- Load puzzle piece
- Load session summary

#### Frontend -> Firebase Functions
- `generatePuzzleForSession`
  - validates creator
  - checks all submissions are present
  - generates artwork with Gemini
  - uploads image
  - slices puzzle
  - writes piece docs
  - updates session status

#### Frontend -> Firebase Storage
- Read final image
- Read puzzle piece images
- Read profile / cover photos

---

## Demo Notes
For Demo Day, we plan to show:
1. Sign up / login
2. Create or join a group
3. Submit group reflections
4. Generate shared AI artwork
5. View puzzle piece and full artwork
6. Open assembly mode
7. Open session history and profile


---

## Architecture Diagram

```mermaid
flowchart TD
    A[iOS App<br/>SwiftUI + MVVM] --> B[Firebase Authentication]
    A --> C[Cloud Firestore]
    A --> D[Firebase Functions Backend]
    A --> E[Firebase Storage]

    D --> F[Gemini / Vertex AI]
    D --> C
    D --> E

    C --> G[Users]
    C --> H[Groups]
    C --> I[Sessions]
    C --> J[Submissions]
    C --> K[Puzzle Pieces]
    C --> L[Personal Journals]
    C --> M[Session History]

    A --> N[Home / Groups / Journal / Profile]
    A --> O[Submission Status]
    A --> P[Final Reveal]
    A --> Q[Full Artwork]
    A --> R[Assembly Mode]


