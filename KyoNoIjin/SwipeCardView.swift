import SwiftUI

struct SwipeCardView: View {
    let card: PersonCard
    let isTop: Bool
    let onSwipe: (SwipeDirection) -> Void

    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0

    private var swipeThreshold: CGFloat { 120 }

    private var swipeIndicator: some View {
        Group {
            if offset.width > 40 {
                SwipeStamp(text: "知ってた", icon: "checkmark.circle.fill", color: IjinTheme.moss)
                    .rotationEffect(.degrees(-15))
            } else if offset.width < -40 {
                SwipeStamp(text: "知らなかった", icon: "sparkle.magnifyingglass", color: IjinTheme.cinnabar)
                    .rotationEffect(.degrees(15))
            }
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [IjinTheme.paper, Color(hex: "ECE0C8")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: IjinTheme.ink.opacity(0.22), radius: 26, y: 18)

            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(IjinTheme.ink.opacity(0.16), lineWidth: 1)

            VStack(spacing: 0) {
                Rectangle()
                    .fill(card.type == .birth ? IjinTheme.moss : IjinTheme.cinnabar)
                    .frame(height: 7)
                Spacer()
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))

            VStack(spacing: 16) {
                HStack {
                    Label(card.type.label, systemImage: card.type == .birth ? "sunrise.fill" : "moon.stars.fill")
                        .font(.caption.bold())
                        .foregroundColor(IjinTheme.paper)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(
                            Capsule()
                                .fill(card.type == .birth ? IjinTheme.moss : IjinTheme.cinnabar)
                        )
                    Spacer()
                    Text(card.year)
                        .font(.system(.headline, design: .serif, weight: .bold))
                        .foregroundColor(IjinTheme.ink.opacity(0.72))
                }

                portrait

                Text(card.name)
                    .font(.system(.title, design: .serif, weight: .bold))
                    .foregroundColor(IjinTheme.ink)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)

                Text(card.description)
                    .font(IjinTheme.bodyFont)
                    .foregroundColor(IjinTheme.ink.opacity(0.78))
                    .lineLimit(4)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)

                BrassDivider()

                if let wikiURL = card.wikiURL, let url = URL(string: wikiURL) {
                    Link(destination: url) {
                        Label("Wikipediaで読む", systemImage: "safari.fill")
                            .font(.caption.bold())
                            .foregroundColor(IjinTheme.ink.opacity(0.72))
                    }
                }

                Spacer()
            }
            .padding(20)

            swipeIndicator
        }
        .frame(height: 456)
        .padding(.horizontal, 8)
        .offset(x: offset.width, y: offset.height * 0.3)
        .rotationEffect(.degrees(rotation))
        .gesture(
            DragGesture()
                .onChanged { value in
                    guard isTop else { return }
                    offset = value.translation
                    rotation = Double(value.translation.width / 20)
                }
                .onEnded { value in
                    guard isTop else { return }
                    if value.translation.width > swipeThreshold {
                        withAnimation(.easeOut(duration: 0.3)) {
                            offset.width = 500
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.onSwipe(.right)
                            self.offset = .zero
                            self.rotation = 0
                        }
                    } else if value.translation.width < -swipeThreshold {
                        withAnimation(.easeOut(duration: 0.3)) {
                            offset.width = -500
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            self.onSwipe(.left)
                            self.offset = .zero
                            self.rotation = 0
                        }
                    } else {
                        withAnimation(.spring()) {
                            offset = .zero
                            rotation = 0
                        }
                    }
                }
        )
    }

    private var portrait: some View {
        ZStack {
            if let imageURL = card.imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        placeholderImage
                    default:
                        ProgressView()
                            .tint(IjinTheme.cinnabar)
                    }
                }
            } else {
                placeholderImage
            }
        }
        .frame(height: 174)
        .frame(maxWidth: .infinity)
        .background(IjinTheme.ink.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(IjinTheme.ink.opacity(0.14), lineWidth: 1)
        )
    }

    private var placeholderImage: some View {
        ZStack {
            LinearGradient(
                colors: [IjinTheme.slate.opacity(0.2), IjinTheme.brass.opacity(0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            TimelineGrid()
                .stroke(IjinTheme.ink.opacity(0.08), lineWidth: 1)
                Image(systemName: "person.fill")
                    .font(.system(size: 50))
                    .foregroundColor(IjinTheme.ink.opacity(0.24))
        }
    }
}

struct SwipeStamp: View {
    let text: String
    let icon: String
    let color: Color

    var body: some View {
        Label(text, systemImage: icon)
            .font(.system(.title3, design: .serif, weight: .bold))
            .foregroundColor(color)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(IjinTheme.paper.opacity(0.9))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(color, lineWidth: 2)
            )
            .shadow(color: color.opacity(0.2), radius: 14, y: 8)
    }
}
