
//
//  UserListCard.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 03/02/24.
//

import SwiftUI
import Kingfisher
import RichText
import AlertToast
import AVFoundation

struct EmployeeStackView: View {
    
    @Environment(\.presentationMode) var presentationMode

    
    @Binding var job: JobDetailResponse
    
    var onClick: ((Int) -> Void)?
    @State var isLoading: Bool = false
    @State var showAlert: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @Binding var userDetail: UserDetailModal
    @Binding var enableSwipe: Bool
    @State var showActiveSheet: Bool = false
    @State var navigateToSubscription : Bool = false
    var onSwipe: ((Bool, Int) -> Void)?
    @State var showSwipeBtn: Bool = true
    var onSaveButtonClick: ((Int) -> Void)?
    
    @State var showHud: Bool = false
    @State var hudMsg: String = ""
    @State private var player: AVPlayer?
    @State private var offset = CGSize.zero
    @State private var color: Color = .white
    @State var navigateToEditJobDetail: Bool = false
    
    //        var viewModal = EmployeeProfileViewModal()
    
    //MARK: - Personal Information View
    @ViewBuilder
    func personalInfo() -> some View {
        VStack(spacing: 10) {
            if userDetail.status != "1"{
                HStack {
                    //                    Text("First Name")
                    //                        .font(.custom(nunitoRegular, fixedSize: 12))
                    //                        .foregroundStyle(.gray)
                    
                    //                    Spacer()
                    
                    Text(userDetail.first_name ?? "")
                        .font(.custom(nunitoBold, fixedSize: 20))
                        .foregroundStyle(.black)
                }
                .padding(.top, 4)
                .padding(.bottom, 4)
            }else{
                HStack {
                    Text("First Name")
                        .font(.custom(nunitoRegular, fixedSize: 12))
                        .foregroundStyle(.gray)
                    
                    Spacer()
                    
                    Text(userDetail.first_name ?? "")
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
                font-size: 13px;
            }
        """)
                        .foregroundStyle(.black)
                }
            }
        }
        .padding(.all)
        .background(color)
        
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
        VStack{
           
                VStack(spacing: 0, content: {
                    VStack {
                        TitleWithPencil(title: job.title?.capitalizingFirstLetter() ?? "", onPencilClick: {
                            withAnimation {
                                navigateToEditJobDetail = true
                            }
                        })
//                        JobListingCard(jobDetail: $job, showStatus: true)
                    }
                    .padding(.all)
                    .background(color)
                    
                    //                            .background(.text.opacity(0.1))
                    ScrollView(showsIndicators: false, content: {
                    VStack {
                        TitleWithPencil(title: "Video Resume", showPencil: false)
                        if userDetail.is_resume_uploaded == false {
                            Text("No Video Resume Added")
                                .font(.custom(nunitoRegular, fixedSize: 14))
                                .foregroundStyle(.black.opacity(0.7))
                                .padding(.vertical)
                        } else {
                            CustomVideoPlayer(player: player)
                                .frame(height: screenHeight/1.5)
                                .onAppear(perform: {
                                    DispatchQueue.global(qos: .background).async {
                                        let videoURL = userDetail.video_resume ?? ""
                                        if let url = URL(string: "https://backend.imperiumjob.com/\(videoURL)"){
                                            let player = AVPlayer(url: url)
                                            self.player = player
                                            self.player?.playImmediately(atRate: 1.0)
                                        }
                                    }
                                })
                                .onDisappear(perform: {
                                    player?.pause()
                                })
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(.all)
                    .background(color)
                    
                    VStack {
                        TitleWithPencil(title: "Personal Information", showPencil: false)
                        
                        personalInfo()
                    }
                    
                    .padding(.all)
                    .background(color)
                    
                    
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
                    .background(color)
                    
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
                    .background(color)
                    
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
                    .background(color)
                    
                    
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
                    .background(color)
                    
                    
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
                    .background(color)
                    
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
                    .background(color)
                })
            }).padding(.top, -topPadding)
            
            Spacer()
            if UserDefaultsManager.shared.value(forKey: .userRoleId) == "3" {
                
                HStack {
                    
                    Button(action: {
                        withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 50, damping: 8, initialVelocity: 0)) {
                            offset.width = -200
                            swipeCard(width: offset.width, currentCard: job.title ?? "")
                            changeColor(width: offset.width)
                        }
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                        
                        Text("Swipe Left")
                            .font(.custom(nunitoBold, fixedSize: 14))
                    }).tint(.red)
                    
                    Spacer()
                    
                    if userDetail.is_employee_saved ?? "" == "0" {
                        Button(action: {
                            onSaveButtonClick?(userDetail.id  ?? 0)
                        }, label: {
                            
                            Text("  Save for later ")
                                .font(.custom(nunitoBold, fixedSize: 16))
                                .underline()
                        }).tint(.black)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        
                        if UserDefaults.EmployerRightSwipe == "" {
                            
                            alertType = .sheetType(icon: .alert, title: "Purchase Right Swipe", message: "You don't have any right swipe in the balance, Do you want to purchase right swipe?", primaryBtnText: "Yes", secondaryBtnText: "No", sheetThemeColor: .pinkBtn)
                            withAnimation { showActiveSheet = true }

                        }else{
                            withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 50, damping: 8, initialVelocity: 0)) {
                                offset.width = 200
                                swipeCard(width: offset.width, currentCard: job.title ?? "")
                                changeColor(width: offset.width)
                            }
                        }
                    }, label: {
                        Text("Swipe Right")
                            .font(.custom(nunitoBold, fixedSize: 14))
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 25)
                    }).tint(.green)
                }
                .padding(.all)
                .background(.white)
                
                
                
            }else{
                if UserDefaults.ActionRead{
                    HStack {
                        
                        Button(action: {
                            if UserDefaults.ActionWrite{
                                withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 50, damping: 8, initialVelocity: 0)) {
                                    offset.width = -200
                                    swipeCard(width: offset.width, currentCard: job.title ?? "")
                                    changeColor(width: offset.width)
                                }
                            }
                        }, label: {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                            
                            Text("Swipe Left")
                                .font(.custom(nunitoBold, fixedSize: 14))
                        }).tint(.red)
                        
                        Spacer()
                        
                        if userDetail.is_employee_saved ?? "" == "0" {
                            Button(action: {
                                if UserDefaults.ActionWrite{
                                    onSaveButtonClick?(userDetail.id  ?? 0)
                                }
                            }, label: {
                                
                                Text("  Save for later ")
                                    .font(.custom(nunitoBold, fixedSize: 16))
                                    .underline()
                            }).tint(.black)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            if UserDefaults.ActionWrite{
                                
                                withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 50, damping: 8, initialVelocity: 0)) {
                                    offset.width = 200
                                    swipeCard(width: offset.width, currentCard: job.title ?? "")
                                    changeColor(width: offset.width)
                                }
                            }
                        }, label: {
                            Text("Swipe Right")
                                .font(.custom(nunitoBold, fixedSize: 14))
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                        }).tint(.green)
                    }
                    .padding(.all)
                    .background(.white)
                }
            }
        }
        .background(color)
        .offset(x: offset.width * 1, y: offset.height * 0.4)
        .rotationEffect(.degrees(Double(offset.width / 40)))
        .onAppear(perform: {
//            player = AVPlayer(url: getMediaURL(url: userDetail.video_resume ?? ""))
//            player?.play()
        })
        .gesture(
            enableSwipe ?
            DragGesture()
                .onChanged { gesture in
                    if abs(gesture.translation.width) > 60 {
                        withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 50, damping: 8, initialVelocity: 0)) {
                            offset = gesture.translation
                            withAnimation {
                                changeColor(width: offset.width)
                            }
                        }
                    }
                    
                }
                .onEnded { _ in
                    withAnimation {
                        swipeCard(width: offset.width, currentCard: job.title ?? "")
                        changeColor(width: offset.width)
                    }
                } : nil
        )
        
        
        
        .toast(isPresenting: $showHud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
        .bottomSheet(isPresented: $showAlert, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showAlert = true }, content: {
            CommonBottomSheet(
                sheetType: $alertType,
                onPrimaryClick: {
                    withAnimation { showAlert = false }
                    self.presentationMode.wrappedValue.dismiss()
                }, onSecondaryClick: {
                    withAnimation { showAlert = false }
                })
        })
        
        .bottomSheet(isPresented: $showActiveSheet, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showActiveSheet = true }, content: {
            CommonBottomSheet(sheetType: $alertType,
                              onPrimaryClick: {
                withAnimation { showActiveSheet = false }
                navigateToSubscription = true
            }, onSecondaryClick: {
                withAnimation { showActiveSheet = false }
            })
        })
        

        
        if isLoading {
            Loader(isLoading: $isLoading)
        }
        
        CusNavLink(doNavigate: $navigateToEditJobDetail, destination: CreateEditJob(isEdit: true, request: JobUpsertParamter(id: job.id, title: job.title  ?? "", salary_type: job.salary_type ?? "", salary: job.salary ?? "", hours_schedule: job.hours_schedule ?? "", type: job.job_type ?? "", description: job.description ?? "", benefits: job.benefits ?? "", experience: job.experience ?? "", licensure: job.licensure ?? "", qualification_id: job.qualification_id ?? "", education_field: job.education_field_id ?? "",is_licensure_required: "0", is_education_required: "0", location_type_id: "")))
        
        CusNavLink(doNavigate: $navigateToSubscription, destination: SubscriptionScreen())

        
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
    
    func swipeCard(width: CGFloat, currentCard: String) {
        switch width {
        case -500...(-150):
            Log.s("\(currentCard) removed")
            self.onSwipe?(false, userDetail.id ?? 0)
            offset = CGSize(width: -500, height: 0)
        case 150...500:
            Log.s("\(currentCard) added")
            self.onSwipe?(true, userDetail.id ?? 0)
            offset = CGSize(width: 500, height: 0)
        default:
            offset = .zero
        }
    }
    
    func changeColor(width: CGFloat) {
        switch width {
        case -500...(-130):
            color = .red
        case 130...500:
            color = .green
        default:
            color = .white
        }
    }
    
}

//#Preview {
//    UserListCard()
//}


//#Preview {
//    EmployeeStackView()
//}
