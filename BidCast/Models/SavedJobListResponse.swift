//
//  SavedJobListResponse.swift
// BidSwipe
//
//  Created by Maneet-JAM-E-282 on 09/02/24.
//

import Foundation

struct SavedJobListResponse: Codable {
    var id: Int
    var user_id, job_id: String
    var job: JobDetailResponse
}
