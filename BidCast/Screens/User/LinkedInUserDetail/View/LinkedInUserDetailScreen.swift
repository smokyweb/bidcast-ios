//
//  LinkedInUserDetailScreen.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 05/04/24.
//

import SwiftUI
import BottomSheet
import RichText

struct LinkedInUserDetailScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var linkedInDetail: LinkedInUserDetail //= LinkedInUserDetail()
    
    @State var showLoading: Bool = false
    @State var showAlert: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    var viewModel = LinkedInConnectViewModel()
    
        //MARK: - Personal Information View
    @ViewBuilder
    func personalInfo() -> some View {
        VStack(spacing: 10) {
            HStack {
                Text("Name")
                    .font(.custom(nunitoRegular, fixedSize: 12))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text(linkedInDetail.full_name ?? " - ")
                    .font(.custom(nunitoMedium, fixedSize: 13))
                    .foregroundStyle(.black)
            }
            HStack {
                Text("Email Address")
                    .font(.custom(nunitoRegular, fixedSize: 12))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text(linkedInDetail.personal_emails?.first ?? " - ")
                    .font(.custom(nunitoMedium, fixedSize: 13))
                    .foregroundStyle(.black)
            }
            HStack(alignment: .top) {
                Text("Location")
                    .font(.custom(nunitoRegular, fixedSize: 12))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text("\(linkedInDetail.city ?? " - "), \(linkedInDetail.state ?? " - "), \(linkedInDetail.country_full_name ?? " - ")")
                    .font(.custom(nunitoMedium, fixedSize: 13))
                    .foregroundStyle(.black)
            }
        }
        .padding(.all)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: .gray, radius: 1, x: 0, y: 0)
        )
    }
    
        //MARK: - Education Information View
    @ViewBuilder
    func educationInfo() -> some View {
        VStack(spacing: 10) {
            ForEach(linkedInDetail.education!.indices, id: \.self) {
                ind in
                let data = linkedInDetail.education?[ind]
                VStack {
                    HStack(alignment: .top) {
                        Text(data?.degree_name ?? " - ")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text(data?.school ?? " - ")
                            .font(.custom(nunitoSemiBold, fixedSize: 13))
                            .foregroundStyle(.black)
                    }
                    
                    HStack(alignment: .top) {
                        Text("Graduated")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text("\(data?.starts_at?.month ?? 0)/\(data?.starts_at?.year ?? 0) - \(data?.ends_at?.month ?? 0)/\(data?.ends_at?.year ?? 0)")
                            .font(.custom(nunitoMedium, fixedSize: 13))
                            .foregroundStyle(.black)
                    }
                    
                    if linkedInDetail.education?.last?.degree_name ?? "" != data?.degree_name ?? "" {
                        Divider()
                    }
                }
            }
        }
        .padding(.all)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: .gray, radius: 1, x: 0, y: 0)
        )
    }
    
        //MARK: - Work History Information View
    @ViewBuilder
    func workHistoryInfo() -> some View {
        VStack(spacing: 10) {
            ForEach(linkedInDetail.experiences!.indices, id: \.self) {
                ind in
                let data = linkedInDetail.experiences?[ind]
                VStack(spacing: 10) {
                    HStack(alignment: .top) {
                        Text("Job Title")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text(data?.title ?? "")
                            .font(.custom(nunitoSemiBold, fixedSize: 13))
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack(alignment: .top) {
                        Text("Company Name")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text(data?.company ?? "")
                            .font(.custom(nunitoMedium, fixedSize: 13))
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack(alignment: .top) {
                        Text("Start Date")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text("\(data?.starts_at?.month ?? 0)/\(data?.starts_at?.year ?? 0)")
                            .font(.custom(nunitoMedium, fixedSize: 13))
                            .foregroundStyle(.black)
                    }
                    
                    HStack(alignment: .top) {
                        Text("End Date")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text("\(data?.ends_at?.month ?? 0)/\(data?.ends_at?.year ?? 0)")
                            .font(.custom(nunitoMedium, fixedSize: 13))
                            .foregroundStyle(.black)
                    }
                    
                    HStack(alignment: .top) {
                        Text("Industry")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text(linkedInDetail.industry ?? " - ")
                            .font(.custom(nunitoMedium, fixedSize: 13))
                            .foregroundStyle(.black)
                    }
                    
                    HStack(alignment: .top) {
                        Text("Description")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        RichText(html: data?.description  ?? " - ")
                            .customCSS("""
            body {
                font-size: 13px;
            }
        """)
                            .font(.custom(nunitoMedium, fixedSize: 13))
                            .foregroundStyle(.black)
                    }
                    
                    HStack(alignment: .top) {
                        Text("Location")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text(data?.location ?? "")
                            .font(.custom(nunitoMedium, fixedSize: 13))
                            .foregroundStyle(.black)
                    }
                }
            }
        }
        .padding(.all)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: .gray, radius: 1, x: 0, y: 0)
        )
    }
    
        //MARK: - Skills Information View
    @ViewBuilder
    func skillsInfo() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(linkedInDetail.skills!.indices, id: \.self) {
                ind in
                HStack {
                    Text(linkedInDetail.skills?[ind] ?? "")
                        .font(.custom(nunitoRegular, fixedSize: 12))
                        .foregroundStyle(.gray)
                    Spacer()
                }
            }
        }
        .padding(.all)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: .gray, radius: 1, x: 0, y: 0)
        )
    }
    
        //MARK: - Licences and Cer. Information View
    @ViewBuilder
    func licAndCerInfo() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(linkedInDetail.certifications!.indices, id: \.self) {
                ind in
                let data = linkedInDetail.certifications?[ind]
                HStack {
                    Text("\(data?.name ?? " - "), \(data?.authority ?? " - ")" )
                        .font(.custom(nunitoRegular, fixedSize: 12))
                    Spacer()
                }
            }
        }
        .padding(.all)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: .gray, radius: 1, x: 0, y: 0)
        )
    }
    
        //        MARK: - Volunteer Exp. Information View
    @ViewBuilder
    func volunExpInfo() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(linkedInDetail.volunteer_work!.indices, id: \.self) {
                ind in
                let data = linkedInDetail.volunteer_work?[ind]
                HStack {
                    Text(data?.title ?? " - ")
                        .font(.custom(nunitoRegular, fixedSize: 12))
                        .foregroundStyle(.gray)
                    Spacer()
                }
            }
        }
        .padding(.all)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: .gray, radius: 1, x: 0, y: 0))
    }
    
        //MARK: - Interested Job Category View
        //    @ViewBuilder
        //    func jobCateOfInterest() -> some View {
        //        VStack(alignment: .leading, spacing: 10) {
        //            ForEach(userDetail.interested_jobs!.indices, id: \.self) {
        //                ind in
        //                HStack {
        //                    Text(userDetail.interested_jobs?[ind].job?.name ?? " - ")
        //                        .font(.custom(nunitoRegular, fixedSize: 12))
        //                        .foregroundStyle(.gray)
        //                    Spacer()
        //                }
        //            }
        //        }
        //        .padding(.all)
        //        .background(
        //            RoundedRectangle(cornerRadius: 10)
        //                .fill(Color.white)
        //                .shadow(color: .gray, radius: 1, x: 0, y: 0))
        //    }
    
        //MARK: - Language View
    @ViewBuilder
    func employeeLanguage() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(linkedInDetail.languages!.indices, id: \.self) {
                ind in
                HStack {
                    Text(linkedInDetail.languages?[ind] ?? " - ")
                        .font(.custom(nunitoRegular, fixedSize: 12))
                        .foregroundStyle(.gray)
                    Spacer()
                }
            }
        }
        .padding(.all)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: .gray, radius: 1, x: 0, y: 0))
    }
    
    //MARK: Primary View Body
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderWithImageTitle(
                    title: "Link Profile",
                    leadingImgArr: [.sideArrow],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    }, userName: $linkedInDetail.full_name.toUnwrapped(defaultValue: "No Name"), userImg: $linkedInDetail.profile_pic_url.toUnwrapped(defaultValue: ""))
                
                ScrollView(showsIndicators: false, content: {
                    VStack(spacing: 20) {
                        
                        Group {
                            TitleWithPencil(title: "Personal Information", showPencil: false)
                            personalInfo()
                        }
                        
                        Group {
                            TitleWithPencil(title: "Education Information", showPencil: false)
                            
                            if linkedInDetail.education?.count ?? 0 > 0 {
                                educationInfo()
                            } else {
                                Text("No Education Details found")
                            }
                        }
                        
                        Group {
                            TitleWithPencil(title: "Work Experiences", showPencil: false)
                            
                            if linkedInDetail.experiences?.count ?? 0 > 0 {
                                workHistoryInfo()
                            } else {
                                Text("No Work Experience Details found")
                            }
                        }
                        
                        Group {
                            TitleWithPencil(title: "Skill Experiences", showPencil: false)
                            
                            if linkedInDetail.skills?.count ?? 0 > 0 {
                                skillsInfo()
                            } else {
                                Text("No Skills found")
                            }
                        }
                        
                        Group {
                            TitleWithPencil(title: "Licences and Certificates", showPencil: false)
                            
                            if linkedInDetail.certifications?.count ?? 0 > 0 {
                                licAndCerInfo()
                            } else {
                                Text("No Certificates found")
                            }
                        }
                        
                        Group {
                            TitleWithPencil(title: "Volunteer Work Experiences", showPencil: false)
                            
                            if linkedInDetail.volunteer_work?.count ?? 0 > 0 {
                                volunExpInfo()
                            } else {
                                Text("No Volunteer Work Experiences found")
                            }
                        }
                        
                        if linkedInDetail.languages?.count ?? 0 > 0 {
                            Group {
                                TitleWithPencil(title: "Languages Added", showPencil: false)
                                employeeLanguage()
                            }
                        }
                    }.padding()
                }).padding(.top, -topPadding)
                
                VStack(alignment: .leading) {
                    Text("Are you sure you want to continue with these details?")
                        .font(.custom(nunitoRegular, fixedSize: 18))
                        .foregroundStyle(.text)
                    
                    HStack {
                        Button(action: {
                            self.presentationMode.wrappedValue.dismiss()
                        }, label: {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                            
                            Text("Cancel")
                                .font(.custom(nunitoBold, fixedSize: 14))
                        }).tint(.red)
                        
                        Spacer()
                        
                        Button(action: {
                            alertType = .sheetType(icon: .alert, title: "Alert", message: "Experiences, Education, Languages, Volunteer Work, Certifications and Skills will be added to your profile", primaryBtnText: "Proceed", secondaryBtnText: "Cancel", sheetThemeColor: .text)
                            showAlert = true
                        }, label: {
                            Text("Accept")
                                .font(.custom(nunitoBold, fixedSize: 14))
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                        }).tint(.green)
                    }
                }
                .padding(.all)
                .background(.white)
                
                Spacer()
            }.onAppear {
                observe()
            }
      //      .background(.backGround)
            .bottomSheet(isPresented: $showAlert, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        if alertType.primaryBtnText == "Proceed" {
                            viewModel.storeLinkedInDetail(param: linkedInDetail)
                            observe()
                        } else {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        showAlert = false
                    }, onSecondaryClick: {
                        withAnimation { showAlert = false }
                    })
            })
            
            if showLoading {
                Loader(isLoading: $showLoading)
            }
        }.edgesIgnoringSafeArea(.bottom)
    }
    
    //MARK: ViewModal Observer
    func observe() {
        viewModel.eventHandler = {
            event in
            switch event {
                case .loading:
                    showLoading = true
                case .stopLoading:
                    showLoading = false
                case .dataLoaded:
                    handleSuccess()
                case .error(let error):
                    showLoading = false
                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .pinkBtn)
                    showAlert = true
            }
        }
    }
    
    //MARK: ViewModel Handel Success
    func handleSuccess() {
        if let response = viewModel.response {
            if response.status == "success" {
                alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .green)
                showAlert = true
            } else {
                alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                showAlert = true
            }
        }
    }
}

#Preview {
    LinkedInUserDetailScreen(linkedInDetail: .constant(LinkedInUserDetail()))
}
