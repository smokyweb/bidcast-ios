//
//  SellerStatusViewModel.swift
//  BidCast
//
//  Created by JAM-E-329 on 06/05/25.
//
import Foundation

final class SellerStatusViewModel {
    
    //MARK: - variables
    enum RequestType {
        case none
    }
    
    weak var userDelegate: UserServices?
    
    var requestType: RequestType = .none


}
