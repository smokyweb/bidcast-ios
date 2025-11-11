//
//  ScheduleRequestStore.swift
//  BidCast
//
//  Created by Vivek_JAM_E-328 on 06/11/25.
//

import Foundation
import Combine

final class ScheduleRequestStore: ObservableObject {
    @Published var request: StoreScheduleShowRequest

    init(request: StoreScheduleShowRequest = StoreScheduleShowRequest(title: "", date: "", time: "", category_id: "", auction_type_id: "", product_ids: "")) {
        self.request = request
    }

    func reset() {
        self.request = StoreScheduleShowRequest(title: "", date: "", time: "", category_id: "", auction_type_id: "", product_ids: "")
    }
}
