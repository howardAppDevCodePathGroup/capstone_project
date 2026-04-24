import Foundation
import FirebaseFirestore

struct GroupSummary: Identifiable {
    let id: String
    let name: String
    let inviteCode: String
    let memberCount: Int
    let maxMembers: Int
    let currentSessionId: String

    var isFull: Bool {
        memberCount >= maxMembers
    }
}

struct SessionStatusInfo {
    let status: String
    let generatedImageURL: String
    let statusStep: String
    let isGenerating: Bool
}

final class GroupService {
    private let db = FirebaseManager.shared.db

    func createGroup(
        name: String,
        maxMembers: Int,
        ownerId: String,
        completion: @escaping (Result<(groupId: String, sessionId: String, inviteCode: String), Error>) -> Void
    ) {
        let groupRef = db.collection("groups").document()
        let sessionRef = db.collection("sessions").document()
        let inviteCode = String(UUID().uuidString.prefix(6)).uppercased()

        let groupData: [String: Any] = [
            "groupId": groupRef.documentID,
            "name": name,
            "inviteCode": inviteCode,
            "ownerId": ownerId,
            "memberIds": [ownerId],
            "maxMembers": maxMembers,
            "currentSessionId": sessionRef.documentID,
            "createdAt": Timestamp(date: Date())
        ]

        let sessionData: [String: Any] = [
            "sessionId": sessionRef.documentID,
            "groupId": groupRef.documentID,
            "status": "waiting_for_members",
            "statusStep": "Waiting for members",
            "isGenerating": false,
            "promptTheme": "How did today feel?",
            "generatedImageURL": "",
            "pieceCount": maxMembers,
            "createdAt": Timestamp(date: Date())
        ]

        let batch = db.batch()
        batch.setData(groupData, forDocument: groupRef)
        batch.setData(sessionData, forDocument: sessionRef)

        batch.commit { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success((
                    groupId: groupRef.documentID,
                    sessionId: sessionRef.documentID,
                    inviteCode: inviteCode
                )))
            }
        }
    }

    func joinGroup(
        inviteCode: String,
        userId: String,
        completion: @escaping (Result<(groupId: String, sessionId: String, groupName: String, maxMembers: Int), Error>) -> Void
    ) {
        db.collection("groups")
            .whereField("inviteCode", isEqualTo: inviteCode.uppercased())
            .getDocuments { [weak self] snapshot, error in
                guard let self else { return }

                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let doc = snapshot?.documents.first else {
                    completion(.failure(
                        NSError(
                            domain: "GroupService",
                            code: 404,
                            userInfo: [NSLocalizedDescriptionKey: "No group found for that invite code."]
                        )
                    ))
                    return
                }

                let data = doc.data()
                let groupId = data["groupId"] as? String ?? doc.documentID
                let sessionId = data["currentSessionId"] as? String ?? ""
                let groupName = data["name"] as? String ?? "Group"
                let maxMembers = data["maxMembers"] as? Int ?? 2
                let memberIds = data["memberIds"] as? [String] ?? []

                if memberIds.contains(userId) {
                    completion(.success((
                        groupId: groupId,
                        sessionId: sessionId,
                        groupName: groupName,
                        maxMembers: maxMembers
                    )))
                    return
                }

                if memberIds.count >= maxMembers {
                    completion(.failure(
                        NSError(
                            domain: "GroupService",
                            code: 409,
                            userInfo: [NSLocalizedDescriptionKey: "This group is already full."]
                        )
                    ))
                    return
                }

                doc.reference.updateData([
                    "memberIds": FieldValue.arrayUnion([userId])
                ]) { updateError in
                    if let updateError = updateError {
                        completion(.failure(updateError))
                    } else {
                        let newCount = memberIds.count + 1
                        if newCount == maxMembers {
                            self.db.collection("sessions").document(sessionId).updateData([
                                "status": "collecting_journals",
                                "statusStep": "Collecting journals"
                            ])
                        }

                        completion(.success((
                            groupId: groupId,
                            sessionId: sessionId,
                            groupName: groupName,
                            maxMembers: maxMembers
                        )))
                    }
                }
            }
    }

    func fetchUserGroups(userId: String, completion: @escaping (Result<[GroupSummary], Error>) -> Void) {
        db.collection("groups")
            .whereField("memberIds", arrayContains: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                let groups: [GroupSummary] = snapshot?.documents.compactMap { doc in
                    let data = doc.data()
                    let name = data["name"] as? String ?? "Unnamed Group"
                    let inviteCode = data["inviteCode"] as? String ?? ""
                    let currentSessionId = data["currentSessionId"] as? String ?? ""
                    let memberIds = data["memberIds"] as? [String] ?? []
                    let maxMembers = data["maxMembers"] as? Int ?? 2

                    return GroupSummary(
                        id: doc.documentID,
                        name: name,
                        inviteCode: inviteCode,
                        memberCount: memberIds.count,
                        maxMembers: maxMembers,
                        currentSessionId: currentSessionId
                    )
                } ?? []

                completion(.success(groups.sorted { $0.name < $1.name }))
            }
    }

    func fetchGroupOwner(groupId: String, completion: @escaping (Result<String, Error>) -> Void) {
        db.collection("groups").document(groupId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let ownerId = snapshot?.data()?["ownerId"] as? String ?? ""
            completion(.success(ownerId))
        }
    }

    func listenToSession(sessionId: String, completion: @escaping (Result<SessionStatusInfo, Error>) -> Void) -> ListenerRegistration {
        db.collection("sessions").document(sessionId).addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let data = snapshot?.data() ?? [:]
            let status = data["status"] as? String ?? "unknown"
            let generatedImageURL = data["generatedImageURL"] as? String ?? ""
            let statusStep = data["statusStep"] as? String ?? ""
            let isGenerating = data["isGenerating"] as? Bool ?? false

            completion(.success(SessionStatusInfo(
                status: status,
                generatedImageURL: generatedImageURL,
                statusStep: statusStep,
                isGenerating: isGenerating
            )))
        }
    }

    func listenToGroup(groupId: String, completion: @escaping (Result<(memberCount: Int, maxMembers: Int), Error>) -> Void) -> ListenerRegistration {
        db.collection("groups").document(groupId).addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = snapshot?.data() else {
                completion(.success((memberCount: 0, maxMembers: 0)))
                return
            }

            let memberIds = data["memberIds"] as? [String] ?? []
            let maxMembers = data["maxMembers"] as? Int ?? 0

            completion(.success((memberCount: memberIds.count, maxMembers: maxMembers)))
        }
    }

    func listenToGroupMemberIds(groupId: String, completion: @escaping (Result<[String], Error>) -> Void) -> ListenerRegistration {
        db.collection("groups").document(groupId).addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            let memberIds = snapshot?.data()?["memberIds"] as? [String] ?? []
            completion(.success(memberIds))
        }
    }
}
