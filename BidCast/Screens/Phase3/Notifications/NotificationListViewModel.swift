//
//  NotificationListViewModel.swift
//  BidCast — iOS parity Phase 3b (2026-04-22)
//
//  Mirrors Android `NotificationFragment`.
//  POST /api/notification/listing (paginated)
//  POST /api/notification/delete
//

import Foundation

final class NotificationListViewModel {
    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?
    var onLoadingChange: ((Bool) -> Void)?

    private(set) var items: [NotificationEntry] = []
    private(set) var paging = P3Paging()

    func loadInitial() {
        items = []
        paging.reset()
        onUpdate?()
        loadNext()
    }

    func loadNext() {
        guard !paging.isLoading, paging.hasMore else { return }
        paging.isLoading = true
        onLoadingChange?(true)

        Task { @MainActor in
            defer {
                self.paging.isLoading = false
                self.onLoadingChange?(false)
            }
            do {
                let fields = ["page": "\(paging.page)"]
                let resp: GetNotificationResponse = try await APIManager.shared.postMultipartForm(
                    type: .getNotification(param: [:]),
                    fields: fields, header: true
                )
                let newItems = resp.data ?? []
                if self.paging.page == 1 {
                    self.items = newItems
                } else {
                    self.items.append(contentsOf: newItems)
                }
                self.paging.advance(from: P3PaginationInfo(
                    currentPage: resp.currentPage,
                    totalPages: resp.totalPage
                ))
                self.onUpdate?()
            } catch let err as DataError {
                self.onError?(err.getErrorMessage())
            } catch {
                self.onError?(error.localizedDescription)
            }
        }
    }

    func delete(at index: Int) {
        guard index >= 0, index < items.count else { return }
        let entry = items[index]
        guard let id = entry.id else { return }
        items.remove(at: index)
        onUpdate?()
        Task {
            do {
                let fields = ["notification_id": "\(id)"]
                let _: APIEmptyResponse = try await APIManager.shared.postMultipartForm(
                    type: .deleteNotification(param: [:]),
                    fields: fields, header: true
                )
            } catch {
                debugLog("deleteNotification error: \(error.localizedDescription)")
            }
        }
    }
}
