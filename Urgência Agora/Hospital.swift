         import Foundation

enum HospitalType: String, CaseIterable {
    case geral = "Geral"
    case pediatrica = "Pediátrica"
    case obstetrica = "Obstétrica"
}

struct TriageLevel {
    let color: String
    let label: String
    let waitMinutes: Int
}

struct Hospital: Identifiable {
    let id: Int
    let name: String
    let city: String
    let address: String
    let distanceKm: Double
    let types: [HospitalType]
    let waitMinutes: Int
    let queueCount: Int
    let phase1Minutes: Int
    let phase2Minutes: Int
    let phase3Minutes: Int
    let triageLevels: [TriageLevel]
    let historicalAvgMinutes: Int

    var trustworthy: Bool {
        let ratio = Double(waitMinutes) / Double(historicalAvgMinutes)
        return ratio >= 0.7
    }

    var waitColor: String {
        if waitMinutes <= 25 { return "green" }
        if waitMinutes <= 50 { return "amber" }
        return "red"
    }
}
