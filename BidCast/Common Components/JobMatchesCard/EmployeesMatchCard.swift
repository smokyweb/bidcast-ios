//
//  EmployeesMatchCard.swift
//  imperium
//
//  Created by JAM-E-221 on 09/08/24.
//

import SwiftUI
import Kingfisher


//struct EmployeesMatchCard: View {
//        
//        @Binding var userList: UserDetailModal
//       @Binding var jobDetail: JobDetailResponse
//
//        //MARK: - CallBack Closure's
//        var onRescheduleClick: (() -> Void)?
//        var onScheduleClick: (() -> Void)?
//        var onClick: (() -> Void)?
//        
//        var onStatusClick: ((String, String) -> Void)?
//        
//        @State var showAction: Bool = false
//        
//        var body: some View {
//            Button(action: { onClick?() }, label: {
//                VStack {
//                    HStack {
//                        KFImage.url(getMediaURL(url: userList.profile_image ?? ""))
//                            .placeholder({
//                                Image(.imgPlaceholder)
//                                    .resizable()
//    //                                .blur(radius: 1.5)
//                            })
//                            .retry(maxCount: 3, interval: .seconds(5))
//                            .cacheOriginalImage()
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: 50, height: 50)
//                            .clipShape(Circle())
//                        
//                        VStack(alignment: .leading) {
//                            Text(userList.name ?? "")
//                                .font(.custom(nunitoSemiBold, fixedSize: 18))
//                                .lineLimit(1)
//                                .foregroundStyle(.black)
//                            
//                            Text(jobDetail.title ?? "")
//                                .font(.custom(nunitoRegular, fixedSize: 14))
//                                .lineLimit(1)
//                                .foregroundStyle(.black)
//                        }.padding(.leading, 10)
//                        
//                        Spacer()
//                    }
//                    
//                    Divider()
//                        .frame(height: 2)
//                    
//                    VStack(spacing: 6) {
//                        HStack {
//                            Text("Salary")
//                                .font(.custom(nunitoRegular, fixedSize: 14))
//                                .foregroundStyle(.black)
//                            Spacer()
//                            Text("$\((jobDetail.salary ?? ""))/\(jobDetail.salary_type ?? "")")
//                                .font(.custom(nunitoSemiBold, fixedSize: 14))
//                                .foregroundStyle(.black)
//                        }
//                        if let role: String = UserDefaultsManager.shared.value(forKey: .userRole) {
//                            if role == "employer" {
//                                HStack {
//                                    
//                                    Text("Interview Status")
//                                        .font(.custom(nunitoRegular, fixedSize: 14))
//                                        .foregroundStyle(.black)
//                                    Spacer()
//                                    Text(userList.job?[0].status?.getInterviewStatus() ?? " - ")
//                                        .font(.custom(nunitoSemiBold, fixedSize: 14))
//                                        .foregroundStyle(userList.status?.getInterviewStatusColor() ?? .pinkBtn)
//                                }
//                            }}
//                            
//                        HStack {
//                            Text("Interview Date")
//                                .font(.custom(nunitoRegular, fixedSize: 14))
//                                .foregroundStyle(.black)
//                            Spacer()
//                            Text("\(userList.job?[0].scheduledDate ?? " - ")")
//                                .font(.custom(nunitoSemiBold, fixedSize: 14))
//                                .foregroundStyle(.black)
//                        }
//                        HStack {
//                            Text("Interview Time")
//                                .font(.custom(nunitoRegular, fixedSize: 14))
//                                .foregroundStyle(.black)
//                            Spacer()
//                            Text("\(userList.job?[0].scheduledTime ?? " - ")")
//                                .font(.custom(nunitoSemiBold, fixedSize: 14))
//                                .foregroundStyle(.black)
//                        }
//                    }
//                    
//                    if userList.status == "0" {
//                        PrimaryButton(
//                            title: "Schedule Interview",
//                            isOutLine: false,
//                            onButtonClick: {
//                                self.onScheduleClick?()
//                            }, width: screenWidth - 60)
//                        .padding(.top, 5)
//                    }
//                    
//                    if let role: String = UserDefaultsManager.shared.value(forKey: .userRole) {
//                        if role == "employer" && userList.status == "3" {
//                            PrimaryButton(
//                                title: "Accept",
//                                isOutLine: false,
//                                onButtonClick: {
//                                    onStatusClick?("2", "\(userList.id ?? 0)")
//                                }, width: screenWidth - 60, height: 40)
//                            .padding(.top, 5)
//                            PrimaryButton(
//                                title: "Reject",
//                                isOutLine: true,
//                                onButtonClick: {
//                                    onStatusClick?("4", "\(userList.id ?? 0)")
//                                }, width: screenWidth - 60, height: 40)
//                            .padding(.top, 5)
//                        }
//                    }
//                
//                }
//                .padding(.all)
//                .frame(width: screenWidth - 30)
//                .background(
//                    RoundedRectangle(cornerRadius: 10)
//                        .fill(Color.white)
//                        .shadow(color: .gray, radius: 2, x: 0, y: 0)
//                )
//            })
//            
//        }
//    }

//#Preview {
//    EmployeesMatchCard()
//}
