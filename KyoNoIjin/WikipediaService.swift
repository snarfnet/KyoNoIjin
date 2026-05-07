import Foundation

class WikipediaService {
    static let shared = WikipediaService()

    private let baseURL = "https://api.wikimedia.org/feed/v1/wikipedia"

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
        request.setValue("KyoNoIjin/1.0 (iOS App; contact: dev@example.com)", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
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
