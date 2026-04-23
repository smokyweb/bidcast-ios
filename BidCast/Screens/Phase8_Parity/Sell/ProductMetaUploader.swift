//
//  ProductMetaUploader.swift
//  BidCast — iOS parity Phase 8 / P1.9b (2026-04-23)
//
//  Uploads in-memory image `Data` blobs to POST api/store-product-meta.
//  Android ApiInterface declares:
//      @Multipart
//      @POST("api/store-product-meta")
//      suspend fun storeProductMeta(
//          @Part productImages: List<MultipartBody.Part?>?,
//          @Part videos: List<MultipartBody.Part?>?,
//          @Part thumbnail: List<MultipartBody.Part?>?,
//      ): StoreProductMetaResponse
//
//  The existing APIManager helpers load files from local URLs. This wizard
//  uses PHPickerViewController which vends in-memory Data, so we build the
//  multipart body here directly. Kept outside APIManager to limit blast
//  radius — if QA surfaces a backend contract tweak, we can iterate on
//  this helper without affecting other feature flows.
//

import Foundation
import UIKit

enum ProductMetaUploader {

    struct Pending {
        let productId: Int
        /// Main images (sent under `product_images[]` to match Android).
        let images: [Data]
        /// Optional thumbnail override — if nil, backend uses the first image.
        let thumbnail: Data?
    }

    /// Upload product media. Returns a decoded `StoreProductMetaResponse` on
    /// success; throws `DataError` on failure.
    @discardableResult
    static func upload(pending: Pending) async throws -> StoreProductMetaResponse {
        // Build URL.
        let endpoint = APIEndPoint.storeProductMeta
        guard let url = endpoint.url else { throw DataError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(NSUUID().uuidString)"

        var headers: [String: String] = [
            "Accept": "application/json",
            "Content-Type": "multipart/form-data; boundary=\(boundary)"
        ]
        headers["Authorization"] = "Bearer \(UserDefaults.accessToken)"
        request.allHTTPHeaderFields = headers

        var body = Data()
        let lineBreak = "\r\n"

        // Text part: product_id
        body.append("--\(boundary)\(lineBreak)")
        body.append("Content-Disposition: form-data; name=\"product_id\"\(lineBreak + lineBreak)")
        body.append("\(pending.productId)\(lineBreak)")

        // Image parts — Android sends them as `product_images[]`.
        for (idx, imgData) in pending.images.enumerated() {
            let filename = "image_\(idx).jpg"
            body.append("--\(boundary)\(lineBreak)")
            body.append("Content-Disposition: form-data; name=\"product_images[]\"; filename=\"\(filename)\"\(lineBreak)")
            body.append("Content-Type: image/jpeg\(lineBreak + lineBreak)")
            body.append(imgData)
            body.append(lineBreak)
        }

        // Thumbnail part (optional).
        if let thumb = pending.thumbnail {
            body.append("--\(boundary)\(lineBreak)")
            body.append("Content-Disposition: form-data; name=\"thumbnail[]\"; filename=\"thumbnail.jpg\"\(lineBreak)")
            body.append("Content-Type: image/jpeg\(lineBreak + lineBreak)")
            body.append(thumb)
            body.append(lineBreak)
        }

        body.append("--\(boundary)--\(lineBreak)")
        request.httpBody = body

        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 240

        let (data, response) = try await URLSession(configuration: config).data(for: request)
        guard let http = response as? HTTPURLResponse,
              200 ... 299 ~= http.statusCode else {
            if let apiError = try? JSONDecoder().decode(ApiError.self, from: data) {
                throw DataError.invalidCode(apiError.message)
            }
            throw DataError.invalidCode("Image upload failed.")
        }
        return try JSONDecoder().decode(StoreProductMetaResponse.self, from: data)
    }
}

// Note: canonical `Data.append(_ string: String)` lives in
// BidCast/Extensions/Data+Extension.swift — do not redeclare here.

