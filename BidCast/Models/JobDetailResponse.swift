//
//  JobDetailResponse.swift
// BidSwipe
//
//  Created by Ankit - JAM - E - 294 on 03/02/24.
//

import Foundation

    // MARK: - JobDetailModal
struct JobDetailResponse: Codable {
    var id: Int?
    var user_id, title, salary_type, salary: String?
    var hours_schedule, job_type, description, benefits: String?
    var experience, licensure, qualification_id, education_field_id,location_type_id,distance: String?
    var created_at, updated_at: String?
    var qualification: Qualification?
    var user: UserDetailModal?
    var education: JobResponse?
    var location_type : locationResponse?
    var isSaved, isAccepted, isRejected, isMatched: Bool?
}

    // MARK: - Qualification
struct locationResponse: Codable {
    var id: Int?
    var type: String?
}

struct Qualification: Codable {
    var id: Int?
    var name, order: String?
}

struct CompanyNameResponse: Codable {
    var id: Int?
    var company_name: String?
}
