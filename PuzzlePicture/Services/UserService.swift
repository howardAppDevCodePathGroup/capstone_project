import Foundation
import FirebaseFirestore

final class UserService {
    private let db = FirebaseManager.shared.db

    func fetchUsers(userIds: [String], completion: @escaping (Result<[SubmittedUser], Error>) -> Void) {
        let uniqueIds = Array(Set(userIds))

        guard !uniqueIds.isEmpty else {
            completion(.success([]))
            return
        }

        var users: [SubmittedUser] = []
        let group = DispatchGroup()
        var firstError: Error?

        for userId in uniqueIds {
            group.enter()

            db.collection("users").document(userId).getDocument { snapshot, error in
                defer { group.leave() }

                if let error = error {
                    if firstError == nil { firstError = error }
                    return
                }

                guard let data = snapshot?.data() else { return }

                let displayName = data["displayName"] as? String ?? "Unknown User"
                let email = data["email"] as? String ?? ""

                users.append(
                    SubmittedUser(
                        id: userId,
                        displayName: displayName,
                        email: email
                    )
                )
            }
        }

        group.notify(queue: .main) {
            if let firstError {
                completion(.failure(firstError))
            } else {
                completion(.success(users.sorted { $0.displayName < $1.displayName }))
            }
        }
    }
}
