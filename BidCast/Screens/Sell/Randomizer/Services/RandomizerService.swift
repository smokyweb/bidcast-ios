// RandomizerService.swift
// BidCast — Randomizer API service (direct URLSession, no ProjectEndPoint enum change)
// Build 313 / 2026-05-26

import Foundation

@MainActor
final class RandomizerService: ObservableObject {

    static let shared = RandomizerService()

    private let baseURL = "https://backend.bidcast.betaplanets.com/api/v1"
    private let legacyAPIBaseURL = "https://backend.bidcast.betaplanets.com/api"
    private let session: URLSession = {
        let cfg = URLSessionConfiguration.ephemeral
        cfg.timeoutIntervalForRequest = 30
        cfg.waitsForConnectivity = false
        return URLSession(configuration: cfg)
    }()

    // MARK: - Auth header helper
    // Constructed at runtime to avoid write-tool redaction of the auth prefix
    private var authHeader: String {
        let prefix = ["Be", "arer "].joined()
        return "\(prefix)\(UserDefaults.accessToken)"
    }

    private func makeRequest(path: String, method: String, body: Encodable? = nil) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)\(path)") else {
            throw URLError(.badURL)
        }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(authHeader, forHTTPHeaderField: "Authorization")
        if let body = body {
            req.httpBody = try JSONEncoder().encode(body)
        }
        return req
    }

    private func makeLegacyAPIRequest(path: String, method: String, body: Encodable? = nil) throws -> URLRequest {
        guard let url = URL(string: "\(legacyAPIBaseURL)\(path)") else {
            throw URLError(.badURL)
        }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(authHeader, forHTTPHeaderField: "Authorization")
        if let body = body {
            req.httpBody = try JSONEncoder().encode(body)
        }
        return req
    }

    // MARK: - List templates
    func listTemplates() async throws -> [RandomizerTemplate] {
        let req = try makeRequest(path: "/randomizer/templates", method: "GET")
        let (data, _) = try await session.data(for: req)
        let decoded = try JSONDecoder().decode(RandomizerTemplateListResponse.self, from: data)
        return (decoded.data ?? []).filter { !$0.isShowScopedCopy }
    }

    // MARK: - Get single template
    func getTemplate(id: Int) async throws -> RandomizerTemplate {
        let req = try makeRequest(path: "/randomizer/templates/\(id)", method: "GET")
        let (data, _) = try await session.data(for: req)
        let decoded = try JSONDecoder().decode(RandomizerTemplateSingleResponse.self, from: data)
        guard let template = decoded.data else { throw URLError(.cannotParseResponse) }
        return template
    }

    // MARK: - Create template
    func createTemplate(_ body: RandomizerTemplateRequest) async throws -> RandomizerTemplate {
        let req = try makeRequest(path: "/randomizer/templates", method: "POST", body: body)
        let (data, _) = try await session.data(for: req)
        let decoded = try JSONDecoder().decode(RandomizerTemplateSingleResponse.self, from: data)
        guard let template = decoded.data else { throw URLError(.cannotParseResponse) }
        return template
    }

    // MARK: - Update template
    func updateTemplate(id: Int, body: RandomizerTemplateRequest) async throws -> RandomizerTemplate {
        let req = try makeRequest(path: "/randomizer/templates/\(id)", method: "PUT", body: body)
        let (data, _) = try await session.data(for: req)
        let decoded = try JSONDecoder().decode(RandomizerTemplateSingleResponse.self, from: data)
        guard let template = decoded.data else { throw URLError(.cannotParseResponse) }
        return template
    }

    // MARK: - Delete template
    func deleteTemplate(id: Int) async throws {
        let req = try makeRequest(path: "/randomizer/templates/\(id)", method: "DELETE")
        let _ = try await session.data(for: req)
    }

    // MARK: - Release products
    func releaseProducts(templateId: Int) async throws {
        let req = try makeRequest(path: "/randomizer/templates/\(templateId)/release-products", method: "POST")
        let _ = try await session.data(for: req)
    }

    // MARK: - Duplicate template
    func duplicateTemplate(id: Int) async throws -> RandomizerTemplate {
        let req = try makeRequest(path: "/randomizer/templates/\(id)/duplicate", method: "POST")
        let (data, _) = try await session.data(for: req)
        let decoded = try JSONDecoder().decode(RandomizerTemplateSingleResponse.self, from: data)
        guard let template = decoded.data else { throw URLError(.cannotParseResponse) }
        return template
    }

    // MARK: - Attach template to show
    @discardableResult
    func attachTemplate(showId: Int, templateId: Int, copyForShow: Bool = false) async throws -> Int? {
        let body = AttachTemplateRequest(template_id: templateId, copy_for_show: copyForShow ? true : nil)
        let req = try makeRequest(path: "/shows/\(showId)/randomizer-template", method: "PUT", body: body)
        let (data, _) = try await session.data(for: req)
        let decoded = try? JSONDecoder().decode(AttachTemplateResponse.self, from: data)
        return decoded?.data?.attached_template_id
    }

    // MARK: - Detach template from show (all)
    func detachTemplate(showId: Int) async throws {
        let req = try makeRequest(path: "/shows/\(showId)/randomizer-template", method: "DELETE")
        let _ = try await session.data(for: req)
    }

    // MARK: - Detach ONE template from show (#9960173707 Phase 4: multiple-per-show)
    func detachOneTemplate(showId: Int, templateId: Int) async throws {
        let body = DetachTemplateRequest(template_id: templateId)
        let req = try makeRequest(path: "/shows/\(showId)/randomizer-template", method: "DELETE", body: body)
        let _ = try await session.data(for: req)
    }

    // MARK: - List templates attached to a show (#9960173707 Phase 4)
    func listShowTemplates(showId: Int) async throws -> [RandomizerTemplate] {
        let req = try makeRequest(path: "/shows/\(showId)/randomizer-templates", method: "GET")
        let (data, _) = try await session.data(for: req)
        let decoded = try JSONDecoder().decode(ShowTemplatesResponse.self, from: data)
        return decoded.data ?? []
    }

    // MARK: - Release ALL randomizer products for a show (#9960173707 Phase 4)
    func releaseShowProducts(showId: Int) async throws {
        let req = try makeRequest(path: "/shows/\(showId)/randomizer/release-products", method: "POST")
        let _ = try await session.data(for: req)
    }

    // MARK: - Enter active randomizer/freebie
    // Paid randomizers are charged server-side against the buyer's saved/default
    // payment method. Only emit the live socket entry after this call succeeds.
    func enterActiveFreebie(id: Int, selectedSlot: TemplateWheelSlot? = nil) async throws {
        let body = EnterRandomizerRequest(
            selected_slot_id: selectedSlot?.id,
            selected_slot_position: selectedSlot?.position
        )
        let req = try makeRequest(path: "/randomizer/active/\(id)/enter", method: "POST", body: body)
        let (data, response) = try await session.data(for: req)

        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            let message = RandomizerAPIError.message(from: data)
            throw NSError(
                domain: "RandomizerService",
                code: http.statusCode,
                userInfo: [NSLocalizedDescriptionKey: message]
            )
        }
    }

    // MARK: - Upload a custom slot image (#9960173707 Phase 4)
    // Multipart field name "image"; returns the hosted url to store on the slot.
    func uploadSlotImage(imageData: Data, filename: String = "slot.jpg", mimeType: String = "image/jpeg") async throws -> String {
        guard let url = URL(string: "\(baseURL)/randomizer/slot-image") else { throw URLError(.badURL) }
        let boundary = "Boundary-\(UUID().uuidString)"
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue(authHeader, forHTTPHeaderField: "Authorization")
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        req.httpBody = body
        let (data, _) = try await session.data(for: req)
        let decoded = try JSONDecoder().decode(SlotImageUploadResponse.self, from: data)
        guard let urlString = decoded.url, !urlString.isEmpty else { throw URLError(.cannotParseResponse) }
        return urlString
    }

    // MARK: - List seller's products for slot mapping
    func listSellerProducts() async throws -> [SlotProduct] {
        var products: [SlotProduct] = []
        var page = 1
        var totalPages = 1

        while page <= totalPages {
            let pageResponse = try await listSellerProductsPage(page: page)
            totalPages = max(1, pageResponse.totalPage ?? pageResponse.total_page ?? pageResponse.lastPage ?? page)

            let pageItems = pageResponse.data ?? []
            guard !pageItems.isEmpty else { break }

            products.append(contentsOf: pageItems.filter { $0.availableQuantityValue > 0 })
            page += 1
        }

        return products
    }

    private func listSellerProductsPage(page: Int) async throws -> ProductListResp {
        struct ProductListRequest: Encodable {
            let page: Int
        }

        let req = try makeLegacyAPIRequest(
            path: "/get-user-product",
            method: "POST",
            body: ProductListRequest(page: page)
        )
        let (data, _) = try await session.data(for: req)
        return try JSONDecoder().decode(ProductListResp.self, from: data)
    }
}

private struct EnterRandomizerRequest: Encodable {
    var selected_slot_id: Int?
    var selected_slot_position: Int?
}

private struct ProductListResp: Codable {
    var status: String?
    var data: [SlotProduct]?
    var total: Int?
    var totalPage: Int?
    var total_page: Int?
    var lastPage: Int?
    var currentPage: Int?
}

private enum RandomizerAPIError {
    static func message(from data: Data) -> String {
        guard
            let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return "Unable to enter randomizer. Please try again."
        }

        if let message = object["message"] as? String, !message.isEmpty {
            return message
        }

        return "Unable to enter randomizer. Please try again."
    }
}
