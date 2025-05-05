//
//  EmployeeDetailScreen.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 04/03/24.
//

import SwiftUI
import AVFoundation
import Kingfisher
import AlertToast
import BottomSheet
import RichText

struct EmployeeDetailScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var employeeId: Int?
    @State var userDetail: UserDetailModal = UserDetailModal()
    
    @State var isLoading: Bool = false
    @State var showAlert: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var request: PerformJobActionRequest = PerformJobActionRequest(status: "", job_id: 0, user_id: 0)
    
    @State private var player: AVPlayer?
    
    @State var showHud: Bool = false
    @State var hudMsg: String = ""
    
    var viewModal = EmployeeProfileViewModal()
    
    @State var press = false
    
        //MARK: - Personal Information View
    @ViewBuilder
    func personalInfo() -> some View {
        VStack(spacing: 10) {
            HStack {
                Text("Name")
                    .font(.custom(nunitoRegular, fixedSize: 12))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text(userDetail.name ?? "")
                    .font(.custom(nunitoMedium, fixedSize: 13))
                    .foregroundStyle(.black)
            }
            HStack {
                Text("Email Address")
                    .font(.custom(nunitoRegular, fixedSize: 12))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text(userDetail.email ?? "")
                    .font(.custom(nunitoMedium, fixedSize: 13))
                    .foregroundStyle(.black)
            }
            HStack {
                Text("Location")
                    .font(.custom(nunitoRegular, fixedSize: 12))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text(userDetail.location ?? "")
                    .font(.custom(nunitoMedium, fixedSize: 13))
                    .foregroundStyle(.black)
            }
            HStack(alignment: .top) {
                Text("Contact Info")
                    .font(.custom(nunitoRegular, fixedSize: 12))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text(userDetail.phone ?? " - ")
                    .font(.custom(nunitoMedium, fixedSize: 13))
                    .foregroundStyle(.black)
            }
            
            HStack(alignment: .top) {
                Text("Description")
                    .font(.custom(nunitoRegular, fixedSize: 12))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                RichText(html: userDetail.description ?? " - ")
                    .customCSS("""
            body {
                font-fixedSize: 13px;
            }
        """)
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
            HStack {
                Text("Highest Level of Edcation")
                    .font(.custom(nunitoRegular, fixedSize: 12))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text(userDetail.qualification?.first?.name ?? "")
                    .font(.custom(nunitoSemiBold, fixedSize: 13))
                    .foregroundStyle(.black)
            }
            
            Divider()
            
            ForEach(userDetail.qualification!.indices, id: \.self) {
                ind in
                VStack {
                    HStack {
                        Text(userDetail.qualification?[ind].name ?? "")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text(userDetail.qualification?[ind].institute_name?.capitalized ?? "")
                            .font(.custom(nunitoSemiBold, fixedSize: 13))
                            .foregroundStyle(.black)
                    }
                    
                    HStack {
                        Text("Graduated")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text(userDetail.qualification?[ind].graduation_date ?? "")
                            .font(.custom(nunitoMedium, fixedSize: 13))
                            .foregroundStyle(.black)
                    }
                    
                    if userDetail.qualification?[ind].graduation_date != userDetail.qualification?.last?.graduation_date {
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
            HStack {
                Text("Dream Job")
                    .font(.custom(nunitoRegular, fixedSize: 12))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text(userDetail.your_dream_job ?? "")
                    .font(.custom(nunitoSemiBold, fixedSize: 13))
                    .foregroundStyle(.black)
            }
            
            Divider()
            
            HStack {
                Text("Most Recent Job Title")
                    .font(.custom(nunitoRegular, fixedSize: 12))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text(userDetail.most_recent_job_title ?? "")
                    .font(.custom(nunitoSemiBold, fixedSize: 13))
                    .foregroundStyle(.black)
            }
            HStack {
                Text("Most Recent Company")
                    .font(.custom(nunitoRegular, fixedSize: 12))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text(userDetail.most_recent_company ?? "")
                    .font(.custom(nunitoMedium, fixedSize: 13))
                    .foregroundStyle(.black)
            }
//            HStack {
//                Text("Contact")
//                    .font(.custom(nunitoRegular, fixedSize: 12))
//                    .foregroundStyle(.gray)
//                
//                Spacer()
//                
//                Text("angela@blustone .com")
//                    .font(.custom(nunitoMedium, fixedSize: 13))
//                    .foregroundStyle(.black)
//            }
            
            ForEach(userDetail.work_histories!, id: \.id) {
                history in
                VStack(spacing: 10) {
                    Divider()
                    
                    HStack {
                        Text("Job Title")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text(history.job_title ?? "")
                            .font(.custom(nunitoSemiBold, fixedSize: 13))
                            .foregroundStyle(.black)
                    }
                    
                    HStack {
                        Text("Company Name")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text(history.company_name ?? "")
                            .font(.custom(nunitoMedium, fixedSize: 13))
                            .foregroundStyle(.black)
                    }
                    
                    HStack {
                        Text("Contact")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text("\(history.contact_info ?? "")")
                            .font(.custom(nunitoMedium, fixedSize: 13))
                            .foregroundStyle(.black)
                    }
                    
                    HStack {
                        Text("Employment Type")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text(history.employment_type ?? "")
                            .font(.custom(nunitoMedium, fixedSize: 13))
                            .foregroundStyle(.black)
                    }
                    
                    HStack {
                        Text("Location Type")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text(history.location_type ?? "")
                            .font(.custom(nunitoMedium, fixedSize: 13))
                            .foregroundStyle(.black)
                    }
                    
                    HStack {
                        Text("Start Date")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text(history.start_date ?? "")
                            .font(.custom(nunitoMedium, fixedSize: 13))
                            .foregroundStyle(.black)
                    }
                    
                    HStack {
                        Text("End Date")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text(history.end_date ?? "")
                            .font(.custom(nunitoMedium, fixedSize: 13))
                            .foregroundStyle(.black)
                    }
                    
                    HStack {
                        Text("Industry")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text(history.industry ?? "")
                            .font(.custom(nunitoMedium, fixedSize: 13))
                            .foregroundStyle(.black)
                    }
                    
                    HStack {
                        Text("Profile Headline")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text(history.profile_headline ?? "")
                            .font(.custom(nunitoMedium, fixedSize: 13))
                            .foregroundStyle(.black)
                    }
                    
                    HStack(alignment: .top) {
                        Text("Location")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text(history.location ?? "")
                            .font(.custom(nunitoMedium, fixedSize: 13))
                            .foregroundStyle(.black)
                    }
                    
                    HStack(alignment: .top) {
                        Text("Description")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        RichText(html: history.description ?? " - ")
                            .customCSS("""
            body {
                font-size: 13px;
            }
        """)
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
            ForEach(userDetail.skills!.indices, id: \.self) {
                ind in
                HStack {
                    Text(userDetail.skills?[ind].skill ?? "")
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
            ForEach(userDetail.license_certifications!.indices, id: \.self) {
                ind in
                HStack {
                    Text(userDetail.license_certifications?[ind].license_certificate ?? "")
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
    
        //MARK: - Volunteer Exp. Information View
    @ViewBuilder
    func volunExpInfo() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(userDetail.volunteer_experiences!.indices, id: \.self) {
                ind in
                HStack {
                    Text(userDetail.volunteer_experiences?[ind].volunteer_experience ?? "")
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
    
        //MARK: - Interested Job Category View
    @ViewBuilder
    func jobCateOfInterest() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(userDetail.interested_jobs!.indices, id: \.self) {
                ind in
                HStack {
                    Text(userDetail.interested_jobs?[ind].job?.name ?? " - ")
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
    
        //MARK: - Language View
    @ViewBuilder
    func employeeLanguage() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(userDetail.language!.indices, id: \.self) {
                ind in
                HStack {
                    Text(userDetail.language?[ind].name ?? "")
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
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                PrimaryHeader(
                    title: "Employee Profile",
                    leadingImgArr: [.sideArrow],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    }, count: .constant(0))
                
                ScrollView(showsIndicators: false, content: {
                    VStack(spacing: 0, content: {
//                        VStack {
//                            TitleWithPencil(title: "Applying For", showPencil: false)
//                            JobListingCard(jobDetail: $job)
//                        }
//                        .padding(.all)
//                        .background(.text.opacity(0.1))
                        
                        VStack {
                            TitleWithPencil(title: "Video Resume", showPencil: false)
                            if userDetail.video_resume != "" && userDetail.video_resume != nil {
                                CustomVideoPlayer(player: player)
                                    .frame(height: screenHeight/1.5)
                                    .onAppear(perform: {
                                        DispatchQueue.global(qos: .background).async {
                                            player?.isMuted = true
                                            player?.play()
                                        }
                                    })
                                    .onDisappear(perform: {
                                        player?.pause()
                                    })
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                Text("No Video Resume Added")
                                    .font(.custom(nunitoRegular, fixedSize: 14))
                                    .foregroundStyle(.black.opacity(0.7))
                                    .padding(.vertical)
                            }
                        }
                        .padding(.all)
            //            .background(.backGround)
                        
                        VStack {
                            TitleWithPencil(title: "Personal Information", showPencil: false)
                            personalInfo()
                        }
                        .padding(.all)
                        .background(.text.opacity(0.1))
                        
                        VStack {
                            TitleWithPencil(title: "Images", showPencil: false)
                            if userDetail.images?.count ?? 0 > 0 {
                                ScrollView(.horizontal, showsIndicators: false, content: {
                                    HStack(content: {
                                        ForEach(userDetail.images!.indices, id: \.self) {
                                            ind in
                                            KFImage.url(getMediaURL(url: userDetail.images?[ind].image ?? ""))
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
                                                .frame(width: 110, height: 110)
                                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                                .contextMenu {
                                                    Button {
                                                        
                                                    } label: { }
                                                } preview: {
                                                    KFImage.url(getMediaURL(url: userDetail.images?[ind].image ?? ""))
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
                                                        .frame(width: screenWidth, height: screenHeight*0.8)
                                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                                }
                                        }
                                        
                                        Spacer()
                                    })
                                })
                            } else {
                                Text("No Images Added")
                                    .font(.custom(nunitoRegular, fixedSize: 14))
                                    .foregroundStyle(.black.opacity(0.7))
                                    .padding(.vertical)
                            }
                        }
                        .padding(.all)
             //           .background(.backGround)
                        
                        VStack {
                            TitleWithPencil(title: "Education", showPencil: false)
                            if (userDetail.qualification?.count ?? 0) > 0 {
                                educationInfo()
                            } else {
                                Text("No Education Details Added")
                                    .font(.custom(nunitoRegular, fixedSize: 14))
                                    .foregroundStyle(.black.opacity(0.7))
                                    .padding(.vertical)
                            }
                        }
                        .padding(.all)
                        .background(.text.opacity(0.1))
                        
                        VStack {
                            TitleWithPencil(title: "Work History", showPencil: false)
                            if (userDetail.work_histories?.count ?? 0) > 0 {
                                workHistoryInfo()
                            } else {
                                Text("No Work History Added")
                                    .font(.custom(nunitoRegular, fixedSize: 14))
                                    .foregroundStyle(.black.opacity(0.7))
                                    .padding(.vertical)
                            }
                        }
                        .padding(.all)
        //                .background(.backGround)
                        
                        
                        VStack {
                            TitleWithPencil(title: "Languages", showPencil: false)
                            if (userDetail.language?.count ?? 0) > 0 {
                                employeeLanguage()
                            } else {
                                Text("No Languages Added")
                                    .font(.custom(nunitoRegular, fixedSize: 14))
                                    .foregroundStyle(.black.opacity(0.7))
                                    .padding(.vertical)
                            }
                        }
                        .padding(.all)
                        .background(.text.opacity(0.1))
                        
                        
                        VStack {
                            TitleWithPencil(title: "Skills", showPencil: false)
                            if (userDetail.skills?.count ?? 0) > 0 {
                                skillsInfo()
                            } else {
                                Text("No Skills Added")
                                    .font(.custom(nunitoRegular, fixedSize: 14))
                                    .foregroundStyle(.black.opacity(0.7))
                                    .padding(.vertical)
                            }
                        }
                        .padding(.all)
           //             .background(.backGround)
                        
                        VStack {
                            TitleWithPencil(title: "Licenses & Certificates", showPencil: false)
                            if (userDetail.license_certifications?.count ?? 0) > 0 {
                                licAndCerInfo()
                            } else {
                                Text("No Licences & Certificates Added")
                                    .font(.custom(nunitoRegular, fixedSize: 14))
                                    .foregroundStyle(.black.opacity(0.7))
                                    .padding(.vertical)
                            }
                        }
                        .padding(.all)
                        .background(.text.opacity(0.1))
                        
                        VStack {
                            TitleWithPencil(title: "Volunteer Experience", showPencil: false)
                            if (userDetail.volunteer_experiences?.count ?? 0) > 0 {
                                volunExpInfo()
                            } else {
                                Text("No Volunteer Experience Added")
                                    .font(.custom(nunitoRegular, fixedSize: 14))
                                    .foregroundStyle(.black.opacity(0.7))
                                    .padding(.vertical)
                            }
                        }
                        .padding(.all)
            //            .background(.backGround)
                        
//                        PrimaryButton(
//                            title: "Save",
//                            isOutLine: true,
//                            onButtonClick: {
//                                request.status = 3
////                                request.job_id = job.id ?? 0
//                                request.user_id = userDetail.id ?? 0
//                                isLoading = true
//                                self.viewModal.performJobAction(parameter: request)
//                            })
//                        .padding(.all)
//                        .padding(.vertical, 20)
//                        .background(.text.opacity(0.1))
                    })
                }).padding(.top, -topPadding)
                
                Spacer()
                
//                HStack {
//                    Button(action: {
//                        request.status = 2
//                        request.job_id = job.id ?? 0
//                        request.user_id = userDetail.id ?? 0
//                        isLoading = true
//                        self.viewModal.performJobAction(parameter: request)
//                    }, label: {
//                        Image(systemName: "xmark.circle.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 25, height: 25)
//                        
//                        Text("Decline")
//                            .font(.custom(nunitoBold, fixedSize: 14))
//                    }).tint(.red)
//                    
//                    Spacer()
//                    
//                    Button(action: {
//                        request.status = 1
//                        request.job_id = job.id ?? 0
//                        request.user_id = userDetail.id ?? 0
//                        isLoading = true
//                        self.viewModal.performJobAction(parameter: request)
//                    }, label: {
//                        Text("Accept")
//                            .font(.custom(nunitoBold, fixedSize: 14))
//                        Image(systemName: "checkmark.circle.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 25, height: 25)
//                    }).tint(.green)
//                }.padding(.all)
            }
            
            if isLoading {
                Loader(isLoading: $isLoading)
            }
            
//            if showAlert {
//                AlertPopUp(
//                    presentAlert: $showAlert,
//                    alertType: alertType,
//                    leftButtonAction: {
//                        withAnimation(.easeIn) { showAlert = false }
//                    },
//                    rightButtonAction: {
//                        withAnimation(.easeIn) { showAlert = false }
//                        self.presentationMode.wrappedValue.dismiss()
//                    })
//            }
        }
        .onAppear(perform: {
            isLoading = true
            self.viewModal.getEmployeeDetail(employeeId: "\(employeeId ?? 0)", jobId: "")
            observe()
        })
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
                    withAnimation(.easeIn) { showAlert = true }
            }
        }
    }
    
        //MARK: View Modal Handle Success
    func handleSuccess() {
        if viewModal.requestType == "GetEmployeeDetails"{
            if let response = viewModal.employeeDetailResponse {
                if response.status == "success" {
                    userDetail = response.data
                    player?.pause()
                    player = AVPlayer(url: getMediaURL(url: userDetail.video_resume ?? ""))
                    player?.play()
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showAlert = true
                }
            }
        }
    }
}

#Preview {
    EmployeeDetailScreen(employeeId: .constant(0))
}
