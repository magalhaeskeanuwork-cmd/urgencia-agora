import SwiftUI
import MapKit

struct HospitalCardView: View {
    let hospital: Hospital
    @State private var expanded = false

    var badgeColor: Color {
        switch hospital.waitColor {
        case "green": return Color(red: 0.23, green: 0.53, blue: 0.07)
        case "amber": return Color(red: 0.73, green: 0.37, blue: 0.04)
        default: return Color(red: 0.64, green: 0.18, blue: 0.18)
        }
    }

    var badgeBg: Color {
        switch hospital.waitColor {
        case "green": return Color(red: 0.92, green: 0.95, blue: 0.87)
        case "amber": return Color(red: 0.98, green: 0.93, blue: 0.85)
        default: return Color(red: 0.99, green: 0.92, blue: 0.92)
        }
    }

    func triageColor(_ name: String) -> Color {
        switch name {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        default: return .gray
        }
    }

    func openMaps() {
        let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(
            latitude: latitudeFor(snsId: String(hospital.id)),
            longitude: longitudeFor(snsId: String(hospital.id))
        ))
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = hospital.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }

    func latitudeFor(snsId: String) -> Double {
        switch snsId {
        case "1": return 38.6971
        case "2": return 38.7489
        case "3": return 38.6762
        case "4": return 38.7291
        case "5": return 38.7245
        default: return 38.7169
        }
    }

    func longitudeFor(snsId: String) -> Double {
        switch snsId {
        case "1": return -9.2271
        case "2": return -9.1600
        case "3": return -9.1553
        case "4": return -9.1432
        case "5": return -9.1490
        default: return -9.1399
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                VStack(spacing: 2) {
                    Text("\(hospital.waitMinutes)")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundColor(badgeColor)
                    Text("min")
                        .font(.system(size: 11))
                        .foregroundColor(badgeColor.opacity(0.8))
                }
                .frame(width: 52, height: 52)
                .background(badgeBg)
                .cornerRadius(10)

                VStack(alignment: .leading, spacing: 4) {
                    Text(hospital.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        Text("\(hospital.city) · \(String(format: "%.1f", hospital.distanceKm)) km")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        ForEach(hospital.types, id: \.self) { type in
                            Text(type.rawValue)
                                .font(.system(size: 11))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(20)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(hospital.trustworthy ? Color.green : Color.orange)
                            .frame(width: 6, height: 6)
                        Text(hospital.trustworthy ? "Fiável" : "Verificar")
                            .font(.system(size: 11))
                            .foregroundColor(hospital.trustworthy ? .green : .orange)
                    }
                    Text("\(hospital.queueCount) em fila")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .padding(14)

            if expanded {
                Divider()
                    .padding(.horizontal, 14)

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 0) {
                        ForEach(hospital.triageLevels, id: \.label) { level in
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(triageColor(level.color))
                                    .frame(width: 20, height: 20)
                                Text(level.label.components(separatedBy: " ").first ?? "")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                Text(level.waitMinutes == 0 ? "Imediato" : "\(level.waitMinutes)m")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.primary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }

                    HStack(spacing: 8) {
                        PhaseBox(label: "Triagem", minutes: hospital.phase1Minutes)
                        PhaseBox(label: "1ª obs.", minutes: hospital.phase2Minutes)
                        PhaseBox(label: "Observação", minutes: hospital.phase3Minutes)
                    }

                    HStack(spacing: 8) {
                        Button(action: { openMaps() }) {
                            Text("Direções")
                                .font(.system(size: 13))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 9)
                                .background(Color.gray.opacity(0.15))
                                .cornerRadius(8)
                                .foregroundColor(.primary)
                        }
                        Button(action: {}) {
                            Text("Comparar")
                                .font(.system(size: 13))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 9)
                                .background(Color.blue.opacity(0.12))
                                .cornerRadius(8)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(14)
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
        )
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                expanded.toggle()
            }
        }
    }
}

struct PhaseBox: View {
    let label: String
    let minutes: Int

    var body: some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            Text("\(minutes)m")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.gray.opacity(0.15))
        .cornerRadius(8)
    }
}
