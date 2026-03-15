import SwiftUI

struct ContentView: View {
    @StateObject private var vm = HospitalViewModel()
    @ObservedObject var favoritesManager = FavoritesManager.shared
    @AppStorage("appLanguage") var appLanguage: String = "pt"
    @AppStorage("boldText") var boldText: Bool = false
    @AppStorage("textSize") var textSize: Double = 1.0
    @AppStorage("showDisclaimer") var showDisclaimer: Bool = true
    @State private var showMenu = false
    @State private var navigateTo: String? = nil

    var snsGreen: Color { Color(red: 0.0, green: 0.47, blue: 0.25) }

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if appLanguage == "en" {
            switch hour {
            case 6..<12: return "Good morning"
            case 12..<18: return "Good afternoon"
            default: return "Good evening"
            }
        } else {
            switch hour {
            case 6..<12: return "Bom dia"
            case 12..<18: return "Boa tarde"
            default: return "Boa noite"
            }
        }
    }

    var bestHospital: Hospital? {
        vm.hospitals.min(by: { $0.waitMinutes < $1.waitMinutes })
    }

    var nearestHospital: Hospital? {
        vm.hospitals.min(by: { $0.distanceKm < $1.distanceKm })
    }

    var body: some View {
        ZStack {
            NavigationView {
                ZStack(alignment: .top) {
                    Color(.systemGroupedBackground).ignoresSafeArea()

                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {

                            // Hidden navigation links
                            NavigationLink(destination: FavoritesView(hospitals: vm.hospitals), tag: "favorites", selection: $navigateTo) { EmptyView() }
                            NavigationLink(destination: ChatView(hospitals: vm.hospitals), tag: "chat", selection: $navigateTo) { EmptyView() }
                            NavigationLink(destination: SettingsView(), tag: "settings", selection: $navigateTo) { EmptyView() }

                            // Hero header
                            ZStack(alignment: .bottomLeading) {
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.0, green: 0.47, blue: 0.25),
                                        Color(red: 0.05, green: 0.62, blue: 0.35)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .frame(height: 160)
                                .cornerRadius(20)

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(greeting)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.white.opacity(0.8))
                                        .textCase(.uppercase)
                                        .tracking(1.2)
                                    Text(appLanguage == "en" ? "SNS Emergencies" : "Urgências SNS")
                                        .font(boldText ? .system(size: 28 * textSize, weight: .bold) : .system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                    Text(appLanguage == "en" ? "Real-time wait times" : "Tempos de espera em tempo real")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.75))
                                }
                                .padding(20)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)

                            // Quick stats
                            if !vm.hospitals.isEmpty {
                                HStack(spacing: 10) {
                                    SNSStatCard(
                                        icon: "clock.fill",
                                        label: appLanguage == "en" ? "Shortest wait" : "Menor espera",
                                        value: "\(bestHospital?.waitMinutes ?? 0) min",
                                        subtitle: bestHospital?.name.components(separatedBy: " ").prefix(2).joined(separator: " ") ?? ""
                                    )
                                    SNSStatCard(
                                        icon: "location.fill",
                                        label: appLanguage == "en" ? "Nearest" : "Mais próximo",
                                        value: "\(String(format: "%.1f", nearestHospital?.distanceKm ?? 0)) km",
                                        subtitle: nearestHospital?.name.components(separatedBy: " ").prefix(2).joined(separator: " ") ?? ""
                                    )
                                    SNSStatCard(
                                        icon: "person.2.fill",
                                        label: appLanguage == "en" ? "In queue" : "Em fila",
                                        value: "\(vm.hospitals.reduce(0) { $0 + $1.queueCount })",
                                        subtitle: appLanguage == "en" ? "all hospitals" : "todos os hospitais"
                                    )
                                }
                                .padding(.horizontal, 16)
                            }

                            // Best hospital highlight
                            if let best = bestHospital {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 11))
                                            .foregroundColor(snsGreen)
                                        Text(appLanguage == "en" ? "BEST OPTION NOW" : "MELHOR OPÇÃO AGORA")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(snsGreen)
                                            .tracking(0.8)
                                    }
                                    HospitalCardView(hospital: best)
                                }
                                .padding(14)
                                .background(snsGreen.opacity(0.07))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(snsGreen.opacity(0.2), lineWidth: 0.5)
                                )
                                .padding(.horizontal, 16)
                            }

                            // Filters
                            VStack(alignment: .leading, spacing: 12) {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(FilterType.allCases, id: \.self) { filter in
                                            Button(action: { vm.activeFilter = filter }) {
                                                Text(filter.rawValue)
                                                    .font(.system(size: 13, weight: .medium))
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 8)
                                                    .background(vm.activeFilter == filter ? snsGreen : Color(.systemBackground))
                                                    .foregroundColor(vm.activeFilter == filter ? .white : snsGreen)
                                                    .cornerRadius(20)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 20)
                                                            .stroke(snsGreen.opacity(0.4), lineWidth: 0.5)
                                                    )
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }

                                HStack(spacing: 6) {
                                    Text(appLanguage == "en" ? "Sort by" : "Ordenar por")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                    ForEach(SortType.allCases, id: \.self) { sort in
                                        Button(action: { vm.activeSort = sort }) {
                                            Text(sort.rawValue)
                                                .font(.system(size: 12, weight: vm.activeSort == sort ? .semibold : .regular))
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 4)
                                                .background(vm.activeSort == sort ? snsGreen.opacity(0.1) : Color.clear)
                                                .cornerRadius(6)
                                                .foregroundColor(vm.activeSort == sort ? snsGreen : .secondary)
                                        }
                                    }
                                    Spacer()
                                    if let updated = vm.lastUpdated {
                                        HStack(spacing: 4) {
                                            Circle()
                                                .fill(snsGreen)
                                                .frame(width: 5, height: 5)
                                            Text(updated, style: .relative)
                                                .font(.system(size: 10))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                            }

                            // Hospital list
                            VStack(alignment: .leading, spacing: 10) {
                                Text(appLanguage == "en" ? "All hospitals" : "Todos os hospitais")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 16)

                                if vm.loading {
                                    HStack {
                                        Spacer()
                                        VStack(spacing: 12) {
                                            ProgressView().tint(snsGreen)
                                            Text(appLanguage == "en" ? "Loading SNS data..." : "A carregar dados SNS...")
                                                .font(.system(size: 13))
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                    }
                                    .padding(.top, 40)
                                } else {
                                    LazyVStack(spacing: 10) {
                                        ForEach(vm.filtered) { hospital in
                                            HospitalCardView(hospital: hospital)
                                                .padding(.horizontal, 16)
                                        }
                                    }
                                }
                            }

                            // Disclaimer
                            if showDisclaimer {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "info.circle")
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                        Text(appLanguage == "en" ? "About the data" : "Sobre os dados")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    Text(appLanguage == "en"
                                         ? "Wait times are provided by the National Health Service via tempos.min-saude.pt and updated every 10 minutes. Data is indicative. In an emergency call 112."
                                         : "Os tempos de espera são fornecidos pelo SNS através do portal tempos.min-saude.pt e atualizados a cada 10 minutos. Os dados são indicativos. Em emergência ligue 112.")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color(.tertiaryLabel))
                                        .lineSpacing(3)
                                }
                                .padding(14)
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                                .padding(.horizontal, 16)
                                .padding(.bottom, 20)
                            }
                        }
                    }
                    .refreshable { await vm.load() }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.25)) { showMenu.toggle() }
                        }) {
                            Image(systemName: showMenu ? "xmark" : "line.3.horizontal")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(snsGreen)
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        HStack(spacing: 6) {
                            Image(systemName: "cross.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(snsGreen)
                            Text("SNS Urgências")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            withAnimation { showMenu = false }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                navigateTo = "chat"
                            }
                        }) {
                            Image(systemName: "message.fill")
                                .foregroundColor(snsGreen)
                        }
                    }
                }
            }

            // Burger menu overlay
            if showMenu {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) { showMenu = false }
                    }

                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        // Menu header
                        VStack(alignment: .leading, spacing: 6) {
                            Image(systemName: "cross.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            Text("SNS Urgências")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            Text(appLanguage == "en" ? "Real-time ER tracker" : "Tempos de espera em tempo real")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.75))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(24)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.0, green: 0.47, blue: 0.25),
                                    Color(red: 0.05, green: 0.62, blue: 0.35)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                        // Menu items
                        VStack(alignment: .leading, spacing: 0) {
                            Button(action: {
                                withAnimation { showMenu = false }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    navigateTo = "favorites"
                                }
                            }) {
                                MenuRow(
                                    icon: "heart.fill",
                                    color: .red,
                                    title: appLanguage == "en" ? "Favourites & History" : "Favoritos & Histórico",
                                    badge: favoritesManager.favoriteIds.isEmpty ? nil : "\(favoritesManager.favoriteIds.count)"
                                )
                            }

                            Divider().padding(.leading, 56)

                            Button(action: {
                                withAnimation { showMenu = false }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    navigateTo = "chat"
                                }
                            }) {
                                MenuRow(
                                    icon: "message.fill",
                                    color: snsGreen,
                                    title: appLanguage == "en" ? "Chat with Lusia" : "Chat com a Lusia",
                                    badge: nil
                                )
                            }

                            Divider().padding(.leading, 56)

                            Button(action: {
                                withAnimation { showMenu = false }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    navigateTo = "settings"
                                }
                            }) {
                                MenuRow(
                                    icon: "gearshape.fill",
                                    color: .gray,
                                    title: appLanguage == "en" ? "Settings" : "Definições",
                                    badge: nil
                                )
                            }
                        }
                        .background(Color(.systemBackground))

                        Spacer()

                        Text(appLanguage == "en" ? "Data: tempos.min-saude.pt" : "Dados: tempos.min-saude.pt")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .padding(20)
                            .background(Color(.systemBackground))
                    }
                    .frame(width: 280)
                    .background(Color(.systemBackground))
                    .ignoresSafeArea()
                    .transition(.move(edge: .leading))

                    Spacer()
                }
            }
        }
        .task {
            await vm.load()
            vm.startAutoRefresh()
        }
        .onDisappear {
            vm.stopAutoRefresh()
        }
    }
}

struct MenuRow: View {
    let icon: String
    let color: Color
    let title: String
    let badge: String?

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.1))
                .cornerRadius(10)
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)
            Spacer()
            if let badge = badge {
                Text(badge)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.red)
                    .cornerRadius(10)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(Color(.tertiaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

struct SNSStatCard: View {
    let icon: String
    let label: String
    let value: String
    let subtitle: String

    var snsGreen: Color { Color(red: 0.0, green: 0.47, blue: 0.25) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(snsGreen)
                .frame(width: 28, height: 28)
                .background(snsGreen.opacity(0.1))
                .cornerRadius(8)
            Text(value)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.primary)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(Color(.tertiaryLabel))
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}
