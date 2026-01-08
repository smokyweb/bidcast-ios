//
//  String+Extension.swift
//  MentorPOS
//
//  Created by admin on 3/3/20.
//  Copyright © 2020 admin. All rights reserved.
//

import Foundation
import UIKit

extension String{

    var htmlToAttributedString: NSAttributedString? {
//        DispatchQueue.global(qos: .userInitiated).async{
            guard let data = data(using: .utf8) else { return NSAttributedString() }
            do {
                return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
            } catch {
                return NSAttributedString()
            }
//        }
    }
    
    var localized: String {
        return Bundle.main.localizedString(forKey: self, value: nil, table: nil)
    }
    
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }

    func localized(lang:String) -> String {
        if let path = Bundle.main.path(forResource: lang, ofType: "lproj"), let bundle = Bundle(path: path) {
            return bundle.localizedString(forKey: self, value: nil, table: nil)
        }
        return self
    }
    
//    func localized() -> String
//    {
//        return self.localized(lang: UserDefaults.standard.object(forKey: "language") != nil ? UserDefaults.standard.object(forKey: "language") as! String : "en")
//    }
    
    var trim: String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func replacingFirstOccurrence(of target: String, with replacement: String) -> String {
        guard let range = self.range(of: target) else { return self }
        return self.replacingCharacters(in: range, with: replacement)
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    var glyphCount: Int {
        
        let richText = NSAttributedString(string: self)
        let line = CTLineCreateWithAttributedString(richText)
        return CTLineGetGlyphCount(line)
    }
    
    var isSingleEmoji: Bool {
        
        return glyphCount == 1 && containsEmoji
    }
    
    var containsEmoji: Bool {
        
        return unicodeScalars.contains { $0.isEmoji }
    }
    
    var containsOnlyEmoji: Bool {
        
        return !isEmpty
        && !unicodeScalars.contains(where: {
            !$0.isEmoji
            && !$0.isZeroWidthJoiner
        })
    }
    
        // The next tricks are mostly to demonstrate how tricky it can be to determine emoji's
        // If anyone has suggestions how to improve this, please let me know
    var emojiString: String {
        
        return emojiScalars.map { String($0) }.reduce("", +)
    }
    
    var emojis: [String] {
        
        var scalars: [[UnicodeScalar]] = []
        var currentScalarSet: [UnicodeScalar] = []
        var previousScalar: UnicodeScalar?
        
        for scalar in emojiScalars {
            
            if let prev = previousScalar, !prev.isZeroWidthJoiner && !scalar.isZeroWidthJoiner {
                
                scalars.append(currentScalarSet)
                currentScalarSet = []
            }
            currentScalarSet.append(scalar)
            
            previousScalar = scalar
        }
        
        scalars.append(currentScalarSet)
        
        return scalars.map { $0.map{ String($0) } .reduce("", +) }
    }
    
    fileprivate var emojiScalars: [UnicodeScalar] {
        
        var chars: [UnicodeScalar] = []
        var previous: UnicodeScalar?
        for cur in unicodeScalars {
            
            if let previous = previous, previous.isZeroWidthJoiner && cur.isEmoji {
                chars.append(previous)
                chars.append(cur)
                
            } else if cur.isEmoji {
                chars.append(cur)
            }
            
            previous = cur
        }
        
        return chars
    }
    
    var digit: [Int] {
        var result = [Int]()
        for char in self {
            if let number = Int(String(char)) {
                result.append(number)
            }
        }
        return result
    }

    
}


//MARK:- Emoji
extension UnicodeScalar {
    
    var isEmoji: Bool {
        
        switch value {
        case 0x1F600...0x1F64F, // Emoticons
        0x1F300...0x1F5FF, // Misc Symbols and Pictographs
        0x1F680...0x1F6FF, // Transport and Map
        0x1F1E6...0x1F1FF, // Regional country flags
        0x2600...0x26FF,   // Misc symbols
        0x2700...0x27BF,   // Dingbats
        0xFE00...0xFE0F,   // Variation Selectors
        0x1F900...0x1F9FF,  // Supplemental Symbols and Pictographs
        65024...65039, // Variation selector
        8400...8447: // Combining Diacritical Marks for Symbols
            return true
            
        default: return false
        }
    }
    
    var isZeroWidthJoiner: Bool {
        
        return value == 8205
    }
}

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        let val = (self * divisor).rounded() / divisor
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 2
        numberFormatter.maximumFractionDigits = 2
        let str = numberFormatter.string(from: NSNumber(value: val))!
        return Double(str)!
    }
}

extension Int {
    var numberStrings: String {
        guard self < 10 else { return "0" }
        return String(self)
    }
}


extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    var buildNumber: String {
        return infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}


func formatTo12HourTime(_ timeString: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"  // input format
    if let date = dateFormatter.date(from: timeString) {
        dateFormatter.dateFormat = "h:mm a" // output format
        return dateFormatter.string(from: date)
    }
    return timeString // fallback
}

extension String {
    /// Converts ISO 8601 date string to a custom formatted string
    /// - Parameter outputFormat: Desired output format (e.g. "dd MMMM yyyy")
    /// - Returns: Formatted date string or original string if parsing fails
    func formattedDate(fromFormat inputFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ",
                       toFormat outputFormat: String = "dd MMMM yyyy") -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = inputFormat
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        guard let date = inputFormatter.date(from: self) else {
            return self  // fallback: return original string if parsing fails
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = outputFormat
        outputFormatter.locale = Locale(identifier: "en_US")
        
        return outputFormatter.string(from: date)
    }
    
    func formattedDateAndTimeString1() -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        inputFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        guard let date = inputFormatter.date(from: self) else {
            return self  // fallback: return original string if parsing fails
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM dd, yyyy, HH:mm"
        outputFormatter.locale = Locale(identifier: "en_US")
        
        return outputFormatter.string(from: date)
    }
    
    func formattedDateAndTimeString() -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        inputFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = inputFormatter.date(from: self) else {
            return "Invalid date"
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM dd yyyy, HH:mm"
        outputFormatter.timeZone = TimeZone.current

        return outputFormatter.string(from: date)
    }
    func formattedDate() -> String {
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            guard let date = isoFormatter.date(from: self) else {
                return "Invalid date"
            }

            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMM dd yyyy, HH:mm"
            outputFormatter.timeZone = .current

            return outputFormatter.string(from: date)
        }
}

extension String {
    /// Converts a string to a `Double` if possible.
    /// Returns `nil` if the string is not a valid number.
    var toDouble: Double? {
        return Double(self)
    }
}

extension String {
    func chunked(into size: Int) -> [String] {
        var result = [String]()
        var startIndex = self.startIndex
        
        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: size, limitedBy: self.endIndex) ?? self.endIndex
            let chunk = String(self[startIndex..<endIndex])
            result.append(chunk)
            startIndex = endIndex
        }
        
        return result
    }
}

extension String {
    func toDateString(
        from fromFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'",
        to   toFormat:   String = "MM/dd/yyyy"
    ) -> String {

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = fromFormat

        guard let date = formatter.date(from: self) else { return "N/A" }

        formatter.dateFormat = toFormat
        return formatter.string(from: date)
    }
}
