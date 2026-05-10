import Vision
import UIKit
import AVFoundation
import SwiftUI

class OCRService {
    static func recognize(image: UIImage, completion: @escaping (String) -> Void) {
        guard let cg = image.cgImage else { completion(""); return }
        let req = VNRecognizeTextRequest { req, _ in
            let text = (req.results as? [VNRecognizedTextObservation] ?? [])
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: " ")
            DispatchQueue.main.async { completion(text) }
        }
        req.recognitionLanguages = ["en-US"]
        req.recognitionLevel = .accurate
        req.usesLanguageCorrection = true
        DispatchQueue.global(qos: .userInitiated).async {
            try? VNImageRequestHandler(cgImage: cg, options: [:]).perform([req])
        }
    }
}

class CanvasRenderer {
    static func render(strokes: [DrawingStroke], size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { ctx in
            ctx.cgContext.setFillColor(UIColor.white.cgColor)
            ctx.cgContext.fill(CGRect(origin: .zero, size: size))
            for stroke in strokes {
                guard stroke.points.count > 1 else { continue }
                let path = UIBezierPath()
                path.move(to: stroke.points[0])
                for i in 1..<stroke.points.count {
                    let a = stroke.points[i-1], b = stroke.points[i]
                    path.addQuadCurve(to: CGPoint(x: (a.x+b.x)/2, y: (a.y+b.y)/2), controlPoint: a)
                }
                path.addLine(to: stroke.points.last!)
                path.lineWidth = stroke.lineWidth
                path.lineCapStyle = .round
                path.lineJoinStyle = .round
                UIColor(AC.stroke).setStroke()
                path.stroke()
            }
        }
    }
}

@MainActor
final class SpeechService: NSObject, ObservableObject {
    private let synth = AVSpeechSynthesizer()
    @Published var isSpeaking = false

    override init() {
        super.init()
        synth.delegate = self
    }

    func speak(_ text: String) {
        guard !text.isEmpty else { return }
        if synth.isSpeaking { synth.stopSpeaking(at: .immediate) }
        let u = AVSpeechUtterance(string: text)
        u.voice = AVSpeechSynthesisVoice(language: "en-US")
        u.rate = 0.50
        u.pitchMultiplier = 1.05
        u.volume = 1.0
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {}
        isSpeaking = true
        synth.speak(u)
    }

    func stop() {
        synth.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
}

extension SpeechService: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(
        _ synthesizer: AVSpeechSynthesizer,
        didFinish utterance: AVSpeechUtterance
    ) {
        Task { @MainActor in self.isSpeaking = false }
    }
}
