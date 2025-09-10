//
//  GetStartedScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 17/05/25.
//

import SwiftUI
import RichText
import SwiftfulLoadingIndicators
import AlertToast

struct SelectShowScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var currentIndex = 0
    @State var tip =  TitleTipsModel()
    @State var isLoading  = false
    var viewModel = ScheduleViewModel()
    @State var title = ""
    @State var navigateToSelectCategory  = false
    @State var navigateToAddProduct  = false
    @State var selectedDate  = Date()
    @State var selectedTime  = Date()
    @State var date = Date()
    @Binding var request : StoreScheduleShowRequest
    @Binding var thumbNail : String
    @Binding var comeFromPrepareScreen : Bool
    @State var showhud: Bool = false
    @Binding var backToPrepare : Bool
    @State var hudMsg: String = ""
    
    var delegate: ShowStepDelegate?
    
    var body: some View {
        VStack(spacing:18){
           
            VStack{
                PrimaryHeader(
                    title: "Select Show Time".localized,
                    isForLogo : false, leadingImgArr: [.sideArrow],
                    trailingImgArr: [],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
                
            }
            ScrollView(showsIndicators: false) {
                VStack(alignment:.leading,spacing: 16) {
                    VStack(alignment:.leading,spacing: 24){
                        FSCalendarView(selectedDate: $selectedDate)
                                       .frame(height: 300)
                    }
                    .padding(.horizontal,Leading/2)
                    .background(.white)
                    .cornerRadius(12)
                    VStack{
                        HStack{
                            Text("Select Time")
                                .font(.custom(poppinsBold, size: 15.0))
                            Spacer()
                        }
                        .padding(.top,4)
                        
                        TimePickerView(selectedDate: $selectedDate,onTImeSelected: { time in
                            selectedTime = time
                        })
                    }
                    .padding(.horizontal,Leading/2)
                    .background(.white)
                    .cornerRadius(12)
                    
                }
            }
            .padding(.top,10)
            .padding(.horizontal,Leading)
            //            .background(.green)
            PrimaryButton(title: "Continue",isOutLine: false,onButtonClick: {
                print("date : \(selectedDate) time : \(selectedTime)")
                
                let selectedDateStr = formatDate(selectedDate, format: "yyyy-MM-dd")
                    let selectedTimeStr = formatDate(selectedTime, format: "HH:mm")

                    print("📆 Date in local time: \(selectedDateStr)")
                    print("⏰ Time in local time: \(selectedTimeStr)")
                request.date = selectedDateStr
                request.time = selectedTimeStr
                print(request)
                if comeFromPrepareScreen {
                    delegate?.didUpdateRequest(request, thumbNail: "")
                    presentationMode.wrappedValue.dismiss()
                }else{
                    guard !request.title.isEmpty else {
                        hudMsg = "Please enter title"
                        showhud = true
                        return
                    }
                    guard !request.category_id.isEmpty else {
                        hudMsg = "Please enter category type"
                        showhud = true
                        return
                    }
                    guard !request.auction_type_id.isEmpty else {
                        hudMsg = "Please enter auction type"
                        showhud = true
                        return
                    }
                    guard !thumbNail.isEmpty else {
                        hudMsg = "Please select thumbnail image"
                        showhud = true
                        return
                    }
                    guard !request.date.isEmpty else {
                        hudMsg = "Please select date"
                        showhud = true
                        return
                    }
                    guard !request.time.isEmpty else {
                        hudMsg = "Please select time"
                        showhud = true
                        return
                    }
                    
                    navigateToAddProduct = true
                }
//                navigateToSelectCategory = true
            },cornerRadius: 12, btnTextColor: .white)
            CusNavLink(doNavigate: $navigateToAddProduct, destination: CreateProductScreen(requests: $request, thumbNail: $thumbNail,backToPrepare: $backToPrepare,fromPrepare: .constant(false)))
//            CusNavLink(doNavigate: $navigateToAddProduct, destination: AddProductsScreen(request:$request,thumbNail: $thumbNail,fromPrepare: .constant(false),backToPrepare: $backToPrepare))
           
        }
    
        .edgesIgnoringSafeArea(.bottom)
        .background(.bg.opacity(0.5))
        .toolbar(.hidden,for: .tabBar)
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
    }
    
    func formatDate(_ date: Date, format: String = "yyyy-MM-dd HH:mm") -> String {
        let formatter = DateFormatter()
        formatter.timeZone = .current // Use device's timezone
        formatter.locale = .current   // Respect user's locale (e.g., AM/PM or 24hr)
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    func success() {
        let dict = viewModel.tipsResponse
        if dict?.status == "success" {
            tip = dict?.data ?? TitleTipsModel()
            } else {
                print("API error: \(dict?.status ?? "")")
            }
        
    }
    //    private func goToNextStep() {
    //        if currentIndex < prepare.count - 1 {
    //            currentIndex += 1
    //        }else{
    //            navigateToTips = true
    //        }
    //    }
}

//#Preview {
//    SelectShowScreen()
//}


//import SwiftUI

struct TimePickerView: View {
    @Binding var selectedDate: Date
    @State var selectedTime: Date? = nil

    let intervalMinutes = 60
    let calendar: Calendar = {
            var cal = Calendar.current
            cal.timeZone = TimeZone.current
            return cal
        }()

    let columns = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    var onTImeSelected : (Date ) -> () = {_ in }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(filteredSlots(date: selectedDate), id: \.self) { time in
                    Button(action: {
                        onTImeSelected(time)
                        selectedTime = time
                    }) {
                        Text(formatTime(time))
                            .font(.custom("Poppins-SemiBold", size: 13.0))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(selectedTime == time ? .white : .black)
                            .background(selectedTime == time ? Color.defaultTheme : Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .cornerRadius(10)
                    }
                    .frame(height: 40)
                    .padding([.top, .bottom], 4)
                }
            }
            .padding()
        }
        .cornerRadius(16)
    }

    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        let format = DateFormatter.dateFormat(fromTemplate: "j:mm", options: 0, locale: Locale.current)!
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    func filteredSlots(date : Date) -> [Date] {
        let baseSlots = Self.generateTimeSlots(from: "09:00", to: "21:00", intervalMinutes: intervalMinutes)
        let now = Date()
        let isToday = calendar.isDateInToday(date)

        return baseSlots.compactMap { baseSlot in
            let slotDateTime = calendar.date(
                bySettingHour: calendar.component(.hour, from: baseSlot),
                minute: calendar.component(.minute, from: baseSlot),
                second: 0,
                of: selectedDate
            )

            if isToday {
                return (slotDateTime ?? now) > now ? slotDateTime : nil
            } else {
                return slotDateTime
            }
        }
    }

    static func generateTimeSlots(from start: String, to end: String, intervalMinutes: Int) -> [Date] {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
               formatter.dateFormat = "HH:mm"

        guard
            let startTime = formatter.date(from: start),
            let endTime = formatter.date(from: end)
        else { return [] }

        var times: [Date] = []
        var currentTime = startTime

        while currentTime <= endTime {
            times.append(currentTime)
            if let nextTime = Calendar.current.date(byAdding: .minute, value: intervalMinutes, to: currentTime) {
                currentTime = nextTime
            } else {
                break
            }
        }

        return times
    }
}
