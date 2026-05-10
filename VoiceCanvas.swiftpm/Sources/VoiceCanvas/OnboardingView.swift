import SwiftUI

private let pages: [(icon: String, title: String, body: String, color: Color)] = [
    ("hand.draw.fill",      "Write Freely",      "Drag your finger on the white canvas.\nWrite naturally — no pressure on neatness.", AC.primary),
    ("text.viewfinder",     "AI Reads for You",  "Tap \"Read Text\" and Vision AI instantly\nconverts your handwriting into clear text.", Color(red:0.28,green:0.60,blue:0.90)),
    ("speaker.wave.3.fill", "Speaks for You",    "The app reads the text aloud so your\ncaregiver can hear without seeing the screen.", AC.success),
    ("bolt.fill",           "Quick Phrases",     "For everyday needs like water, medicine,\nor pain — just tap once.", AC.warning),
]

struct OnboardingView: View {
    @Binding var show: Bool
    @State private var page = 0

    var body: some View {
        ZStack {
            AC.background.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("Skip") { withAnimation(.spring()) { show = false } }
                        .font(.rounded(15)).foregroundColor(AC.textSecondary).padding()
                }
                Spacer()
                TabView(selection: $page) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        OBPage(icon: pages[i].icon, title: pages[i].title,
                               pageBody: pages[i].body, color: pages[i].color).tag(i)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never)).frame(height: 420)
                Spacer()
                // Dots
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Capsule()
                            .fill(i == page ? AC.primary : AC.primary.opacity(0.2))
                            .frame(width: i == page ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: page)
                    }
                }
                Spacer().frame(height: 28)
                Button {
                    if page < pages.count - 1 { withAnimation(.spring()) { page += 1 } }
                    else { withAnimation(.spring()) { show = false } }
                } label: {
                    Text(page < pages.count - 1 ? "Next" : "Get Started")
                        .font(.rounded(17, weight: .semibold)).foregroundColor(.white)
                        .frame(maxWidth: .infinity).frame(height: 56)
                        .background(RoundedRectangle(cornerRadius: AC.btnCorner).fill(AC.primary)
                            .shadow(color: AC.primary.opacity(0.35), radius: 10, x: 0, y: 5))
                }
                .padding(.horizontal, 32).padding(.bottom, 44)
            }
        }
    }
}

private struct OBPage: View {
    let icon: String; let title: String; let pageBody: String; let color: Color
    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                Circle().fill(color.opacity(0.12)).frame(width: 130, height: 130)
                Circle().fill(color.opacity(0.18)).frame(width: 100, height: 100)
                Image(systemName: icon).font(.system(size: 48, weight: .semibold)).foregroundColor(color)
            }
            VStack(spacing: 12) {
                Text(title).font(.rounded(28, weight: .bold))
                    .foregroundColor(AC.textPrimary).multilineTextAlignment(.center)
                Text(pageBody).font(.rounded(16))
                    .foregroundColor(AC.textSecondary).multilineTextAlignment(.center).lineSpacing(4)
            }
        }
        .padding(.horizontal, 32)
    }
}
