//
//  JobMatchSheet.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 03/02/24.
//

import SwiftUI
import Kingfisher

struct JobMatchSheet: View {
    
    @Binding var jobDetail: InterviewScheduleModal
    
    @State var userImage: String = ""
    
        //MARK: - CallBack Functions
    var onScheduleClick: (() -> Void)?
    var onContinueClick: (() -> Void)?
    
    @ViewBuilder
    func InterviewCard() -> some View {
        HStack {
            Spacer()
            VStack(spacing: 0) {
//                Text(jobDetail.job?.title ?? "")
//                    .font(.custom(nunitoBold, fixedSize: 16))
//                    .foregroundStyle(.black)
                
//                Text("\(jobDetail.job?.salary?.toCurrency() ?? "")/\(jobDetail.job?.salary_type ?? "")")
//                    .font(.custom(nunitoMedium, fixedSize: 13))
//                    .foregroundStyle(.black)
                
//                Text("\(jobDetail.job?.user?.company_data?.company_name ?? "" != "" ? jobDetail.job?.user?.company_data?.company_name ?? "" : jobDetail.job?.user?.name ?? "")")
//                    .font(.custom(nunitoMedium, fixedSize: 13))
//                    .foregroundStyle(.gray)
            }
            Spacer()
        }
        .padding(.vertical)
        .background(.text.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
    
        //MARK: - Logout Sheet View
    var body: some View {
        VStack(spacing: 18) {
            
            ZStack {
                KFImage.url(getMediaURL(url: jobDetail.job?.user?.company_data?.company_logo ?? "" != "" ? jobDetail.job?.user?.company_data?.company_logo ?? "" : jobDetail.job?.user?.profile_image ?? ""))
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
                    .padding(.all, 2)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(radius: 3)
                    .offset(x: 25)
                KFImage.url(getMediaURL(url: userImage))
                    .placeholder({
                        Image(.menuProfile)
                            .renderingMode(.template)
                            .resizable()
                            .padding(.all, 5)
                            .foregroundStyle(.text.opacity(0.5))
                    })
                    .retry(maxCount: 3, interval: .seconds(5))
                    .cacheOriginalImage()
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 55, height: 55)
                    .clipShape(Circle())
                    .padding(.all, 2)
                    .background(.white)
                    .clipShape(Circle())
                    .shadow(radius: 3)
                    .offset(x: -20)
            }
            
            Text("You have matched!")
                .font(.custom(nunitoBold, fixedSize: 20))
            
            InterviewCard()
            
            PrimaryButton(title: "Schedule Interview", isOutLine: false, onButtonClick: {
                self.onScheduleClick?()
            }, width: screenWidth/1.5, height: 45)
            
            PrimaryButton(title: "Continue Discovering", isOutLine: true, onButtonClick: {
                self.onContinueClick?()
            }, width: screenWidth/1.5, height: 45)
        }.onAppear(perform: {
            if let userDetail: UserDetailModal = UserDefaultsManager.shared.getModel(forKey: .userDetail) {
                userImage = userDetail.profile_image ?? ""
            }
        })
    }
}

//#Preview {
//    JobMatchSheet(jobDetail: .constant(JobDetailResponse()))
//}
