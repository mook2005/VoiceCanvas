import SwiftUI

let quickPhrases: [(emoji: String, text: String)] = [
    ("💧","Water"), ("🚽","Toilet"), ("😣","Pain"), ("💊","Medicine"),
    ("🍚","Hungry"), ("🥱","Sleepy"), ("🤒","Unwell"), ("📞","Call Doctor"),
    ("❤️","Thank you"), ("🙋","Call Nurse"), ("🌡️","Fever"), ("🤢","Nausea")
]

struct PhraseChip: View {
    let emoji: String
    let text: String
    let onTap: () -> Void
    @State private var pressed = false

    var body: some View {
        Button {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            onTap()
        } label: {
            HStack(spacing: 6) {
                Text(emoji).font(.system(size: 17))
                Text(text)
                    .font(.rounded(14, weight: .semibold))
                    .foregroundColor(AC.textPrimary)
                    .fixedSize()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                Capsule()
                    .fill(AC.canvas)
                    .shadow(color: AC.primary.opacity(pressed ? 0.18 : 0.09),
                            radius: pressed ? 2 : 5, x: 0, y: pressed ? 1 : 2)
            )
            .overlay(Capsule().stroke(AC.primary.opacity(pressed ? 0.35 : 0.13), lineWidth: 1.2))
            .scaleEffect(pressed ? 0.93 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.55), value: pressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded   { _ in pressed = false }
        )
    }
}

struct QuickPhrasesBar: View {
    let onSelect: (String) -> Void

    @State private var scrollProxy: ScrollViewProxy? = nil
    @State private var currentIndex: Int = 0

    private let chipWidth: CGFloat = 110
    private let visibleCount: Int = 4

    var body: some View {
        HStack(spacing: 0) {
            // ── Left arrow ──
            arrowButton(icon: "chevron.left", enabled: currentIndex > 0) {
                let next = max(currentIndex - visibleCount, 0)
                currentIndex = next
                withAnimation(.easeInOut(duration: 0.35)) {
                    scrollProxy?.scrollTo(next, anchor: .leading)
                }
            }

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(quickPhrases.enumerated()), id: \.offset) { index, p in
                            PhraseChip(emoji: p.emoji, text: p.text) { onSelect(p.text) }
                                .id(index)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                }
                .scrollIndicators(.never)
                .onAppear { scrollProxy = proxy }
            }
            
            arrowButton(icon: "chevron.right", enabled: currentIndex < quickPhrases.count - visibleCount) {
                let next = min(currentIndex + visibleCount, quickPhrases.count - 1)
                currentIndex = next
                withAnimation(.easeInOut(duration: 0.35)) {
                    scrollProxy?.scrollTo(next, anchor: .leading)
                }
            }
        }
        .frame(height: 54)
        .background(AC.background)
    }

    @ViewBuilder
    func arrowButton(icon: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(enabled ? AC.primary : AC.textSecondary.opacity(0.25))
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(enabled ? AC.primaryLight : Color.clear)
                )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!enabled)
        .padding(.horizontal, 6)
        .animation(.easeInOut(duration: 0.2), value: enabled)
    }
}
