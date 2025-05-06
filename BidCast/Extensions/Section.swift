//
//  Section.swift
//  Rise Shine Swing
//
//  Created by Vivek-JAM-E-328 on 18/09/24.
//

import Foundation

//manage section type for table view
enum SectionType: Int, CaseIterable {
    case section0 = 0
    case section1
    case section2
    case section3
    case section4
    case section5
    case section6
    case section7
    case section8
    case section9
    case section10
    case unknown
    
    static func section(for index: Int) -> SectionType {
        return SectionType(rawValue: index) ?? .unknown
    }
}
