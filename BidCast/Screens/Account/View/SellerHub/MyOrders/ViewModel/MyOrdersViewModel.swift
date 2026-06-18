//
//  MyOrdersViewModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

@MainActor
final class MyOrdersViewModel: ObservableObject {
    
    @Published var myOrderResponse = ResponseModelOrder<[MyOrderModel]>()
    @Published var errorMessage: String? = nil

    // MARK: - getMyOrderList.
    func getMyOrderList(parameters: ProductOrderListingRequest) async {
        do {
            let response: ResponseModelOrder<[MyOrderModel]> = try await APIManager.shared.request(
                type: APIEndPoint.productOrderListing(param: parameters),
                header: true
            )
            self.myOrderResponse = response
        } catch {
            self.handle(error: error)
        }
    }

    // MARK: - Error Handling
    private func handle(error: Error) {
        self.errorMessage = error.localizedDescription
    }
}



//
//  OrderWorkflowViewModel.swift
//  BidCast
//
//  QA Wave 2 Orange tier — iOS USPS order workflow (#31 / #32 / #33 / #34).
//  Mirrors the PWA Phase C backend endpoints landed by the prior subagent:
//    POST /api/change-order-status   → ApiController@changeOrderStatus
//    POST /api/usps/create-label     → ApiController@createLabel
//    POST /api/usps/track-order      → ApiController@trackOrder
//
//  Allowed change-order-status values are
//    'pending' | 'processing' | 'out_for_delivery' | 'delivered'.
//  When marking shipped, include the tracking_number returned from createLabel so the
//  backend persists shipping_status='shipped' on the order row.
//

// MARK: - Response payloads

/// USPS label response. Backend returns whatever the USPS SDK gave back under `data`.
/// We model just the fields the iOS UI consumes; everything else is ignored.
struct CreateLabelData: Codable {
    var trackingNumber: String?
    var shipmentId: String?
    var shippingStatus: String?
    var labelURL: String?
    /// Base64-encoded PDF of the label. Decoded on-device before display / share.
    var labelImage: String?

    enum CodingKeys: String, CodingKey {
        case trackingNumber
        case shipmentId
        case shippingStatus = "shipping_status"
        case labelURL = "label_url"
        case labelImage
    }
}

/// USPS tracking response — backend forwards the raw tracking blob; we treat it as
/// opaque JSON until QA confirms the shape we want to surface.
/// Local minimal codable wrapper avoids the JSONValue.swift type (not in the Xcode
/// project target as of build 14).
enum OrderAnyJSON: Codable {
    case null
    case bool(Bool)
    case number(Double)
    case string(String)
    case array([OrderAnyJSON])
    case object([String: OrderAnyJSON])
    
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() { self = .null; return }
        if let v = try? c.decode(Bool.self)     { self = .bool(v); return }
        if let v = try? c.decode(Double.self)   { self = .number(v); return }
        if let v = try? c.decode(String.self)   { self = .string(v); return }
        if let v = try? c.decode([OrderAnyJSON].self)         { self = .array(v); return }
        if let v = try? c.decode([String: OrderAnyJSON].self) { self = .object(v); return }
        self = .null
    }
    
    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .null:          try c.encodeNil()
        case .bool(let v):   try c.encode(v)
        case .number(let v): try c.encode(v)
        case .string(let v): try c.encode(v)
        case .array(let v):  try c.encode(v)
        case .object(let v): try c.encode(v)
        }
    }
}
typealias TrackOrderData = [String: OrderAnyJSON]

@MainActor
final class OrderWorkflowViewModel: ObservableObject {

    @Published var isWorking = false
    @Published var lastError: String?
    @Published var lastLabel: CreateLabelData?
    @Published var lastStatusChangeOk: Bool = false
    @Published var lastTrackingResponse: TrackOrderData?

    /// QA #31 / #34 — progress an order through the four valid statuses.
    /// Returns true on a successful API "status":"success" response.
    func changeStatus(orderId: Int, status: String, trackingNumber: String? = nil) async -> Bool {
        isWorking = true
        defer { isWorking = false }
        do {
            let param = ChangeOrderStatusRequest(
                order_id: orderId,
                status: status,
                tracking_number: trackingNumber
            )
            let response: ResponseModel<OrderAnyJSON> = try await APIManager.shared.request(
                type: APIEndPoint.changeOrderStatus(param: param),
                header: true
            )
            let ok = (response.status?.lowercased() == "success")
            lastStatusChangeOk = ok
            if !ok { lastError = response.message }
            return ok
        } catch {
            lastError = (error as? DataError)?.getErrorMessage() ?? error.localizedDescription
            return false
        }
    }

    /// QA #32 / #33 — create the USPS shipping label for this order. Backend persists
    /// order.tracking_number, order.label_url, and order.shipping_status='label_created'.
    /// On success returns the decoded CreateLabelData (also stored on lastLabel).
    func createLabel(orderId: Int) async -> CreateLabelData? {
        isWorking = true
        defer { isWorking = false }
        do {
            let param = CreateUSPSLabelRequest(order_id: orderId)
            let response: ResponseModel<CreateLabelData> = try await APIManager.shared.request(
                type: APIEndPoint.createUSPSLabel(param: param),
                header: true
            )
            if response.status?.lowercased() == "success", let data = response.data {
                lastLabel = data
                return data
            }
            lastError = response.message ?? "Label creation failed."
            return nil
        } catch {
            lastError = (error as? DataError)?.getErrorMessage() ?? error.localizedDescription
            return nil
        }
    }

    /// Basecamp #9934033253 (2026-05-29) — buyer requests an order cancellation
    /// with a reason. Backend methods restored + LIVE.
    /// POST /api/product/request-cancellation { order_id, reason }
    func requestCancellation(orderId: Int, reason: String) async -> Bool {
        isWorking = true
        defer { isWorking = false }
        do {
            let param = RequestCancellationRequest(order_id: orderId, reason: reason)
            let response: ResponseModel<OrderAnyJSON> = try await APIManager.shared.request(
                type: APIEndPoint.requestCancellation(param: param),
                header: true
            )
            let ok = (response.status?.lowercased() == "success")
            if !ok { lastError = response.message ?? "Cancellation request failed." }
            return ok
        } catch {
            lastError = (error as? DataError)?.getErrorMessage() ?? error.localizedDescription
            return false
        }
    }

    /// Basecamp #9934033253 (2026-05-29) — seller approves or rejects a pending
    /// cancellation request.
    /// POST /api/product/decide-cancellation { order_id, decision, reject_reason? }
    func decideCancellation(orderId: Int, decision: String, rejectReason: String? = nil) async -> Bool {
        isWorking = true
        defer { isWorking = false }
        do {
            let param = DecideCancellationRequest(
                order_id: orderId,
                decision: decision,
                reject_reason: rejectReason
            )
            let response: ResponseModel<OrderAnyJSON> = try await APIManager.shared.request(
                type: APIEndPoint.decideCancellation(param: param),
                header: true
            )
            let ok = (response.status?.lowercased() == "success")
            if !ok { lastError = response.message ?? "Could not update the cancellation." }
            return ok
        } catch {
            lastError = (error as? DataError)?.getErrorMessage() ?? error.localizedDescription
            return false
        }
    }

    /// QA #32 / #34 — query USPS for current tracking state. Caller can compare the
    /// status string and call changeStatus(orderId:, status:'delivered') when USPS
    /// reports delivery, which lets the order flip into the Completed tab.
    func trackOrder(trackingNumber: String) async -> TrackOrderData? {
        isWorking = true
        defer { isWorking = false }
        do {
            let param = TrackUSPSOrderRequest(tracking_number: trackingNumber)
            let response: ResponseModel<TrackOrderData> = try await APIManager.shared.request(
                type: APIEndPoint.trackUSPSOrder(param: param),
                header: true
            )
            if response.status?.lowercased() == "success" {
                lastTrackingResponse = response.data
                return response.data
            }
            lastError = response.message ?? "Tracking lookup failed."
            return nil
        } catch {
            lastError = (error as? DataError)?.getErrorMessage() ?? error.localizedDescription
            return nil
        }
    }

    // MARK: - Helpers

    /// Decode the base64 PDF returned by createLabel into a tmp file URL suitable for
    /// previewing in a `QLPreviewController` or sharing via `UIActivityViewController`.
    static func writeLabelPDFToTempFile(_ base64: String, orderId: Int) -> URL? {
        guard let data = Data(base64Encoded: base64) else { return nil }
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("bidcast-label-\(orderId)-\(Int(Date().timeIntervalSince1970)).pdf")
        do {
            try data.write(to: tmp, options: .atomic)
            return tmp
        } catch {
            return nil
        }
    }

    /// Download the persisted label URL into a local temporary PDF so iOS exposes
    /// the native preview/share/print actions instead of only sharing a web link.
    static func downloadLabelPDF(from remoteURL: URL, orderId: Int) async -> URL? {
        do {
            let (downloadedURL, _) = try await URLSession.shared.download(from: remoteURL)
            let destination = FileManager.default.temporaryDirectory
                .appendingPathComponent("bidcast-label-\(orderId)-\(Int(Date().timeIntervalSince1970)).pdf")
            if FileManager.default.fileExists(atPath: destination.path) {
                try FileManager.default.removeItem(at: destination)
            }
            try FileManager.default.moveItem(at: downloadedURL, to: destination)
            return destination
        } catch {
            return nil
        }
    }
}
