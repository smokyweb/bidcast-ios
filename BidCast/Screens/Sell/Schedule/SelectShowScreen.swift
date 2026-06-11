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

// #9986412273: replaced the hourly slot-grid (filteredSlots / LazyVGrid)
// with a 3-wheel Picker (Hour 1–12 / Minute 00,05,…,55 / AM-PM) to match
// the PWA clock-style picker.  The struct name, Binding parameters, and
// onTImeSelected callback are unchanged so SelectShowScreen needs no edits.
// Validation rule (#9986417249) is preserved: today → past combinations
// show a warning and do not propagate; future dates → all times allowed.
struct TimePickerView: View {
    @Binding var selectedDate: Date
    @Binding var selectedTime: Date
    var onTImeSelected: (Date) -> () = { _ in }

    // 5-minute minute labels: "00", "05", "10", …, "55"
    private let minuteLabels: [String] = (0..<12).map { String(format: "%02d", $0 * 5) }

    private let calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = TimeZone.current
        return cal
    }()

    // Picker state stored as indices
    @State private var hourIdx:  Int = 11  // 0→1, …, 11→12  (default noon)
    @State private var minIdx:   Int = 0   // 0→"00", …, 11→"55"
    @State private var ampmIdx:  Int = 1   // 0=AM, 1=PM

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {

            // Column headers
            HStack {
                Text("Hour")
                    .font(.custom(poppinsSemiBold, size: 12))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                Text("Min")
                    .font(.custom(poppinsSemiBold, size: 12))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                Text("AM / PM")
                    .font(.custom(poppinsSemiBold, size: 12))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)

            // 3-wheel row
            HStack(spacing: 0) {
                // Hour wheel  1…12
                Picker("Hour", selection: $hourIdx) {
                    ForEach(0..<12, id: \.self) { i in
                        Text("\(i + 1)")
                            .font(.custom(poppinsSemiBold, size: 17))
                            .tag(i)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .clipped()
                .onChange(of: hourIdx)  { _ in commitTime() }

                // Minute wheel  00, 05, …, 55
                Picker("Minute", selection: $minIdx) {
                    ForEach(0..<12, id: \.self) { i in
                        Text(minuteLabels[i])
                            .font(.custom(poppinsSemiBold, size: 17))
                            .tag(i)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .clipped()
                .onChange(of: minIdx)   { _ in commitTime() }

                // AM / PM wheel
                Picker("AM/PM", selection: $ampmIdx) {
                    Text("AM").font(.custom(poppinsSemiBold, size: 17)).tag(0)
                    Text("PM").font(.custom(poppinsSemiBold, size: 17)).tag(1)
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                .clipped()
                .onChange(of: ampmIdx)  { _ in commitTime() }
            }
            .frame(height: 150)

            // Past-time warning — mirrors PWA #timePastWarning / Android timePastWarning
            if isPastTimeSelected() {
                Text("Please select a future time.")
                    .font(.custom(poppinsRegular, size: 12))
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .padding(.top, 2)
            }
        }
        .onAppear { syncPickersFromSelectedTime() }
        .onChange(of: selectedDate) { _ in
            // Re-validate when the user picks a different calendar date
            commitTime()
        }
        .onChange(of: selectedTime) { newTime in
            // Keep pickers in sync when selectedTime is updated externally
            // (e.g. loadExistingDateTime on appear)
            syncFromDate(newTime)
        }
    }

    // MARK: - Helpers

    /// Convert current picker indices to a 24-hour (hour, minute) pair.
    private func pickedHour24() -> Int {
        let h12 = hourIdx + 1          // 1…12
        let pm  = ampmIdx == 1
        switch (pm, h12) {
        case (false, 12): return 0
        case (true,  12): return 12
        case (true,   _): return h12 + 12
        default:          return h12
        }
    }

    /// Build a Date for the currently picked time combined with selectedDate.
    private func pickedDateTime() -> Date? {
        let h24 = pickedHour24()
        let min = minIdx * 5
        return calendar.date(
            bySettingHour: h24, minute: min, second: 0, of: selectedDate
        )
    }

    /// True when the currently selected date is today and the picked time is
    /// in the past (same rule as #9986417249).
    private func isPastTimeSelected() -> Bool {
        guard calendar.isDateInToday(selectedDate) else { return false }
        guard let dt = pickedDateTime() else { return false }
        return dt <= Date()
    }

    /// Push the picked time to the parent only when it is valid (future).
    private func commitTime() {
        guard let dt = pickedDateTime() else { return }
        // For today: reject past times.  For future dates: always accept.
        if calendar.isDateInToday(selectedDate) && dt <= Date() { return }
        selectedTime = dt
        onTImeSelected(dt)
    }

    /// Sync the three wheel pickers from a given Date value.
    private func syncFromDate(_ date: Date) {
        let h24  = calendar.component(.hour,   from: date)
        let rawM = calendar.component(.minute, from: date)
        // Snap to nearest 5-min boundary
        let snappedM = min(55, Int((Double(rawM) / 5.0).rounded()) * 5)

        let newAmpm  = h24 >= 12 ? 1 : 0
        let h12      = { () -> Int in
            switch h24 {
            case 0:  return 12
            case 13...: return h24 - 12
            default:    return h24
            }
        }()
        let newHourIdx = h12 - 1          // 0-based (1→0, …, 12→11)
        let newMinIdx  = snappedM / 5

        if hourIdx  != newHourIdx { hourIdx  = newHourIdx }
        if minIdx   != newMinIdx  { minIdx   = newMinIdx  }
        if ampmIdx  != newAmpm    { ampmIdx  = newAmpm    }
    }

    private func syncPickersFromSelectedTime() {
        syncFromDate(selectedTime)
    }
}
