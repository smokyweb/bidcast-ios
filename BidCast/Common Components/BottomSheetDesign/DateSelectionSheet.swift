//
//  DateSelectionSheet.swift
// BidSwipe
//
//  Created by Maneet-JAM-E-282 on 02/03/24.
//

import SwiftUI

struct DateSelectionSheet: View {
    
    @State var selectedDate: Date = Date()
    @State var showFutureDate: Bool = false
    
    var showTime: Bool = false
    var comefromEndDate : Bool = false
        //MARK: - CallBack Functions
    var onConfirmClick: ((String, String) -> Void)?
    var onCancelClick: (() -> Void)?
    var onPresentClick: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 70) {
                Text("Select Date")
                    .font(.custom(nunitoBold, fixedSize: 22))
                    .bold()
                    .foregroundStyle(.pinkBtn)
                if comefromEndDate{
                    PrimaryButton(title: "Present", isOutLine: true, onButtonClick: {
                        self.onPresentClick?()
                    }, width: screenWidth/2.5, height: 40, btnColor: .green)
            }
            }
            
            DatePicker(
                "Pick a date",
                selection: $selectedDate,
                in: showFutureDate ? Date() ... Calendar.current.date(byAdding: .year, value: 10, to: Date())! : Calendar.current.date(byAdding: .year, value: -50, to: Date())! ...  Date(),
                displayedComponents: showTime ? [.date, .hourAndMinute] : [.date]
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .tint(.red)
            .padding(.horizontal, 40)
            
            HStack {
                PrimaryButton(title: "Cancel", isOutLine: true, onButtonClick: {
                    self.onCancelClick?()
                }, width: screenWidth/2.5, height: 40, btnColor: .pinkBtn)
                
                PrimaryButton(title: "Confirm", isOutLine: false, onButtonClick: {
                    self.onConfirmClick?("\(selectedDate.forInterview().split(separator: " @ ").first ?? "")", "\(selectedDate.forInterview().split(separator: " @ ").last ?? "")")
                }, width: screenWidth/2.5, height: 40, btnColor: .pinkBtn)
            }
            
        }
        .padding()
    }
}

#Preview {
    DateSelectionSheet()
}
