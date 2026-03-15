import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let relatedHospital: Hospital?
    let showFollowUp: Bool

    init(text: String, isUser: Bool, relatedHospital: Hospital? = nil, showFollowUp: Bool = false) {
        self.text = text
        self.isUser = isUser
        self.relatedHospital = relatedHospital
        self.showFollowUp = showFollowUp
    }
}

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var messages: [Message] = [
        Message(text: "Olá! Sou o assistente da Urgência Agora. Posso ajudar-te a escolher o melhor hospital ou responder dúvidas sobre urgências. Como posso ajudar?", isUser: false)
    ]
    @State private var inputText = ""
    @State private var loading = false
    @State private var finished = false
    let hospitals: [Hospital]

    private let apiKey = "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"

    var hospitalContext: String {
        hospitals.map { h in
            "\(h.name) (\(h.city)): \(h.waitMinutes) min de espera, \(h.queueCount) em fila"
        }.joined(separator: "\n")
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 8) {
                                MessageBubble(message: message)

                                if !message.isUser, let hospital = message.relatedHospital {
                                    HospitalSnippet(hospital: hospital)
                                        .padding(.leading, 4)
                                }

                                if message.showFollowUp && !finished {
                                    HStack(spacing: 8) {
                                        Button(action: {
                                            messages.append(Message(text: "Sim", isUser: true))
                                        }) {
                                            Text("Sim")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.blue)
                                                .padding(.horizontal, 24)
                                                .padding(.vertical, 10)
                                                .background(Color.blue.opacity(0.1))
                                                .cornerRadius(20)
                                        }
                                        Button(action: endConversation) {
                                            Text("Não")
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal, 24)
                                                .padding(.vertical, 10)
                                                .background(Color.gray.opacity(0.1))
                                                .cornerRadius(20)
                                        }
                                    }
                                    .padding(.leading, 4)
                                }
                            }
                            .id(message.id)
                        }

                        if loading {
                            HStack {
                                ProgressView().scaleEffect(0.8)
                                Text("A pensar...")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .padding(16)
                }
                .onChange(of: messages.count) { _ in
                    if let last = messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            if !finished {
                Button(action: call112) {
                    HStack(spacing: 8) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 14))
                        Text("Ligar 112 — Emergência")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red)
                    .cornerRadius(12)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                }

                Divider().padding(.top, 10)

                HStack(spacing: 10) {
                    TextField("Pergunta sobre urgências...", text: $inputText)
                        .font(.system(size: 15))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(20)

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(inputText.isEmpty ? .gray : .blue)
                    }
                    .disabled(inputText.isEmpty || loading)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            }
        }
        .navigationTitle("Assistente")
        .navigationBarTitleDisplayMode(.inline)
    }

    func call112() {
        if let url = URL(string: "tel://112") {
            UIApplication.shared.open(url)
        }
    }

    func endConversation() {
        finished = true
        messages.append(Message(text: "Fico feliz por ter ajudado! Boa sorte e boa recuperação. Até à próxima! 👋", isUser: false))
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            dismiss()
        }
    }

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        messages.append(Message(text: text, isUser: true))
        inputText = ""
        loading = true
        Task {
            let (reply, hospital) = await askGroq(question: text)
            messages.append(Message(text: reply, isUser: false, relatedHospital: hospital, showFollowUp: true))
            loading = false
        }
    }

    func askGroq(question: String) async -> (String, Hospital?) {
        guard let url = URL(string: "https://api.groq.com/openai/v1/chat/completions") else {
            return ("Erro ao conectar.", nil)
        }

        let hospitalList = hospitals.map { "\($0.name)" }.joined(separator: ", ")

        let systemPrompt = """
        És um assistente de saúde português que ajuda utilizadores a escolher urgências hospitalares em Portugal.
        Responde sempre em português europeu, de forma clara e empática.
        Aqui estão os dados atuais das urgências:
        \(hospitalContext)
        Usa estes dados para recomendar o melhor hospital quando relevante.
        Nunca dês diagnósticos médicos. Em emergências diz sempre para ligar 112.
        Termina SEMPRE a tua resposta com a pergunta: "Posso ajudar-te com mais alguma coisa?"
        NÃO incluas botões nem opções de sim/não — isso é tratado pela app.

        IMPORTANTE: Se a tua resposta mencionar ou recomendar um hospital específico, termina SEMPRE com uma linha no formato exato:
        HOSPITAL_RECOMENDADO: [nome exato do hospital]
        Os hospitais disponíveis são: \(hospitalList)
        Se não recomendares nenhum hospital específico, não incluas essa linha.
        """

        let body: [String: Any] = [
            "model": "llama-3.3-70b-versatile",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": question]
            ],
            "max_tokens": 500,
            "temperature": 0.7
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let choices = json?["choices"] as? [[String: Any]]
            let messageContent = choices?.first?["message"] as? [String: Any]
            var fullText = messageContent?["content"] as? String ?? "Não consegui obter resposta."

            var recommendedHospital: Hospital? = nil
            if let range = fullText.range(of: "HOSPITAL_RECOMENDADO:") {
                let after = fullText[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
                let hospitalName = after.components(separatedBy: "\n").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                recommendedHospital = hospitals.first {
                    $0.name.lowercased().contains(hospitalName.lowercased()) ||
                    hospitalName.lowercased().contains($0.name.lowercased())
                }
                fullText = fullText.replacingOccurrences(of: "\nHOSPITAL_RECOMENDADO: \(after.components(separatedBy: "\n").first ?? "")", with: "")
                fullText = fullText.replacingOccurrences(of: "HOSPITAL_RECOMENDADO: \(after.components(separatedBy: "\n").first ?? "")", with: "")
            }

            return (fullText.trimmingCharacters(in: .whitespacesAndNewlines), recommendedHospital)
        } catch {
            return ("Erro de ligação. Tenta novamente.", nil)
        }
    }
}

struct HospitalSnippet: View {
    let hospital: Hospital

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

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                VStack(spacing: 2) {
                    Text("\(hospital.waitMinutes)")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(badgeColor)
                    Text("min")
                        .font(.system(size: 10))
                        .foregroundColor(badgeColor.opacity(0.8))
                }
                .frame(width: 46, height: 46)
                .background(badgeBg)
                .cornerRadius(8)

                VStack(alignment: .leading, spacing: 3) {
                    Text(hospital.name)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    Text("\(hospital.city) · \(String(format: "%.1f", hospital.distanceKm)) km · \(hospital.queueCount) em fila")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 3) {
                    Circle()
                        .fill(hospital.trustworthy ? Color.green : Color.orange)
                        .frame(width: 6, height: 6)
                    Text(hospital.trustworthy ? "Fiável" : "Verificar")
                        .font(.system(size: 11))
                        .foregroundColor(hospital.trustworthy ? .green : .orange)
                }
            }

            HStack(spacing: 6) {
                SnippetPhase(label: "Triagem", minutes: hospital.phase1Minutes)
                SnippetPhase(label: "1ª obs.", minutes: hospital.phase2Minutes)
                SnippetPhase(label: "Observação", minutes: hospital.phase3Minutes)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.06))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
        )
    }
}

struct SnippetPhase: View {
    let label: String
    let minutes: Int

    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 10))
                .foregroundColor(.secondary)
            Text("\(minutes)m")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
    }
}

struct MessageBubble: View {
    let message: Message

    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            Text(message.text)
                .font(.system(size: 15))
                .foregroundColor(message.isUser ? .white : .primary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(message.isUser ? Color.blue : Color.gray.opacity(0.12))
                .cornerRadius(18)
                .frame(maxWidth: 280, alignment: message.isUser ? .trailing : .leading)
            if !message.isUser { Spacer() }
        }
    }
}
