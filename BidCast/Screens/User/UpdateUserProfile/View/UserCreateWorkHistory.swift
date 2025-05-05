//
//  UserCreateWorkHistory.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 30/01/24.
//

import SwiftUI
import BottomSheet
import AlertToast

struct UserCreateWorkHistory: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var workHistory: CreateWorkHistory = CreateWorkHistory(job_title: "", company_name: "", location: "", employment_type: "", location_type: "", start_date: "", end_date: "", profile_headline: "", description: "", industry: "", contact_info: "")
    @State var showLoading: Bool = false
    @State var showAlert: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var locationArr: [String] = []
    @State var employementTypeArr: [String] = []
    @State var locationTypeArr: [String] = []
    @State var industryTypeArr: [String] = []
    
    @State var isStartDate: Bool = false
    @State var isEndDate: Bool = false
    
    @State var number: String = ""
    @State var endDate: String = ""
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    
    @State var isEdit: Bool = false
    
    var viewModal = UpdateUserProfileViewModal()
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                PrimaryHeader(
                    title: isEdit ? "Edit Work History" : "New Work History",
                    trailingImgArr: [.cancel],
                    onClickTrailing: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    }, count: .constant(0))
                
                ScrollView(showsIndicators: false, content: {
                    VStack(alignment: .leading, spacing: 20, content: {
                        
                        AuthTextField(floatingLabel: "Job Title", placeholder: "Enter Job Title", icon: .bag, text: $workHistory.job_title.toUnwrapped(defaultValue: ""), enteredText: { value in
                            workHistory.job_title = value
                        })
                        
                        DropDownTextField(
                            hint: "Employement Type",
                            floatingLabel: "Employement Type",
                            text: $workHistory.employment_type.toUnwrapped(defaultValue: ""),
                            options: $employementTypeArr,
                            leadingIcon: .gradCap,
                            showLeadingIcon: true,
                            showTrailingIcon: false)
                        .zIndex(1200.0)
                        
                        AuthTextField(floatingLabel: "Company Name", placeholder: "Enter Company Name", icon: .menuNews, text: $workHistory.company_name.toUnwrapped(defaultValue: ""), enteredText: { value in
                            workHistory.company_name = value
                        })
                        
                        AuthTextField(floatingLabel: "Contact Info", placeholder: "not mandatory", icon: .menuProfile, text: $number, enteredText: { value in
                            workHistory.contact_info = "\(Int(value.filter(\.isWholeNumber)) ?? 0)"
                        })
                        .keyboardType(.numberPad)
                        .onChange(of: number, perform: { value in
                            number = String(value.filter(\.isWholeNumber).prefix(10)).toPhoneNumber()
                        })
                        
                        DropDownTextField(
                            hint: "Location",
                            floatingLabel: "Location",
                            text: $workHistory.location.toUnwrapped(defaultValue: ""),
                            options: $locationArr,
                            leadingIcon: .location,
                            showLeadingIcon: true,
                            showTrailingIcon: false,
                            anchor: .top)
                        .zIndex(2000.0)
                        .onChange(of: workHistory.location ?? "") { newValue in
                            GooglePlacesManager.shared.findPlaces(query: newValue) { result in
                                switch result {
                                    case .success(let places):
                                        withAnimation(.easeIn(duration: 0.5)) {
                                            locationArr.removeAll()
                                            places.forEach { place in
                                                locationArr.append(place.name)
                                            }
                                        }
                                    case .failure(let error):
                                        print(error)
                                }
                            }
                        }
                        
                        DropDownTextField(
                            hint: "Location Type",
                            floatingLabel: "Location Type",
                            text: $workHistory.location_type.toUnwrapped(defaultValue: ""),
                            options: $locationTypeArr,
                            leadingIcon: .location,
                            showLeadingIcon: true,
                            showTrailingIcon: false)
                        .zIndex(1400.0)
                        
                        AuthTextField(floatingLabel: "Start Date", placeholder: "Enter Start Date", icon: .hours, text: $workHistory.start_date.toUnwrapped(defaultValue: ""), enteredText: { value in
                            workHistory.start_date = value
                        })
                        .disabled(true)
                        .onTapGesture {
                            UIApplication.shared.endEditing()
                            isStartDate = true
                        }
                        
                        AuthTextField(floatingLabel: "End Date", placeholder: "not mandatory", icon: .hours, text: $workHistory.end_date.toUnwrapped(defaultValue: ""), enteredText: { value in
                            endDate = value
                            workHistory.end_date = value
                        })
                        .disabled(true)
                        .onTapGesture {
                            UIApplication.shared.endEditing()
                            isEndDate = true
                        }
                        
                        DropDownTextField(
                            hint: "Industry",
                            floatingLabel: "Industry",
                            text: $workHistory.industry.toUnwrapped(defaultValue: ""),
                            options: $industryTypeArr,
                            leadingIcon: .gradCap,
                            showLeadingIcon: true,
                            showTrailingIcon: false)
                        .zIndex(1500.0)
                        
                        MultilineTextField(
                            floatingLabel: "Description",
                            placeholder: "Enter Description",
                            text: $workHistory.description.toUnwrapped(defaultValue: ""),
                            isForDescription: true,
                            enteredText: {
                                des in
                                workHistory.description = des
                            })
                        
                        AuthTextField(floatingLabel: "Profile Headline", placeholder: "not mandatory", icon: .gradCap, text: $workHistory.profile_headline.toUnwrapped(defaultValue: ""), enteredText: { value in
                            workHistory.profile_headline = value
                        })
                        
                        VStack(spacing: 24) {
                            PrimaryButton(title: "Save", isOutLine: false, onButtonClick: {
                                validateWorkHistory()
                            })
                            
                            PrimaryButton(title: "Cancel", onButtonClick: {
                                self.presentationMode.wrappedValue.dismiss()
                            })
                        }.padding(.top)
                    })
                    .padding(.all)
                })
                .padding(.top, -topPadding)
                Spacer()
            }
            .onTapGesture(perform: {
                UIApplication.shared.endEditing()
            })
            .toast(isPresenting: $showhud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
            .bottomSheet(isPresented: $showAlert, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        withAnimation { showAlert = false }
                        self.presentationMode.wrappedValue.dismiss()
                    }, onSecondaryClick: {
                        withAnimation { showAlert = false }
                    })
            })
            
            if showLoading {
                Loader(isLoading: $showLoading)
            }
        }
        .bottomSheet(isPresented: $isStartDate, height: screenHeight/1.65, topBarCornerRadius: 25, showTopIndicator: false, content: {
            DateSelectionSheet(
                onConfirmClick: {
                    date, time in
                    workHistory.start_date = date
                    isStartDate = false
                }, onCancelClick: {
                    isStartDate = false
                })
        })
        .bottomSheet(isPresented: $isEndDate, height: screenHeight/1.65, topBarCornerRadius: 25, showTopIndicator: false, content: {
            DateSelectionSheet(
                showFutureDate: true, comefromEndDate: true,
                onConfirmClick: {
                    date, time in
                    workHistory.end_date = date
                    isEndDate = false
                }, onCancelClick: {
                    isEndDate = false
                },onPresentClick: {
                    workHistory.end_date = "Present"
                    isEndDate = false
                })
        })
        .onAppear(perform: {
            self.observe()
            if let data: CombineDataModel = UserDefaultsManager.shared.getModel(forKey: .combineData) {
                data.employment_type.forEach { type in
                    employementTypeArr.append(type.type)
                }
                data.location_type.forEach { type in
                    locationTypeArr.append(type.type)
                }
                data.category.forEach { type in
                    industryTypeArr.append(type.name)
                }
            }
            
            if isEdit {
                if let data: WorkHistory = UserDefaultsManager.shared.getModel(forKey: .editWorkHistory) {
                    workHistory.job_title = data.job_title ?? ""
                    workHistory.employment_type = data.employment_type ?? ""
                    workHistory.company_name = data.company_name ?? ""
                    workHistory.contact_info = data.contact_info ?? "0"
                    workHistory.location = data.location ?? ""
                    workHistory.location_type = data.location_type ?? ""
                    workHistory.start_date = data.start_date ?? ""
                    workHistory.end_date = data.end_date ?? ""
                    workHistory.industry = data.industry ?? ""
                    workHistory.description = data.description ?? ""
                    workHistory.profile_headline = data.profile_headline ?? ""
                    workHistory.id = data.id ?? 0
                }
            }
        })
    }
    
    func validateWorkHistory() {
        
        UIApplication.shared.endEditing()

        guard workHistory.job_title != "" else {
            hudMsg = "Job Title is required"
            showhud = true
            return
        }
        
        guard workHistory.employment_type != "" else {
            hudMsg = "Job Employement Type is required"
            showhud = true
            return
        }
        
        guard workHistory.company_name != "" else {
            hudMsg = "Job Company is required"
            showhud = true
            return
        }
        
//        guard workHistory.contact_info ?? "" != "" else {
//            hudMsg = "Contact info is required"
//            showhud = true
//            return
//        }
        
        guard workHistory.location != "" else {
            hudMsg = "Job Location is required"
            showhud = true
            return
        }
        
        guard workHistory.location_type != "" else {
            hudMsg = "Job Location Type is required"
            showhud = true
            return
        }
        
        guard workHistory.start_date != "" else {
            hudMsg = "Job start date is required"
            showhud = true
            return
        }
        
//        guard workHistory.end_date != "" else {
//            hudMsg = "Job end date is required"
//            showhud = true
//            return
//        }
        
        guard workHistory.industry != "" else {
            hudMsg = "Job Industry is required"
            showhud = true
            return
        }
        
        guard workHistory.description != "" else {
            hudMsg = "Job description is required"
            showhud = true
            return
        }
        
//        guard workHistory.profile_headline != "" else {
//            hudMsg = "Job Profile is required"
//            showhud = true
//            return
//        }
        
        if let data: CombineDataModel = UserDefaultsManager.shared.getModel(forKey: .combineData) {
            workHistory.employment_type = "\(data.employment_type.first(where: { $0.type == workHistory.employment_type })?.id ?? 0)"
            workHistory.location_type = "\(data.location_type.first(where: { $0.type == workHistory.location_type })?.id ?? 0)"
            if  endDate == "Present"{
                workHistory.end_date = workHistory.end_date
            }else{
                workHistory.end_date = workHistory.end_date?.toDate().toYYYMMDD()
            }
            workHistory.start_date = workHistory.start_date?.toDate().toYYYMMDD()
            workHistory.contact_info = workHistory.contact_info!
            self.viewModal.createEmployeeWorkHistory(parameter: workHistory)
            self.observe()
        }
    }
    
        //MARK: - Observing API Request
    func observe() {
        self.viewModal.eventHandler = {
            event in
            switch event {
                case .loading:
                    self.showLoading = true
                case .stopLoading:
                    self.showLoading = false
                case .dataLoaded:
                    handleSuccess()
                case .error(let error):
                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    withAnimation(.easeIn) { showAlert = true }
            }
        }
    }
    
        //MARK: - Handle API Response
    func handleSuccess() {
        if viewModal.requestType == "GetDetail" {
            if let response = viewModal.userDetailResponse {
                if response.status == "success" {
                    UserDefaultsManager.shared.setModel(response.data, forKey: .userDetail)
                    withAnimation(.easeIn) { showAlert = true }
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    withAnimation(.easeIn) { showAlert = true }
                }
            }
        } else if viewModal.requestType == "CreateEmployeeWorkHistory" {
            if let response = viewModal.createJobResponse {
                if response.status == "success" {
                    viewModal.getDetail()
                    alertType = .sheetType(icon: .success, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .green)
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    withAnimation(.easeIn) { showAlert = true }
                }
            }
        }
    }
}

#Preview {
    UserCreateWorkHistory()
}
