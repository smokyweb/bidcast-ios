//
//  LinkedInUserDetail.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 05/04/24.
//

import Foundation

struct LinkedInURL: Codable {
    var url: String
}

    // MARK: - LinkedInUserDetail
struct LinkedInUserDetail: Codable {
    var background_cover_image_url: String?
    var last_name, summary, country_full_name, public_identifier: String?
    var country: String?
    var education: [LinkedInEducation]?
    var state: String?
    var languages: [String]?
//    var personal_numbers: [String]?
    var profile_pic_url: String?
//    var similarly_named_profiles: [PeopleAlsoViewed]?
    var follower_count: Int?
    var groups, accomplishment_patents, skills: [String]?
    var birth_date: String?
//    var people_also_viewed: [PeopleAlsoViewed]?
    var personal_emails, interests: [String]?
    var industry: String?
    var full_name: String?
//    var extra: String?
    var experiences: [Experience]?
//    var activities: [Activity]?
    var volunteer_work: [Experience]?
//    var recommendations: [String]?
    var city: String?
//    var accomplishment_projects: [AccomplishmentProject]?
//    var accomplishment_test_scores: [AccomplishmentTestScore]?
//    var connections: Int?
    var first_name, occupation: String?
//    var accomplishment_publications: [AccomplishmentProject]?
//    var inferred_salary: InferredSalary?
    var gender: String?
    var certifications: [Certification]?
//    var articles, accomplishment_organisations: [AccomplishmentProject]?
//    var accomplishment_courses: [AccomplishmentCourse]?
//    var accomplishment_honors_awards: [AccomplishmentHonorsAward]?
    var headline: String?
}

    // MARK: - AccomplishmentProject
struct AccomplishmentProject: Codable {
    var url: String?
    var title: String?
    var ends_at: IssuedOn?
    var description: String?
    var starts_at: IssuedOn?
}

    // MARK: - AccomplishmentTestScore
struct AccomplishmentTestScore: Codable {
    var score, name: String?
    var date_on: IssuedOn?
    var description: String?
}

    // MARK: - AccomplishmentCourse
struct AccomplishmentCourse: Codable {
    var name, number: String?
}
    // MARK: - AccomplishmentHonorsAward
struct AccomplishmentHonorsAward: Codable {
    var title: String?
    var issued_on: IssuedOn?
    var description, issuer: String?
}

    // MARK: - IssuedOn
struct IssuedOn: Codable {
    var day, month, year: Int?
}

    // MARK: - Activity
struct Activity: Codable {
    var title: String?
    var link: String?
    var activity_status: String?
}

    // MARK: - Certification
struct Certification: Codable {
    var starts_at, ends_at: IssuedOn?
    var name: String?
    var license_number, display_source: String?
    var authority: String?
    var url: String?
}

    // MARK: - Education
struct LinkedInEducation: Codable {
    var starts_at, ends_at: IssuedOn?
    var field_of_study: String?
    var degree_name, school: String?
    var school_linkedin_profile_url: String?
    var description: String?
    var logo_url: String?
    var grade, activities_and_societies: String?
}

    // MARK: - Experience
struct Experience: Codable {
    var starts_at, ends_at: IssuedOn?
    var company: String?
    var company_linkedin_profile_url: String?
    var title: String?
    var description, location: String?
    var logo_url: String?
    var cause: String?
}

    // MARK: - InferredSalary
struct InferredSalary: Codable {
    var min, max: Int?
}

    // MARK: - PeopleAlsoViewed
struct PeopleAlsoViewed: Codable {
    var summary, name: String?
    var location: String?
    var link: String?
}

struct StoreLinkedInRequest: Codable {
    var experiences: [Experience]?
    var education: [LinkedInEducation]?
    var languages, skills: [String]?
    var volunteer_work: [Experience]?
    var certifications: [Certification]?
}
