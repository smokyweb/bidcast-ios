//
//  CreateEditJob.swift
//  imperium
//
//  Created by JAM-E-282 on 20/01/24.
//

import SwiftUI
import AlertToast
import BottomSheet
import MarkupEditor
import Sliders

struct CreateEditJob: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var keyboardHeight: CGFloat = 0
    
    @State var isLoading: Bool = false
    @State var showAlert: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var showHud: Bool = false
    @State var hudMessage: String = ""
    
    @State var qualifationList: [QualificationResponse] = []
    @State var qualificationOption: [String] = []
    
    @State var salaryTypeList: [SalaryTypeResponse] = []
    @State var salaryTypeOption: [String] = []
    @State var locationTypeNameArr : [String] = []

    @State var isEdit: Bool = false
    @State var request: JobUpsertParamter = JobUpsertParamter(title: "", salary_type: "", salary: "", hours_schedule: "", type: "", description: "", benefits: "", experience: "", licensure: "", qualification_id: "", education_field: "",is_licensure_required: "0",is_education_required: "0", location_type_id: "")
    
    @State var industryTypeArr: [String] = []
    @State var locationTypeArr: [String] = []
    @State var categoriesArr: [String] = []
    @State var benefitArr: [String] = []

    @State var educationField: String = ""
    @State var qualificationField: String = ""
    @State var locationField: String = ""

    @State var range = 0.0...1.0
    @State var maxSalary: String = ""
    @State var minSalary: String = ""
    @State var maximum = 0
    @State var minimum = 0
    
    var viewModal = JobUpsertViewModal()
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                PrimaryHeader(title: isEdit ? "Edit Job" : "New Job", trailingImgArr: [.cancel], onClickTrailing: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                }, count: .constant(0))
                
                VStack {
                    TitleWithLine(title: isEdit ? "Edit Job" : "New Job", lineLength: 24)
                        .padding([.top, .horizontal])
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 15) {
                            AuthTextField(floatingLabel: "Job Title *", placeholder: "Enter Job Title", icon: .bag, text: $request.title, enteredText: {
                                value in
                                request.title = value
                            })
                            .textContentType(.username)

                            
                            DropDown(hint: request.salary_type == "" ? "Please select Salary Type" : request.salary_type,
                                     options: salaryTypeOption,
                                     anchor: .bottom,
                                     floatingLabel:"Salary Type *",
                                     cornerRadius: 25,
                                     showLeadingIcon:true,
                                     leadingIcon:.dollar,
                                     onOptionSelected: { value in
                                request.salary_type = value
                            })
                            .zIndex(2400.0)
                            
//                            DropDown(hint: request.location_type_id == "" ? "Please select Location" : request.location_type_id,
//                                                         options: locationTypeNameArr,
//                                                         anchor: .top,
//                                                         floatingLabel:"Location Type *",
//                                                         cornerRadius: 25,
//                                                         showLeadingIcon:true,
//                                                         leadingIcon:.dollar,
//                                                         onOptionSelected: { value in
//                                                    request.location_type_id = value
//                                                })
//                                                .zIndex(2100.0)
//                            
                            
                            DropDownTextField(
                                hint: "Not Mandatory",
                                floatingLabel: "Select Location",
                                text: $locationField, //$request.qualification_id,
                                options: $locationTypeNameArr,
                                isMandatory: true,
                                leadingIcon: .bag,
                                showLeadingIcon: true,
                                showTrailingIcon: false,
                                showDropDownIcon: true,
                                onOptionSelected: {
                                    value in
                                    
                                },anchor: .bottom)
                            .zIndex(2300.0)
                            
                            
                            HStack(alignment: .center, spacing: 15) {
                                AuthTextField(floatingLabel: "Min Salary", placeholder: "Minimum", icon: .dollar, text: $minSalary, enteredText: {
                                    value in
                                    minSalary = value
                                    minimum  = Int(minSalary) ?? 0
                                })
                                .keyboardType(.numberPad)
                                
                                AuthTextField(floatingLabel: "Max Salary", placeholder: "Maximum", icon: .dollar, text: $maxSalary, enteredText: {
                                    value in
                                    maxSalary = value
                                    maximum  = Int(maxSalary) ?? 0
                                })
                                .keyboardType(.numberPad)
                            }
                            .zIndex(2100.0)
                            .padding(-3)
                            
                            AuthTextField(floatingLabel: "Hours / Schedule", placeholder: "Enter Hours", icon: .hours, text: $request.hours_schedule, enteredText: {
                                value in
                                request.hours_schedule = value
                            })
                            .keyboardType(.numberPad)
                            
                            DropDownTextField(
                                hint: "Select Job Type",
                                floatingLabel: "Job Type *",
                                text: $request.type,
                                options: $locationTypeArr,
                                leadingIcon: .gradCap,
                                showLeadingIcon: true,
                                showTrailingIcon: false,
                                showDropDownIcon: true,
                                onOptionSelected: {
                                    value in
                                    print(value)
                                }, anchor: .top)
                            .zIndex(2100.0)
                            
                            MultilineTextField(floatingLabel: "Job Description", placeholder: "Type your description here...", text: $request.description, isForDescription: true, enteredText: {
                                value in
                                request.description = value
                            })
                            
//                            AuthTextField(floatingLabel: "Benefits", placeholder: "Enter Job Benefits", icon: .benefits, text: $request.benefits, enteredText: {
//                                value in
//                                request.benefits = value
//                            })
//                            .keyboardType(.default)
                            
                            
                            MultiSelectionDropDownTextField(
                                hint: "Enter Job Benefits",
                                floatingLabel: "Benefits",
                                text: $request.benefits,
                                options: $benefitArr,
                                leadingIcon: .benefits,
                                showLeadingIcon: true,
                                showTrailingIcon: false,
                                showDropDownIcon: true
                                )
                            .zIndex(2100.0)
                            
                            
                            
                            MultiSelectionDropDownTextField(
                                hint: "Not Mandatory",
                                floatingLabel: "Relevant Experience",
                                text: $request.experience,
                                options: $industryTypeArr,
                                leadingIcon: .gradCap,
                                showLeadingIcon: true,
                                showTrailingIcon: false,
                                showDropDownIcon: true)
                            .zIndex(2100.0)
                            
                            AuthTextField(floatingLabel: "Licensure",isMandatory:true, placeholder: "Enter Licensure", icon: .licensure, text: $request.licensure, enteredText: {
                                value in
                                request.licensure = value
                            },isRequiredValue:{ value in
                                if value == 1{
                                    request.is_licensure_required = "1"
                                }else{
                                    request.is_licensure_required = "0"
                                }
                            })
                            .keyboardType(.default)
                            
                            DropDownTextField(
                                hint: "Not Mandatory",
                                floatingLabel: "Educational Level",
                                text: $qualificationField, //$request.qualification_id,
                                options: $qualificationOption,
                                isMandatory: true,
                                leadingIcon: .gradCap,
                                showLeadingIcon: true,
                                showTrailingIcon: false,
                                showDropDownIcon: true,
                                onOptionSelected: {
                                    value in
                                    
                                },
                                isRequiredValues: {
                                    value in
                                    if value == 1{
                                        request.is_education_required = "1"
                                    }else{
                                        request.is_education_required = "0"
                                    }
                                },anchor: .top)
                            .zIndex(2100.0)
                            
                            
                            
                            DropDownTextField(
                                hint: "Not Mandatory",
                                floatingLabel: "Field of Education",
                                text: $educationField, //$request.education_field,
                                options: $industryTypeArr,
                                leadingIcon: .gradCap,
                                showLeadingIcon: true,
                                showTrailingIcon: false,
                                showDropDownIcon: true,
                                anchor: .top)
                            .zIndex(2100.0)
                            
                     
                            
                            PrimaryButton(title: isEdit ? "Update" : "Next", isOutLine: false, onButtonClick: {
                                validateRequest()
                            })
                            .padding(.top, 10)
                        }.padding([.horizontal, .vertical])
                    }
                }
                
                Spacer()
                
            }
            .padding(.top, -topPadding)
            .onAppear(perform: {
                if let data: CombineDataModel = UserDefaultsManager.shared.getModel(forKey: .combineData) {
                    data.category.forEach { type in
                        industryTypeArr.append(type.name)
                    }
                    data.employment_type.forEach { type in
                        locationTypeArr.append(type.type)
                    }
                    data.benefits.forEach { type in
                        benefitArr.append(type.benefit)
                    }
                    data.qualification.forEach { qua in
                        qualificationOption.append(qua.name ?? "")
                    }
                    data.location_type.forEach { type in
                                        locationTypeNameArr.append(type.type)
                                    }
                    data.salary_type.forEach { salType in
                        salaryTypeOption.append(salType.type)
                    }
                    
                    if isEdit {
                        
                        educationField = data.category.first(where: { "\($0.id)" == request.education_field })?.name ?? ""
                        qualificationField = data.qualification.first(where: { $0.order == request.qualification_id })?.name ?? ""
                        locationField = data.location_type.first(where: { "\($0.id)" == request.location_type_id })?.type ?? ""
                        
                        let rangeString = request.salary
                        let parts = rangeString.split(separator: "-")
                        
                        if parts.count == 2,
                           let lowerBound = Int(parts[0]),
                           let upperBound = Int(parts[1]) {
                            
                            
                            self.minSalary = String(lowerBound)
                            
                            self.maxSalary = String(upperBound)
                            
                            
                        }

                    }
                }
                observe()
            })
            
            .toast(isPresenting: $showHud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMessage, style: alertStlye)}
            .bottomSheet(isPresented: $showAlert, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showAlert = true }, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        showAlert = false
                        if viewModal.jobResponse?.status == "success" {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    }, onSecondaryClick: {
                        withAnimation { showAlert = false }
                    })
            })
            
            
            if isLoading {
                Loader(isLoading: $isLoading)
            }
        }.onTapGesture(perform: {
            UIApplication.shared.endEditing()
        })
    }
    
    
    
    func validateRequest() {
        
        UIApplication.shared.endEditing()
        
        guard (request.title != "") else {
            
            hudMessage = "Job title can not be empty"
            showHud = true
            return
        }
        
        guard (request.salary_type != "") else {
            
            hudMessage = "Salary Type can not be empty"
            showHud = true
            return
        }
        
        if minSalary != "" || maxSalary != "" {
            
            guard (minimum != maximum) else {
                print("min salary \(minimum) max salery \(maximum)")
                hudMessage = "min and max salary can not be same"
                showHud = true
                
                return
            }
            
            
            guard (minimum < maximum) else {
                
                hudMessage = "Min salary can not be greater than max salary"
                showHud = true
                print("min salary \(minimum) max salery \(maximum)")
                return
            }
        }

        guard (request.type != "") else {
            
            hudMessage = "Job Type can not be empty"
            showHud = true
            
            return
        }
        
          
        
        if let detail: CombineDataModel = UserDefaultsManager.shared.getModel(forKey: .combineData) {
    
            request.salary = "\(minSalary)-\(maxSalary)"
            
            request.education_field = educationField != "" ? "\(detail.category.first(where: { $0.name == educationField })?.id ?? 0)" : ""
            request.qualification_id = qualificationField != "" ? "\(detail.qualification.first(where: { $0.name == qualificationField })?.order ?? "0")" : ""
            request.location_type_id = locationField != "" ? "\(detail.location_type.first(where: { $0.type == locationField })?.id ?? 0)" : ""
        }
        
        self.viewModal.upsertJob(parameters: request)
        observe()
        
    
    }
    
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
                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok")
                    showAlert = true
            }
        }
    }
    
    func handleSuccess() {
        
        if viewModal.requestType == "GetQualification" {
            if let response = viewModal.qualificationResponse {
                if response.status == "success" {
                    self.viewModal.getSalaryType()
                    qualifationList = response.data
                    response.data.forEach { data in
                        if !qualificationOption.contains(data.name) {
                            withAnimation(.interactiveSpring(duration: 0.45, extraBounce: 0.3, blendDuration: 0.25)) {
                                qualificationOption.append(data.name)
                            }
                        }
                    }
                }
            }
        } else if viewModal.requestType == "GetSalaryType" {
            if let response = viewModal.salaryTypeResponse {
                if response.status == "success" {
                    salaryTypeList = response.data
                    response.data.forEach({ data in
                        if !salaryTypeOption.contains(data.type ?? "") {
                            salaryTypeOption.append(data.type ?? "")
                        }
                    })
                }
            }
        } else if viewModal.requestType == "CreateJob" {
            if let response = viewModal.jobResponse {
                if response.status == "success" {
                    alertType = .sheetType(icon: .success, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .green)
                    showAlert = true
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showAlert = true
                }
            }
        }
    }
}






#Preview {
    CreateEditJob()
}
