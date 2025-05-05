//
//  DatePicker.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 01/02/24.
//

import SwiftUI

struct DatePickerView: View {
    @Binding var closePopUp: Bool
    @Binding var date: Date
    @State var startDate: String = (Calendar.current.date(byAdding: .year, value: -99, to: Date())?.toString() ?? "")
    @State var selectFuture: Bool = true
    var dateChanged: ((Date) -> Void)?
    
    @ViewBuilder
    func InterviewCard() -> some View {
        VStack(spacing: 16) {
            Image(.imgPlaceholder)
                .resizable()
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    Text("Job Title")
                        .font(.custom(nunitoBold, fixedSize: 18))
                        .foregroundStyle(.black)
                    
                    Text("$15/hr")
                        .font(.custom(nunitoRegular, fixedSize: 15))
                        .foregroundStyle(.black)
                    
                    Text("Comnpany Name")
                        .font(.custom(nunitoRegular, fixedSize: 15))
                        .foregroundStyle(.gray)
                }
                Spacer()
            }
        }
        
    }
    
    var body: some View {
        VStack(spacing: 0) {
            PrimaryHeader(
                title: "Schedule Interview",
                trailingImgArr: [.cancel],
                onClickTrailing: { _ in
                    
                })
            
            ScrollView(showsIndicators: false, content: {
                VStack(alignment: .center, spacing: 0) {
                    InterviewCard()
                    
                    Divider()
                    
                    DatePicker(
                        "Pick a date",
                        selection: $date,
                        in: startDate.toDate() ... (selectFuture ? Calendar.current.date(byAdding: .year, value: 5, to: Date())! : Date()),
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .tint(.red)
                    .padding(.horizontal, 30)
                    
                    
                    Divider()
                }.padding(.all)
            }).padding(.top, -topPadding)
            
        }
        .frame(width: screenWidth)
        .background(Color("backgroundColor"))
    }
}

#Preview {
    DatePickerView(closePopUp: .constant(false), date: .constant(Date()))
}

extension String {
    func toDate() -> Date {
        let format = DateFormatter()
        format.dateFormat = "dd-MM-yyyy"
        return format.date(from: self) ?? Date()
    }
}

extension View {
    @ViewBuilder func changeTextColor(_ color: Color) -> some View {
        if UITraitCollection.current.userInterfaceStyle == .light {
            self.colorInvert().colorMultiply(color)
        } else {
            self.colorMultiply(color)
        }
    }
}
