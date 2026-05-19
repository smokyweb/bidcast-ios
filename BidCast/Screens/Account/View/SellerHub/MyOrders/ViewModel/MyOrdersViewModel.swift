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
    /// Base64-encoded PDF of the label. Decoded on-device before display / share.
    var labelImage: String?
}

/// USPS tracking response — backend forwards the raw tracking blob; we treat it as
/// opaque JSON until QA confirms the shape we want to surface.
typealias TrackOrderData = [String: JSONValue]

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
            let response: ResponseModel<JSONValue> = try await APIManager.shared.request(
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
}
