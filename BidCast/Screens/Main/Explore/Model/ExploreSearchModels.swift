import Foundation

struct ExploreSearchResponse: Codable {
    let status: String?
    let message: String?
    let errorType: String?
    let data: ExploreSearchData?

    enum CodingKeys: String, CodingKey {
        case status, message, data
        case errorType = "error_type"
    }
}

struct ExploreSearchData: Codable {
    let shows: [Show?]?
    let products: [ExploreSearchProduct?]?
    let users: [SearchUserEntry?]?
}

struct ExploreSearchProduct: Codable {
    let id: Int?
    let image: String?
    let name: String?
    let price: String?
    let user: ExploreSearchProductUser?
}

struct ExploreSearchProductUser: Codable {
    let id: Int?
    let name: String?
}
