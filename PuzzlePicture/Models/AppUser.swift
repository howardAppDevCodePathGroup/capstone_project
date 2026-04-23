import Foundation

struct AppUser: Identifiable, Codable {
    let id: String
    let email: String
    var firstName: String
    var lastName: String
    var displayName: String
    var profileImageURL: String
    var coverImageURL: String
    var bio: String
}
