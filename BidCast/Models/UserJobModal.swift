//
//  UserJobModal.swift
// BidSwipe
//
//  Created by Ankit - JAM - E - 294 on 29/01/24.
//

import Foundation

//MARK: - Job Response Modal
struct JobResponseModal: Codable {
    var status, message, error_type: String?
    var data: [JobDetailModal]?
    var total, total_page, current_page, per_page: Int?
}

//MARK: Job Details
struct JobDetailModal: Codable {
    var id: Int?
    var title: String?
    var salary_type, salary, hours_schedule, job_type: String?
    var job_description, benefits, required_experience, required_licensure: String?
    var education_level, field_of_education: String?
    var created_at, updated_at, user_id, job_id: String?
    var type: String?
}

//MARK: - Job Swipe Response
struct JobSwipeResponse: Codable {
    var type, job_id, update_at, created_at: String
    var user_id, id: Int
}
