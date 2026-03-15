import SwiftUI

struct FavoritesView: View {
    @ObservedObject var favoritesManager = FavoritesManager.shared
    let hospitals: [Hospital]

    var favoriteHospitals: [Hospital] {
        hospitals.filter { favoritesManager.isFavorite($0) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Favoritos
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 13))
                            .foregroundColor(Color(red: 0.0, green: 0.47, blue: 0.25))
                        Text("Hospitais favoritos")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 16)

                    if favoriteHospitals.isEmpty {
                        EmptyStateCard(
                            icon: "heart",
                            title: "Sem favoritos",
                            subtitle: "Adiciona hospitais aos favoritos tocando no ícone de coração no cartão do hospital."
                        )
                        .padding(.horizontal, 16)
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(favoriteHospitals) { hospital in
                                HospitalCardView(hospital: hospital)
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                }

                // Histórico
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        HStack(spacing: 6) {
                            Image(systemName: "clock.arrow.circlepath")
                                .font(.system(size: 13))
                                .foregroundColor(Color(red: 0.0, green: 0.47, blue: 0.25))
                            Text("Histórico de visitas")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                        Spacer()
                        if !favoritesManager.visitHistory.isEmpty {
                            Button(action: { favoritesManager.clearHistory() }) {
                                Text("Limpar")
                                    .font(.system(size: 13))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .padding(.horizontal, 16)

                    if favoritesManager.visitHistory.isEmpty {
                        EmptyStateCard(
                            icon: "clock",
                            title: "Sem histórico",
                            subtitle: "As tuas visitas a urgências aparecerão aqui automaticamente."
                        )
                        .padding(.horizontal, 16)
                    } else {
                        LazyVStack(spacing: 8) {
                            ForEach(favoritesManager.visitHistory) { record in
                                VisitRecordCard(record: record)
                                    .padding(.horizontal, 16)
                            }
                        }
                    }
                }

                Spacer(minLength: 20)
            }
            .padding(.top, 16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Favoritos & Histórico")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct VisitRecordCard: View {
    let record: VisitRecord

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 2) {
                Text("\(record.waitMinutes)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.0, green: 0.47, blue: 0.25))
                Text("min")
                    .font(.system(size: 10))
                    .foregroundColor(Color(red: 0.0, green: 0.47, blue: 0.25).opacity(0.7))
            }
            .frame(width: 44, height: 44)
            .background(Color(red: 0.0, green: 0.47, blue: 0.25).opacity(0.08))
            .cornerRadius(10)

            VStack(alignment: .leading, spacing: 3) {
                Text(record.hospitalName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                Text("\(record.city) · \(record.queueCount) em fila")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                Text(record.date, style: .date)
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                Text(record.date, style: .time)
                    .font(.system(size: 11))
                    .foregroundColor(Color(.tertiaryLabel))
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
        )
    }
}

struct EmptyStateCard: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(Color(red: 0.0, green: 0.47, blue: 0.25).opacity(0.4))
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
        )
    }
}
