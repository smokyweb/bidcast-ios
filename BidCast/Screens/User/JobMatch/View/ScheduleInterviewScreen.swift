//
//  ScheduleInterviewScreen.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 01/02/24.
//

import SwiftUI
import BottomSheet
import Kingfisher
import AlertToast

struct ScheduleInterviewScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
        //MARK: - Variable Initializer
    

    @Binding var interviewId: String
    @Binding var employerId: String
    @Binding var date: Date
    @Binding var isReschedule: Bool
    @State private var selectedChips: Set<String> = []
    @State var interviewDetail: InterviewScheduleModal = InterviewScheduleModal()
    @State var scheduleSuccess: Bool = false
    @State var showScheduleSuccess: Bool = false
    @State var isLoading: Bool = false
    @State private var selectedIndex: Int?
    @State private var selectedTime: String?
    @State private var selectedEndTime: String?
    @State var timeDuration: [TimeSlot]?
    @State var start_time: String?
    @State var request: ScheduleInterviewRequest = ScheduleInterviewRequest(matched_id: "", scheduledDate: "", scheduledTime: "", timezone: "UTC", scheduledEndTime: "")
    
    @State var hudMsg: String = ""
    @State var showHud: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false

    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    
        //MARK: - View Modal
    var viewModal = InterviewDetailViewModel()
    var timeSlotVM = EmployeeProfileViewModal()
    
        //MARK: - Interview Card View
    @ViewBuilder
    func InterviewCard() -> some View {
        VStack(spacing: 12) {
            
            KFImage.url(getMediaURL(url: interviewDetail.job?.user?.company_data?.company_logo ?? "" != "" ? interviewDetail.job?.user?.company_data?.company_logo ?? "" : interviewDetail.job?.user?.profile_image ?? ""))
                .placeholder({
                    Image(.imgPlaceholder)
                        .resizable()
                        .blur(radius: 1.5)
                        .foregroundStyle(.text.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                })
                .retry(maxCount: 3, interval: .seconds(5))
                .cacheOriginalImage()
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 55, height: 55)
                .clipShape(Circle())
            
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    Text(interviewDetail.job?.title ?? "")
                        .font(.custom(nunitoBold, fixedSize: 16))
                        .foregroundStyle(.black)
                    
                    Text("$\(interviewDetail.job?.salary ?? "")/\(interviewDetail.job?.salary_type ?? "")")
                        .font(.custom(nunitoMedium, fixedSize: 13))
                        .foregroundStyle(.black)
                    
                    Text("\(interviewDetail.job?.user?.company_data?.company_name ?? "" != "" ? interviewDetail.job?.user?.company_data?.company_name ?? "" : interviewDetail.job?.user?.name ?? "")")
                        .font(.custom(nunitoMedium, fixedSize: 13))
                        .foregroundStyle(.gray)
                }
                Spacer()
            }
        }
        .padding(.vertical)
        .background(.text.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(content: {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.text, lineWidth: 1.0)
        })
        .unredacted(when: $isLoading)
    }
    
        //MARK: - Primary View Body
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                PrimaryHeader(
                    title: isReschedule ? "Reschedule Interview" : "Schedule Interview",
                    trailingImgArr: [.cancel],
                    onClickTrailing: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    }, count: .constant(0))
                
                ScrollView(showsIndicators: false, content: {
                    VStack(alignment: .leading, spacing: 12) {
                        InterviewCard()
                        
                        Divider()
                        
                        DatePicker(
                            "Pick a date",
                            selection: $date,
                            in: Date() ...  Calendar.current.date(byAdding: .month, value: 6, to: Date())!,
                            displayedComponents: .date//[.date, .hourAndMinute]
                        )
                        .onChange(of: date) { newDate in
                                   handleDateChange(newDate)
                               }
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .tint(.red)
                        .padding(.top, -20)
                        .padding(.bottom, -20)
                        
                        Text("Time")
                            .font(.custom(nunitoBold, fixedSize: 18))
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)
                            .padding(.leading, 10)
                        if timeSlotVM.employerScheduleData?.data?.count ?? 0 > 0{
                            LazyVGrid(columns: columns, spacing: 8) {
                                let data = timeSlotVM.employerScheduleData?.data ?? []
                                ForEach(data.indices, id: \.self) { index in
                                    let isSelected = index == selectedIndex
                                    ChipView(text: data[index].start_time ?? "", isSelected: isSelected) {
                                        if isSelected {
                                            selectedIndex = nil
                                        } else {
                                            selectedIndex = index
                                            selectedTime = data[index].start_time ?? ""
                                            selectedEndTime = data[index].end_time ?? ""
                                            print("\(data[index].start_time ?? "") chip tapped")
                                        }
                                    }
                                }
                            }
                        }else{
                            VStack {
                                Image(.noData)
                                    .renderingMode(.template)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: screenWidth/2, height: screenHeight/6)
                                    .foregroundStyle(.text)
                                
                                Text("    There are no time slots on selected date.")
                                    .font(.custom(nunitoMedium, fixedSize: 18))
                                    .foregroundStyle(.gray)
                                    .multilineTextAlignment(.center)
                            }.frame(height: screenHeight * 0.2).multilineTextAlignment(.center)
                        }
                        
                        Divider()
                        
                        PrimaryButton(title: "Submit", isOutLine: false, onButtonClick: {
                            
                            if selectedTime == ""{
                                    AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
                            }else{
                                request.scheduledDate = date.toMMYY(_format: "yyyy-MM-dd")
                                request.scheduledTime = selectedTime ?? ""
                                request.scheduledEndTime = selectedEndTime ?? ""
                                request.matched_id = "\(interviewDetail.id ?? 0)"
                                Task {
                                    self.viewModal.scheduleMatchedJobInterview(parameter: request)
                                }
                            }
                        }).padding(.top)
                        
                        PrimaryButton(title: "Cancel", isOutLine: true, onButtonClick: {
                            self.presentationMode.wrappedValue.dismiss()
                        })
                    }.padding(.all)
                }).padding(.top, -topPadding)
                
            }
            .task({
                
              
                
                if employerId == ""{
                    if let emp_id: UserDetailModal = UserDefaultsManager.shared.getModel(forKey: .userDetail) {
                        let id = String(emp_id.id ?? 0)
                        let date = date.toMMYY(_format: "yyyy-MM-dd")
                        let param = EmployerScheduleRequest(date:date , employer_id: id)
                        self.timeSlotVM.employerScheduleApi(parameter: param)
                    }
                }else{
                    let date = date.toMMYY(_format: "yyyy-MM-dd")
                    let param = EmployerScheduleRequest(date:date , employer_id: employerId)
                    self.timeSlotVM.employerScheduleApi(parameter: param)
                }
                viewModal.getInterviewDetail(id: interviewId)
            })
            .toast(isPresenting: $showHud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
            .bottomSheet(isPresented: $showScheduleSuccess, height: screenHeight/2.5, topBarHeight: 0, topBarCornerRadius: 20, showTopIndicator: false) {
                InterviewScheduledSheet(
                    isSuccess: $scheduleSuccess,
                    date: $date,
                    onContinueClick: {

                        showScheduleSuccess = false
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    onCancelClick: {
                        withAnimation { showScheduleSuccess = false }
                    })
            }
            .bottomSheet(isPresented: $showError, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        withAnimation { showError = false }
                    }, onSecondaryClick: {
                        withAnimation { showError = false }
                        self.presentationMode.wrappedValue.dismiss()
                    })
            })
           
            
            if isLoading {
                Loader(isLoading: $isLoading)
            }
            
        }.onAppear{
            observeTime()
            observe()
            if let time: String = UserDefaultsManager.shared.value(forKey: .startTimeSlot) {
              start_time = time
            }
        }
    }
    
    
    private func handleDateChange(_ selectedDate: Date) {
           print("Selected date: \(selectedDate)")

        let date = selectedDate.toMMYY(_format: "yyyy-MM-dd")
        if employerId == ""{
            if let emp_id: UserDetailModal = UserDefaultsManager.shared.getModel(forKey: .userDetail) {
                let id = String(emp_id.id ?? 0)
                let param = EmployerScheduleRequest(date:date , employer_id: id)
                self.timeSlotVM.employerScheduleApi(parameter: param)
            }
        }else{
            let param = EmployerScheduleRequest(date:date , employer_id: employerId)
            self.timeSlotVM.employerScheduleApi(parameter: param)
        }

       }
    
        //MARK: - View Modal Observer
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
                case .error(_):
                    isLoading = false
            }
        }
    }
    
    func observeTime() {
        self.timeSlotVM.eventHandler = {
            event in
            switch event {
                case .loading:
                    isLoading = true
                case .stopLoading:
                    isLoading = false
                case .dataLoaded:
                    success()
                case .error(_):
                    isLoading = false
                scheduleSuccess = false
                withAnimation { showScheduleSuccess = true }
            }
        }
    }
    
        //MARK: - View Modal Handle Success
    func handleSuccess() {
        if viewModal.requestType == "GetInterviewDetail" {
            if let response = viewModal.response {
                if response.status == "success" {
                    interviewDetail = response.data
                }
            }
        } else if viewModal.requestType == "ScheduleInterview" {
            if let response = self.viewModal.scheduleJobResponse {
                if response.status == "success" {
                    scheduleSuccess = true
                    generateFeedback(type: .medium)
                    withAnimation { showScheduleSuccess = true }
                } else {
                    scheduleSuccess = false
                    withAnimation { showScheduleSuccess = true }
                }
            }
        }
    }
    
    
    func success() {
        
        if timeSlotVM.requestType == "EmployerScheduleInterView"{
            let response = timeSlotVM.employerScheduleData
            if response?.status == "success" {
                print("suceess")
            } else {
                print("failed")
                scheduleSuccess = false
                withAnimation { showScheduleSuccess = true }
            }

        }
        
    }
}

//#Preview {
//    ScheduleInterviewScreen()
//}

extension String {
    func toDate() -> Date {
        let format = DateFormatter()
        format.dateFormat = "dd-MM-yyyy"
        return format.date(from: self) ?? Date()
    }
    
    func toEventDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        if let date = dateFormatter.date(from: self) {
            return date
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm a"
        return dateFormatter.date(from: self) ?? Date()
    }
    
    func getInterviewStatus() -> String {
        switch self {
            case "1":
                return "Pending"
            case "2":
                return "Accepted"
            case "3":
                return "Re-Scheduled"
            case "4":
                return "Rejected"
            case "5":
                return "Cancel"
            default:
                return "Not Scheduled"
        }
    }
    
    func getInterviewStatusColor() -> Color {
        switch self {
            case "1":
                return .pinkBtn
            case "2":
                return .green
            case "3":
                return .text
            case "4":
                return .red
            default:
                return .gray
        }
    }
    
    func toCurrency(locale: Locale = Locale(identifier: "en_US")) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = locale
        
        if let number = Double(self) {
            return formatter.string(from: NSNumber(value: number)) ?? ""
        }
        
        return ""
    }
    
    public func toPhoneNumber() -> String {
        return self.replacingOccurrences(of: "(\\d{3})(\\d{3})(\\d+)", with: "$1-$2-$3", options: .regularExpression, range: nil)
    }
}
