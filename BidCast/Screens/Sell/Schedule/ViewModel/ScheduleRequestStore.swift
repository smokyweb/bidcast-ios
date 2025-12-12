//
//  ScheduleRequestStore.swift
//  BidCast
//
//  Created by Vivek_JAM_E-328 on 06/11/25.
//

import Foundation
import Combine

//var title: String
//var date: String
//var time: String
//var category_id: String
//var auction_type_id: String
//var product_ids: String
//var isExplicitContent: Bool
//var discoverablitity: String
//var primaryLanguage: String
//var repeats: String

final class ScheduleRequestStore: ObservableObject {
    @Published var request: StoreScheduleShowRequest
    
    init(request: StoreScheduleShowRequest = StoreScheduleShowRequest(title: "", date: "", time: "", category_id: "", auction_type_id: "", product_ids: "", isExplicitContent: false, discoverablitity: "", primaryLanguage: "", repeats: "")) {
        self.request = request
    }

    func reset() {
        self.request = StoreScheduleShowRequest(title: "", date: "", time: "", category_id: "", auction_type_id: "", product_ids: "", isExplicitContent: false, discoverablitity: "", primaryLanguage: "", repeats: "")
    }
}
