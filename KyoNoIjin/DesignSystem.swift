import SwiftUI

enum IjinTheme {
    static let ink = Color(hex: "111216")
    static let paper = Color(hex: "F6F0E5")
    static let brass = Color(hex: "D7A84D")
    static let cinnabar = Color(hex: "B84A3A")
    static let moss = Color(hex: "3C6F58")
    static let night = Color(hex: "171B25")
    static let slate = Color(hex: "2B3342")
    static let blueBlack = Color(hex: "101827")

    static var displayFont: Font { .system(.largeTitle, design: .serif, weight: .bold) }
    static var titleFont: Font { .system(.title2, design: .serif, weight: .bold) }
    static var bodyFont: Font { .system(.body, design: .serif) }
}

struct MuseumBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    IjinTheme.paper,
                    Color(hex: "E7D8BE"),
                    Color(hex: "C8B48F")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [Color.white.opacity(0.55), Color.clear],
                center: .topLeading,
                startRadius: 40,
                endRadius: 520
            )

            RadialGradient(
                colors: [IjinTheme.cinnabar.opacity(0.22), Color.clear],
                center: .bottomTrailing,
                startRadius: 20,
                endRadius: 460
            )

            TimelineGrid()
                .stroke(IjinTheme.ink.opacity(0.08), lineWidth: 1)
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }
}

struct TimelineGrid: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let spacing: CGFloat = 54

        var x = rect.minX - rect.height
        while x < rect.maxX + rect.height {
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x + rect.height, y: rect.maxY))
            x += spacing
        }

        var y = rect.minY
        while y < rect.maxY {
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
            y += spacing
        }

        return path
    }
}

struct BrassDivider: View {
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        IjinTheme.brass.opacity(0),
                        IjinTheme.brass,
                        IjinTheme.cinnabar,
                        IjinTheme.brass.opacity(0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(height: 1)
    }
}

struct FineBorder: ViewModifier {
    let cornerRadius: CGFloat
    let color: Color

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(color, lineWidth: 1)
            )
    }
}

extension View {
    func fineBorder(cornerRadius: CGFloat = 16, color: Color = IjinTheme.ink.opacity(0.12)) -> some View {
        modifier(FineBorder(cornerRadius: cornerRadius, color: color))
    }
}
