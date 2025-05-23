//
//  InterviewScheduleModal.swift
// BidSwipe
//
//  Created by Ankit - JAM - E - 294 on 09/02/24.
//

import Foundation

struct InterviewScheduleModal: Codable {
    var id: Int?
    var user_job_id, user_id, employer_id,job_id: String?
    var scheduledDate, scheduledTime, scheduledEndTime, timezone, status: String?
    var created_at, updated_at: String?
    var employer_agree, employee_agree: String?
    var job_title, salary: String?
    var job: JobDetailResponse?
    var user: UserData?
    var rescheduled_date, rescheduled_time, rescheduled_end_time: String?
}

struct SubCompanyModal: Codable {
    var id: Int?
    var profile_image, user_name, email,phone,first_name,last_name,status: String?
    var roles: String?
    var permission: [SubCompanyDetailsModal]?
}


struct SubCompanyDetailsModal: Codable {
    var id: Int?
    var user_id, sub_user_id: String?
}

struct DeleteCompanyUserParam: Codable {
    var user_id, status: String?
}
