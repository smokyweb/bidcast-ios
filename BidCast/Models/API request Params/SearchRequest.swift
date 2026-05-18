//
//  SearchRequest.swift
//  BidCast
//
//  Created by Larry Difficult Task Agent on 2026-05-17.
//

import Foundation

struct SearchRequest: Encodable {
    let search: String
    let page: Int?
}
