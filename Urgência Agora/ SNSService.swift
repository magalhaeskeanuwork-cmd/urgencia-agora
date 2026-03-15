import Foundation

class SNSService {
    static let shared = SNSService()

    private let hospitalIds = [
        (id: 1, snsId: "1404", name: "Hospital São Francisco Xavier"),
        (id: 2, snsId: "1402", name: "Hospital Santa Maria"),
        (id: 3, snsId: "1407", name: "Hospital Garcia de Orta"),
        (id: 4, snsId: "1403", name: "Hospital Dona Estefânia"),
        (id: 5, snsId: "1406", name: "Maternidade Dr. Alfredo da Costa")
    ]

    func fetchHospitals() async -> [Hospital] {
        var results: [Hospital] = []

        await withTaskGroup(of: Hospital?.self) { group in
            for entry in hospitalIds {
                group.addTask {
                    await self.fetchHospital(id: entry.id, snsId: entry.snsId, name: entry.name)
                }
            }
            for await result in group {
                if let hospital = result {
                    results.append(hospital)
                }
            }
        }

        return results.isEmpty ? mockHospitals() : results
    }

    private func fetchHospital(id: Int, snsId: String, name: String) async -> Hospital? {
        let urlString = "https://servicos.min-saude.pt/pds/api/tems/standbyTime/\(snsId)"
        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

            let waitMinutes = json?["globalWaitingTime"] as? Int ?? 30
            let queueCount = json?["waitingPatients"] as? Int ?? 10

            return Hospital(
                id: id,
                name: name,
                city: cityFor(snsId: snsId),
                address: addressFor(snsId: snsId),
                distanceKm: distanceFor(snsId: snsId),
                types: typesFor(snsId: snsId),
                waitMinutes: waitMinutes,
                queueCount: queueCount,
                phase1Minutes: json?["triageWaitingTime"] as? Int ?? 10,
                phase2Minutes: json?["observationWaitingTime"] as? Int ?? 20,
                phase3Minutes: json?["totalWaitingTime"] as? Int ?? 40,
                triageLevels: triageLevelsFrom(json: json),
                historicalAvgMinutes: waitMinutes
            )
        } catch {
            return nil
        }
    }

    private func triageLevelsFrom(json: [String: Any]?) -> [TriageLevel] {
        return [
            TriageLevel(color: "red",    label: "Imediato",       waitMinutes: 0),
            TriageLevel(color: "orange", label: "Muito urgente",  waitMinutes: json?["orangeWaitingTime"] as? Int ?? 15),
            TriageLevel(color: "yellow", label: "Urgente",        waitMinutes: json?["yellowWaitingTime"] as? Int ?? 30),
            TriageLevel(color: "green",  label: "Pouco urgente",  waitMinutes: json?["greenWaitingTime"]  as? Int ?? 60),
            TriageLevel(color: "blue",   label: "Não urgente",    waitMinutes: json?["blueWaitingTime"]   as? Int ?? 120)
        ]
    }

    private func cityFor(snsId: String) -> String {
        switch snsId {
        case "1407": return "Almada"
        default: return "Lisboa"
        }
    }

    private func addressFor(snsId: String) -> String {
        switch snsId {
        case "1404": return "Estrada do Forte do Alto do Duque"
        case "1402": return "Av. Prof. Egas Moniz"
        case "1407": return "Av. Torrado da Silva"
        case "1403": return "Rua Jacinta Marto"
        case "1406": return "Rua Viriato 1"
        default: return "Lisboa"
        }
    }

    private func distanceFor(snsId: String) -> Double {
        switch snsId {
        case "1404": return 4.7
        case "1402": return 1.2
        case "1407": return 8.4
        case "1403": return 2.1
        case "1406": return 3.3
        default: return 5.0
        }
    }

    private func typesFor(snsId: String) -> [HospitalType] {
        switch snsId {
        case "1402": return [.geral, .obstetrica]
        case "1407": return [.geral, .pediatrica]
        case "1403": return [.pediatrica]
        case "1406": return [.obstetrica]
        default: return [.geral]
        }
    }

    private func mockHospitals() -> [Hospital] {
        return [
            Hospital(id: 1, name: "Hospital São Francisco Xavier", city: "Lisboa", address: "Estrada do Forte do Alto do Duque", distanceKm: 4.7, types: [.geral], waitMinutes: 15, queueCount: 6, phase1Minutes: 7, phase2Minutes: 8, phase3Minutes: 28, triageLevels: [
                TriageLevel(color: "red", label: "Imediato", waitMinutes: 0),
                TriageLevel(color: "orange", label: "Muito urgente", waitMinutes: 8),
                TriageLevel(color: "yellow", label: "Urgente", waitMinutes: 15),
                TriageLevel(color: "green", label: "Pouco urgente", waitMinutes: 35),
                TriageLevel(color: "blue", label: "Não urgente", waitMinutes: 60)
            ], historicalAvgMinutes: 18),
            Hospital(id: 2, name: "Hospital Santa Maria", city: "Lisboa", address: "Av. Prof. Egas Moniz", distanceKm: 1.2, types: [.geral, .obstetrica], waitMinutes: 28, queueCount: 14, phase1Minutes: 12, phase2Minutes: 16, phase3Minutes: 44, triageLevels: [
                TriageLevel(color: "red", label: "Imediato", waitMinutes: 0),
                TriageLevel(color: "orange", label: "Muito urgente", waitMinutes: 12),
                TriageLevel(color: "yellow", label: "Urgente", waitMinutes: 28),
                TriageLevel(color: "green", label: "Pouco urgente", waitMinutes: 55),
                TriageLevel(color: "blue", label: "Não urgente", waitMinutes: 90)
            ], historicalAvgMinutes: 30),
            Hospital(id: 3, name: "Hospital Garcia de Orta", city: "Almada", address: "Av. Torrado da Silva", distanceKm: 8.4, types: [.geral, .pediatrica], waitMinutes: 45, queueCount: 31, phase1Minutes: 8, phase2Minutes: 37, phase3Minutes: 62, triageLevels: [
                TriageLevel(color: "red", label: "Imediato", waitMinutes: 0),
                TriageLevel(color: "orange", label: "Muito urgente", waitMinutes: 18),
                TriageLevel(color: "yellow", label: "Urgente", waitMinutes: 45),
                TriageLevel(color: "green", label: "Pouco urgente", waitMinutes: 80),
                TriageLevel(color: "blue", label: "Não urgente", waitMinutes: 130)
            ], historicalAvgMinutes: 40),
            Hospital(id: 4, name: "Hospital Dona Estefânia", city: "Lisboa", address: "Rua Jacinta Marto", distanceKm: 2.1, types: [.pediatrica], waitMinutes: 62, queueCount: 44, phase1Minutes: 20, phase2Minutes: 42, phase3Minutes: 90, triageLevels: [
                TriageLevel(color: "red", label: "Imediato", waitMinutes: 0),
                TriageLevel(color: "orange", label: "Muito urgente", waitMinutes: 22),
                TriageLevel(color: "yellow", label: "Urgente", waitMinutes: 62),
                TriageLevel(color: "green", label: "Pouco urgente", waitMinutes: 110),
                TriageLevel(color: "blue", label: "Não urgente", waitMinutes: 180)
            ], historicalAvgMinutes: 55),
            Hospital(id: 5, name: "Maternidade Dr. Alfredo da Costa", city: "Lisboa", address: "Rua Viriato 1", distanceKm: 3.3, types: [.obstetrica], waitMinutes: 20, queueCount: 9, phase1Minutes: 9, phase2Minutes: 11, phase3Minutes: 35, triageLevels: [
                TriageLevel(color: "red", label: "Imediato", waitMinutes: 0),
                TriageLevel(color: "orange", label: "Muito urgente", waitMinutes: 10),
                TriageLevel(color: "yellow", label: "Urgente", waitMinutes: 20),
                TriageLevel(color: "green", label: "Pouco urgente", waitMinutes: 45),
                TriageLevel(color: "blue", label: "Não urgente", waitMinutes: 75)
            ], historicalAvgMinutes: 22)
        ]
    }
}
