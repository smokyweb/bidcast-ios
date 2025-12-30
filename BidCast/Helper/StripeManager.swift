//
//  StripeManager.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 03/06/25.
//

import Foundation
import Stripe
//
//class StripeCardViewModel: ObservableObject {
//    
//    func addCard(cardNumber: String, exp: String, cvc: String, completion: @escaping (Result<String, Error>) -> Void) {
//        
//        let cardParams = STPCardParams()
//        cardParams.number = cardNumber.replacingOccurrences(of: "-", with: "")
//        
//        let components = exp.components(separatedBy: "/")
//        if components.count == 2 {
//            cardParams.expMonth = UInt(components[0]) ?? 0
//            cardParams.expYear = UInt(components[1]) ?? 0
//        }
//
//        cardParams.cvc = cvc
//
//        STPAPIClient.shared.createToken(withCard: cardParams) { token, error in
//            if let error = error {
//                completion(.failure(error))
//            } else if let token = token {
//                completion(.success(token.tokenId))
//            }
//        }
//    }
//}
