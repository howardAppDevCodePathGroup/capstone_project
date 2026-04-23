import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

final class FirebaseManager {
    static let shared = FirebaseManager()

    let auth = Auth.auth()
    let db = Firestore.firestore()
    let storage = Storage.storage()

    private init() { }
}
