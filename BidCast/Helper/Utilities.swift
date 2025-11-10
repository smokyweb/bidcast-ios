

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

let poppinsBlack = "Poppins-Black"
let poppinsBlackItalic = "Poppins-BlackItalic"
let poppinsBold = "Poppins-Bold"
let poppinsBoldItalic = "Poppins-BoldItalic"
let poppinsExtraBold = "Poppins-ExtraBold"
let poppinsExtraBoldItalic = "Poppins-ExtraBoldItalic"
let poppinsExtraLight = "Poppins-ExtraLight"
let poppinsExtraLightItalic = "Poppins-ExtraLightItalic"
let poppinsItalic = "Poppins-Italic"
let poppinsLight = "Poppins-Light"
let poppinsLightItalic = "Poppins-LightItalic"
let poppinsMedium = "Poppins-Medium"
let poppinsMediumItalic = "Poppins-MediumItalic"
let poppinsRegular = "Poppins-Regular"
let poppinsSemiBold = "Poppins-SemiBold"
let poppinsSemiBoldItalic = "Poppins-SemiBoldItalic"
let poppinsThin = "Poppins-Thin"
let poppinsThinItalic = "Poppins-ThinItalic"



// Roboto Core
let robotoThin = "Roboto-Thin"
let robotoThinItalic = "Roboto-ThinItalic"
let robotoExtraLight = "Roboto-ExtraLight"
let robotoExtraLightItalic = "Roboto-ExtraLightItalic"
let robotoLight = "Roboto-Light"
let robotoLightItalic = "Roboto-LightItalic"
let robotoRegular = "Roboto-Regular"
let robotoItalic = "Roboto-Italic"
let robotoMedium = "Roboto-Medium"
let robotoMediumItalic = "Roboto-MediumItalic"
let robotoSemiBold = "Roboto-SemiBold"
let robotoSemiBoldItalic = "Roboto-SemiBoldItalic"
let robotoBold = "Roboto-Bold"
let robotoBoldItalic = "Roboto-BoldItalic"
let robotoExtraBold = "Roboto-ExtraBold"
let robotoExtraBoldItalic = "Roboto-ExtraBoldItalic"
let robotoBlack = "Roboto-Black"
let robotoBlackItalic = "Roboto-BlackItalic"

// Roboto Condensed
let robotoCondensedLight = "RobotoCondensed-Light"
let robotoCondensedLightItalic = "RobotoCondensed-LightItalic"
let robotoCondensedRegular = "RobotoCondensed-Regular"
let robotoCondensedItalic = "RobotoCondensed-Italic"
let robotoCondensedBold = "RobotoCondensed-Bold"
let robotoCondensedBoldItalic = "RobotoCondensed-BoldItalic"

// Roboto Slab
let robotoSlabThin = "RobotoSlab-Thin"
let robotoSlabLight = "RobotoSlab-Light"
let robotoSlabRegular = "RobotoSlab-Regular"
let robotoSlabBold = "RobotoSlab-Bold"

// Roboto Mono
let robotoMonoThin = "RobotoMono-Thin"
let robotoMonoThinItalic = "RobotoMono-ThinItalic"
let robotoMonoLight = "RobotoMono-Light"
let robotoMonoLightItalic = "RobotoMono-LightItalic"
let robotoMonoRegular = "RobotoMono-Regular"
let robotoMonoItalic = "RobotoMono-Italic"
let robotoMonoMedium = "RobotoMono-Medium"
let robotoMonoMediumItalic = "RobotoMono-MediumItalic"
let robotoMonoBold = "RobotoMono-Bold"
let robotoMonoBoldItalic = "RobotoMono-BoldItalic"
let robotoMonoSemiBold = "RobotoMono-SemiBold"
let robotoMonoSemiBoldItalic = "RobotoMono-SemiBoldItalic"

// Optional (if you have Flex or Variable)
let robotoFlex = "RobotoFlex-Regular"
let robotoFlexItalic = "RobotoFlex-Italic"



let Leading = 16.0
let Trailing = 16.0
let flotingLabel = 13.0
let placeHolder = 13.0
let buttonTitle = 16.0
let headerTitle = 20.0
let sepratorLine = 38.0

let appID = 1005763407
let appSign = "73678be720c3ea2d871376882d27d21d5c2bc891363547424458f9febc8bf423"

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

//MARK: formatDateTime.
func formatDateTime(_ isoDate: String?) -> String {
        guard let isoDate = isoDate else {
            return "N/A"
        }

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let date = isoFormatter.date(from: isoDate) else {
            return "N/A"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy, HH:mm"
        return formatter.string(from: date)
    }


//MARK: Collection.
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

//MARK: compressAndSaveImage.
func compressAndSaveImage(data: Data, maxFileSizeKB: Int = 2048) -> URL? {
    guard let image = UIImage(data: data) else { return nil }

    var compressionQuality: CGFloat = 0.8
    let minCompression: CGFloat = 0.2
    let maxSizeBytes = maxFileSizeKB * 1024

    var compressedData = image.jpegData(compressionQuality: compressionQuality)

    while let currentData = compressedData, currentData.count > maxSizeBytes && compressionQuality > minCompression {
        compressionQuality -= 0.1
        compressedData = image.jpegData(compressionQuality: compressionQuality)
    }

    guard let finalData = compressedData, finalData.count <= maxSizeBytes else {
        print("⚠️ Compression failed or still too big, falling back to original.")
        return nil
    }

    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("compressed_\(UUID().uuidString).jpg")
    do {
        try finalData.write(to: tempURL)
        print("✅ Compressed image saved, size: \(finalData.count / 1024) KB")
        return tempURL
    } catch {
        print("❌ Failed to write compressed image:", error)
        return nil
    }
}

//MARK: saveImageToTemporaryDirectory.
func saveImageToTemporaryDirectory(data: Data) -> URL? {
    let tempDir = FileManager.default.temporaryDirectory
    let fileName = "\(Int(Date().timeIntervalSince1970)).png"
    let fileURL = tempDir.appendingPathComponent(fileName)
    do {
        try data.write(to: fileURL)
        return fileURL
    } catch {
        print("Error writing image to file:", error)
        return nil
    }
}

extension TimeInterval {
    func toDateString() -> String {
        let date = Date(timeIntervalSince1970: self)
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.timeZone = TimeZone(identifier: "Asia/Kolkata")
        return formatter.string(from: date)
    }
}

extension Notification.Name {
    static let userSessionExpired = Notification.Name("userSessionExpired")
}



