import SwiftUI

struct LevelHeaderView: View {
    @EnvironmentObject var knowledgeStore: KnowledgeStore

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(IjinTheme.ink)
                    Text("\(knowledgeStore.level)")
                        .font(.system(.title3, design: .serif, weight: .bold))
                        .foregroundColor(IjinTheme.brass)
                }
                .frame(width: 48, height: 48)
                .overlay(Circle().stroke(IjinTheme.brass.opacity(0.6), lineWidth: 1))

                VStack(alignment: .leading, spacing: 2) {
                    Text(knowledgeStore.levelTitle)
                        .font(.system(.headline, design: .serif, weight: .bold))
                        .foregroundColor(IjinTheme.ink)

                    if knowledgeStore.streak > 2 {
                        Text("\(knowledgeStore.streak)連続で知ってた")
                            .font(.caption)
                            .foregroundColor(IjinTheme.cinnabar)
                    } else {
                        Text("Lv.\(knowledgeStore.level)  歴史レコード")
                            .font(.caption)
                            .foregroundColor(IjinTheme.ink.opacity(0.55))
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("今日の偉人")
                        .font(.system(.headline, design: .serif, weight: .bold))
                        .foregroundColor(IjinTheme.ink)
                    Text("誕生 / 没")
                        .font(.caption)
                        .foregroundColor(IjinTheme.ink.opacity(0.55))
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(IjinTheme.ink.opacity(0.12))

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [IjinTheme.cinnabar, IjinTheme.brass],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * knowledgeStore.progress)
                        .animation(.easeOut(duration: 0.3), value: knowledgeStore.progress)
                }
            }
            .frame(height: 6)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(IjinTheme.paper.opacity(0.76))
                .shadow(color: IjinTheme.ink.opacity(0.1), radius: 18, y: 10)
        )
        .fineBorder(cornerRadius: 18)
    }
}

struct StatsBarView: View {
    @EnvironmentObject var knowledgeStore: KnowledgeStore

    var body: some View {
        HStack(spacing: 10) {
            StatItem(label: "知ってた", value: "\(knowledgeStore.totalKnown)", color: IjinTheme.moss)
            StatItem(label: "知らなかった", value: "\(knowledgeStore.totalUnknown)", color: IjinTheme.cinnabar)
            StatItem(label: "知識率", value: "\(Int(knowledgeStore.knowledgeRate * 100))%", color: IjinTheme.ink)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(IjinTheme.paper.opacity(0.72))
                .shadow(color: IjinTheme.ink.opacity(0.08), radius: 14, y: 8)
        )
        .fineBorder(cornerRadius: 16)
    }
}

struct StatItem: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(.headline, design: .serif, weight: .bold))
                .foregroundColor(color)
                .minimumScaleFactor(0.75)
            Text(label)
                .font(.caption2)
                .foregroundColor(IjinTheme.ink.opacity(0.56))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

struct LevelUpOverlay: View {
    @EnvironmentObject var knowledgeStore: KnowledgeStore

    var body: some View {
        ZStack {
            IjinTheme.ink.opacity(0.68)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image(systemName: "seal.fill")
                    .font(.system(size: 60))
                    .foregroundColor(IjinTheme.brass)

                Text("Lv.\(knowledgeStore.level)")
                    .font(.system(size: 58, weight: .bold, design: .serif))
                    .foregroundColor(IjinTheme.ink)

                Text(knowledgeStore.levelTitle)
                    .font(IjinTheme.titleFont)
                    .foregroundColor(IjinTheme.cinnabar)

                Button("OK") {
                    withAnimation {
                        knowledgeStore.showLevelUp = false
                    }
                }
                .font(.headline)
                .foregroundColor(IjinTheme.paper)
                .padding(.horizontal, 40)
                .padding(.vertical, 12)
                .background(IjinTheme.ink)
                .cornerRadius(25)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(IjinTheme.paper)
                    .shadow(color: IjinTheme.brass.opacity(0.3), radius: 20)
            )
            .fineBorder(cornerRadius: 20, color: IjinTheme.brass.opacity(0.55))
        }
        .transition(.opacity)
        .onTapGesture {
            withAnimation {
                knowledgeStore.showLevelUp = false
            }
        }
    }
}
