//
//  UserDetailModal.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 25/01/24.
//

import Foundation

struct UserResponseModal: Codable{
    var status: String = ""
    var message: String = ""
    var error_type: String = ""
    var data: UserDetailModal?
}


struct UserDetailModal: Codable {
    var id: Int?
    var name: String?
    var first_name: String?
    var last_name: String?
    var email: String?
    var role_id: String?
    var location: String?
    var is_student: String?
    var is_first_login : Int?
    var most_recent_job_title: String?
    var most_recent_company: String?
    var your_dream_job: String?
    var profile_image: String?
    var video_resume: String?
    var is_resume_uploaded : Bool?
    var deleted_at: String?
    var created_at: String?
    var is_employee_saved:String?
    var status: String?
    var user_role:String?
    var roles: UserRole?
    var images: [Imagee]?
    var job : [InterviewScheduleModal]?
    var qualification: [EducationResponse]?
    var work_histories: [WorkHistory]?
    var skills: [Skill]?
    var license_certifications: [LicenseCertification]?
    var volunteer_experiences: [VolunteerExperience]?
    var language: [Languages]?
    var interested_jobs: [IntJobResponse]?
    var phone, description, linkedIn_id, token, linkedIn_acc_exists,right_swipes,left_right_swipes: String?
    var emp_company_created: Bool?
    var company_data: CreateCompanyResponse?
    var jobMatched: EmployeesMatchedJob?
    var employer_matches_count: String?
    var subscription: SubscriptionStatus?
    var job_category_id: String?
    var isApplied:Bool?
    
}


struct EmployeesMatchedJob: Codable{
    var id:Int?
    var user_job_id,user_id,employer_id,job_id,scheduledDate,scheduledTime,scheduledEndTime,timezone: String?
    var rescheduled_date,rescheduled_time,rescheduled_end_time,status,employer_agree,employee_agree,created_at,updated_at,salary,salary_type: String?
    
}


struct userCategories: Codable{
    var id:Int?
    var name: String?
}



struct UserDetailSearchModal: Codable {
    var id: Int?
    var name: String?
    var first_name: String?
    var last_name: String?
    var email: String?
    var role_id: String?
    var location: String?
    var is_student: String?
    var most_recent_job_title: String?
    var most_recent_company: String?
    var your_dream_job: String?
    var profile_image: String?
    var video_resume: String?
    var deleted_at: String?
    var created_at: String?
    var is_employee_saved:String?
    var status: String?
    var user_role:String?
    var roles: UserRole?
    var qualification: [EducationResponse]?
    var language: [Languages]?
    var phone, description, linkedIn_id, token, linkedIn_acc_exists: String?
    var emp_company_created: Bool?
    var job_category_id: String?
    var isApplied:Bool?
}

struct ImageModal: Codable {
    var image, user_id: String
    var id: Int
}

struct UserRole: Codable {
    var id: Int?
    var user_role: String?
}

struct EducationResponse: Codable {
    var id: Int?
    var institute_name, graduation_date, order, name: String?
}

struct IntJobResponse: Codable {
    var job_id: String?
    var job: JobResponse?
}

struct JobResponse: Codable {
    var id: Int?
    var name: String?
}

struct SubscriptionStatus: Codable {
    var membershipEnable: String?
    var expires_date_pst: String?
    var product_id: String?
    var is_expired: String?
}

struct SubscriptionProduct: Codable{
    var id: Int?
    var subscription_plan: String?
    var benefits: String?
    var android_pland_id: String?
    var iOS_plan_id: String?
    var isActive: String?
    var applicable_role: String?
    var created_at: String?
    var updated_at: String?
}


struct RightSwipeStatus: Codable {
    var user_id,id: Int?
    var quantity,price: String?
}

struct RemoveSaveJobRequest: Codable {
    var id: String
}
