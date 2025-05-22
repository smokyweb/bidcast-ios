//
//  FSCalendar.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 22/05/25.
//

import Foundation
import SwiftUI
import FSCalendar

struct FSCalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date

    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        var parent: FSCalendarView

        init(_ parent: FSCalendarView) {
            self.parent = parent
        }

        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            let now = Calendar.current.startOfDay(for: Date())
            let thisDate = Calendar.current.startOfDay(for: date)
            if thisDate < now {
                
            }else{
                parent.selectedDate = date
            }
        }
        
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
                let now = Calendar.current.startOfDay(for: Date())
                let thisDate = Calendar.current.startOfDay(for: date)

                if thisDate < now {
                    return .lightGray  // Color for past dates
                } else {
                    return .label  // Default color
                }
            }
        
       
        func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
            let now = Calendar.current.startOfDay(for: Date())
            let thisDate = Calendar.current.startOfDay(for: date)

            if thisDate < now {
                return false  // Color for past dates
            } else {
                return true  // Default color
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        calendar.scrollDirection = .horizontal
        calendar.scope = .month
        calendar.appearance.headerTitleColor = .defaultTheme
        calendar.appearance.weekdayTextColor = .defaultTheme
        calendar.appearance.todayColor = .defaultTheme
        calendar.appearance.selectionColor = .darkBlue
        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        uiView.select(selectedDate)
    }
}
