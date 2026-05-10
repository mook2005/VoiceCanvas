import SwiftUI

struct IconBtn: View {
    let icon: String; let label: String; let color: Color; let action: () -> Void
    @State private var pressed = false
    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            action()
        } label: {
            VStack(spacing: 5) {
                Image(systemName: icon).font(.system(size: 19, weight: .medium))
                Text(label).font(.rounded(11, weight: .semibold))
            }
            .foregroundColor(color)
            .frame(width: 62, height: 54)
            .background(
                RoundedRectangle(cornerRadius: 14).fill(color.opacity(0.09))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.16), lineWidth: 1))
            )
            .scaleEffect(pressed ? 0.91 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: pressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in pressed = true }.onEnded { _ in pressed = false })
    }
}

struct PrimaryBtn: View {
    let label: String; let loadingLabel: String
    let isLoading: Bool; let isDisabled: Bool; let action: () -> Void
    @State private var pressed = false
    var body: some View {
        Button {
            guard !isDisabled && !isLoading else { return }
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            action()
        } label: {
            HStack(spacing: 9) {
                if isLoading {
                    ProgressView().progressViewStyle(.circular).tint(.white).scaleEffect(0.82)
                } else {
                    Image(systemName: "text.viewfinder").font(.system(size: 18, weight: .semibold))
                }
                Text(isLoading ? loadingLabel : label).font(.rounded(16, weight: .bold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity).frame(height: 54)
            .background(
                RoundedRectangle(cornerRadius: AC.btnCorner)
                    .fill(isDisabled
                          ? LinearGradient(colors: [AC.primary.opacity(0.3), AC.primary.opacity(0.2)],
                                           startPoint: .topLeading, endPoint: .bottomTrailing)
                          : LinearGradient(colors: [AC.primary, AC.primaryDark],
                                           startPoint: .topLeading, endPoint: .bottomTrailing))
                    .shadow(color: AC.primary.opacity(isDisabled ? 0 : 0.38), radius: 10, x: 0, y: 5)
            )
            .scaleEffect(pressed ? 0.96 : 1)
            .animation(.spring(response: 0.22, dampingFraction: 0.7), value: pressed)
        }
        .buttonStyle(PlainButtonStyle()).disabled(isDisabled || isLoading)
        .simultaneousGesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in if !isDisabled && !isLoading { pressed = true } }
            .onEnded   { _ in pressed = false })
    }
}

struct StrokePicker: View {
    @Binding var width: CGFloat
    let options: [(CGFloat, String)] = [(5, "S"), (8, "M"), (12, "L")]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(options, id: \.0) { (w, label) in
                Button {
                    withAnimation(.spring(response: 0.2)) { width = w }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    VStack(spacing: 4) {
                        Circle()
                            .fill(width == w ? AC.primary : AC.textSecondary.opacity(0.28))
                            .frame(width: min(max(w, 5), 14), height: min(max(w, 5), 14))
                        Text(label)
                            .font(.rounded(10, weight: .bold))
                            .foregroundColor(width == w ? AC.primary : AC.textSecondary.opacity(0.6))
                    }
                    .frame(width: 36, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(width == w ? AC.primaryLight : Color.clear)
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(width == w ? AC.primary.opacity(0.22) : Color.clear, lineWidth: 1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct SpeakButton: View {
    let isSpeaking: Bool; let action: () -> Void
    @State private var pulse = false
    var body: some View {
        Button(action: action) {
            ZStack {
                if isSpeaking {
                    Circle()
                        .stroke(AC.primary.opacity(0.25), lineWidth: 3)
                        .frame(width: 80, height: 80)
                        .scaleEffect(pulse ? 1.18 : 1.0)
                        .opacity(pulse ? 0 : 0.8)
                        .animation(.easeOut(duration: 1.0).repeatForever(autoreverses: false), value: pulse)
                }
                Circle()
                    .fill(LinearGradient(
                        colors: isSpeaking ? [AC.primaryDark, AC.primary] : [AC.primary, AC.primaryDark],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 64, height: 64)
                    .shadow(color: AC.primary.opacity(0.40), radius: 10, x: 0, y: 5)
                Image(systemName: isSpeaking ? "stop.fill" : "speaker.wave.3.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onChange(of: isSpeaking) { pulse = $0 }
    }
}

struct ResultPanel: View {
    let text: String; let isRecognizing: Bool
    let onSpeak: () -> Void; let onClear: () -> Void
    @ObservedObject var speech: SpeechService

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(text.isEmpty ? AC.textSecondary.opacity(0.3) : AC.success)
                        .frame(width: 8, height: 8)
                    Text("Recognized Text")
                        .font(.rounded(13, weight: .semibold))
                        .foregroundColor(AC.textSecondary)
                }
                Spacer()
                if !text.isEmpty {
                    Button(action: onClear) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AC.textSecondary.opacity(0.45))
                            .font(.system(size: 19))
                    }
                }
            }
            .padding(.horizontal, AC.pad).padding(.top, 13).padding(.bottom, 9)

            Divider().background(AC.primary.opacity(0.08))

            if isRecognizing {
                HStack(spacing: 12) {
                    ProgressView().progressViewStyle(.circular).tint(AC.primary)
                    Text("Reading handwriting…").font(.rounded(15, weight: .medium)).foregroundColor(AC.primary)
                }
                .padding(.vertical, 22)
            } else if text.isEmpty {
                Text("Tap \u{201C}Read Text\u{201D} to convert your handwriting")
                    .font(.rounded(14))
                    .foregroundColor(AC.textSecondary.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AC.pad).padding(.vertical, 20)
            } else {
                HStack(alignment: .center, spacing: 12) {
                    ScrollView {
                        Text(text)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AC.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, AC.pad).padding(.vertical, 12)
                    }
                    .frame(maxHeight: 90)
                    SpeakButton(isSpeaking: speech.isSpeaking, action: onSpeak)
                        .padding(.trailing, AC.pad)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: AC.cardCorner).fill(AC.surface)
                .shadow(color: AC.primary.opacity(0.07), radius: 12, x: 0, y: 4)
                .overlay(RoundedRectangle(cornerRadius: AC.cardCorner)
                    .stroke(AC.primary.opacity(0.11), lineWidth: 1))
        )
    }
}

struct HistorySheet: View {
    let history: [HistoryEntry]; let onSelect: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            Group {
                if history.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 56, weight: .ultraLight))
                            .foregroundColor(AC.primary.opacity(0.3))
                        Text("No history yet")
                            .font(.rounded(18, weight: .semibold)).foregroundColor(AC.textSecondary)
                        Text("Messages you speak will appear here")
                            .font(.rounded(14)).foregroundColor(AC.textSecondary.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity).background(AC.background)
                } else {
                    List {
                        ForEach(history) { entry in
                            Button { onSelect(entry.text); dismiss() } label: {
                                HStack(spacing: 14) {
                                    ZStack {
                                        Circle()
                                            .fill(LinearGradient(colors: [AC.primary, AC.primaryDark],
                                                                 startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .frame(width: 44, height: 44)
                                        Image(systemName: "speaker.wave.2.fill")
                                            .font(.system(size: 16, weight: .semibold)).foregroundColor(.white)
                                    }
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(entry.text).font(.rounded(17, weight: .semibold)).foregroundColor(AC.textPrimary)
                                        Text(entry.timeString).font(.rounded(12)).foregroundColor(AC.textSecondary)
                                    }
                                    Spacer()
                                    Image(systemName: "play.circle.fill")
                                        .font(.system(size: 26)).foregroundColor(AC.primary.opacity(0.4))
                                }
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .listStyle(.insetGrouped).scrollContentBackground(.hidden).background(AC.background)
                }
            }
            .navigationTitle("History").navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                        .font(.rounded(16, weight: .semibold)).foregroundColor(AC.primary)
                }
            }
        }
    }
}

struct SpeakToast: View {
    let text: String
    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 10) {
                ZStack {
                    Circle().fill(AC.primary).frame(width: 32, height: 32)
                    Image(systemName: "speaker.wave.2.fill")
                        .font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                }
                Text(text).font(.rounded(15, weight: .semibold)).foregroundColor(AC.textPrimary).lineLimit(1)
            }
            .padding(.horizontal, 18).padding(.vertical, 12)
            .background(Capsule().fill(.white).shadow(color: AC.primary.opacity(0.18), radius: 18, x: 0, y: 6))
            .padding(.bottom, 40)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}
