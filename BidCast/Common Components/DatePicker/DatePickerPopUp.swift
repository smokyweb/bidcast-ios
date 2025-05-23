//
//  DatePickerPopUp.swift
// BidSwipe
//
//  Created by Ankit - JAM - E - 294 on 01/02/24.
//

import SwiftUI

struct DatePickerPopUp: View {
    
    @State var date: Date = Date()
    @State var startDate: String = (Calendar.current.date(byAdding: .year, value: -99, to: Date())?.toString() ?? "")
    @State var selectFuture: Bool = false
    
    var dateChanged: ((Date) -> Void)?
    var onCancelClick: (() -> Void)?
    
    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                DatePicker(
                    "Pick a date",
                    selection: $date,
//                    in: startDate.toDate() ... (selectFuture ? Calendar.current.date(byAdding: .year, value: 5, to: Date())! : Date()),
                    displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .labelsHidden()
                .tint(.red)
                
                Divider()
                HStack {
                    Button(action: { self.onCancelClick?() }, label: {
                        Text("Cancel")
                            .font(.custom(nunitoRegular, fixedSize: 14))
                    })
                    Spacer()
                    Button(action: {
                        self.onCancelClick?()
                        self.dateChanged?(date)
                    }, label: {
                        Text("Submit")
                            .font(.custom(nunitoSemiBold, fixedSize: 14))
                    })
                }.padding(.all, 10)
            }
            .frame(width: screenWidth / 1.35)
            .background(.white)
            .cornerRadius(15)
            .shadow(color: .gray, radius: 4, x: 0, y: 0)
            Spacer()
        }
        .frame(width: screenWidth)
        .background(.text.opacity(0.35))
    }
}

#Preview {
    DatePickerPopUp()
}
