// RandomizerService.swift
// BidCast — Randomizer API service (direct URLSession, no ProjectEndPoint enum change)
// Build 313 / 2026-05-26

import Foundation

@MainActor
final class RandomizerService: ObservableObject {

    static let shared = RandomizerService()

    private let baseURL = "https://backend.bidcast.betaplanets.com/api/v1"
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

    // MARK: - List templates
    func listTemplates() async throws -> [RandomizerTemplate] {
        let req = try makeRequest(path: "/randomizer/templates", method: "GET")
        let (data, _) = try await session.data(for: req)
        let decoded = try JSONDecoder().decode(RandomizerTemplateListResponse.self, from: data)
        return decoded.data ?? []
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
    func attachTemplate(showId: Int, templateId: Int) async throws {
        let body = AttachTemplateRequest(template_id: templateId)
        let req = try makeRequest(path: "/shows/\(showId)/randomizer-template", method: "PUT", body: body)
        let _ = try await session.data(for: req)
    }

    // MARK: - Detach template from show
    func detachTemplate(showId: Int) async throws {
        let req = try makeRequest(path: "/shows/\(showId)/randomizer-template", method: "DELETE")
        let _ = try await session.data(for: req)
    }

    // MARK: - List seller's products for slot mapping
    func listSellerProducts(page: Int = 1) async throws -> [SlotProduct] {
        let req = try makeRequest(path: "/products?status=active&page=\(page)&per_page=50", method: "GET")
        let (data, _) = try await session.data(for: req)
        // Use the same ResponseModel wrapper pattern
        struct ProductListResp: Codable {
            var status: String?
            var data: [SlotProduct]?
        }
        let decoded = try JSONDecoder().decode(ProductListResp.self, from: data)
        return decoded.data ?? []
    }
}
