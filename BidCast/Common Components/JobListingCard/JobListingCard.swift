////
////  JobListingCard.swift
//// BidSwipe
////
////  Created by JAM-E-282 on 20/01/24.
////
//
//import SwiftUI
//import RichText
//
//struct JobListingCard: View {
//    
//    @Binding var jobDetail: JobDetailResponse
//    
//    @State var readMoreDisable: Bool = false
//    
//    var showStatus: Bool = false
//    @State private var contentHeight: CGFloat = .zero
//
//    var onClick: ((Int) -> Void)?
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 5) {
//                
//                HStack {
//                    Text(jobDetail.title ?? " - ")
//                        .font(.custom(nunitoBold, fixedSize: 18))
//                        .bold()
//                        .foregroundStyle(.black)
//                    
//                    if showStatus {
//                        Circle()
//                            .frame(width: 3, height: 3)
//                            .foregroundColor(.gray)
//                        
//                        Text(jobDetail.job_type ?? " - ")
//                            .font(.custom(nunitoRegular, fixedSize: 13))
//                            .bold()
//                            .foregroundStyle(.green)
//                            .lineLimit(1)
//                    }
//                    Spacer()
//                }
//                
//                if showStatus {
//                    VStack(alignment: .leading, spacing: 5) {
//                        RichText(html: jobDetail.description ?? " - ")
//                            .customCSS("""
//                                            body {
//                                                font-size: 14px;
//                                            }
//                                        """)
//                            .background(GeometryReader { geometry -> Color in
//                                DispatchQueue.main.async {
//                                    contentHeight = geometry.size.height
//                                }
//                                return Color.clear
//                            })
//                        //                                }
//                            .frame(height: readMoreDisable ? min(contentHeight, 60) : contentHeight)
//                            .overlay(alignment: .bottomTrailing) {
//                                if readMoreDisable && contentHeight > 60 {
//                                    Button(action: {
//                                        withAnimation {
//                                            readMoreDisable.toggle()
//                                        }
//                                    }) {
//                                        Text("Read More")
//                                            .font(.custom("Nunito-Regular", fixedSize: 10))
//                                            .foregroundColor(.blue)
//                                            .underline()
//                                    }
//                                }
//                            }
//                        Text("$\(jobDetail.salary ?? "")/\(jobDetail.salary_type?.capitalized ?? " - ")")
//                            .font(.custom("Nunito-Regular", fixedSize: 14))
//                            .bold()
//                            .foregroundColor(.black)
//                    }
//                } else {
//                    HStack {
//                        Text(jobDetail.job_type?.capitalized ?? " - ")
//                            .font(.custom(nunitoRegular, fixedSize: 14))
//                            .bold()
//                            .foregroundStyle(.gray)
//                        
//                        Circle()
//                            .frame(width: 3, height: 3)
//                            .foregroundColor(.gray)
//                        
//                        Text("$\(jobDetail.salary ?? " - ")/\(jobDetail.salary_type?.capitalized ?? " - ")")
//                            .font(.custom(nunitoRegular, fixedSize: 14))
//                            .bold()
//                            .foregroundStyle(.black)
//                        
//                        Spacer()
//                    }
//                }
//            
//        }
//            .onTapGesture {
//                self.onClick?(jobDetail.id ?? 0)
//            }
//            .padding(.all)
//            .background(
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(Color.white)
//                    .shadow(color: .gray, radius: 2, x: 0, y: 0)
//            )
//            .onTapGesture {
//                self.onClick?(jobDetail.id ?? 0)
//            }
//    }
//}
//
//#Preview {
//    JobListingCard(jobDetail: .constant(JobDetailResponse()))
//}
