
import Foundation
import FirebaseFirestore

final class FirestoreSeeder {
    private let db = FirebaseManager.shared.db

    func seedDemoData(currentUserId: String, currentUserEmail: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let batch = db.batch()

        let now = Date()
        let groupCount = 8
        let demoUsersCount = 60

        // Make current user profile doc exist
        let currentUserRef = db.collection("users").document(currentUserId)
        batch.setData([
            "uid": currentUserId,
            "email": currentUserEmail,
            "firstName": "Niya",
            "lastName": "Traynham",
            "displayName": "Niya Traynham",
            "profileImageURL": "",
            "coverImageURL": "",
            "bio": "Building shared stories, one reflection at a time.",
            "createdAt": Timestamp(date: now)
        ], forDocument: currentUserRef, merge: true)

        // Create demo users
        var allUserIds: [String] = [currentUserId]

        for i in 1...demoUsersCount {
            let uid = "demo_user_\(i)"
            allUserIds.append(uid)

            let firstName = [
                "Ava", "Liam", "Mia", "Noah", "Sophia", "Elijah", "Isabella", "Lucas",
                "Amelia", "Mason", "Charlotte", "James", "Harper", "Benjamin", "Evelyn"
            ].randomElement() ?? "User"

            let lastName = [
                "Carter", "Hall", "Lopez", "King", "Wright", "Scott", "Young", "Green",
                "Baker", "Adams", "Nelson", "Perez", "Mitchell", "Roberts", "Turner"
            ].randomElement() ?? "Demo"

            let email = "demo\(i)@puzzlepicture.app"
            let ref = db.collection("users").document(uid)

            batch.setData([
                "uid": uid,
                "email": email,
                "firstName": firstName,
                "lastName": lastName,
                "displayName": "\(firstName) \(lastName)",
                "profileImageURL": "",
                "coverImageURL": "",
                "bio": "Demo user \(i)",
                "createdAt": Timestamp(date: now)
            ], forDocument: ref, merge: true)
        }

        // Create groups, sessions, submissions, puzzle pieces
        for g in 1...groupCount {
            let groupId = "demo_group_\(g)"
            let sessionId = "demo_session_\(g)"
            let inviteCode = "GRP\(100 + g)"

            let groupName = [
                "Dream Circle", "Midnight Thinkers", "Blue Room", "Reflection Lab",
                "Creative Souls", "Deep Talks", "Quiet Minds", "Weekend Journalers"
            ][(g - 1) % 8]

            var memberIds: [String] = []
            memberIds.append(currentUserId)

            let extraMembers = Array(allUserIds.dropFirst()).shuffled().prefix(Int.random(in: 4...8))
            memberIds.append(contentsOf: extraMembers)

            let uniqueMembers = Array(Set(memberIds))

            let groupRef = db.collection("groups").document(groupId)
            let sessionRef = db.collection("sessions").document(sessionId)

            batch.setData([
                "groupId": groupId,
                "name": groupName,
                "inviteCode": inviteCode,
                "ownerId": currentUserId,
                "memberIds": uniqueMembers,
                "currentSessionId": sessionId,
                "createdAt": Timestamp(date: Calendar.current.date(byAdding: .day, value: -g, to: now) ?? now)
            ], forDocument: groupRef, merge: true)

            let generatedImageURL = "https://picsum.photos/seed/\(groupId)/800/800"

            batch.setData([
                "sessionId": sessionId,
                "groupId": groupId,
                "status": g <= 3 ? "revealed" : "collecting",
                "promptTheme": [
                    "How did today feel?",
                    "What stayed on your mind today?",
                    "What gave you hope this week?",
                    "Describe your current mood in words."
                ].randomElement() ?? "How did today feel?",
                "generatedImageURL": generatedImageURL,
                "pieceCount": uniqueMembers.count,
                "createdAt": Timestamp(date: Calendar.current.date(byAdding: .hour, value: -g * 3, to: now) ?? now)
            ], forDocument: sessionRef, merge: true)

            // Create submissions for most members
            let submissionCount = min(uniqueMembers.count, Int.random(in: max(2, uniqueMembers.count - 2)...uniqueMembers.count))
            let submittingMembers = Array(uniqueMembers.shuffled().prefix(submissionCount))

            for (index, uid) in submittingMembers.enumerated() {
                let submissionId = "\(sessionId)_submission_\(uid)"
                let subRef = db.collection("submissions").document(submissionId)

                let demoText = [
                    "Today felt calm, hopeful, and reflective.",
                    "I felt productive but also emotionally tired.",
                    "This day felt heavy, but I still found small joy.",
                    "I felt grateful, grounded, and creative today.",
                    "Today was messy, emotional, but meaningful."
                ].randomElement() ?? "Today felt reflective."

                batch.setData([
                    "submissionId": submissionId,
                    "sessionId": sessionId,
                    "groupId": groupId,
                    "userId": uid,
                    "journalText": demoText,
                    "submittedAt": Timestamp(date: Calendar.current.date(byAdding: .minute, value: -(index * 7), to: now) ?? now)
                ], forDocument: subRef, merge: true)
            }

            // Create puzzle piece docs
            for (index, uid) in uniqueMembers.enumerated() {
                let pieceId = "\(sessionId)_piece_\(uid)"
                let pieceRef = db.collection("puzzlePieces").document(pieceId)

                batch.setData([
                    "pieceId": pieceId,
                    "sessionId": sessionId,
                    "groupId": groupId,
                    "userId": uid,
                    "imageURL": "https://picsum.photos/seed/\(pieceId)/300/300",
                    "index": index
                ], forDocument: pieceRef, merge: true)
            }
        }

        batch.commit { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}
