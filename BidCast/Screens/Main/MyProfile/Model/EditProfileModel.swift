//
//  EditProfileModel.swift
//  Hey MarketPlace App
//
//  Created by JAM-E-174 on 19/09/24.
//

import Foundation
import UIKit

struct EditProfileDetailsRequest:Encodable {
    let first_name : String
    let last_name : String
    let profile_image : String
}

struct EditProfileModel : Codable{
    let first_name : String?
    let last_name : String?
    let image : String?
}

