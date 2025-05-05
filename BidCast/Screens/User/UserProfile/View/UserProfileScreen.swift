//
//  UserProfileScreen.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 25/01/24.
//

import SwiftUI
import AVFoundation
import Kingfisher
import BottomSheet
import WebKit
import AlertToast
import RichText

struct UserProfileScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
        //MARK: - Variables
    @State var isLoading: Bool = false
    @State var showLoading: Bool = false
    @State var showAlert: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var userDetail: UserDetailModal = UserDetailModal(id: 0, name: "", first_name: "", last_name: "", email: "", role_id: "", location: "", is_student: "", most_recent_job_title: "", most_recent_company: "", your_dream_job: "", profile_image: "", video_resume: "", deleted_at: "", created_at: "", roles: UserRole(id: 0, user_role: ""), images: [], qualification: [], work_histories: [], skills: [], license_certifications: [], volunteer_experiences: [], language: [], interested_jobs: [])
    
    @State var detailInfo: UserPersonalInfo = UserPersonalInfo(first_name: "", last_name: "", email: "", location: "", password: "", phone: "", description: "", profile_image: "")
    @State private var player: AVPlayer?
    
        //MARK: - Navigation Variables
    @State var navigateToPersInfo: Bool = false
    @State var navigateToVidRes: Bool = false
    @State var navigateToImages: Bool = false
    @State var navigateToEdu: Bool = false
    @State var navigateToWorkHis: Bool = false
    @State var navigateToSubscription: Bool = false

    @State var navigateToSkills: Bool = false
    @State var navigateToLicCer: Bool = false
    @State var navigateToVolExp: Bool = false
    @State var navigateToJobCatInt: Bool = false
    @State var navigateToLang: Bool = false
    @State var showLinkedIn: Bool = false
    @State var showLinkedInSheet: Bool = false
    @State var showSwipeSheet: Bool = false

    @State var showVideoResumeSheet: Bool = false
    @State var navigateToVideoResume: Bool = false
    @State var navigateToVidResTuto: Bool = false
    @State var navigateToLinkedInDetail: Bool = false
    
    @State var showHud: Bool = false
    @State var openActionSheet: Bool = false
    @State var openImageSheet: Bool = false
    @State var imageSelectorSource: UIImagePickerController.SourceType = .photoLibrary
    @State var selectedImageArray: [String] = []
    @State var hudMsg: String = ""
    
    @State var linkedInDetail: LinkedInUserDetail = LinkedInUserDetail()
    
    var viewModal = UserProfileViewModal()
    var viewModel = CreateEmployerProfileViewModal()
    
        //MARK: - Personal Information View
    @ViewBuilder
    func personalInfo() -> some View {
        VStack(spacing: 10) {
            HStack {
                Text("Name")
                    .font(.custom(nunitoRegular, fixedSize: 12))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text(userDetail.name ?? " - ")
                    .font(.custom(nunitoMedium, fixedSize: 13))
                    .foregroundStyle(.black)
            }
            HStack {
                Text("Email Address")
                    .font(.custom(nunitoRegular, fixedSize: 12))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text(userDetail.email ?? " - ")
                    .font(.custom(nunitoMedium, fixedSize: 13))
                    .foregroundStyle(.black)
            }
            HStack(alignment: .top) {
                Text("Location")
                    .font(.custom(nunitoRegular, fixedSize: 12))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text(userDetail.location ?? " - ")
                    .font(.custom(nunitoMedium, fixedSize: 13))
                    .foregroundStyle(.black)
            }
            
            HStack(alignment: .top) {
                Text("Contact Info")
                    .font(.custom(nunitoRegular, fixedSize: 12))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text(userDetail.phone?.toPhoneNumber() ?? " - ")
                    .font(.custom(nunitoMedium, fixedSize: 13))
                    .foregroundStyle(.black)
            }
            
            HStack(alignment: .top) {
                Text("Description")
                    .font(.custom(nunitoRegular, fixedSize: 12))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                
                Text(userDetail.description?.htmlToString ?? " - ")
                    .font(.custom(nunitoMedium, fixedSize: 13))
                    .foregroundStyle(.black)
                
//                RichText(html: userDetail.description ?? " - ")
//                    .customCSS("""
//            body {
//                font-size: 13px;
//                line-height: 0.8;
//            }
//        """)
//                    .foregroundStyle(.black)
            }
        }
        .padding(.all)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: .gray, radius: 3, x: 0, y: 0)
        )
    }
    
    
    //MARK: - Right Swipe
    
    func rightSwipeInfo() -> some View {
        
        VStack(spacing: 10) {
            HStack {
                Text("Balance Right Swipe : ")
                    .font(.custom(nunitoBold, fixedSize: 18))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text(userDetail.right_swipes ?? "0")
                    .font(.custom(nunitoSemiBold, fixedSize: 18))
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
                
                Text(userDetail.qualification?.first?.name ?? " - ")
                    .font(.custom(nunitoSemiBold, fixedSize: 13))
                    .foregroundStyle(.black)
            }
            
            Divider()
            
            ForEach(userDetail.qualification!.indices, id: \.self) {
                ind in
                VStack {
                    HStack {
                        Text(userDetail.qualification?[ind].name ?? " - ")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text(userDetail.qualification?[ind].institute_name?.capitalized ?? " - ")
                            .font(.custom(nunitoSemiBold, fixedSize: 13))
                            .foregroundStyle(.black)
                    }
                    
                    HStack {
                        Text("Graduated")
                            .font(.custom(nunitoRegular, fixedSize: 12))
                            .foregroundStyle(.gray)
                        
                        Spacer()
                        
                        Text(userDetail.qualification?[ind].graduation_date ?? " - ")
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
                        
                            //                        Text(history.description ?? "")
                        RichText(html: history.description ?? " - ")
                            .customCSS("""
            body {
                font-size: 13px;
                line-height: 1.0;
            }
        """)
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
                .shadow(color: .gray, radius: 1, x: 0, y: 0))
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
    
        //MARK: - User Detail Information View
    var body: some View {
        ZStack {
            VStack(spacing: 0, content: {
                HeaderWithImageTitle(
                    title: "Profile",
                    leadingImgArr: [.sideArrow],
                    onSelectImage: {
                        openActionSheet = true
                    }, onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    userName: .constant(userDetail.name ?? ""),
                    userImg: .constant(userDetail.profile_image ?? ""),isEditable:true)
                
                
                ScrollView(showsIndicators: false, content: {
                    VStack(spacing: 0, content: {
                        VStack {
                            TitleWithPencil(title: "Personal Information", onPencilClick: {
                                withAnimation(.easeOut) { navigateToPersInfo = true }
                            })
                            personalInfo()
                        }
                        .padding(.all)
                        .background(.text.opacity(0.05))
                        
                        VStack {
                            TitleWithPencil(title: "Video Resume", onPencilClick: {
                                withAnimation(.easeOut) { navigateToVidRes = true }
                            })
                            
                            if userDetail.video_resume != "" && userDetail.video_resume != nil {
                                CustomVideoPlayer(player: player)
                                    .frame(height: screenHeight/1.5)
                                    .onAppear(perform: {
                                        player?.isMuted = true
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
                        .background(.text.opacity(0.1))
                        
                        VStack {
                            TitleWithPencil(title: "Images", onPencilClick: {
                                withAnimation(.easeOut) { navigateToImages = true }
                            })
                            
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
                                                    Text("Image - \(ind + 1)")
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
                                                        .scaledToFit()
                                                        .frame(width: screenWidth, height: screenHeight*0.85)
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
                        .background(.text.opacity(0.05))
                        
                        VStack {
                            TitleWithPencil(title: "Education", onPencilClick: {
                                withAnimation(.easeOut) { navigateToEdu = true }
                            })
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
                            TitleWithPencil(title: "Work History", onPencilClick: {
                                withAnimation(.easeOut) { navigateToWorkHis = true }
                            })
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
                        .background(.text.opacity(0.05))
                        
                        VStack {
                            TitleWithPencil(title: "Languages", onPencilClick: {
                                withAnimation(.easeOut) { navigateToLang = true }
                            })
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
                            TitleWithPencil(title: "Skills", onPencilClick: {
                                withAnimation(.easeOut) { navigateToSkills = true }
                            })
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
                        .background(.text.opacity(0.05))
                        
                        
                        VStack {
                            TitleWithPencil(title: "Licenses & Certificates", onPencilClick: {
                                withAnimation(.easeOut) { navigateToLicCer = true }
                            })
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
                            TitleWithPencil(title: "Volunteer Experience", onPencilClick: {
                                withAnimation(.easeOut) { navigateToVolExp = true }
                            })
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
                        .background(.text.opacity(0.05))
                        
                        
                        VStack {
                            TitleWithPencil(title: "Job Categories of Interest", onPencilClick: {
                                withAnimation(.easeOut) { navigateToJobCatInt = true }
                            })
                            if (userDetail.interested_jobs?.count ?? 0) > 0 {
                                jobCateOfInterest()
                            } else {
                                Text("No Interested Job Categories Added")
                                    .font(.custom(nunitoRegular, fixedSize: 14))
                                    .foregroundStyle(.black.opacity(0.7))
                                    .padding(.vertical)
                            }
                        }
                        .padding(.all)
                        .background(.text.opacity(0.1))
                        
                        VStack {
                            TitleWithPencil(title: "Right Swipes", onPencilClick: {
                                alertType = .sheetType(icon: .alert, title: "Purchase Right Swipe", message: "You have \(self.viewModal.response.data?.right_swipes ?? "0") right swipe balance, Do you want to purchase 10 right swipe more?", primaryBtnText: "Yes", secondaryBtnText: "No", sheetThemeColor: .pinkBtn)
                                withAnimation { showSwipeSheet = true }
                            },comeFrom: true)
                            rightSwipeInfo()
                        }
                        .padding(.all)
                        .background(.text.opacity(0.05))
                        
                        VStack(alignment: .leading, spacing: 12, content: {
                            if userDetail.linkedIn_acc_exists ?? "0" == "0" {
                                HStack {
                                    Text("Link Account with LinkedIn")
                                        .font(.custom(nunitoSemiBold, fixedSize: 16))
                                        .foregroundStyle(.black)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        if userDetail.linkedIn_acc_exists ?? "0" == "0"  && userDetail.linkedIn_id ?? ""  == "" {
                                            withAnimation{ showLinkedIn = true }
                                        } else if userDetail.linkedIn_id ?? "" != "" && userDetail.linkedIn_acc_exists ?? "0" == "0" {
                                            withAnimation { showLinkedInSheet = true }
                                        }
                                    }, label: {
                                        Image(.linkedIn)
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 20, height: 20)
                                            .foregroundStyle(.text)
                                        
                                        Text("LinkedIn")
                                            .font(.custom(nunitoMedium, fixedSize: 15))
                                            .foregroundStyle(.black)
                                    })
                                    .padding(.all, 12)
                                    .background(content: {
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(.blue.opacity(0.2))
                                    })
                                }
                            } else {
                                HStack {
                                    Text("Re-Connect Account with LinkedIn")
                                        .font(.custom(nunitoSemiBold, fixedSize: 16))
                                        .foregroundStyle(.black)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        withAnimation { showLinkedInSheet = true }
                                    }, label: {
                                        Image(.linkedIn)
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 20, height: 20)
                                            .foregroundStyle(.text)
                                        
                                        Text("LinkedIn")
                                            .font(.custom(nunitoMedium, fixedSize: 15))
                                            .foregroundStyle(.black)
                                    })
                                    .padding(.all, 12)
                                    .background(content: {
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(.blue.opacity(0.2))
                                    })
                                }
                            }
                        })
                        .padding(.all)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                                .shadow(color: .gray, radius: 2, x: 0, y: 0)
                        )
                        .padding(.all)
                    }).unredacted(when: $isLoading)
                }).padding(.top, -topPadding)
                
                Spacer()
            })
            .sheet(isPresented: $openImageSheet, content: {
                ImageSelector(sourceType: $imageSelectorSource, isPresented: $openImageSheet) { image, imageURL in
                    if image != nil {
                        withAnimation(.easeIn) {
                            openImageSheet = false
                            selectedImageArray.append(imageURL ?? "")
                            detailInfo.profile_image = imageURL ?? ""
                            validate()
                        }
                    }
                }
            })
            .actionSheet(isPresented: $openActionSheet) { () -> ActionSheet in
                ActionSheet(title: Text("Select Image"), buttons: [ActionSheet.Button.default(Text("Take a Photo").font(.custom(nunitoRegular, fixedSize: 14)), action: {
                    imageSelectorSource = .camera
                    openImageSheet = true
                }), ActionSheet.Button.default(Text("Choose from Gallery"), action: {
                    imageSelectorSource = .photoLibrary
                    openImageSheet = true
                }), ActionSheet.Button.cancel()])
            }
            .bottomSheet(isPresented: $showAlert, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        withAnimation { showAlert = false }
                    }, onSecondaryClick: {
                        withAnimation { showAlert = false }
                    })
            })
            .bottomSheet(isPresented: $showVideoResumeSheet, height: screenHeight/1.75, topBarHeight: 10, topBarCornerRadius: 25, showTopIndicator: false) {
                VideoResumeSheet(message: "Missing your video resume. Continue to create now?", onStartResumeClick: {
                    withAnimation(.easeOut) { showVideoResumeSheet = false }
                    withAnimation(.easeInOut) { navigateToVideoResume = true }
                }, onWatchTutorialClick: {
                    withAnimation(.easeOut) { showVideoResumeSheet = false }
                    withAnimation(.easeInOut) { navigateToVidResTuto = true }
                }, onSkipClick: {
                    withAnimation(.easeOut) { showVideoResumeSheet = false }
                })
            }
            .bottomSheet(isPresented: $showLinkedInSheet, height: screenHeight/1.8, topBarHeight: 15, topBarCornerRadius: 15, showTopIndicator: false, onDismiss: { UIApplication.shared.endEditing() }, content: {
                LinkedInBottomSheet(onBtnClick: {
                    linkedInURL in
                    UIApplication.shared.endEditing()
//                    if linkedInURL.isValidLinkedIn() {
                        viewModal.linkedInAccConnect(param: LinkedInURL(url: linkedInURL))
                        observe()
//                    } else {
//                        hudMsg = "Please enter a valid LinkedIn Profile URL"
//                        showHud = true
//                    }
                })
            })
            .fullScreenCover(isPresented: $showLinkedIn) {
                ZStack {
                    
                    VStack(spacing: 0) {
                        PrimaryHeader(
                            title: "LinkedIn",
                            trailingImgArr: [.cancel],
                            onClickTrailing: { _ in
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showLinkedIn = false
                                }
                            }, count: .constant(0))
                        
                        LinkedInViewContainer(url: LinkedInConstants.AUTHURL + "?response_type=code&client_id=" + LinkedInConstants.CLIENT_ID + "&scope=" + LinkedInConstants.SCOPE + "&client_secret=" + LinkedInConstants.CLIENT_SECRET + "&redirect_uri=" + LinkedInConstants.REDIRECT_URI) { result in
                            switch result {
                                case .success(authCode: let authCode):
                                    withAnimation { showLinkedIn = false }
                                    self.viewModal.linkLinkedIn(param: LinkedInLinkModel(code: authCode))
                                    observe()
                                case .inProgress:
                                    showLoading = true
                                case .aceessDenied:
                                    withAnimation { showLinkedIn = false }
                                    hudMsg = result.message()
                                    showHud = true
                                    return
                                case .loginCancel, .loginFailed:
                                    withAnimation { showLinkedIn = false }
                                    hudMsg = result.message()
                                    showHud = true
                                    return
                                case .error(error: _):
                                    withAnimation { showLinkedIn = false }
                                    hudMsg = result.message()
                                    showHud = true
                                    return
                                case .stopLoading:
                                    showLoading = false
                            }
                        }
                    }
                    
                    if showLoading {
                        Loader(isLoading: $showLoading)
                    }
                }
            }
            .refreshable {
                generateFeedback(type: .medium)
                showLoading = true
                self.viewModal.getProfile()
                self.observe()
            }
            .task {
                self.viewModal.getProfile()
            }
            .onAppear(perform: {
                observe()
                observeProfile()
            })
            .onDisappear(perform: {
                player?.pause()
            })
            .toast(isPresenting: $showHud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
            
            .bottomSheet(isPresented: $showSwipeSheet, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showSwipeSheet = true }, content: {
                CommonBottomSheet(sheetType: $alertType,
                                  onPrimaryClick: {
                    withAnimation { showSwipeSheet = false }
                    withAnimation (.easeInOut){ navigateToSubscription = true }
                }, onSecondaryClick: {
                        withAnimation { showSwipeSheet = false }
                })
            })
            
            if showLoading {
                Loader(isLoading: $showLoading)
            }
            
            CusNavLink(doNavigate: $navigateToImages, destination: UserImageSelectionScreen())
            CusNavLink(doNavigate: $navigateToVidRes, destination: YourVideoResume())
            CusNavLink(doNavigate: $navigateToJobCatInt, destination: JobCategoriesView())
            CusNavLink(doNavigate: $navigateToSkills, destination: MySkillScreen())
            CusNavLink(doNavigate: $navigateToLicCer, destination: LicensesScreen())
            CusNavLink(doNavigate: $navigateToVolExp, destination: VolunteerScreen())
            CusNavLink(doNavigate: $navigateToWorkHis, destination: UserWorkHistory())
            CusNavLink(doNavigate: $navigateToSubscription, destination: SubscriptionScreen())
            CusNavLink(doNavigate: $navigateToPersInfo, destination: UpdateEmployerProfile())
            CusNavLink(doNavigate: $navigateToEdu, destination: MyEducationScreen())
            CusNavLink(doNavigate: $navigateToLang, destination: LanguagesScreen())
            CusNavLink(doNavigate: $navigateToVidResTuto, destination: WelcomeScreen())
            CusNavLink(doNavigate: $navigateToVideoResume, destination: YourVideoResume())
            CusNavLink(doNavigate: $navigateToLinkedInDetail, destination: LinkedInUserDetailScreen(linkedInDetail: $linkedInDetail))
        }
    }
    func validate(){
        if userDetail.first_name == ""{
            hudMsg = "First Name is required"
            showHud = true
           
        }else if userDetail.last_name == "" {
            hudMsg = "Last Name is required"
            showHud = true
            
        }else if userDetail.email == "" {
            hudMsg = "Email Address is required."
            showHud = true
            
        }else if userDetail.phone == "" {
            hudMsg = "Contact Info is required"
            showHud = true
        }else if userDetail.description == "" {
            hudMsg = "Your short description is required"
            showHud = true
        }else if userDetail.location == "" {
            hudMsg = "Location is required"
            showHud = true
        }else{
            detailInfo.first_name = userDetail.first_name ?? ""
            detailInfo.last_name = userDetail.last_name ?? ""
            detailInfo.email = userDetail.email ?? ""
            detailInfo.location = userDetail.location ?? ""
            detailInfo.phone = userDetail.phone ?? ""
            detailInfo.description = userDetail.description ?? ""
            viewModel.updateEmployerDetails(parameter: detailInfo)
        }
    }
        //MARK: - View Modal Observer
    func observeProfile() {
        viewModel.eventHandler = { event in
            switch event {
                case .loading:
                    self.isLoading = true
                case .stopLoading:
                    self.isLoading = false
                case .dataLoaded:
                    handleSuccessProfile()
                case .error(let error):
                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showAlert = true
                    print(error as Any)
            }
        }
    }
    
        //MARK: View Model Handle Success
    func handleSuccessProfile() {
        if viewModel.requestType == "UpdateDetail" {
            if let response = viewModel.response {
                if response.status == "success" {
                    self.viewModal.getProfile()
                    alertType = .sheetType(icon: .success, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .green)
                    showAlert = true
                   
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showAlert = true
                    
                }
            }
        }
    }
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
                    showLoading = false
                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showAlert = true
            }
        }
    }
    
        //MARK: - View Modal Success handler
    func handleSuccess() {
        if viewModal.requestType == "GetProfile" {
            let response = viewModal.response
            if response.status == "success" {
                userDetail = response.data!
                userDetail.qualification?.sort(by: { Int($0.order ?? "0")! < Int($1.order ?? "0")! })
                if (userDetail.video_resume ?? "") != "" {
                    player?.pause()
                    player = AVPlayer(url: getMediaURL(url: userDetail.video_resume ?? ""))
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                        withAnimation{ showVideoResumeSheet = true }
                    })
                }
                UserDefaultsManager.shared.remove(forKey: .userDetail)
                UserDefaultsManager.shared.setModel(userDetail, forKey: .userDetail)
            } else {
                alertType = .sheetType(icon: .alert, title: response.status.capitalized, message: response.message.capitalized, primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                showAlert = true
            }
        } else if viewModal.requestType == "LinkLinkedIn" {
            if let response = viewModal.linkedInResponse {
                if response.status == "success" {
                    alertType = .sheetType(icon: .success, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "OK", secondaryBtnText: "", sheetThemeColor: .green)
                    showAlert = true
                    showLinkedInSheet = false
                    showLinkedIn = false
                    viewModal.getProfile()
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showAlert = true
                }
            }
        } else if viewModal.requestType == "ConnectLinkedIn" {
            if let response = viewModal.linkedInUserResponse {
                if response.status == "success" {
                    showLinkedInSheet = false
                    showLinkedIn = false
                    linkedInDetail = response.data
                    navigateToLinkedInDetail = true
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showAlert = true
                    showLoading = false
                }
            }
        }
    }
}

#Preview {
    UserProfileScreen()
}
