import Foundation

// Wikipedia On This Day API response models
struct OnThisDayResponse: Codable {
    let births: [OnThisDayEvent]?
    let deaths: [OnThisDayEvent]?
}

struct OnThisDayEvent: Codable, Identifiable {
    let text: String
    let year: Int?
    let pages: [WikiPage]?

    var id: String { "\(text)_\(year ?? 0)" }

    var displayYear: String {
        guard let year = year else { return "?" }
        if year < 0 {
            return "紀元前\(abs(year))年"
        }
        return "\(year)年"
    }
}

struct WikiPage: Codable {
    let title: String
    let extract: String?
    let thumbnail: WikiThumbnail?
    let contentUrls: ContentUrls?

    enum CodingKeys: String, CodingKey {
        case title, extract, thumbnail
        case contentUrls = "content_urls"
    }
}

struct WikiThumbnail: Codable {
    let source: String
    let width: Int
    let height: Int
}

struct ContentUrls: Codable {
    let mobile: UrlInfo?
    let desktop: UrlInfo?
}

struct UrlInfo: Codable {
    let page: String?
}

// Person card model for display
struct PersonCard: Identifiable {
    let id = UUID()
    let name: String
    let year: String
    let description: String
    let imageURL: String?
    let wikiURL: String?
    let type: PersonType

    enum PersonType {
        case birth
        case death

        var label: String {
            switch self {
            case .birth: return "誕生"
            case .death: return "没"
            }
        }

        var emoji: String {
            switch self {
            case .birth: return "🎂"
            case .death: return "🕯️"
            }
        }
    }
}

// Swipe result
enum SwipeDirection {
    case left  // 知らなかった
    case right // 知ってた
}
