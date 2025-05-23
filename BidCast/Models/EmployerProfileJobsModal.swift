//
//  EmployerProfileJobsModal.swift
// BidSwipe
//
//  Created by Ankit - JAM - E - 294 on 12/02/24.
//

import Foundation

struct EmployerProfileJobsModal: Codable {
    var id: Int?
    var name: String?
    var first_name: String?
    var last_name: String?
    var email: String?
    var role_id: String?
    var location: String?
    var most_recent_job_title: String?
    var most_recent_company: String?
    var your_dream_job: String?
    var profile_image: String?
    var video_resume: String?
    var deleted_at: String?
    var created_at: String?
    var roles: UserRole?
    var jobs: EmployerJobData?
    var company_data: CreateCompanyResponse?
}

struct EmployerJobData: Codable {
    var data: [JobDetailResponse]?
}
