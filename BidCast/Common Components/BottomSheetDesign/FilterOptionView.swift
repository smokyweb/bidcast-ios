////
////  FilterOptionView.swift
//// BidSwipe
////
////  Created by Maneet-JAM-E-282 on 03/05/24.
////
//
//import SwiftUI
//import Sliders
//import AlertToast
//
struct FilterRequestModal: Codable {
    var location, job_title, company_name, job_description: String
    var category,job_id: Int
    var salary,benefit: String
}
//
//struct FilterOptionView: View {
//    
//    @Environment(\.dismiss) var dismiss
//    
//    @State var filterRequest: FilterRequestModal = FilterRequestModal(location: "", job_title: "", company_name: "", job_description: "", category: 0, job_id: 0, salary: "", benefit: "")
//
//    
//    @State var categoriesArr: [String] = []
//    @State var beneFitsArr: [String] = []
//    @State var locationArr: [String] = []
//    @State var companyNameArr: [String] = []
//    @State var selectedOptions: [String] = []
//    @State var animateIcon: Bool = false
//    @State var animateScale = 1.0
//    @State var isJobSearch: Bool = false
//    @State var showHud: Bool = false
//    @State var hudMsg: String = ""
//    @State var jobDetail: JobDetailResponse = JobDetailResponse()
//    @State var companyName : String = ""
//    @State var category : String = ""
//    @State var cate: String = ""
//    @State var benefit: String = ""
//
//    
//    @State var range = 0.0...1.0
//    
//    @State var isEmployee: Bool = true
//    
//    @State var maxSalary: Int = 0
//    @State var minSalary: String = ""
//    
//    var onApplyFilterClick: ((FilterRequestModal) -> Void)?
//    
//    var body: some View {
//        VStack(alignment: .center) {
//            
//            HStack {
//                Spacer()
//                Text("Filter by")
//                    .font(.custom(nunitoBold, fixedSize: 24))
//                Spacer()
//            }
//            .overlay(alignment: .trailing) {
//                Button(action: { dismiss() }, label: {
//                    Image(.cancel)
//                        .renderingMode(.template)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 40, height: 40)
//                        .foregroundStyle(.pinkBtn)
//                })
//            }
//            .padding()
//            
//            ScrollView(showsIndicators: false) {
//                VStack {
//                        //MARK: Salary Range Slider
//                    if isJobSearch {
//                        VStack(alignment: .leading, spacing: 4, content: {
//                            Text("Salary")
//                                .font(.custom(nunitoSemiBold, fixedSize: 21))
//                            RangeSlider(range: $range)
//                                .rangeSliderStyle(
//                                    HorizontalRangeSliderStyle(
//                                        track:
//                                            HorizontalRangeTrack(
//                                                view: Capsule().foregroundColor(.text)
//                                            )
//                                            .background(Capsule().foregroundColor(Color.text.opacity(0.25)))
//                                            .frame(height: 6),
//                                        lowerThumb: Circle().foregroundColor(.text),
//                                        upperThumb: Circle().foregroundColor(.text),
//                                        lowerThumbSize: CGSize(width: 20, height: 20),
//                                        upperThumbSize: CGSize(width: 20, height: 20),
//                                        options: .forceAdjacentValue
//                                    )
//                                )
//                                .overlay(alignment: .top) {
//                                    HStack(content: {
//                                        Text("\(Int(Double(maxSalary) * range.lowerBound)).00")
//                                            .font(.custom(nunitoMedium, fixedSize: 12))
//                                        Spacer()
//                                        Text("\(Int(Double(maxSalary) * range.upperBound)).00")
//                                            .font(.custom(nunitoMedium, fixedSize: 12))
//                                    }).offset(y: -2)
//                                }
//                        })
//                    }
//                    
//                        //MARK: Categorries DropDown TextField
//                    VStack(alignment: .leading, spacing: 4, content: {
//                        Text("Categories")
//                            .font(.custom(nunitoSemiBold, fixedSize: 21))
//                        DropDownTextField(
//                            hint: "Select Job Category",
//                            text: $cate,
//                            options: $categoriesArr,
//                            leadingIcon: .location,
//                            showLeadingIcon: true,
//                            showTrailingIcon: false,
//                            showDropDownIcon: true,
//                            anchor: .bottom)
//                    }).zIndex(2100.0)
//                    
//                    
//                    //MARK: Benefit DropDown TextField
//                    if isEmployee{
//                        VStack(alignment: .leading, spacing: 4, content: {
//                            Text("Benefits")
//                                .font(.custom(nunitoSemiBold, fixedSize: 21))
//                            DropDownTextField(
//                                hint: "Select Job Benefits",
//                                text: $filterRequest.benefit,
//                                options: $beneFitsArr,
//                                leadingIcon: .location,
//                                showLeadingIcon: true,
//                                showTrailingIcon: false,
//                                showDropDownIcon: true,
//                                anchor: .bottom)
//                        }).zIndex(1600.0)
//                    }
//                    
//                        //MARK: Job Title DropDown TextField
//                        VStack(alignment: .leading, spacing: 15, content: {
//                            Text("Job Title")
//                                .font(.custom(nunitoSemiBold, fixedSize: 21))
//                                AuthTextField(placeholder: "Enter desired Job Title", icon: .gradCap, text: $filterRequest.job_title)
//
//                        })
//                    
//                        //MARK: Company Name DropDown TextField
//                    if isJobSearch {
//                        if isEmployee{
//                            VStack(alignment: .leading, spacing: 4, content: {
//                                Text("Company Name")
//                                    .font(.custom(nunitoSemiBold, fixedSize: 21))
//                                DropDownTextField(
//                                    hint: "Select Company Name",
//                                    text: $filterRequest.company_name,
//                                    options: $companyNameArr,
//                                    leadingIcon: .location,
//                                    showLeadingIcon: true,
//                                    showTrailingIcon: false,
//                                    showDropDownIcon: true,
//                                    anchor: .bottom)
//                            }).zIndex(1400.0)
//                        }
//                    }
//                    
//                        //MARK: Location DropDown TextField
//                    if isEmployee || !isJobSearch{
//                        VStack(alignment: .leading, spacing: 4, content: {
//                            Text("Location")
//                                .font(.custom(nunitoSemiBold, fixedSize: 21))
//                            DropDownTextField(
//                                hint: "Search your location",
//                                text: $filterRequest.location,
//                                options: $locationArr,
//                                leadingIcon: .location,
//                                showLeadingIcon: true,
//                                showTrailingIcon: false,
//                                showDropDownIcon: true,
//                                anchor: .bottom)
//                            .textContentType(.location)
//                            .onChange(of: filterRequest.location) { newValue in
//                                GooglePlacesManager.shared.findPlaces(query: newValue) { result in
//                                    switch result {
//                                    case .success(let places):
//                                        withAnimation(.easeIn(duration: 0.5)) {
//                                            locationArr.removeAll()
//                                            places.forEach { place in
//                                                locationArr.append(place.name)
//                                            }
//                                        }
//                                    case .failure(let error):
//                                        print(error)
//                                    }
//                                }
//                            }
//                        }).zIndex(1200.0)
//                    }
//                    
//                        //MARK: Company Name DropDown TextField
//                    if isJobSearch {
//                        if isEmployee{
//                            VStack(alignment: .leading, spacing: 4, content: {
//                                Text("Description")
//                                    .font(.custom(nunitoSemiBold, fixedSize: 21))
//                                MultilineTextField(placeholder: "Enter Description", text: $filterRequest.job_description, isForDescription: false)
//                            })
//                        }
//                    }
//                    
//                    HStack {
//                        PrimaryButton(
//                            title: "Reset",
//                            isOutLine: false,
//                            onButtonClick: {
//                                withAnimation {
//                                    cate = ""
//                                    filterRequest = FilterRequestModal(location: "", job_title: "", company_name: "", job_description: "", category: 0, job_id: jobDetail.id ?? 0, salary: "", benefit: "")
//                                    onApplyFilterClick?(filterRequest)
//
//                                }
//                            }, width: screenWidth/3.25, btnColor: .pinkBtn)
//                        
//                        Spacer()
//                        
//                        PrimaryButton(
//                            title: "Apply Filter",
//                            isOutLine: false,
//                            onButtonClick: {
//                                validateFilter()
//                                
//                            }, width: screenWidth/1.5 - 30)
//                    }
//                    .padding(.vertical)
//                    .padding(.top, isEmployee ? 10 : screenHeight * 0.35)
//                }.padding(.horizontal)
//            }
////            Spacer()
//        }
//        .onAppear(perform: {
//            if let companyList: [CompanyNameResponse] = UserDefaultsManager.shared.getModel(forKey: .companyNameList) {
//                companyList.forEach { data in
//                    companyNameArr.append(data.company_name?.capitalized ?? "")
//                }
//            }
//            
//            if let combineData: CombineDataModel = UserDefaultsManager.shared.getModel(forKey: .combineData) {
//                combineData.category.forEach { cate in
//                    categoriesArr.append(cate.name.capitalized)
//                }
//                
//                maxSalary = Int(combineData.max_salary) ?? 0
//            }
//            
//            if let combineData: CombineDataModel = UserDefaultsManager.shared.getModel(forKey: .combineData) {
//
//                combineData.benefits.forEach { cate in
//                    beneFitsArr.append(cate.benefit.capitalized)
//                }
//                
//                
//            }
//            
//            if let role: String = UserDefaultsManager.shared.value(forKey: .userRole) {
//                if role == "employer" {
//                    isEmployee = false
//                }
//            }
//        })
//        .toast(isPresenting: $showHud) {
//            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
//    }
//    
//    func validateFilter() {
//        var isAny: Bool = false
//        
//        filterRequest.salary = "\(Int(Double(maxSalary) * range.lowerBound))-\(Int(Double(maxSalary) * range.upperBound))"
//        
//        if filterRequest.salary != "1-\(maxSalary)" {
//            isAny = true
//        } else {
//            filterRequest.salary = ""
//        }
//        
//        if cate != "" {
//            isAny = true
//        }
//        
//        if filterRequest.location != "" {
//            isAny = true
//        }
//        
//        if filterRequest.job_title != "" {
//            isAny = true
//        }
//        
//        if filterRequest.job_description != "" {
//            isAny = true
//        }
//        
//        if filterRequest.company_name != "" {
//            isAny = true
//        }
//        
//        if filterRequest.benefit != "" {
//            isAny = true
//        }
//
//        
//        if !isAny {
//            hudMsg = "Please select any filter to apply"
//            showHud = true
//        } else {
//            if let data: CombineDataModel = UserDefaultsManager.shared.getModel(forKey: .combineData) {
//                filterRequest.category = data.category.first(where: { $0.name == cate })?.id ?? 0
//                filterRequest.job_id = jobDetail.id ?? 0
//                
//            }
//            
//            companyName = filterRequest.company_name
//            benefit = filterRequest.benefit
//            if filterRequest.salary == "0-\(maxSalary)"{
//                filterRequest.salary = ""
//            }
//            onApplyFilterClick?(filterRequest)
//        }
//    }
//    
//}
//
//#Preview {
//    FilterOptionView()
//}
