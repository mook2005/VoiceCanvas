import SwiftUI

struct ContentView: View {
    @StateObject private var model  = CanvasModel()
    @StateObject private var speech = SpeechService()
    @State private var showHistory    = false
    @State private var showOnboarding = true
    @State private var showToast      = false
    @State private var toastText      = ""

    var body: some View {
        GeometryReader { geo in
            ZStack {
                AC.background.ignoresSafeArea()

                if showOnboarding {
                    OnboardingView(show: $showOnboarding)
                        .transition(.asymmetric(
                            insertion: .opacity,
                            removal: .move(edge: .top).combined(with: .opacity)))
                } else {
                    mainView(geo: geo).transition(.opacity)
                }

                if showToast { SpeakToast(text: toastText) }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: showOnboarding)
        }
        .sheet(isPresented: $showHistory) {
            HistorySheet(history: model.history) { text in
                model.recognizedText = text
                speech.speak(text)
            }
        }
    }

    @ViewBuilder
    func mainView(geo: GeometryProxy) -> some View {
        if geo.size.width > 700 {
            iPadLandscape(geo: geo)
        } else {
            stackLayout(geo: geo)
        }
    }

    func iPadLandscape(geo: GeometryProxy) -> some View {
        HStack(spacing: 0) {

            VStack(spacing: 0) {
                navbar.padding(.horizontal, AC.pad).padding(.top, 14).padding(.bottom, 8)

                phraseBar
                separator

                CanvasView(model: model)
                    .padding(.horizontal, AC.pad)
                    .padding(.top, 10)

                toolbar
                    .padding(.horizontal, AC.pad)
                    .padding(.top, 10)
                    .padding(.bottom, 14)
            }
            .frame(width: geo.size.width * 0.65)
            .background(AC.background)

            Rectangle()
                .fill(AC.primary.opacity(0.10))
                .frame(width: 1)

            VStack(spacing: 0) {
                HStack {
                    Text("OUTPUT")
                        .font(.system(size: 10, weight: .black, design: .rounded))
                        .foregroundColor(AC.textSecondary.opacity(0.5))
                        .kerning(1)
                    Spacer()
                }
                .padding(.horizontal, AC.pad)
                .padding(.top, 20)
                .padding(.bottom, 10)

                resultPanel
                    .padding(.horizontal, AC.pad)

                Spacer()

                historyBtn
                    .padding(.horizontal, AC.pad)
                    .padding(.bottom, 24)
            }
            .frame(width: geo.size.width * 0.35)
            .background(AC.surface)
        }
    }

    func stackLayout(geo: GeometryProxy) -> some View {
        let isPad   = geo.size.width > 500
        let hPad    = isPad ? CGFloat(28) : AC.pad
        let canvasH = geo.size.height * (isPad ? 0.45 : 0.42)

        return VStack(spacing: 0) {
            navbar
                .padding(.horizontal, hPad)
                .padding(.top, 14)
                .padding(.bottom, 8)

            phraseBar
            separator

            CanvasView(model: model)
                .frame(height: canvasH)
                .padding(.horizontal, hPad)
                .padding(.top, 10)

            toolbar
                .padding(.horizontal, hPad)
                .padding(.top, 8)
                .padding(.bottom, 6)

            resultPanel
                .padding(.horizontal, hPad)
                .frame(height: 118)

            Spacer(minLength: 0)
        }
    }

    var phraseBar: some View {
        QuickPhrasesBar { phrase in handlePhrase(phrase) }
    }

    var separator: some View {
        Rectangle()
            .fill(AC.primary.opacity(0.07))
            .frame(height: 1)
    }

    var navbar: some View {
        HStack {
            HStack(spacing: 11) {
                ZStack {
                    RoundedRectangle(cornerRadius: 13)
                        .fill(LinearGradient(
                            colors: [AC.primary, AC.primaryDark],
                            startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 44, height: 44)
                        .shadow(color: AC.primary.opacity(0.30), radius: 6, x: 0, y: 3)
                    Image(systemName: "hand.draw.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text("VoiceCanvas")
                        .font(.rounded(18, weight: .bold))
                        .foregroundColor(AC.textPrimary)
                    Text("Voice from the Heart")
                        .font(.rounded(11, weight: .medium))
                        .foregroundColor(AC.textSecondary)
                }
            }
            Spacer()
            Button { showHistory = true } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.system(size: 19, weight: .medium))
                        .foregroundColor(AC.primary)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(AC.primaryLight))
                    if !model.history.isEmpty {
                        Circle().fill(AC.danger)
                            .frame(width: 9, height: 9)
                            .offset(x: 1, y: -1)
                    }
                }
            }
        }
    }

    var toolbar: some View {
        HStack(spacing: 8) {
            IconBtn(icon: "arrow.uturn.backward", label: "Undo",  color: AC.textSecondary) { model.undo() }
            IconBtn(icon: "trash",                label: "Clear", color: AC.danger) {
                withAnimation(.spring()) { model.clear() }
            }
            Rectangle().fill(AC.primary.opacity(0.12)).frame(width: 1, height: 32).padding(.horizontal, 2)
            StrokePicker(width: $model.strokeWidth)
            Spacer()
            PrimaryBtn(label: "Read Text", loadingLabel: "Reading…",
                       isLoading: model.isRecognizing, isDisabled: model.isEmpty) { performOCR() }
                .frame(width: 144)
        }
    }

    var resultPanel: some View {
        ResultPanel(
            text: model.recognizedText,
            isRecognizing: model.isRecognizing,
            onSpeak: { speech.isSpeaking ? speech.stop() : speech.speak(model.recognizedText) },
            onClear: { model.recognizedText = "" },
            speech: speech
        )
    }

    var historyBtn: some View {
        Button { showHistory = true } label: {
            Label("Communication History", systemImage: "clock.arrow.circlepath")
                .font(.rounded(14, weight: .semibold))
                .foregroundColor(AC.primary)
                .frame(maxWidth: .infinity).frame(height: 48)
                .background(RoundedRectangle(cornerRadius: AC.btnCorner)
                    .fill(AC.primaryLight)
                    .overlay(RoundedRectangle(cornerRadius: AC.btnCorner)
                        .stroke(AC.primary.opacity(0.20), lineWidth: 1)))
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func performOCR() {
        guard !model.isEmpty else { return }
        model.isRecognizing = true
        let img = CanvasRenderer.render(strokes: model.strokes, size: model.canvasSize)
        OCRService.recognize(image: img) { text in
            model.isRecognizing = false
            let result = text.trimmingCharacters(in: .whitespacesAndNewlines)
            model.recognizedText = result.isEmpty ? "Almost there! Try writing a bit larger or clearer so I can help translate for you." : result
            if !result.isEmpty {
                model.addHistory(result)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { speech.speak(result) }
            }
        }
    }

    private func handlePhrase(_ text: String) {
        model.recognizedText = text
        model.addHistory(text)
        speech.speak(text)
        toastText = text
        withAnimation(.spring()) { showToast = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.spring()) { showToast = false }
        }
    }
}
