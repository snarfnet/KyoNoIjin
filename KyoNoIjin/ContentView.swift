import SwiftUI

struct ContentView: View {
    @EnvironmentObject var knowledgeStore: KnowledgeStore
    @StateObject private var viewModel = CardViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                MuseumBackground()

                VStack(spacing: 14) {
                    LevelHeaderView()

                    HStack(alignment: .firstTextBaseline) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.todayString)
                                .font(.system(.title3, design: .serif, weight: .bold))
                                .foregroundColor(IjinTheme.ink)
                            Text("今日、歴史に刻まれた人物")
                                .font(.caption)
                                .foregroundColor(IjinTheme.ink.opacity(0.62))
                        }
                        Spacer()
                        Text("\(viewModel.cards.count)枚")
                            .font(.caption.bold())
                            .foregroundColor(IjinTheme.paper)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Capsule().fill(IjinTheme.ink))
                    }
                    .padding(.horizontal, 4)

                    if viewModel.isLoading {
                        LoadingStateView()
                            .frame(maxHeight: .infinity)
                    } else if viewModel.cards.isEmpty {
                        EmptyStateView {
                            Task { await viewModel.loadCards() }
                        }
                        .frame(maxHeight: .infinity)
                    } else {
                        ZStack {
                            ForEach(Array(viewModel.cards.enumerated().reversed().prefix(3)), id: \.element.id) { index, card in
                                SwipeCardView(card: card, isTop: index == 0) { direction in
                                    knowledgeStore.recordSwipe(direction)
                                    withAnimation(.spring(response: 0.4)) {
                                        viewModel.removeTopCard()
                                    }
                                }
                                .offset(y: CGFloat(index) * 4)
                                .scaleEffect(1.0 - CGFloat(index) * 0.03)
                            }
                        }
                        .frame(maxHeight: .infinity)
                    }

                    HStack(spacing: 10) {
                        SwipeHint(title: "知らなかった", icon: "arrow.left", color: IjinTheme.cinnabar)
                        Spacer()
                        SwipeHint(title: "知ってた", icon: "arrow.right", color: IjinTheme.moss)
                    }
                    .padding(.horizontal, 6)

                    StatsBarView()

                    BannerAdView()
                        .frame(height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .fineBorder(cornerRadius: 8, color: IjinTheme.ink.opacity(0.12))
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)
                .padding(.bottom, 8)

                if knowledgeStore.showLevelUp {
                    LevelUpOverlay()
                }
            }
            .navigationBarHidden(true)
        }
        .task {
            await viewModel.loadCards()
        }
    }
}

struct LoadingStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(IjinTheme.cinnabar)
                .scaleEffect(1.3)
            Text("今日の人物を収集中")
                .font(.system(.headline, design: .serif, weight: .bold))
                .foregroundColor(IjinTheme.ink)
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(IjinTheme.paper.opacity(0.72))
                .shadow(color: IjinTheme.ink.opacity(0.12), radius: 24, y: 14)
        )
        .fineBorder(cornerRadius: 18)
    }
}

struct EmptyStateView: View {
    let reload: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 54, weight: .bold))
                .foregroundColor(IjinTheme.moss)

            VStack(spacing: 6) {
                Text("本日分は読了")
                    .font(IjinTheme.titleFont)
                    .foregroundColor(IjinTheme.ink)
                Text("明日の朝、また新しい人物が届きます。")
                    .font(.subheadline)
                    .foregroundColor(IjinTheme.ink.opacity(0.62))
                    .multilineTextAlignment(.center)
            }

            Button(action: reload) {
                Label("もう一度読み込む", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundColor(IjinTheme.paper)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(IjinTheme.ink))
            }
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(IjinTheme.paper.opacity(0.78))
                .shadow(color: IjinTheme.ink.opacity(0.18), radius: 28, y: 16)
        )
        .fineBorder(cornerRadius: 20)
    }
}

struct SwipeHint: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        Label(title, systemImage: icon)
            .font(.caption.bold())
            .foregroundColor(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(color.opacity(0.12)))
            .fineBorder(cornerRadius: 999, color: color.opacity(0.22))
    }
}

// MARK: - Card ViewModel
@MainActor
class CardViewModel: ObservableObject {
    @Published var cards: [PersonCard] = []
    @Published var isLoading = false

    var todayString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: Date())
    }

    func loadCards() async {
        isLoading = true
        do {
            cards = try await WikipediaService.shared.fetchTodaysPeople()
        } catch {
            print("Error loading cards: \(error)")
        }
        isLoading = false
    }

    func removeTopCard() {
        guard !cards.isEmpty else { return }
        cards.removeFirst()
    }
}
