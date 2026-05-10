import Foundation

class WikipediaService {
    static let shared = WikipediaService()

    private let baseURL = "https://api.wikimedia.org/feed/v1/wikipedia"

    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        return URLSession(configuration: config)
    }()

    func fetchTodaysPeople(language: String = "ja") async throws -> [PersonCard] {
        let calendar = Calendar.current
        let now = Date()
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)

        let urlString = "\(baseURL)/\(language)/onthisday/all/\(String(format: "%02d", month))/\(String(format: "%02d", day))"

        guard let url = URL(string: urlString) else {
            throw WikiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("KyoNoIjin/1.0 (https://snarfnet.github.io/; contact: app@snarfnet.dev)", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            print("WikipediaService: HTTP \(statusCode) for \(urlString)")
            throw WikiError.serverError
        }

        let decoded = try JSONDecoder().decode(OnThisDayResponse.self, from: data)

        var cards: [PersonCard] = []

        // Births
        if let births = decoded.births {
            let selected = births.prefix(10).compactMap { event -> PersonCard? in
                guard let page = event.pages?.first else { return nil }
                return PersonCard(
                    name: page.title,
                    year: event.displayYear,
                    description: page.extract ?? event.text,
                    imageURL: page.thumbnail?.source,
                    wikiURL: page.contentUrls?.mobile?.page,
                    type: .birth
                )
            }
            cards.append(contentsOf: selected)
        }

        // Deaths
        if let deaths = decoded.deaths {
            let selected = deaths.prefix(10).compactMap { event -> PersonCard? in
                guard let page = event.pages?.first else { return nil }
                return PersonCard(
                    name: page.title,
                    year: event.displayYear,
                    description: page.extract ?? event.text,
                    imageURL: page.thumbnail?.source,
                    wikiURL: page.contentUrls?.mobile?.page,
                    type: .death
                )
            }
            cards.append(contentsOf: selected)
        }

        return cards.shuffled()
    }
}

enum WikiError: Error, LocalizedError {
    case invalidURL
    case serverError
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "URLが無効です"
        case .serverError: return "サーバーエラー"
        case .decodingError: return "データの解析に失敗"
        }
    }
}

// MARK: - Fallback Data (API失敗時に表示)
extension WikipediaService {
    static func fallbackCards(for month: Int, day: Int) -> [PersonCard] {
        let allFallback: [(String, String, String, PersonCard.PersonType)] = [
            ("レオナルド・ダ・ヴィンチ", "1452年", "イタリアの芸術家・発明家。モナ・リザや最後の晩餐で知られる万能の天才。", .birth),
            ("アルベルト・アインシュタイン", "1879年", "相対性理論を提唱した理論物理学者。ノーベル物理学賞受賞。", .birth),
            ("マリー・キュリー", "1867年", "放射能の研究で2度のノーベル賞を受賞したポーランド出身の物理学者・化学者。", .birth),
            ("ウィリアム・シェイクスピア", "1564年", "イギリスの劇作家・詩人。ハムレットやロミオとジュリエットなど数々の名作を残した。", .birth),
            ("モーツァルト", "1756年", "オーストリアの作曲家。5歳で作曲を始め、35年の短い生涯で600曲以上を作曲。", .birth),
            ("ガリレオ・ガリレイ", "1564年", "イタリアの天文学者・物理学者。望遠鏡で天体を観測し地動説を支持した。", .birth),
            ("ナイチンゲール", "1820年", "イギリスの看護師。クリミア戦争で活躍し、近代看護の基礎を築いた。", .birth),
            ("チャールズ・ダーウィン", "1809年", "イギリスの自然科学者。進化論を提唱し、種の起源を著した。", .birth),
            ("織田信長", "1534年", "戦国時代の武将。天下統一を目指し、桶狭間の戦いなどで名を馳せた。", .birth),
            ("紫式部", "978年頃", "平安時代の作家。世界最古の長編小説とされる源氏物語の著者。", .birth),
            ("葛飾北斎", "1760年", "江戸時代の浮世絵師。富嶽三十六景の神奈川沖浪裏は世界的に有名。", .birth),
            ("手塚治虫", "1928年", "日本の漫画家。鉄腕アトムやブラック・ジャックなど多数の名作を生み出した漫画の神様。", .birth),
            ("クレオパトラ", "紀元前69年", "古代エジプト最後のファラオ。政治的手腕と美貌で知られる。", .birth),
            ("ベートーヴェン", "1770年", "ドイツの作曲家。聴力を失いながらも第九交響曲などの傑作を生み出した。", .birth),
            ("ニコラ・テスラ", "1856年", "セルビア出身の発明家。交流電力システムの発明者として知られる。", .birth),
            ("宮沢賢治", "1896年", "日本の詩人・童話作家。銀河鉄道の夜や注文の多い料理店の著者。", .birth),
            ("ピカソ", "1881年", "スペインの画家。キュビスムの創始者の一人でゲルニカなどの作品で知られる。", .birth),
            ("ガンジー", "1869年", "インド独立の父。非暴力・不服従運動を指導し、インドの独立を達成した。", .birth),
            ("坂本龍馬", "1836年", "幕末の志士。薩長同盟の仲介や大政奉還に尽力した。", .birth),
            ("ヘレン・ケラー", "1880年", "アメリカの教育者・社会活動家。視力と聴力を失いながらも世界に希望を与えた。", .birth),
        ]

        // Use date as seed for consistent daily shuffle
        let seed = month * 100 + day
        var rng = SeededRNG(seed: UInt64(seed))
        let shuffled = allFallback.shuffled(using: &rng)
        let selected = Array(shuffled.prefix(10))

        return selected.map { item in
            PersonCard(name: item.0, year: item.1, description: item.2,
                       imageURL: nil, wikiURL: nil, type: item.3)
        }
    }
}

struct SeededRNG: RandomNumberGenerator {
    private var state: UInt64
    init(seed: UInt64) { state = seed }
    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}
