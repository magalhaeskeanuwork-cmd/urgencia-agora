import SwiftUI

struct SettingsView: View {
    @AppStorage("appLanguage") var appLanguage: String = "pt"
    @AppStorage("textSize") var textSize: Double = 1.0
    @AppStorage("highContrast") var highContrast: Bool = false
    @AppStorage("reduceMotion") var reduceMotion: Bool = false
    @AppStorage("boldText") var boldText: Bool = false
    @AppStorage("hapticFeedback") var hapticFeedback: Bool = true
    @AppStorage("autoRefresh") var autoRefresh: Bool = true
    @AppStorage("refreshInterval") var refreshInterval: Double = 10
    @AppStorage("showDisclaimer") var showDisclaimer: Bool = true
    @AppStorage("colorBlindMode") var colorBlindMode: Bool = false
    @State private var showClearHistoryAlert = false
    @State private var showLanguageRestartAlert = false

    var snsGreen: Color { Color(red: 0.0, green: 0.47, blue: 0.25) }

    var t: (String) -> String {
        { key in appLanguage == "pt" ? ptStrings[key] ?? key : enStrings[key] ?? key }
    }

    let ptStrings: [String: String] = [
        "settings": "Definições",
        "language": "Idioma",
        "portuguese": "Português",
        "english": "English",
        "language_note": "Reinicia a app para aplicar o idioma",
        "accessibility": "Acessibilidade",
        "text_size": "Tamanho do texto",
        "small": "Pequeno",
        "large": "Grande",
        "high_contrast": "Alto contraste",
        "high_contrast_sub": "Aumenta o contraste das cores",
        "reduce_motion": "Reduzir movimento",
        "reduce_motion_sub": "Desativa animações",
        "bold_text": "Texto a negrito",
        "bold_text_sub": "Torna o texto mais espesso",
        "haptic": "Feedback tátil",
        "haptic_sub": "Vibração ao interagir",
        "color_blind": "Modo daltónico",
        "color_blind_sub": "Usa formas além de cores",
        "data": "Dados",
        "auto_refresh": "Atualização automática",
        "auto_refresh_sub": "Atualiza dados periodicamente",
        "refresh_interval": "Intervalo de atualização",
        "mins": "min",
        "clear_history": "Limpar histórico",
        "clear_history_sub": "Remove todas as visitas guardadas",
        "clear_confirm": "Tens a certeza?",
        "clear_confirm_sub": "O histórico de visitas será apagado permanentemente.",
        "cancel": "Cancelar",
        "clear": "Limpar",
        "about": "Sobre",
        "version": "Versão",
        "data_source": "Fonte de dados",
        "data_source_val": "SNS — tempos.min-saude.pt",
        "disclaimer": "Aviso legal",
        "disclaimer_text": "Esta app é independente e não é afiliada com o SNS ou o Ministério da Saúde.",
        "show_disclaimer": "Mostrar aviso de dados",
        "show_disclaimer_sub": "Mostra o aviso na página principal",
        "restart_needed": "É necessário reiniciar",
        "restart_text": "Por favor reinicia a app para aplicar o novo idioma.",
        "ok": "OK"
    ]

    let enStrings: [String: String] = [
        "settings": "Settings",
        "language": "Language",
        "portuguese": "Português",
        "english": "English",
        "language_note": "Restart the app to apply the language",
        "accessibility": "Accessibility",
        "text_size": "Text size",
        "small": "Small",
        "large": "Large",
        "high_contrast": "High contrast",
        "high_contrast_sub": "Increases colour contrast",
        "reduce_motion": "Reduce motion",
        "reduce_motion_sub": "Disables animations",
        "bold_text": "Bold text",
        "bold_text_sub": "Makes text thicker",
        "haptic": "Haptic feedback",
        "haptic_sub": "Vibration on interaction",
        "color_blind": "Colour blind mode",
        "color_blind_sub": "Uses shapes in addition to colours",
        "data": "Data",
        "auto_refresh": "Auto refresh",
        "auto_refresh_sub": "Periodically updates data",
        "refresh_interval": "Refresh interval",
        "mins": "min",
        "clear_history": "Clear history",
        "clear_history_sub": "Removes all saved visits",
        "clear_confirm": "Are you sure?",
        "clear_confirm_sub": "Visit history will be permanently deleted.",
        "cancel": "Cancel",
        "clear": "Clear",
        "about": "About",
        "version": "Version",
        "data_source": "Data source",
        "data_source_val": "SNS — tempos.min-saude.pt",
        "disclaimer": "Legal disclaimer",
        "disclaimer_text": "This app is independent and not affiliated with SNS or the Ministry of Health.",
        "show_disclaimer": "Show data disclaimer",
        "show_disclaimer_sub": "Shows the disclaimer on the main page",
        "restart_needed": "Restart required",
        "restart_text": "Please restart the app to apply the new language.",
        "ok": "OK"
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Language
                SettingsSection(title: t("language"), icon: "globe", color: snsGreen) {
                    VStack(spacing: 0) {
                        SettingsRow {
                            HStack {
                                Text(t("portuguese"))
                                    .font(boldText ? .system(size: 15 * textSize, weight: .bold) : .system(size: 15 * textSize))
                                    .foregroundColor(.primary)
                                Spacer()
                                if appLanguage == "pt" {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(snsGreen)
                                        .font(.system(size: 14, weight: .semibold))
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if appLanguage != "pt" {
                                    appLanguage = "pt"
                                    showLanguageRestartAlert = true
                                }
                            }
                        }
                        Divider().padding(.leading, 16)
                        SettingsRow {
                            HStack {
                                Text(t("english"))
                                    .font(boldText ? .system(size: 15 * textSize, weight: .bold) : .system(size: 15 * textSize))
                                    .foregroundColor(.primary)
                                Spacer()
                                if appLanguage == "en" {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(snsGreen)
                                        .font(.system(size: 14, weight: .semibold))
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if appLanguage != "en" {
                                    appLanguage = "en"
                                    showLanguageRestartAlert = true
                                }
                            }
                        }
                    }
                    Text(t("language_note"))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                }

                // Accessibility
                SettingsSection(title: t("accessibility"), icon: "accessibility", color: .blue) {
                    VStack(spacing: 0) {
                        SettingsRow {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(t("text_size"))
                                    .font(boldText ? .system(size: 15 * textSize, weight: .bold) : .system(size: 15 * textSize))
                                    .foregroundColor(.primary)
                                HStack {
                                    Text(t("small"))
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                    Slider(value: $textSize, in: 0.85...1.3, step: 0.05)
                                        .tint(snsGreen)
                                    Text(t("large"))
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        Divider().padding(.leading, 16)
                        SettingsToggleRow(
                            title: t("bold_text"),
                            subtitle: t("bold_text_sub"),
                            isOn: $boldText,
                            textSize: textSize,
                            bold: boldText,
                            color: snsGreen
                        )
                        Divider().padding(.leading, 16)
                        SettingsToggleRow(
                            title: t("high_contrast"),
                            subtitle: t("high_contrast_sub"),
                            isOn: $highContrast,
                            textSize: textSize,
                            bold: boldText,
                            color: snsGreen
                        )
                        Divider().padding(.leading, 16)
                        SettingsToggleRow(
                            title: t("reduce_motion"),
                            subtitle: t("reduce_motion_sub"),
                            isOn: $reduceMotion,
                            textSize: textSize,
                            bold: boldText,
                            color: snsGreen
                        )
                        Divider().padding(.leading, 16)
                        SettingsToggleRow(
                            title: t("color_blind"),
                            subtitle: t("color_blind_sub"),
                            isOn: $colorBlindMode,
                            textSize: textSize,
                            bold: boldText,
                            color: snsGreen
                        )
                        Divider().padding(.leading, 16)
                        SettingsToggleRow(
                            title: t("haptic"),
                            subtitle: t("haptic_sub"),
                            isOn: $hapticFeedback,
                            textSize: textSize,
                            bold: boldText,
                            color: snsGreen
                        )
                    }
                }

                // Data
                SettingsSection(title: t("data"), icon: "antenna.radiowaves.left.and.right", color: .orange) {
                    VStack(spacing: 0) {
                        SettingsToggleRow(
                            title: t("auto_refresh"),
                            subtitle: t("auto_refresh_sub"),
                            isOn: $autoRefresh,
                            textSize: textSize,
                            bold: boldText,
                            color: snsGreen
                        )
                        Divider().padding(.leading, 16)
                        SettingsRow {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(t("refresh_interval"))
                                        .font(boldText ? .system(size: 15 * textSize, weight: .bold) : .system(size: 15 * textSize))
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Text("\(Int(refreshInterval)) \(t("mins"))")
                                        .font(.system(size: 14))
                                        .foregroundColor(snsGreen)
                                        .fontWeight(.medium)
                                }
                                Slider(value: $refreshInterval, in: 5...30, step: 5)
                                    .tint(snsGreen)
                                    .disabled(!autoRefresh)
                                    .opacity(autoRefresh ? 1 : 0.4)
                            }
                        }
                        Divider().padding(.leading, 16)
                        SettingsToggleRow(
                            title: t("show_disclaimer"),
                            subtitle: t("show_disclaimer_sub"),
                            isOn: $showDisclaimer,
                            textSize: textSize,
                            bold: boldText,
                            color: snsGreen
                        )
                        Divider().padding(.leading, 16)
                        SettingsRow {
                            Button(action: { showClearHistoryAlert = true }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(t("clear_history"))
                                            .font(boldText ? .system(size: 15 * textSize, weight: .bold) : .system(size: 15 * textSize))
                                            .foregroundColor(.red)
                                        Text(t("clear_history_sub"))
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                        .font(.system(size: 14))
                                }
                            }
                        }
                    }
                }

                // About
                SettingsSection(title: t("about"), icon: "info.circle", color: .gray) {
                    VStack(spacing: 0) {
                        SettingsInfoRow(label: t("version"), value: "1.0.0", textSize: textSize, bold: boldText)
                        Divider().padding(.leading, 16)
                        SettingsInfoRow(label: t("data_source"), value: t("data_source_val"), textSize: textSize, bold: boldText)
                        Divider().padding(.leading, 16)
                        SettingsRow {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(t("disclaimer"))
                                    .font(boldText ? .system(size: 15 * textSize, weight: .bold) : .system(size: 15 * textSize))
                                    .foregroundColor(.primary)
                                Text(t("disclaimer_text"))
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                    .lineSpacing(3)
                            }
                        }
                    }
                }

                Spacer(minLength: 20)
            }
            .padding(.top, 16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(t("settings"))
        .navigationBarTitleDisplayMode(.inline)
        .alert(t("clear_confirm"), isPresented: $showClearHistoryAlert) {
            Button(t("cancel"), role: .cancel) {}
            Button(t("clear"), role: .destructive) {
                FavoritesManager.shared.clearHistory()
            }
        } message: {
            Text(t("clear_confirm_sub"))
        }
        .alert(t("restart_needed"), isPresented: $showLanguageRestartAlert) {
            Button(t("ok"), role: .cancel) {}
        } message: {
            Text(t("restart_text"))
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(color)
                Text(title.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
                    .tracking(0.8)
            }
            .padding(.horizontal, 16)

            VStack(spacing: 0) {
                content
            }
            .background(Color(.systemBackground))
            .cornerRadius(14)
            .padding(.horizontal, 16)
        }
    }
}

struct SettingsRow<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
    }
}

struct SettingsToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    let textSize: Double
    let bold: Bool
    let color: Color

    var body: some View {
        SettingsRow {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(bold ? .system(size: 15 * textSize, weight: .bold) : .system(size: 15 * textSize))
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Toggle("", isOn: $isOn)
                    .tint(color)
                    .labelsHidden()
            }
        }
    }
}

struct SettingsInfoRow: View {
    let label: String
    let value: String
    let textSize: Double
    let bold: Bool

    var body: some View {
        SettingsRow {
            HStack {
                Text(label)
                    .font(bold ? .system(size: 15 * textSize, weight: .bold) : .system(size: 15 * textSize))
                    .foregroundColor(.primary)
                Spacer()
                Text(value)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}

