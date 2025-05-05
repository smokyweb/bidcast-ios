//
//  MyEducationScreen.swift
//  imperium
//
//  Created by JAM-E-265 on 24/01/24.
//

import SwiftUI
import BottomSheet
import AlertToast

struct MyEducationScreen: View {
    
        //MARK: Variable Parameter
    @Environment(\.presentationMode) var presentationMode
    
    @State var showLoading: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showAlert: Bool = false
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    
    @State var showDatePicker: Bool = false
    
    @State var qualifationList: [Qualification] = []
    @State var qualificationOption: [String] = []
    
    @State var showPhd: Bool = false
    @State var showMasters: Bool = false
    @State var showBachelors: Bool = false
    @State var showDiploma: Bool = false
    @State var showIntermediate: Bool = false
    @State var showHighSchool: Bool = false
    
    @State var isForPhd: Bool = false
    @State var isForMasters: Bool = false
    @State var isForBachelors: Bool = false
    @State var isForDiploma: Bool = false
    @State var isForIntermediate: Bool = false
    @State var isForHighSchool: Bool = false
    
    @State var educationList: [EmployeeEducationRequest] = []
    
    @State var phdEdu: EmployeeEducationRequest = EmployeeEducationRequest(qualification_id: 0, institute_name: "", graduation_date: "")
    @State var mastEdu: EmployeeEducationRequest = EmployeeEducationRequest(qualification_id: 0, institute_name: "", graduation_date: "")
    @State var bachEdu: EmployeeEducationRequest = EmployeeEducationRequest(qualification_id: 0, institute_name: "", graduation_date: "")
    @State var dipEdu: EmployeeEducationRequest = EmployeeEducationRequest(qualification_id: 0, institute_name: "", graduation_date: "")
    @State var intEdu: EmployeeEducationRequest = EmployeeEducationRequest(qualification_id: 0, institute_name: "", graduation_date: "")
    @State var higSchEdu: EmployeeEducationRequest = EmployeeEducationRequest(qualification_id: 0, institute_name: "", graduation_date: "")
    
        //MARK: View Modal
    var viewModal = UpdateUserProfileViewModal()
    
        //MARK: Primary View Body
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                PrimaryHeader(
                    title:"My Education",
                    trailingImgArr: [.cancel],
                    onClickTrailing: {
                        _ in
                        self.presentationMode.wrappedValue.dismiss()
                    }, count: .constant(0))
                ScrollView(showsIndicators: false){
                    VStack(spacing: 16, content: {
                        Group{
                            
                            DropDownSelection(
                                options: $qualificationOption,
                                floatingLabel: "What is the highest level of education you have received?",
                                hint: "Please select education level",
                                onOptionSelected: {
                                    selected in
                                    withAnimation(.easeIn) {
                                        showPhd = false
                                        showMasters = false
                                        showBachelors = false
                                        showDiploma = false
                                        showIntermediate = false
                                        showHighSchool = false
                                    }
                                    withAnimation(.easeOut) {
                                        switch selected.first {
                                            case "P":
                                                showPhd = true
                                                showMasters = true
                                                showBachelors = true
                                                showDiploma = true
                                                showIntermediate = true
                                                showHighSchool = true
                                            case "M", "E":
                                                showMasters = true
                                                showBachelors = true
                                                showDiploma = true
                                                showIntermediate = true
                                                showHighSchool = true
                                            case "B", "G":
                                                showBachelors = true
                                                showDiploma = true
                                                showIntermediate = true
                                                showHighSchool = true
                                            case "D":
                                                showDiploma = true
                                                showIntermediate = true
                                                showHighSchool = true
                                            case "I":
                                                showIntermediate = true
                                                showHighSchool = true
                                            case "H":
                                                showHighSchool = true
                                            default:
                                                return
                                        }
                                    }
                                }).zIndex(2100.0)
                            
                            if showPhd {
                                AuthTextField(floatingLabel: "Ph. D", placeholder: "Enter name of Ph. D College", icon: .gradCap, text: $phdEdu.institute_name)
                                
                                AuthTextField(floatingLabel: "Ph. D Graduation Date", placeholder:  "MM/YYYY", icon: .menuContactUs, text: $phdEdu.graduation_date)
                                    .disabled(true)
                                    .onTapGesture {
                                        showDatePicker = true
                                        isForPhd = true
                                    }
                            }
                            
                            if showMasters {
                                AuthTextField(floatingLabel: "Master's", placeholder: "Enter name of Master's College", icon: .gradCap, text: $mastEdu.institute_name)
                                
                                AuthTextField(floatingLabel: "Master's Graduation Date", placeholder:  "MM/YYYY", icon: .menuContactUs, text: $mastEdu.graduation_date)
                                    .disabled(true)
                                    .onTapGesture {
                                        showDatePicker = true
                                        isForMasters = true
                                    }
                            }
                            
                            if showBachelors {
                                AuthTextField(floatingLabel: "Bachelor's", placeholder: "Enter name of Bachelor's College", icon: .gradCap, text: $bachEdu.institute_name)
                                
                                AuthTextField(floatingLabel: "Bachelor's Graduation Date", placeholder:  "MM/YYYY", icon: .menuContactUs, text: $bachEdu.graduation_date)
                                    .disabled(true)
                                    .onTapGesture {
                                        showDatePicker = true
                                        isForBachelors = true
                                    }
                            }
                            
                            if showDiploma {
                                AuthTextField(floatingLabel: "Diploma", placeholder: "Enter name of Diploma School/College", icon: .gradCap, text: $dipEdu.institute_name)
                                
                                AuthTextField(floatingLabel: "Diploma Graduation Date", placeholder:  "MM/YYYY", icon: .menuContactUs, text: $dipEdu.graduation_date)
                                    .disabled(true)
                                    .onTapGesture {
                                        showDatePicker = true
                                        isForDiploma = true
                                    }
                            }
                            
                            if showIntermediate {
                                AuthTextField(floatingLabel: "Intermediate", placeholder: "Enter name of Intermediate School/College", icon: .gradCap, text: $intEdu.institute_name)
                                
                                AuthTextField(floatingLabel: "Intermediate Graduation Date", placeholder:  "MM/YYYY", icon: .menuContactUs, text: $intEdu.graduation_date)
                                    .disabled(true)
                                    .onTapGesture {
                                        showDatePicker = true
                                        isForIntermediate = true
                                    }
                            }
                            
                            if showHighSchool {
                                AuthTextField(floatingLabel: "High School", placeholder: "Enter name of High School", icon: .gradCap, text: $higSchEdu.institute_name)
                                
                                AuthTextField(floatingLabel: "High School Graduation Date", placeholder: "MM/YYYY", icon: .menuContactUs, text: $higSchEdu.graduation_date)
                                    .disabled(true)
                                    .onTapGesture {
                                        showDatePicker = true
                                        isForHighSchool = true
                                    }
                            }
                        }
                        
                        Spacer()
                        
                        if showHighSchool {
                            PrimaryButton(title: "Save", isOutLine: false){
                                validateEducation()
                            }
                            PrimaryButton(title: "Cancel"){
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }).padding(.all)
                }.padding(.top, -topPadding)
                Spacer(minLength: -50)
            }
            .onTapGesture(perform: {
                UIApplication.shared.endEditing()
            })
            .onAppear(perform: {
                if let detail: CombineDataModel = UserDefaultsManager.shared.getModel(forKey: .combineData) {
                    qualifationList = detail.qualification
                    detail.qualification.forEach { qua in
                        if let name = qua.name {
                            qualificationOption.append(name)
                        }
                    }
                }
                observe()
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
            
                //MARK: Loader
            if showLoading {
                Loader(isLoading: $showLoading)
            }
            
                //MARK: Alert Pop Up
//            if showAlert {
//                AlertPopUp(
//                    presentAlert: $showAlert,
//                    alertType: alertType,
//                    leftButtonAction: {
//                        withAnimation(.easeOut) { showAlert = false } },
//                    rightButtonAction: {
//                        withAnimation(.easeOut) { showAlert = false }
//                        self.presentationMode.wrappedValue.dismiss()
//                    })
//            }
            
                //MARK: Date Picker Pop Up
            if showDatePicker {
                DatePickerPopUp(
                    dateChanged: { date in
                        if isForPhd {
                            phdEdu.graduation_date = date.toMMYY()
                            isForPhd = false
                        }
                        if isForMasters {
                            mastEdu.graduation_date = date.toMMYY()
                            isForMasters = false
                        }
                        if isForBachelors {
                            bachEdu.graduation_date = date.toMMYY()
                            isForBachelors = false
                        }
                        if isForDiploma {
                            dipEdu.graduation_date = date.toMMYY()
                            isForDiploma = false
                        }
                        if isForIntermediate {
                            intEdu.graduation_date = date.toMMYY()
                            isForIntermediate = false
                        }
                        if isForHighSchool {
                            higSchEdu.graduation_date = date.toMMYY()
                            isForHighSchool = false
                        }
                        showDatePicker = false
                    },
                    onCancelClick: {
                        showDatePicker = false
                    })
            }
        }
    }
    
        //MARK: Handle Validation
    func validateEducation() {
        
        UIApplication.shared.endEditing()
        
        var allValid: Bool = true
        
        if showPhd {
            if phdEdu.institute_name == "" {
                allValid = false
                hudMsg = "P.H.D institute name is required."
                showhud = true
                return
            }
            
            if phdEdu.graduation_date == "" {
                allValid = false
                hudMsg = "P.H.D graduation date is required."
                showhud = true
                return
            }
            phdEdu.qualification_id = 8
            educationList.append(phdEdu)
        }
        
        if showMasters {
            if mastEdu.institute_name == "" {
                allValid = false
                hudMsg = "Master's Degree institute name is required."
                showhud = true
                return
            }
            
            if mastEdu.graduation_date == "" {
                allValid = false
                hudMsg = "Master's Degree graduation date is required."
                showhud = true
                return
            }
            mastEdu.qualification_id = 7
            educationList.append(mastEdu)
        }
        
        if showBachelors {
            if bachEdu.institute_name == "" {
                allValid = false
                hudMsg = "Bachelor's Degree institute name is required."
                showhud = true
                return
            }
            
            if bachEdu.graduation_date == "" {
                allValid = false
                hudMsg = "Bachelor's Degree graduation date is required."
                showhud = true
                return
            }
            bachEdu.qualification_id = 6
            educationList.append(bachEdu)
        }
        
        if showDiploma {
            if dipEdu.institute_name == "" {
                allValid = false
                hudMsg = "Diploma Degree institute name is required."
                showhud = true
                return
            }
            
            if dipEdu.graduation_date == "" {
                allValid = false
                hudMsg = "Diploma Degree graduation date is required."
                showhud = true
                return
            }
            dipEdu.qualification_id = 3
            educationList.append(dipEdu)
        }
        
        if showIntermediate {
            if intEdu.institute_name == "" {
                allValid = false
                hudMsg = "Intermediate institute name is required."
                showhud = true
                return
            }
            
            if intEdu.graduation_date == "" {
                allValid = false
                hudMsg = "Intermediate graduation date is required."
                showhud = true
                return
            }
            intEdu.qualification_id = 2
            educationList.append(intEdu)
        }
        
        if showHighSchool {
            if higSchEdu.institute_name == "" {
                allValid = false
                hudMsg = "High School name is required."
                showhud = true
                return
            }
            
            if higSchEdu.graduation_date == "" {
                allValid = false
                hudMsg = "High School graduation date is required."
                showhud = true
                return
            }
            higSchEdu.qualification_id = 1
            educationList.append(higSchEdu)
        }
        
        if allValid {
            print("List >> \(educationList)")
            self.viewModal.updateEmployeeEducation(parameter: educationList)
        }
    }
    
        //MARK: View Modal Observer
    func observe() {
        self.viewModal.eventHandler = {
            event in
            switch event {
                case .loading:
                    showLoading = true
                case .stopLoading:
                    showLoading = false
                case .dataLoaded:
                    handleSuccess()
                case .error(let error):
                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    withAnimation(.interpolatingSpring) { showAlert = true }
            }
        }
    }
    
        //MARK: View Modal Success Handler
    func handleSuccess() {
        if viewModal.requestType == "GetQualification" {
            if let response = viewModal.qualificationResponse {
                if response.status == "success" {
                    response.data.forEach { data in
                        qualificationOption.append(data.name)
                    }
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    withAnimation(.interpolatingSpring) { showAlert = true }
                }
            }
        } else if viewModal.requestType == "UpdateEmployeeEducation" {
            if let response = viewModal.educationResponse {
                if response.status == "success" {
                    alertType = .sheetType(icon: .success, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .green)
                    withAnimation(.interpolatingSpring) { showAlert = true }
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    withAnimation(.interpolatingSpring) { showAlert = true }
                }
            }
        }
    }
}


#Preview {
    MyEducationScreen()
}
