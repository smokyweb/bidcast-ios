////
////  JobMatchesCard.swift
////  imperium
////
////  Created by JAM-E-282 on 20/01/24.
////
//
//import SwiftUI
//import Kingfisher
//
//struct JobMatchesCard: View {
//    
//    @Binding var matchedJobDetail: InterviewScheduleModal
//
//    //MARK: - CallBack Closure's
//    var onRescheduleClick: (() -> Void)?
//    var onScheduleClick: (() -> Void)?
//    var onClick: (() -> Void)?
//    
//    var onStatusClick: ((String, String) -> Void)?
//    
//    @State var showAction: Bool = false
//    
//    var body: some View {
//        Button(action: { onClick?() }, label: {
//            VStack {
//                HStack {
//                    KFImage.url(getMediaURL(url: matchedJobDetail.job?.user?.company_data?.company_logo ?? "" != "" ? matchedJobDetail.job?.user?.company_data?.company_logo ?? "" : (matchedJobDetail.user?.profile_image ?? "") == "" ? matchedJobDetail.job?.user?.profile_image ?? "" : matchedJobDetail.user?.profile_image ?? ""))
//                        .placeholder({
//                            Image(.imgPlaceholder)
//                                .resizable()
////                                .blur(radius: 1.5)
//                        })
//                        .retry(maxCount: 3, interval: .seconds(5))
//                        .cacheOriginalImage()
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 50, height: 50)
//                        .clipShape(Circle())
//                    
//                    VStack(alignment: .leading) {
//                        Text(matchedJobDetail.job?.title ?? "")
//                            .font(.custom(nunitoSemiBold, fixedSize: 18))
//                            .lineLimit(1)
//                            .foregroundStyle(.black)
//                        
//                        Text(matchedJobDetail.job?.user?.company_data?.company_name ?? "" != "" ? matchedJobDetail.job?.user?.company_data?.company_name ?? "" : matchedJobDetail.user?.name ?? "" == "" ? matchedJobDetail.job?.user?.name ?? "" : matchedJobDetail.user?.name ?? "")
//                            .font(.custom(nunitoRegular, fixedSize: 14))
//                            .lineLimit(1)
//                            .foregroundStyle(.black)
//                    }.padding(.leading, 10)
//                    
//                    Spacer()
//                }
//                
//                Divider()
//                    .frame(height: 2)
//                
//                VStack(spacing: 6) {
//                    HStack {
//                        Text("Salary")
//                            .font(.custom(nunitoRegular, fixedSize: 14))
//                            .foregroundStyle(.black)
//                        Spacer()
//                        Text("$\((matchedJobDetail.job?.salary ?? ""))/\(matchedJobDetail.job?.salary_type ?? "")")
//                            .font(.custom(nunitoSemiBold, fixedSize: 14))
//                            .foregroundStyle(.black)
//                    }
//                    if let role: String = UserDefaultsManager.shared.value(forKey: .userRole) {
//                        if role == "employer" {
//                            HStack {
//                                
//                                Text("Interview Status")
//                                    .font(.custom(nunitoRegular, fixedSize: 14))
//                                    .foregroundStyle(.black)
//                                Spacer()
//                                Text(matchedJobDetail.status?.getInterviewStatus() ?? " - ")
//                                    .font(.custom(nunitoSemiBold, fixedSize: 14))
//                                    .foregroundStyle(matchedJobDetail.status?.getInterviewStatusColor() ?? .pinkBtn)
//                            }
//                        }}
//                        
//                    HStack {
//                        Text("Interview Date")
//                            .font(.custom(nunitoRegular, fixedSize: 14))
//                            .foregroundStyle(.black)
//                        Spacer()
//                        Text("\(matchedJobDetail.scheduledDate ?? " - ")")
//                            .font(.custom(nunitoSemiBold, fixedSize: 14))
//                            .foregroundStyle(.black)
//                    }
//                    HStack {
//                        Text("Interview Time")
//                            .font(.custom(nunitoRegular, fixedSize: 14))
//                            .foregroundStyle(.black)
//                        Spacer()
//                        Text("\(matchedJobDetail.scheduledTime ?? " - ")")
//                            .font(.custom(nunitoSemiBold, fixedSize: 14))
//                            .foregroundStyle(.black)
//                    }
//                }
//                
//                if matchedJobDetail.status == "0" {
//                    PrimaryButton(
//                        title: "Schedule Interview",
//                        isOutLine: false,
//                        onButtonClick: {
//                            self.onScheduleClick?()
//                        }, width: screenWidth - 60)
//                    .padding(.top, 5)
//                }
//                
//                if let role: String = UserDefaultsManager.shared.value(forKey: .userRole) {
//                    if role == "employee" && matchedJobDetail.status == "3" {
//                        PrimaryButton(
//                            title: "Accept",
//                            isOutLine: false,
//                            onButtonClick: {
//                                onStatusClick?("2", "\(matchedJobDetail.id ?? 0)")
//                            }, width: screenWidth - 60, height: 40)
//                        .padding(.top, 5)
//                        PrimaryButton(
//                            title: "Reject",
//                            isOutLine: true,
//                            onButtonClick: {
//                                onStatusClick?("4", "\(matchedJobDetail.id ?? 0)")
//                            }, width: screenWidth - 60, height: 40)
//                        .padding(.top, 5)
//                    }
//                }
//                
//                    //            if matchedJobDetail.status == "1" {
//                    //                PrimaryButton(
//                    //                    title: "Reschedule",
//                    //                    isOutLine: true,
//                    //                    onButtonClick: {
//                    //                        self.onRescheduleClick?()
//                    //                    }, width: screenWidth - 60)
//                    //                .padding(.top, 5)
//                    //            } else if matchedJobDetail.status == "0" {
//                    //                PrimaryButton(
//                    //                    title: "Schedule Interview",
//                    //                    isOutLine: false,
//                    //                    onButtonClick: {
//                    //                        self.onScheduleClick?()
//                    //                    }, width: screenWidth - 60)
//                    //                .padding(.top, 5)
//                    //            } else if matchedJobDetail.status == "2" {
//                    //                PrimaryButton(
//                    //                    title: "Schedule Interview",
//                    //                    isOutLine: false,
//                    //                    onButtonClick: {
//                    //                        self.onScheduleClick?()
//                    //                    }, width: screenWidth - 60)
//                    //                .padding(.top, 5)
//                    //                PrimaryButton(
//                    //                    title: "Reschedule",
//                    //                    isOutLine: true,
//                    //                    onButtonClick: {
//                    //                        self.onRescheduleClick?()
//                    //                    }, width: screenWidth - 60)
//                    //                .padding(.top, 5)
//                    //            }
//            }
//            .padding(.all)
//            .frame(width: screenWidth - 30)
//            .background(
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(Color.white)
//                    .shadow(color: .gray, radius: 2, x: 0, y: 0)
//            )
//        })
//    }
//}
//
//#Preview {
//    JobMatchesCard(matchedJobDetail: .constant(InterviewScheduleModal()))
//}
