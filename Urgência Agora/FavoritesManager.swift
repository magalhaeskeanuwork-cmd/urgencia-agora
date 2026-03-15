import Foundation
import Combine

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()

    @Published var favoriteIds: Set<Int> = []
    @Published var visitHistory: [VisitRecord] = []

    private let favoritesKey = "favoriteHospitalIds"
    private let historyKey = "visitHistory"

    init() {
        load()
    }

    func toggleFavorite(_ hospital: Hospital) {
        if favoriteIds.contains(hospital.id) {
            favoriteIds.remove(hospital.id)
        } else {
            favoriteIds.insert(hospital.id)
        }
        saveFavorites()
    }

    func isFavorite(_ hospital: Hospital) -> Bool {
        favoriteIds.contains(hospital.id)
    }

    func addVisit(_ hospital: Hospital) {
        let record = VisitRecord(
            id: UUID(),
            hospitalId: hospital.id,
            hospitalName: hospital.name,
            city: hospital.city,
            waitMinutes: hospital.waitMinutes,
            queueCount: hospital.queueCount,
            date: Date()
        )
        visitHistory.insert(record, at: 0)
        if visitHistory.count > 50 {
            visitHistory = Array(visitHistory.prefix(50))
        }
        saveHistory()
    }

    func clearHistory() {
        visitHistory = []
        saveHistory()
    }

    private func load() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let ids = try? JSONDecoder().decode(Set<Int>.self, from: data) {
            favoriteIds = ids
        }
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let history = try? JSONDecoder().decode([VisitRecord].self, from: data) {
            visitHistory = history
        }
    }

    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteIds) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }

    private func saveHistory() {
        if let data = try? JSONEncoder().encode(visitHistory) {
            UserDefaults.standard.set(data, forKey: historyKey)
        }
    }
}

struct VisitRecord: Identifiable, Codable {
    let id: UUID
    let hospitalId: Int
    let hospitalName: String
    let city: String
    let waitMinutes: Int
    let queueCount: Int
    let date: Date
}
