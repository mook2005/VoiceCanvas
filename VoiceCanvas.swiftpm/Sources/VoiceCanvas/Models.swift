import SwiftUI

struct DrawingStroke: Identifiable {
    let id = UUID()
    var points: [CGPoint] = []
    var lineWidth: CGFloat = AC.strokeWidth
}

struct HistoryEntry: Identifiable {
    let id = UUID()
    let text: String
    let date = Date()
    var timeString: String {
        let f = DateFormatter(); f.timeStyle = .short; return f.string(from: date)
    }
}

class CanvasModel: ObservableObject {
    @Published var strokes: [DrawingStroke] = []
    @Published var currentStroke: DrawingStroke?
    @Published var recognizedText = ""
    @Published var isRecognizing = false
    @Published var history: [HistoryEntry] = []
    @Published var strokeWidth: CGFloat = 8
    var canvasSize: CGSize = .zero

    var isEmpty: Bool { strokes.isEmpty && currentStroke == nil }

    func beginStroke(at point: CGPoint) {
        var s = DrawingStroke(lineWidth: strokeWidth)
        s.points.append(point)
        currentStroke = s
    }
    func addPoint(_ point: CGPoint) { currentStroke?.points.append(point) }
    func endStroke() {
        if let s = currentStroke, s.points.count > 1 { strokes.append(s) }
        currentStroke = nil
    }
    func undo() { if !strokes.isEmpty { strokes.removeLast() } }
    func clear() { strokes = []; currentStroke = nil; recognizedText = "" }
    func addHistory(_ text: String) {
        history.insert(HistoryEntry(text: text), at: 0)
        if history.count > 30 { history.removeLast() }
    }
}
