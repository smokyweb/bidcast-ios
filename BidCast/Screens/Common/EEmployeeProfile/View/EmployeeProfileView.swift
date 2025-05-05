//
//  EmployeeProfileView.swift
//  imperium
//
//  Created by JAM-E-265 on 08/02/24.
//

import SwiftUI
import AVFoundation
import Kingfisher

struct EmployeeProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    
    //MARK: - Variables
    @State var showLoading: Bool = false
    @State var showAlert: Bool = false
    @State var alertType: AlertType = .error(title: "", message: "", leftBtnText: "", rightBtnText: "")
    @State var employeeDetail: UserDetailModal = UserDetailModal(id: 0,name: "",first_name: "",last_name: "",email: "",role_id: "", location: "", is_student: "",most_recent_job_title: "",most_recent_company: "", your_dream_job: "", profile_image: "", video_resume: "" , deleted_at: "", created_at: "",roles: UserRole(id: 0, user_role: ""),images: [], qualification: [],work_histories: [], skills: [],license_certifications: [], volunteer_experiences: [], languages: [], interested_jobs: [])
    
    @State private var player: AVPlayer = AVPlayer(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
    
    
    
    //MARK: - Navigation Variables
    @State var navigateToPersInfo: Bool = false
    @State var navigateToVidRes: Bool = false
    @State var naviagteToImages: Bool = false
    @State var naviagteToEdu: Bool = false
    @State var naviagetToWorkHis: Bool = false
    @State var navigateToSkills: Bool = false
    @State var navigateToLicCer: Bool = false
    @State var navigateToVolExp: Bool = false
    @State var navigateToJobCatInt: Bool = false
    
    var viewModal = UserProfileViewModal()
    
    //MARK: - Personal Information View
    @ViewBuilder
    func personalInfo() -> some View {
        VStack(spacing: 10){
            HStack{
                Text ("Name")
                    .font(.custom(nunitoRegular, size: 12))
                    .foregroundStyle(.gray)
                Spacer()
                
                Text(employeeDetail.name ?? "")
                    .font(.custom(nunitoMedium, size: 13))
                    .foregroundStyle(.black)
            }
            HStack{
                Text ("Email Address")
                    .font(.custom(nunitoRegular, size: 12))
                Spacer()
                
                Text(employeeDetail.email ?? "")
                    .font(.custom(nunitoMedium, size: 13))
                    .foregroundStyle(.black)
                
            }
            HStack{
                Text("Location")
                    .font(.custom(nunitoRegular, size: 12))
                Spacer()
                
                Text(employeeDetail.location ?? "")
                    .font(.custom(nunitoMedium, size: 13))
            }
            HStack{
                Text("Passsword")
                    .font(.custom(nunitoRegular, size: 12))
                    .foregroundColor(.gray)
                
                Spacer()
                
                Text("********")
                    .font(.custom(nunitoMedium, size: 13))
                    .kerning(4)
                    .foregroundStyle(.black)
            }
        }
        .padding(.all)
        .background( RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .shadow(color: .gray, radius: 1 ,x: 0, y:0)
        )
    }
    
    //MARK: - Education Information View
@ViewBuilder
func educationInfo() -> some View {
    
    VStack(spacing: 10) {
        HStack {
            Text("Highest Level of Edcation")
                .font(.custom(nunitoRegular, size: 12))
                .foregroundStyle(.gray)
            
            Spacer()
            
            Text(employeeDetail.qualification?.first?.name ?? "")
                .font(.custom(nunitoSemiBold, size: 13))
                .foregroundStyle(.black)
        }
        
        Divider()
        
        ForEach(employeeDetail.qualification!.indices, id: \.self) {
            ind in
            VStack {
                HStack {
                    Text(employeeDetail.qualification?[ind].name ?? "")
                        .font(.custom(nunitoRegular, size: 12))
                        .foregroundStyle(.gray)
                    
                    Spacer()
                    
                    Text(employeeDetail.qualification?[ind].institute_name?.capitalized ?? "")
                        .font(.custom(nunitoSemiBold, size: 13))
                        .foregroundStyle(.black)
                }
                
                HStack {
                    Text("Graduated")
                        .font(.custom(nunitoRegular, size: 12))
                        .foregroundStyle(.gray)
                    
                    Spacer()
                    
                    Text(employeeDetail.qualification?[ind].graduation_date ?? "")
                        .font(.custom(nunitoMedium, size: 13))
                        .foregroundStyle(.black)
                }
                
                if employeeDetail.qualification?[ind].graduation_date != employeeDetail.qualification?.last?.graduation_date {
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
        VStack(spacing: 10){
            HStack{
                Text("Dream Job")
                    .font(.custom(nunitoRegular , size: 12))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text(employeeDetail.your_dream_job ?? "")
                    .font(.custom(nunitoSemiBold, size: 13))
                    .foregroundStyle(.black)
            }
            
            Divider()
            
            HStack{
                Text("Most Recent Job Title")
                    .font(.custom(nunitoRegular, size: 12))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text(employeeDetail.most_recent_job_title ?? "")
                    .font(.custom(nunitoSemiBold, size: 13))
                    .foregroundStyle(.black)
            }
            HStack {
                Text("Most Recent Company")
                    .font(.custom(nunitoRegular, size: 12))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text(employeeDetail.most_recent_company ?? "")
                    .font(.custom(nunitoMedium, size: 13))
                    .foregroundStyle(.black)
            }
            HStack {
                Text("Contact")
                    .font(.custom(nunitoRegular, size: 12))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text("angela@blustone .com")
                    .font(.custom(nunitoMedium, size: 13))
                    .foregroundStyle(.black)
            }
            Divider()
            
            HStack {
                Text("Job Title")
                    .font(.custom(nunitoRegular, size: 12))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text("angela@blustone .com")
                    .font(.custom(nunitoSemiBold, size: 13))
                    .foregroundStyle(.black)
            }
            
            HStack {
                Text("Company")
                    .font(.custom(nunitoRegular, size: 12))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text("BlueCorp")
                    .font(.custom(nunitoMedium, size: 13))
                    .kerning(4)
                    .foregroundStyle(.black)
            }
            
            HStack {
                Text("Contact")
                    .font(.custom(nunitoRegular, size: 12))
                    .foregroundStyle(.gray)
                
                Spacer()
                
                Text("angela@blustone .com")
                    .font(.custom(nunitoMedium, size: 13))
                    .foregroundStyle(.black)
            }
        }
        .padding(.all)
        .background(RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .shadow(color: .gray, radius: 1 ,x:0 ,y:0)
        )
        
    }
    //MARK: - Skills Information View
    @ViewBuilder
    func skillsInfo() -> some View{
        VStack(alignment: .leading, spacing: 10) {
            ForEach(employeeDetail.skills!.indices, id: \.self){
                ind in
                HStack{
                    Text(employeeDetail.skills?[ind].skill ?? "")
                        .font(.custom(nunitoRegular, size: 12))
                    foregroundStyle(.gray)
                    Spacer()
                    
                }
            }
        }
        .padding(.all)
        .background(RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .shadow(color: .gray, radius: 1,x: 0,y: 0))
        
    }
    //MARK: - Licences and Cer. Information View
    @ViewBuilder
    func licAndCerInfo() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(employeeDetail.license_certifications!.indices, id: \.self) {
                ind in
                HStack{
                    Text(employeeDetail.license_certifications?[ind].license_certificate ?? "")
                        .font(.custom(nunitoRegular, size: 12))
                        .foregroundStyle(.gray)
                    Spacer()
                }
            }
        }
        
        .padding(.all)
        .background(RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .shadow(color: .gray,radius: 1, x: 0,y: 0)
        )
    }
    //MARK: - Volunteer Exp. Information View
    @ViewBuilder
    func volunExpInfo() -> some View{
        VStack(alignment: .leading, spacing : 10) {
            ForEach(employeeDetail.volunteer_experiences!.indices, id: \.self){
                ind in
                
                HStack{
                    Text(employeeDetail.volunteer_experiences?[ind].volunteer_experience ?? "")
                        .font(.custom(nunitoRegular, size: 12))
                        .foregroundStyle(.gray)
                    Spacer()
                }
            }
        }
        .padding(.all)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .shadow(color: .gray, radius: 1, x: 0 ,y: 0)
        )
        
    }
    
    //MARK: - Interested Job Category View
    @ViewBuilder
    func jobCateOfInterest () -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(employeeDetail.interested_jobs!.indices, id: \.self){
                ind  in
                HStack{
                    Text(employeeDetail.interested_jobs?[ind].job.name ?? "")
                        .font(.custom(nunitoRegular, size: 12))
                        .foregroundStyle(.gray)
                    Spacer()
                }
            }
        }
        .padding(.all)
        .background(RoundedRectangle(cornerRadius: 10)
            .fill(Color.white)
            .shadow(color: .gray, radius: 1, x:0 , y: 0)
        )
        
    }
    
    //MARK: - User Detail Information View
    
    var body: some View {
        ZStack {
            VStack(spacing: 0, content: {
                PrimaryHeader(title: "Employee Profile", leadingImgArr: [.sideArrow], trailingImgArr: [.notification], onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                }, onClickTrailing: { _ in
                    print("Bell Button Clicked")
                })
                ScrollView(showsIndicators: false, content: {
                    VStack(){
                        
                        Text("Applying For")
                            .font(.custom(nunitoBlack, fixedSize: 18))
                            .foregroundStyle(.black)
                            .padding(.all)
                        //                          Text.padding([.top, .leading])
                            .padding(.leading ,-200)
                            .padding(.bottom , -29)
                        
                        LazyVStack(spacing: 18) {
                            ForEach(0...0, id: \.self) {
                                _ in
                                JobListCardImg()
                            }
                        }.padding(.all)
                        
                    }
                    VStack(spacing: 0, content: {
                        VStack {
                            TitleWithPencil(title: "Video Resume", onPencilClick: {
                                withAnimation(.easeOut) { navigateToVidRes = true }
                            })
                            
                            if employeeDetail.video_resume != "" && employeeDetail.video_resume != nil {
                                CustomVideoPlayer(player: player)
                                    .frame(height: screenHeight/1.5)
                                    .onAppear(perform: {
                                        player.play()
                                    })
                                    .onDisappear(perform: {
                                        player.pause()
                                    })
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                Text("No Video Resume Added")
                                    .font(.custom(nunitoRegular, fixedSize: 14))
                                    .foregroundStyle(.black.opacity(0.7))
                                    .padding(.vertical)
                            }
                            
                            //                            Image(.dummy1)
                            //                                .resizable()
                            //                                .frame(width: screenWidth - 30, height: screenHeight/1.75)
                            //                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .padding(.all)
                        .background(.text.opacity(0.1))
                        
                        VStack {
                            TitleWithPencil(title: "Personal Information", onPencilClick: {
                                withAnimation(.easeOut) { navigateToPersInfo = true }
                            })
                            personalInfo()
                        }
                        .padding(.all)
                        .background(.text.opacity(0.05))
                        
                        
                        VStack {
                            TitleWithPencil(title: "Images", onPencilClick: {
                                withAnimation(.easeOut) { naviagteToImages = true }
                            })
                            
                            if employeeDetail.images?.count ?? 0 > 0 {
                                ScrollView(.horizontal, showsIndicators: false, content: {
                                    HStack(content: {
                                        ForEach(employeeDetail.images!.indices, id: \.self) {
                                            ind in
                                            KFImage.url(getMediaURL(url: employeeDetail.images?[ind].image ?? ""))
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
                                withAnimation(.easeOut) { naviagteToEdu = true }
                            })
                            if (employeeDetail.qualification?.count ?? 0) > 0 {
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
                                withAnimation(.easeOut) { naviagetToWorkHis = true }
                            })
                            if (employeeDetail.work_histories?.count ?? 0) > 0 {
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
                            TitleWithPencil(title: "Skills", onPencilClick: {
                                withAnimation(.easeOut) { navigateToSkills = true }
                            })
                            if (employeeDetail.skills?.count ?? 0) > 0 {
                                skillsInfo()
                            } else {
                                Text("No Skills Added")
                                    .font(.custom(nunitoRegular, fixedSize: 14))
                                    .foregroundStyle(.black.opacity(0.7))
                                    .padding(.vertical)
                            }
                        }
                        .padding(.all)
                        .background(.text.opacity(0.1))
                        
                        
                        VStack {
                            TitleWithPencil(title: "Licenses & Certificates", onPencilClick: {
                                withAnimation(.easeOut) { navigateToLicCer = true }
                            })
                            if (employeeDetail.license_certifications?.count ?? 0) > 0 {
                                licAndCerInfo()
                            } else {
                                Text("No Licences & Certificates Added")
                                    .font(.custom(nunitoRegular, fixedSize: 14))
                                    .foregroundStyle(.black.opacity(0.7))
                                    .padding(.vertical)
                            }
                        }
                        .padding(.all)
                        .background(.text.opacity(0.05))
                        
                        
                        VStack {
                            TitleWithPencil(title: "Volunteer Experience", onPencilClick: {
                                withAnimation(.easeOut) { navigateToVolExp = true }
                            })
                            if (employeeDetail.volunteer_experiences?.count ?? 0) > 0 {
                                volunExpInfo()
                            } else {
                                Text("No Volunteer Experience Added")
                                    .font(.custom(nunitoRegular, fixedSize: 14))
                                    .foregroundStyle(.black.opacity(0.7))
                                    .padding(.vertical)
                            }
                        }
                        .padding(.all)
                        .background(.text.opacity(0.1))
                        
                        
                        VStack {
                            TitleWithPencil(title: "Job Categories of Interest", onPencilClick: {
                                withAnimation(.easeOut) { navigateToJobCatInt = true }
                            })
                            if (employeeDetail.interested_jobs?.count ?? 0) > 0 {
                                jobCateOfInterest()
                            } else {
                                Text("No Interested Job Categories Added")
                                    .font(.custom(nunitoRegular, fixedSize: 14))
                                    .foregroundStyle(.black.opacity(0.7))
                                    .padding(.vertical)
                            }
                        }
                        .padding(.all)
                        .background(.text.opacity(0.05))
                    })
                }).padding(.top, -topPadding)
                
                Spacer()
//                
//                HStack {
//                    Button(action: {}, label: {
//                        Image(systemName: "xmark.circle.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 25, height: 25)
//                        
//                        Text("Swipe Left")
//                            .font(.custom(nunitoBold, fixedSize: 14))
//                    }).tint(.red)
//                    
//                    Spacer()
//                    
//                    Button(action: {}, label: {
//                        Text("Swipe Right")
//                            .font(.custom(nunitoBold, fixedSize: 14))
//                        Image(systemName: "checkmark.circle.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 25, height: 25)
//                    }).tint(.green)
//                    
//                    
//                    Spacer()
//                }.padding(.all)
            })
            .onAppear(perform: {
                showLoading = false
                self.viewModal.getProfile()
                self.observe()
            })
            
            if showLoading {
                Loader(isLoading: $showLoading)
            }
            
            
            CusNavLink(doNavigate: $naviagteToImages, destination: UserImageSelectionScreen())
            CusNavLink(doNavigate: $navigateToVidRes, destination: YourVideoResume())
            CusNavLink(doNavigate: $navigateToJobCatInt, destination: JobCategoriesView())
            CusNavLink(doNavigate: $navigateToSkills, destination: MySkillScreen(skillArray: $employeeDetail.skills))
            CusNavLink(doNavigate: $navigateToLicCer, destination: LicensesScreen())
            CusNavLink(doNavigate: $navigateToVolExp, destination: VolunteerScreen(volunExpArray: $employeeDetail.volunteer_experiences))
            CusNavLink(doNavigate: $naviagetToWorkHis, destination: UserWorkHistory())
            CusNavLink(doNavigate: $navigateToPersInfo, destination: UserPersonalInfoScreen())
            CusNavLink(doNavigate: $naviagteToEdu, destination: MyEducationScreen())
            
            
           
          
            
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
                    print("Error >> \(String(describing: error))")
            }
        }
    }
    
    func handleSuccess() {
        let response = viewModal.response
        
        if response.status == "success" {
            employeeDetail = response.data!
            employeeDetail.qualification?.sort(by: { $0.order ?? "" < $1.order ?? "" })
            
            if employeeDetail.video_resume != "" {
                let url = getMediaURL(url: employeeDetail.video_resume ?? "")
                player.pause()
                player.replaceCurrentItem(with: AVPlayerItem(url: url))
                player.play()
            }
            
            UserDefaultsManager.shared.remove(forKey: .userDetail)
            UserDefaultsManager.shared.setModel(employeeDetail, forKey: .userDetail)
        }
    }
    
      
    }




#Preview {
    EmployeeProfileView()
}
