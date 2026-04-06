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
import SVProgressHUD

struct SelectShowScreen: View {

    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var productManager: ProductManager
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
//    @Binding var backToPrepare : Bool
    @State var hudMsg: String = ""
    
    @EnvironmentObject var coordinator: LetsPrepareCoordinator
    
    var body: some View {
        VStack(spacing:18){
           
            VStack{
                PrimaryHeader(
                    title: "Select Show Time".localized,
                    isForLogo : false, leadingImgArr: ["chevron.left"],
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
                        
                        TimePickerView(selectedDate: $selectedDate,
                                       selectedTime: $selectedTime,
                                       onTImeSelected: { time in
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
//                    delegate?.didUpdateRequest(request, thumbNail: "")
                    Task { @MainActor in
                        coordinator.request = request
                        coordinator.thumbNAil = ""

                        coordinator.markCurrentStepCompleted()
                    }
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
                    Task{
                        SVProgressHUD.show()
                        if request.show_id != "" {
                            let param = checkScheduleRequest(show_id:request.show_id ?? "" ,date: request.date, time: request.time)
                            await viewModel.CheckScheduleShow(param: param)
                            await SVProgressHUD.dismiss()
                        }else{
                            let param = checkScheduleRequest(date: request.date, time: request.time)
                            await viewModel.CheckScheduleShow(param: param)
                            await SVProgressHUD.dismiss()
                        }
                        if self.viewModel.errorMessage == nil || viewModel.errorMessage == ""{
                            scheduleSuccess()
                        }else{
                            
                        }
                    }
//                    navigateToAddProduct = true
                }
//                navigateToSelectCategory = true
            },cornerRadius: 32, btnTextColor: .white)
            
            
            
            
            CusNavLink(doNavigate: $navigateToAddProduct, destination:
                        AddProductsScreen(
                            request: $request,
                            thumbNail: $thumbNail,
                            fromPrepare: .constant(false),
                            NavFromProductLibrary: .constant(false),
                            backToCreateProduct: $navigateToAddProduct,
                            didTapBack: { _,_,_  in },
                            didTapEdit: { _,_ in }
                        )
                        .environmentObject(productManager)
            )
//            CusNavLink(doNavigate: $navigateToAddProduct, destination: AddProductsScreen(request:$request,thumbNail: $thumbNail,fromPrepare: .constant(false),backToPrepare: $backToPrepare))
           
        }
    
        .edgesIgnoringSafeArea(.bottom)
        .background(.bg.opacity(0.5))
        .toolbar(.hidden,for: .tabBar)
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .onAppear {
                    // ⭐ LOAD EXISTING DATE AND TIME
                    loadExistingDateTime()
                }
    }
    
    func loadExistingDateTime() {
            // Parse date if available
            if !request.date.isEmpty {
                if let date = parseDate(request.date, format: "yyyy-MM-dd") {
                    selectedDate = date
                    print("✅ Loaded existing date: \(request.date) -> \(selectedDate)")
                }
            }
            
            // Parse time if available
        if !request.time.isEmpty {
            // Try parsing with seconds first (HH:mm:ss), then fallback to HH:mm
            let timeFormat = request.time.contains(":") && request.time.split(separator: ":").count == 3 ? "HH:mm:ss" : "HH:mm"
            
            if let time = parseDate(request.time, format: timeFormat) {
                // Combine the selected date with the parsed time
                let calendar = Calendar.current
                let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
                if let combinedDateTime = calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                                        minute: timeComponents.minute ?? 0,
                                                        second: 0,
                                                        of: selectedDate) {
                    selectedTime = combinedDateTime
                    print("✅ Loaded existing time: \(request.time) -> \(selectedTime)")
                }
            }
        }
        }
    func parseDate(_ dateString: String, format: String) -> Date? {
           let formatter = DateFormatter()
           formatter.timeZone = .current
           formatter.locale = .current
           formatter.dateFormat = format
           return formatter.date(from: dateString)
       }
    func scheduleSuccess(){
        let response = viewModel.checkScheduleResponse
        if response?.status == "success"{
            if response?.data.isExists ?? false{
                showhud = true
                hudMsg = "Please select another date for scheduling show"
            }else{
                navigateToAddProduct = true
            }
        }else{
            
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
    
    @Binding var selectedTime: Date

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
                ForEach(filteredSlots(for: selectedDate), id: \.self) { time in
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

    func isTimeSelected(_ time: Date) -> Bool {
           let timeHour = calendar.component(.hour, from: time)
           let timeMinute = calendar.component(.minute, from: time)
           let selectedHour = calendar.component(.hour, from: selectedTime)
           let selectedMinute = calendar.component(.minute, from: selectedTime)
           
           return timeHour == selectedHour && timeMinute == selectedMinute
       }
    
    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        let format = DateFormatter.dateFormat(fromTemplate: "j:mm", options: 0, locale: Locale.current)!
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    func filteredSlots(for date : Date) -> [Date] {
        
        let now = Date()
        let isToday = calendar.isDateInToday(date)
        var baseSlots:[Date] = []
        if !isToday {
            baseSlots = Self.generateTimeSlots(from: "00:00", to: "23:00", intervalMinutes: intervalMinutes)
        }
        else {
            let currentHour = currentHourStringWithTimeZone()
            print(currentHour)
            baseSlots = Self.generateTimeSlots(from: "\(currentHour)", to: "23:00", intervalMinutes: intervalMinutes)
        }
        
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
    
    
    func currentHourStringWithTimeZone() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:00"
        formatter.timeZone = TimeZone.current  // 👈 ensures it uses the user's local timezone
        return formatter.string(from: date)
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
