import Foundation
import Combine

enum FilterType: String, CaseIterable {
    case todas = "Todas"
    case geral = "Geral"
    case pediatrica = "Pediátrica"
    case obstetrica = "Obstétrica"
}

enum SortType: String, CaseIterable {
    case tempo = "Tempo"
    case distancia = "Distância"
    case fila = "Fila"
}

@MainActor
class HospitalViewModel: ObservableObject {
    @Published var hospitals: [Hospital] = []
    @Published var loading = false
    @Published var error: String? = nil
    @Published var lastUpdated: Date? = nil
    @Published var activeFilter: FilterType = .todas
    @Published var activeSort: SortType = .tempo

    private var timer: Timer?

    var filtered: [Hospital] {
        var list = hospitals

        switch activeFilter {
        case .todas: break
        case .geral: list = list.filter { $0.types.contains(.geral) }
        case .pediatrica: list = list.filter { $0.types.contains(.pediatrica) }
        case .obstetrica: list = list.filter { $0.types.contains(.obstetrica) }
        }

        switch activeSort {
        case .tempo: list.sort { $0.waitMinutes < $1.waitMinutes }
        case .distancia: list.sort { $0.distanceKm < $1.distanceKm }
        case .fila: list.sort { $0.queueCount < $1.queueCount }
        }

        return list
    }

    func load() async {
        loading = true
        error = nil
        hospitals = await SNSService.shared.fetchHospitals()
        lastUpdated = Date()
        loading = false
    }

    func startAutoRefresh() {
        timer = Timer.scheduledTimer(withTimeInterval: 600, repeats: true) { _ in
            Task { await self.load() }
        }
    }

    func stopAutoRefresh() {
        timer?.invalidate()
        timer = nil
    }
}
