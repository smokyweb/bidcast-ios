//
//  InterviewlistModel.swift
// BidSwipe
//
//  Created by Abdul-JAM-E-157 on 27/02/24.
//

import Foundation

//struct InterviewListMode:Codable {
//    var employment, location: [values]?
//}
//struct values:Codable {
//    var id: Int?
//    var type: String?
//}


struct InterviewListModel:Codable {
    var id: Int?
    var user_job_id, user_id, job_id, scheduledDate: String?
    var scheduledTime, timezone, status, created_at: String?
    var updated_at: String?
    var job: JobDetailResponse?
    var user: UserData?
}

// MARK: - Job
struct JobData :Codable{
    var id: Int?
    var user_id, title, salary_type, salary: String?
    var hours_schedule, job_sype, experience: String?
}

// MARK: - User
struct UserData :Codable {
    var id: Int?
    var name, email: String?
    var profile_image: String?
}
