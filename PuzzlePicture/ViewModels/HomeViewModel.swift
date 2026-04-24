
import Foundation
import Combine

final class HomeViewModel: ObservableObject {
    @Published var groups: [GroupSummary] = []
    @Published var statusMessage: String = ""
    @Published var isLoading = false

    private let groupService = GroupService()
    private let seeder = FirestoreSeeder()

    func loadHome(userId: String) {
        isLoading = true

        groupService.fetchUserGroups(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success(let groups):
                    self?.groups = groups
                    self?.statusMessage = groups.isEmpty ? "No groups yet. Create one or seed demo data." : ""
                case .failure(let error):
                    self?.statusMessage = error.localizedDescription
                }
            }
        }
    }

    func seedDemo(currentUserId: String, currentUserEmail: String) {
        isLoading = true

        seeder.seedDemoData(currentUserId: currentUserId, currentUserEmail: currentUserEmail) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.statusMessage = "Demo data seeded successfully."
                    self?.loadHome(userId: currentUserId)
                case .failure(let error):
                    self?.isLoading = false
                    self?.statusMessage = error.localizedDescription
                }
            }
        }
    }
}
