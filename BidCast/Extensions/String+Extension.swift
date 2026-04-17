//  BidCast
//
//  Created by Abdul-JAM-E-157 on 31/08/24.

import Foundation
import UIKit

extension String{
    var capitalizedSentence: String {
        // 1
        let firstLetter = self.prefix(1).capitalized
        // 2
        let remainingLetters = self.dropFirst().lowercased()
        // 3
        return firstLetter + remainingLetters
    }
    var htmlToAttributedString: NSAttributedString? {
        //        DispatchQueue.global(qos: .userInitiated).async{
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
        //}
    }
    func attributedStringFromHTML(_ htmlString: String) -> NSAttributedString? {
        guard let data = htmlString.data(using: .utf8) else { return nil }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        return try? NSAttributedString(data: data, options: options, documentAttributes: nil)
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
    
    func localized() -> String
    {
        let language = UserDefaults.standard.string(forKey: "language") ?? "en"
        return self.localized(lang: language)
    }
    
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
    
    func formattedDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        // Convert string to date
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = "MMMM d, yyyy"
            return dateFormatter.string(from: date)
        }
        return "Date not available"
    }
    func formattedAttributedString(boldRange: NSRange, boldFont: UIFont, regularFont: UIFont) -> NSAttributedString? {
        let fullText = self
        guard let data = fullText.data(using: .utf8) else { return nil }
        
        let attributedString = NSMutableAttributedString()
        
        do {
            let htmlAttributedString = try NSAttributedString(data: data,
                                                              options: [.documentType: NSAttributedString.DocumentType.html,
                                                                        .characterEncoding: String.Encoding.utf8.rawValue],
                                                              documentAttributes: nil)
            
            attributedString.append(htmlAttributedString)
            attributedString.addAttribute(.font, value: boldFont, range: boldRange)
        } catch {
            debugLog("Error parsing HTML: \(error)")
            return nil
        }
        
        return attributedString
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

extension String {
    /// Creates an attributed string with a dot (•) between two pieces of text, allowing customization.
    /// - Parameters:
    ///   - secondText: The second piece of text.
    ///   - dotColor: The color of the dot. Defaults to `.black`.
    ///   - firstTextColor: The color of the first text. Defaults to `.black`.
    ///   - secondTextColor: The color of the second text. Defaults to `.black`.
    ///   - font: The font for all the text. Defaults to `nil` (uses system default font).
    /// - Returns: An `NSAttributedString` with the formatted text.
    func attributedStringWithDot(
        secondText: String,
        dotColor: UIColor = .lightGray,
        firstTextColor: UIColor = .black,
        secondTextColor: UIColor = .black,
        font: UIFont? = nil
    ) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()

        // First Text
        let firstAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: firstTextColor,
            .font: font ?? UIFont.systemFont(ofSize: 17)
        ]
        attributedString.append(NSAttributedString(string: self, attributes: firstAttributes))

        // Dot
        let dotAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: dotColor,
            .font: font ?? UIFont.systemFont(ofSize: 17)
        ]
        attributedString.append(NSAttributedString(string: " • ", attributes: dotAttributes))

        // Second Text
        let secondAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: secondTextColor,
            .font: font ?? UIFont.systemFont(ofSize: 17)
        ]
        attributedString.append(NSAttributedString(string: secondText, attributes: secondAttributes))

        return attributedString
    }
}


extension String {
    /// Converts a date string from one format to another.
    /// - Parameters:
    ///   - inputFormat: The format of the input date string.
    ///   - outputFormat: The desired format for the output date string.
    /// - Returns: A formatted date string or `nil` if the conversion fails.
    func convertDateFormat(from inputFormat: String = "MM/dd/yyyy", to outputFormat: String = "MM-dd-yyyy") -> String? {
        let dateFormatter = DateFormatter()
        
        // Set the input format
        dateFormatter.dateFormat = inputFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Ensure consistent parsing
        
        // Convert the string to a Date object
        guard let date = dateFormatter.date(from: self) else {
            return nil
        }
        
        // Set the output format
        dateFormatter.dateFormat = outputFormat
        
        // Convert the Date object back to the desired output string
        return dateFormatter.string(from: date)
    }

}
func formatTimeToHourAndMinuteWithAMPM(_ timeString: String) -> String? {
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "HH:mm:ss"
    if let time = inputFormatter.date(from: timeString) {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "hh:mm a"
        let formattedTime = outputFormatter.string(from: time)
        
        return formattedTime
    }
    return nil
}


