////
////  InterviewListCard.swift
//// BidSwipe
////
////  Created by Abdul-JAM-E-157 on 27/02/24.
////
//
//import SwiftUI
//import Kingfisher
//
//struct InterviewListCard: View {
//    
//    @Binding var interviewDetail: InterviewListModel
//    
//    var body: some View {
//        VStack {
//            HStack {
//                KFImage.url(getMediaURL(url: interviewDetail.user?.profile_image ?? ""))
//                    .placeholder({
//                        Image(.imgPlaceholder)
//                            .resizable()
//                            .blur(radius: 1.5)
//                    })
//                    .retry(maxCount: 3, interval: .seconds(5))
//                    .cacheOriginalImage()
//                    .resizable()
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 50, height: 50)
//                    .clipShape(Circle())
//                
//                VStack(alignment: .leading) {
//                    Text(interviewDetail.job?.title ?? "")
//                        .font(.custom(nunitoSemiBold, fixedSize: 18))
//                        .lineLimit(1)
//                    
//                    Text(interviewDetail.user?.name ?? "")
//                        .font(.custom(nunitoRegular, fixedSize: 14))
//                        .lineLimit(1)
//                }.padding(.leading, 10)
//                
//                Spacer()
//            }
//            
//            Divider()
//                .frame(height: 2)
//                .padding(.top)
//            
//            VStack(spacing: 6) {
//                HStack {
//                    Text("Salary")
//                        .font(.custom(nunitoRegular, fixedSize: 14))
//                    Spacer()
//                    Text("\(interviewDetail.job?.salary?.toCurrency() ?? "")/\(interviewDetail.job?.salary_type ?? "")")
//                        .font(.custom(nunitoSemiBold, fixedSize: 14))
//                }
//                HStack {
//                    Text("Interview Date")
//                        .font(.custom(nunitoRegular, fixedSize: 14))
//                    Spacer()
//                    Text("\(interviewDetail.scheduledDate ?? " - ")")
//                        .font(.custom(nunitoSemiBold, fixedSize: 14))
//                }
//                HStack {
//                    Text("Interview Time")
//                        .font(.custom(nunitoRegular, fixedSize: 14))
//                    Spacer()
//                    Text("\(interviewDetail.scheduledTime ?? " - ")")
//                        .font(.custom(nunitoSemiBold, fixedSize: 14))
//                }
//            }
//        }
//        .padding(.all)
//        .frame(width: screenWidth - 30)
//        .background(
//            RoundedRectangle(cornerRadius: 10)
//                .fill(Color.white)
//                .shadow(color: .gray, radius: 3, x: 0, y: 0)
//        )
//    }
//}
//
//#Preview {
//    InterviewListCard(interviewDetail: .constant( InterviewListModel()))
//}
