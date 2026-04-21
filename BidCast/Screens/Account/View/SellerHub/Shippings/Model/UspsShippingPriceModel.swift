import Foundation

struct UspsShippingPriceModel: Codable {
    let id: Int?
    let name: String?
    let type: String?
    let shippingPrice: String?
    let length: String?
    let width: String?
    let height: String?
    let unit: String?
    let greatFor: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case shippingPrice = "shipping_price"
        case length
        case width
        case height
        case unit
        case greatFor = "great _for"
    }
}

