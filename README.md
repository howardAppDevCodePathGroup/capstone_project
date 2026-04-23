# Puzzle Picture App

## Table of Contents
1. [Overview](#overview)
2. [Product Spec](#product-spec)
3. [Wireframes](#wireframes)
4. [Build Progress](#build-progress)
5. [Schema](#schema)

## Overview

### Description
An app that creates an image from multiple users' journal entries using AI. The image is partitioned into pieces, and one piece is given to each group member. Members must collaborate to assemble the full AI-generated masterpiece.

### App Evaluation
- **Category:** Social / Entertainment / Mindfulness
- **Mobile:** Uniquely mobile experience utilizing push notifications, camera access, and real-time collaborative assembly.
- **Story:** Individual daily reflections come together to create a collective visual story.
- **Market:** Families, friend groups, and organizations looking for a digital bonding ritual.
- **Habit:** Designed for daily or weekly use to encourage consistent journaling.
- **Scope:** Feature-rich, moving from basic text input to complex AI generation and collaborative gameplay.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**
- [x] User can register an account (Unit 8)
- [x] User can log in and log out (Unit 8)
- [ ] User can create a group or join via invite code
- [x] User can write and submit a journal entry (Unit 8)
- [ ] User can view the status of group submissions
- [ ] User can trigger AI image generation
- [ ] User can view their assigned puzzle piece
- [ ] User can collaborate to assemble the full image
- [ ] User can see the completed image

**Optional Nice-to-have Stories**
- [ ] Edit/Delete journal entries
- [ ] Memory gallery for past sessions
- [ ] Custom puzzle difficulty levels
- [ ] Voice-to-text journal entries

### 2. Screen Archetypes
- **Login / Sign Up Screen**
  - User can register an account and log in securely.
- **Home Screen (Dashboard)**
  - User can view the main app dashboard after authentication.
- **Groups Screen**
  - User can view the group section for future create/join functionality.
- **Journal Entry Screen**
  - User can write and submit a journal entry for a group session.
- **Profile Screen**
  - User can view and manage account information and log out.

### 3. Navigation

**Tab Navigation** (Tab to Screen)
- Home (Dashboard)
- Groups
- Journal
- Profile

**Flow Navigation** (Screen to Screen)
- Login Screen -> Home
- Sign Up Screen -> Home
- Home Screen -> Groups or Journal
- Journal Entry Screen -> Submitted Journal State
- Profile Screen -> Log Out -> Login Screen

## Wireframes

<img src="https://github.com/user-attachments/assets/29ea6da2-129c-4c68-8dda-6a6408683268" width="600">

---

## Build Progress

### Unit 8: Milestone 2 (Build Sprint 1)
- [x] Set up GitHub Project Board and Milestones
- [x] Initialized Xcode project and app folder structure
- [x] Created Login/Signup UI and local authentication flow
- [x] Built Home, Groups, Journal, and Profile screens
- [x] Developed basic Journal Entry View

**Progress Video/GIF:**  
> [https://drive.google.com/file/d/1vUUmEn8M2fRSfVQ23qmspgCBayaEfy7k/view?usp=sharing]

### Unit 9: Milestone 3 (Build Sprint 2)
- [ ] Integrate AI Image Generation API (DALL-E)
- [ ] Implement image partitioning/slicing logic
- [ ] Record Demo Day practice run

**Demo Day Practice Video:**  
> [INSERT UNIT 9 DEMO VIDEO LINK HERE]

---

## Schema

### Models

| Property | Type | Description |
| :--- | :--- | :--- |
| objectId | String | Unique id for the user post (default field) |
| username | String | User's unique handle |
| password | String | Hashed password for authentication |
| journalText | String | The content of the user's daily entry |
| groupID | Pointer | Reference to the Group model |

### Networking
- [POST] /signup - Create a new user account
- [POST] /login - Authenticate user
- [GET] /groups - Fetch active groups for the user
- [POST] /journalEntry - Save a new journal entry
- [GET] /aiImage - Fetch generated image from API
