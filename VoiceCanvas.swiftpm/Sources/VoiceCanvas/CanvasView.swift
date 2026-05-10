import SwiftUI

struct CanvasView: View {
    @ObservedObject var model: CanvasModel

    var body: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: AC.corner)
                    .fill(AC.canvas)
                    .shadow(color: AC.primary.opacity(0.08), radius: 20, x: 0, y: 8)

                GridLines()
                    .clipShape(RoundedRectangle(cornerRadius: AC.corner))

                Canvas { ctx, _ in
                    (model.strokes + [model.currentStroke].compactMap { $0 })
                        .forEach { drawStroke($0, ctx: ctx) }
                }
                .clipShape(RoundedRectangle(cornerRadius: AC.corner))

                if model.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "hand.draw")
                            .font(.system(size: geo.size.width > 500 ? 64 : 48, weight: .ultraLight))
                            .foregroundColor(AC.primary.opacity(0.18))

                        VStack(spacing: 6) {
                            Text("Write here")
                                .font(.rounded(geo.size.width > 500 ? 22 : 18, weight: .semibold))
                                .foregroundColor(AC.textSecondary.opacity(0.32))
                            Text("Drag your finger on the white area")
                                .font(.rounded(geo.size.width > 500 ? 15 : 13, weight: .regular))
                                .foregroundColor(AC.textSecondary.opacity(0.22))
                        }
                    }
                    .allowsHitTesting(false)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { v in
                        if model.currentStroke == nil { model.beginStroke(at: v.location) }
                        else { model.addPoint(v.location) }
                    }
                    .onEnded { _ in model.endStroke() }
            )
            .onAppear { model.canvasSize = geo.size }
            .onChange(of: geo.size.width) { _ in model.canvasSize = geo.size }
        }
    }

    private func drawStroke(_ stroke: DrawingStroke, ctx: GraphicsContext) {
        guard stroke.points.count > 1 else {
            if let p = stroke.points.first {
                ctx.fill(Path(ellipseIn: CGRect(
                    x: p.x - stroke.lineWidth / 2, y: p.y - stroke.lineWidth / 2,
                    width: stroke.lineWidth, height: stroke.lineWidth)),
                         with: .color(AC.stroke))
            }
            return
        }
        var path = Path()
        path.move(to: stroke.points[0])
        for i in 1..<stroke.points.count {
            let a = stroke.points[i-1], b = stroke.points[i]
            path.addQuadCurve(to: CGPoint(x: (a.x+b.x)/2, y: (a.y+b.y)/2), control: a)
        }
        path.addLine(to: stroke.points.last!)
        ctx.stroke(path, with: .color(AC.stroke),
                   style: StrokeStyle(lineWidth: stroke.lineWidth, lineCap: .round, lineJoin: .round))
    }
}

struct GridLines: View {
    var body: some View {
        Canvas { ctx, size in
            let color = Color(red: 0.88, green: 0.89, blue: 0.96)
            var y: CGFloat = 44
            while y < size.height {
                var p = Path()
                p.move(to: CGPoint(x: 0, y: y))
                p.addLine(to: CGPoint(x: size.width, y: y))
                ctx.stroke(p, with: .color(color), lineWidth: 0.5)
                y += 44
            }
        }
    }
}
