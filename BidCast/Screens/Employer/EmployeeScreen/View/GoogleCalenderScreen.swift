//
//  GoogleCalenderScreen.swift
//  imperium
//
//  Created by Jamtech on 15/05/24.
//

import SwiftUI
import AlertToast
import Combine

enum PickerType {
    case start, end
}

struct GoogleCalenderScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDate: Date = Date()
    @State private var events: [String] = []
    @State private var selectedChips: Set<String> = []
    @State private var selectedChip: String?
    @Environment(\.sizeCategory) var sizeCategory
    @State private var isStartTimePickerPresented = false
    @State private var isEndTimePickerPresented = false
    @State var isLoading: Bool = false
    @State private var startTime = ""
    @State private var endTime = ""
    @State private var navigateToScheduleInterviewScreen = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var check = false
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State private var timeSlots: [TimeSlot] = []
    @State var showAlert: Bool = false

    var days = ["Mon","Tue","Wed","Thu","Fri","Sat"]
   
    @State var abbreviatedDays = [String]()
    @State var fullDays = [String]()
    @State var duration: String = "Select Duration"
    @State var durationOption = ["15 min","30 min","45 min","60 min"]
    
    @State private var selectedStartTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()//Date()
    @State private var selectedEndTime: Date = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date()) ?? Date()//Date()
    @State var syncDetails: Bool = false

    @State var viewModal = EmployeeProfileViewModal()
    @State var request: EmployerAvailabilityRequest = EmployerAvailabilityRequest(day_name: [""], duration: "", end_time: "", start_time: "")
    @State private var selectedDays: [String] = []
    let calendar = Calendar.current
    let timeInterval: TimeInterval = 60 * 15
    private let didBecomeActivePublisher = NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
    
    @State private var notificationObserver: AnyCancellable?
    
    var body: some View {
        
        ZStack {
            VStack(spacing: 0, content: {
                PrimaryHeader(title: "Calendar Management", leadingImgArr: [.sideArrow], onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                }, count: .constant(0))
                TitleWithLine(title: "Calendar Events", lineLength: 36)
                    .padding(.horizontal)
                    .padding(.top, -30)
                
                Spacer()
//                MenuListCard(check: true,menu: MenuModal(title: "Google Calender", img: .google)) { _ in
//                }.padding([.horizontal,.top])
                
                SubscriptionCard(comeFromCalendar: true, syncDetails: syncDetails)
                    .padding([.horizontal,.top])
                Spacer()
                Text("Working Days").font(.custom(nunitoMedium, fixedSize: 15))
                    .multilineTextAlignment(.leading)
                    .padding(.top, 15)
                HStack{
                    ForEach(days, id: \.self) { chipText in
                        ChipView(text: chipText, isSelected: selectedChips.contains(chipText)) {
                            let selecteddays = self.viewModal.getEmployerAvailability?.data?.day_name
                            let stringRepresentation = selecteddays?.joined(separator: ", ")
                            if selectedChips.contains(chipText) {
                                selectedChips.remove(chipText)
                            }/* else if !selectedChips.isEmpty {
                              var newChipSet: Set<String> = []
                              newChipSet.insert(chipText)
                              selectedChips.formUnion(newChipSet)
                              abbreviatedDays.append(contentsOf: selectedChips)
                              print("\(selectedChips) chips selected")
                              }*/else{
                                  selectedChips.insert(chipText)
                                  abbreviatedDays.append(chipText)
                                  abbreviatedDays.append(stringRepresentation ?? "")
                                  
                                  print("\(chipText) chip tapped")
                                  print("abbreviatedDays=====>",abbreviatedDays)
                              }
                            
                        }
                        
                    }
                    
                    
                }
                .padding(.top,20)
                Spacer()
                Text("Working Hours").font(.custom(nunitoMedium, fixedSize: 14))
                    .multilineTextAlignment(.leading)
                    .padding(.top, 25)
                
                
                HStack {
                    
                    ChipView(text: "Start Time: \(formattedTime(date: selectedStartTime))") {
                        self.startTime = formattedTime(date: selectedStartTime)
                        self.isStartTimePickerPresented.toggle()
                    }
                    ChipView(text: "End Time: \(formattedTime(date: selectedEndTime))") {
                        self.endTime = formattedTime(date: selectedEndTime)
                        self.isEndTimePickerPresented.toggle()
                    }
                    
                }
                
                .padding(.all)
                
                .sheet(isPresented: $isStartTimePickerPresented) {
                    CustomSheetView {
                        DateTimePickerView(selectedDate: $selectedStartTime, isPresented: $isStartTimePickerPresented)
                        
                    }
                    .presentationDetents([.height(250)])
                }
                .sheet(isPresented: $isEndTimePickerPresented) {
                    CustomSheetView {
                        DateTimePickerView(selectedDate: $selectedEndTime, isPresented: $isEndTimePickerPresented)
                    }
                    .presentationDetents([.height(250)])
                }
                Spacer()
                
//                VStack(alignment: .leading, spacing: 12, content: {
//                    Text("Select Interview Duration")
//                        .font(.custom(nunitoSemiBold, fixedSize: 14))
//                    DropDownTextField(
//                        hint: "Select Interview Duration",
//                        text: $duration,
//                        options: $durationOption,
//                        leadingIcon: .location,
//                        showLeadingIcon: false,
//                        showTrailingIcon: false,
//                        showDropDownIcon: true,
//                        anchor: .top)
//                }).zIndex(2100.0)
                
                
                DropDown(hint: duration == "" ? "Please select duration" : duration,
                         options: durationOption,
                         anchor: .top,
                         floatingLabel:"Select Interview Duration",
                         cornerRadius: 25,
                         showLeadingIcon:true,
                         leadingIcon:.location)
                .zIndex(2400.0)
                    .padding(.top,15)
                Spacer()
                
                List(events, id: \.self) { event in
                    Text(event)
                }
                PrimaryButton(title: "Save", isOutLine: false, onButtonClick: {
                    self.setAvailabilty()
                    // Dismiss the detail view
                    if self.fullDays.count > 0 && self.duration != "Select Duration"{
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    
                    
                }, width: screenWidth-30, height: 45, btnColor: .text)
                .padding(.bottom, 20)
                .toast(isPresenting: $showhud) {
                    AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
            }
            )
            
            .bottomSheet(isPresented: $showAlert, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        withAnimation { showAlert = false }
                    }, onSecondaryClick: {
                        withAnimation { showAlert = false }
                    })
            })
            if isLoading {
                Loader(isLoading: $isLoading)
            }
            
        } .onAppear {
            self.observeNotifications()
            observe()
            self.viewModal.getEmployerAvailabilityData()
            
        }
        .onDisappear {
                    self.notificationObserver?.cancel()
                }
        
        
    }
    
    private func observeNotifications() {
        notificationObserver = NotificationCenter.default.publisher(for: Notification.Name("HandleUniversalLink"))
            .sink { notification in
                if let incomingURL = notification.object as? URL {
                    self.handleUniversalLink(incomingURL)
                }
            }
    }
    
        func handleUniversalLink(_ url: URL) {
             print(url)
                 let code = url.queryParameters?["code"]
            self.viewModal.CreateEvents(param: CreateEventParam(code: code ?? ""))

         }

        
    func hasTwoDigits(in duration: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "\\d{2}")
        let range = NSRange(location: 0, length: duration.utf16.count)
        return regex.firstMatch(in: duration, range: range) != nil
    }
    
    func setAvailabilty(){
        let days = convertToFullDayNames(abbreviatedNames: abbreviatedDays)
        fullDays = days
        print("fullDays are",fullDays)
        
        if self.fullDays == []{
            request.day_name = self.viewModal.getEmployerAvailability?.data?.day_name ?? []
        }else{
            request.day_name = self.fullDays
        }
 
        let duration = self.duration
        if  self.duration == "" || isOnlyTwoDigitNumber(duration)  {
            request.duration = self.duration
        }else{
            var duration = self.duration
            let endtime: () = duration.removeLast(4)
            request.duration = duration
        }

        
        print("\(startTime)")
        print("\(endTime)")

       
        if fullDays.count == 0 && self.viewModal.getEmployerAvailability?.data?.day_name == []{
            hudMsg = "Please select interview days"
            showhud = true
        }else if self.duration == ""{
            hudMsg = "Please select interview duration"
            showhud = true
        }else if formattedTime(date: selectedStartTime) == formattedTime(date: selectedEndTime){
            hudMsg = "Start time and end time can not be same"
            showhud = true
        }else if formattedTime(date: selectedStartTime)>formattedTime(date: selectedEndTime){
            hudMsg = "End time can not be before start time"
            showhud = true
        }else{
            request.start_time = formattedTime(date: selectedStartTime)
            request.end_time = formattedTime(date: selectedEndTime)
            observe()
            self.viewModal.setEmployerAvailabilityData(parameter: request)
        }
        
    }
    
    
    
    func formattedTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
//    func convertDateTo12HourFormat(date: String) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "h:mm a" // 12-hour format with AM/PM
//        
//        // Optionally set the locale if needed to ensure consistent formatting
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//        
//        return dateFormatter.string(from: date)
//    }
    func convertToDate(from time: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        if let date = dateFormatter.date(from: time) {
            return date
        }
        
        return nil
    }
    
    private func formattedDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a" // 12-hour format with AM/PM
        return dateFormatter.string(from: selectedDate)
    }
    
    func isOnlyTwoDigitNumber(_ string: String) -> Bool {
        let pattern = "^\\d{2}$" // ^ and $ assert position at the start and end of the string, respectively
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: string.utf16.count)
        let matches = regex.matches(in: string, options: [], range: range)
        return !matches.isEmpty
    }
    
    func convertToFullDayNames(abbreviatedNames: [String]) -> [String] {
        let dayNameMap: [String: String] = [
            "Sun": "Sunday",
            "Mon": "Monday",
            "Tue": "Tuesday",
            "Wed": "Wedneday",
            "Thu": "Thursday",
            "Fri": "Friday",
            "Sat": "Saturday"
        ]
        let newArr = abbreviatedNames.compactMap{ abbreviatedName in
            return dayNameMap[abbreviatedName]
        }//abbreviatedNames.compactMap { dayNameMap[$0.lowercased()] }
        print("newArr=====>", newArr)
        return newArr
    }
    
    func convertToShortDayNames(abbreviatedNames: [String]) -> [String] {
        let dayNameMap: [String: String] = [
            "Sunday": "Sun",
            "Monday":"Mon",
            "Tuesday":"Tue",
            "Wedneday":"Wed",
            "Thursday":"Thu",
            "Friday":"Fri",
            "Saturday":"Sat"
        ]
        let newArr = abbreviatedNames.compactMap{ abbreviatedName in
            return dayNameMap[abbreviatedName]
        }//abbreviatedNames.compactMap { dayNameMap[$0.lowercased()] }
        print("newArr=====>", newArr)
        return newArr
    }
    
    //MARK: - View Modal Observe
    func observe() {
        self.viewModal.eventHandler = {
            event in
            switch event {
            case .loading:
                isLoading = true
            case .stopLoading:
                isLoading = false
            case .dataLoaded:
                handleSuccess()
            case .error(let error):
                alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                showAlert = true
                return
            }
        }
    }
    
    //MARK: View Modal Handle Success
    func handleSuccess() {
        if viewModal.requestType == "GetEmployerAvailability"{
            let response = viewModal.getEmployerAvailability
            if response?.status == "success" {
                self.selectedStartTime = convertToDate(from: self.viewModal.getEmployerAvailability?.data?.start_time ?? "") ?? Date()
                self.selectedEndTime = convertToDate(from: self.viewModal.getEmployerAvailability?.data?.end_time ?? "") ?? Date()
                self.syncDetails = response?.data?.isCalSync ?? false
                
                if self.viewModal.getEmployerAvailability != nil{
                    selectedDays = self.viewModal.getEmployerAvailability?.data?.day_name ?? []
                    let days = convertToShortDayNames(abbreviatedNames: selectedDays)
                    print("dbfjshdknfksdb====>>>",selectedDays)
                  //  selectedChips = Set(days)
                    selectedChips.formUnion(days)
                    let duration = self.viewModal.getEmployerAvailability?.data?.duration ?? ""
                   
                    self.duration = duration
                }
            } else {
                alertType = .sheetType(icon: .alert, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .pinkBtn)
                showAlert = true
            }
        }else if viewModal.requestType == "SetEmployerAvailability"{
            let response = viewModal.setEmployerAvailability
            if response?.status == "success" {
                alertType = .sheetType(icon: .success, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .green)
                showAlert = true
            } else {
                alertType = .sheetType(icon: .alert, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .pinkBtn)
                showAlert = true
            }
        }else if viewModal.requestType == "CreateEvents"{
            let response = viewModal.createEventDict
            if viewModal.createEventDict?.status == "success" {
                alertType = .sheetType(icon: .success, title: response?.status?.capitalized ?? "", message: "Google calendar sync successfully.", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .green)
                showAlert = true
               // viewModal.getDetail()
            } else {
                alertType = .sheetType(icon: .alert, title: response?.status?.capitalized ?? "", message: response?.message?.capitalized ?? "", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .pinkBtn)
                showAlert = true
            }
        }  
    }
    
    
}

struct ChipView: View {
    var text: String
    var isSelected: Bool = false
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            
            HStack {
                Text(text)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .padding(.horizontal, 12)
            }
            .padding(.vertical, 8)
            .background(isSelected ? .text : .white)
            .foregroundColor(isSelected ? .white : .black)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.text : Color.black, lineWidth: 1)
            )
            .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        
    }
    
    
}
struct TimeSlot {
    let startTime: String
    let endTime: String
}


struct DateTimePickerView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack{
            DatePicker("", selection: $selectedDate, displayedComponents: .hourAndMinute)
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .frame(width: 200)
                .frame(height: 100)
                .padding(.bottom,30)
                
            PrimaryButton(title: "Done", isOutLine: false, onButtonClick: {
                self.isPresented = false
            }, width: 80, height: 25, btnColor: .text)
            .padding(.top,35)
        }

        .frame(height: 200)
        
    }
}

struct CustomSheetView<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack {
            content
        }
        .background(Color.white)
        .cornerRadius(15)
       // .shadow(radius: 10)
        .padding(.top,30)
      //  .padding(.bottom,30)
    }
}
extension URL {
    var queryParameters: [String: String]? {
        guard let query = self.query else { return nil }
        var parameters: [String: String] = [:]
        for pair in query.components(separatedBy: "&") {
            let elements = pair.components(separatedBy: "=")
            if elements.count >= 2 {
                let key = elements[0]
                let value = elements[1]
                parameters[key] = value
            }
        }
        return parameters
    }
}

#Preview {
    GoogleCalenderScreen()
}



