//
//  CombineDataModel.swift
// BidSwipe
//
//  Created by Maneet-JAM-E-282 on 02/03/24.
//

import Foundation

struct CombineDataModel: Codable {
    var employment_type: [IdTypeModel]
    var location_type: [IdTypeModel]
    var salary_type: [IdTypeModel]
    var qualification: [Qualification]
    var language: [Languages]
    var category: [CategoryType]
    var benefits : [BenefitType]
    var notification_count,max_salary,min_salary: Int
    var one_signal_app_id,your_video_text,example_video_test: String
    var employer_matches_count : String?
    var is_verified : String?
}

struct IdTypeModel: Codable {
    var id: Int
    var type: String
}

struct CategoryType: Codable {
    var id: Int
    var name: String
}

struct BenefitType: Codable {
    var id: Int
    var benefit: String
}
