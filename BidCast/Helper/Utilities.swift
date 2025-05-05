

import Foundation
import UIKit
import SwiftUI
import AlertToast



    // MARK: SCREENSIZES
let screenSize: CGRect = UIScreen.main.bounds
let screenWidth = screenSize.width
let screenHeight = screenSize.height
let window = UIApplication.shared.windows[0]
let safeFrame = window.safeAreaLayoutGuide.layoutFrame
let safeWidth = safeFrame.width
let safeHeight = safeFrame.height
let topPadding = window.safeAreaInsets.top
let bottomPadding = window.safeAreaInsets.bottom

    // MARK: Fonts Used
let nunitoLight = "NunitoSans10ptCondensed-Regular"
let nunitoRegular = "NunitoSans10ptCondensed-Medium"
let nunitoMedium = "NunitoSans10ptCondensed-SemiBold"
let nunitoBold = "NunitoSans10ptCondensed-ExtraBold"
let nunitoSemiBold = "NunitoSans10ptCondensed-Bold"
let nunitoBlack = "NunitoSans10ptCondensed-Black"

func generateFeedback(type: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
    let impactHeavy = UIImpactFeedbackGenerator(style: type)
    impactHeavy.impactOccurred()
}


let alertStlye: AlertToast.AlertStyle = .style(backgroundColor: .red, titleColor: .white, subTitleColor: .white, titleFont: .custom(nunitoMedium, fixedSize: 14), subTitleFont: .custom(nunitoRegular, fixedSize: 14))

let alertStlyeSuccess: AlertToast.AlertStyle = .style(backgroundColor: .green, titleColor: .white, subTitleColor: .white, titleFont: .custom(nunitoMedium, fixedSize: 14), subTitleFont: .custom(nunitoRegular, fixedSize: 14))

//extension Encodable {
//
//    /// Converting object to postable dictionary
//    func toDictionary(_ encoder: JSONEncoder = JSONEncoder()) throws -> [String: Any] {
//        encoder.outputFormatting = .prettyPrinted
//        let data = try encoder.encode(self)
//        let object = try JSONSerialization.jsonObject(with: data)
//        guard let json = object as? [String: Any] else {
//            let context = DecodingError.Context(codingPath: [], debugDescription: "Deserialized object is not a dictionary")
//            throw DecodingError.typeMismatch(type(of: object), context)
//        }
//        return json
//    }
//
//      func asDictionary() throws -> [String: Any] {
//        let data = try JSONEncoder().encode(self)
//        
//        guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
//          throw NSError()
//        }
//        return dictionary
//      }
//    
//  
//    
//    //MARK:Date Formats
//    
//    
//    
//}

//extension Dictionary {
//
//    var json: String {
//        let invalidJson = "Not a valid JSON"
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
//            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
//        } catch {
//            return invalidJson
//        }
//    }
//
//    func printJson() {
//        print(json)
//    }
//
//}
