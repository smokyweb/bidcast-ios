////
////  JobPostDetailScreen.swift
////  imperium
////
////  Created by JAM-E-282 on 20/01/24.
////
//
//import SwiftUI
//import Kingfisher
//import RichText
//import BottomSheet
//
//struct JobPostDetailScreen: View {
//    
//    @Binding var job: JobDetailResponse
//    @Binding var enableSwipe: Bool
//    @Binding var rightSwipe: Int
//    @State var showTryThis: Bool = false
//    @State var showSwipeSheet: Bool = false
//    @State var isFromHome: Bool = false
//
//    @State var educationField: String = ""
//    @State var navigateToSubscription: Bool = false
//
//    @State var navigateToCompanyScreen: Bool = false
//    @State var selectedCompanyId: String = ""
//    @State var navigateToSearch: Bool = false
//    @State private var offset = CGSize.zero
//    @State private var color: Color = .white
//    
//    @State var showSwipeBtn: Bool = true
//    
//    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
//    @State var showAlert: Bool = false
//    
//    var onSwipe: ((Bool, Int) -> Void)?
//    var onSaveButtonClick: ((Int) -> Void)?
//    
//    @ViewBuilder
//    func detailBlockSection(title: String, description: String, ind: Int) -> some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(title)
//                .font(.custom(nunitoBold, fixedSize: 18))
//            RichText(html: description)
//                .customCSS("""
//            body {
//                font-size: 15px;
//            }
//        """)
//                .font(.custom(nunitoRegular, fixedSize: 15))
//                .multilineTextAlignment(.leading)
//        }
//        .padding(.vertical, 8)
//        .padding(.horizontal)
//        .background(ind%2 == 0 ? .text.opacity(0.05) : .clear)
//    }
//    
//    var body: some View {
//        VStack {
//            ScrollView(showsIndicators: false, content: {
//                VStack(alignment: .leading, content: {
//                    if job.isMatched ?? false {
//                        KFImage.url(getMediaURL(url: job.user?.company_data?.company_logo ?? "" != "" ? job.user?.company_data?.company_logo ?? "" : job.user?.profile_image ?? ""))
//                            .placeholder({
//                                Image(.imgPlaceholder)
//                                    .resizable()
//    //                                .blur(radius: 1.5)
//                            })
//                            .retry(maxCount: 3, interval: .seconds(5))
//                            .cacheOriginalImage()
//                            .resizable()
//                            .frame(width: screenWidth, height: screenHeight/4)
//                            .overlay(alignment: .topTrailing) {
//                                Button(action: {
//                                    withAnimation {
//                                        if job.isSaved ?? false {
//                                            alertType = .sheetType(icon: .alert, title: "Alert", message: "Do you want to remove this job from Saved?", primaryBtnText: "Continue", secondaryBtnText: "Cancel")
//                                            showAlert = true
//                                        } else {
//                                            onSaveButtonClick?(job.id ?? 0)
//                                        }
//                                    } }, label: {
//                                    Image(.starImg)
//                                        .resizable()
//                                        .renderingMode(.template)
//                                        .frame(width: 26, height: 26)
//                                        .foregroundStyle(job.isSaved ?? false ? .yellow : .gray.opacity(0.5))
//                                        .padding([.top, .trailing], 8)
//                                })
//                            }
//                    }else{
//                        KFImage.url(getMediaURL(url:  ""))
//                            .placeholder({
//                                Image(uiImage: UIImage(named: "logo_Image")!)
//                                    .resizable()
////                                    .blur(radius: 1.5)
//                            })
//                            .retry(maxCount: 3, interval: .seconds(5))
//                            .cacheOriginalImage()
//                            .resizable()
//                            .frame(width: screenWidth, height: screenHeight/4)
//                            .overlay(alignment: .topTrailing) {
//                                Button(action: {
//                                    withAnimation {
//                                        if job.isSaved ?? false {
//                                            alertType = .sheetType(icon: .alert, title: "Alert", message: "Do you want to remove this job from Saved?", primaryBtnText: "Continue", secondaryBtnText: "Cancel")
//                                            showAlert = true
//                                        } else {
//                                            onSaveButtonClick?(job.id ?? 0)
//                                        }
//                                    } }, label: {
//                                    Image(.starImg)
//                                        .resizable()
//                                        .renderingMode(.template)
//                                        
//                                        .frame(width: 26, height: 26)
//                                        .foregroundStyle(job.isSaved ?? false ? .yellow : .gray.opacity(0.5))
//                                        .padding([.top, .trailing], 8)
//                                })
//                            }
//                    }
//                    
//                   
//
//                        
//                    
//                    VStack(alignment: .leading) {
//                        
//                        TitleWithLine(title: job.title ?? "")
//                        
//                        Text("$\(job.salary ?? "")/\(job.salary_type ?? "")")
//                            .font(.custom(nunitoBold, fixedSize: 15))
//                        
//                        Button(action: { withAnimation {
//                            if let id = job.user?.id {
//                                selectedCompanyId = "\(id)"
//                                navigateToCompanyScreen = true
//                            }
//                        }}, label: {
//                            HStack(alignment: .center) {
//                                if job.isMatched ?? false {
//                                    KFImage.url(getMediaURL(url: job.user?.company_data?.company_logo ?? "" != "" ? job.user?.company_data?.company_logo ?? "" : job.user?.profile_image ?? ""))
//                                        .placeholder({
//                                            Image(.imgPlaceholder)
//                                                .resizable()
//                                            //                                            .blur(radius: 1.5)
//                                        })
//                                        .retry(maxCount: 3, interval: .seconds(5))
//                                        .cacheOriginalImage()
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fill)
//                                        .frame(width: 40, height: 40)
//                                        .clipShape(Circle())
//                                }else{
//                                    KFImage.url(getMediaURL(url: ""))
//                                        .placeholder({
//                                            Image(uiImage: UIImage(named: "logo_Image")!)
//                                                .resizable()
//                                        })
//                                        .retry(maxCount: 3, interval: .seconds(5))
//                                        .cacheOriginalImage()
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fill)
//                                        .frame(width: 40, height: 40)
//                                        .clipShape(Circle())
//                                }
//                                Text(job.user?.company_data?.company_name ?? "" != "" ? job.user?.company_data?.company_name ?? "" : job.user?.name ?? "")
//                                    .font(.custom(nunitoMedium, fixedSize: 15))
//                                    .foregroundStyle(.black)
//                            }
//                        })
//                    }.padding(.horizontal)
//                    
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Job Detail")
//                            .font(.custom(nunitoBold, fixedSize: 18))
//                        
//                        HStack {
//                            RichText(html: job.description ?? " - ")
//                                .customCSS("""
//            body {
//                font-size: 14px;
//            }
//        """)
//                                .font(.custom(nunitoRegular, fixedSize: 15))
//                                .multilineTextAlignment(.leading)
//                            
//                            Spacer()
//                        }
//                    }
//                    .padding(.vertical, 8)
//                    .padding(.horizontal)
//                    .background(.text.opacity(0.05))
//                    
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Distance")
//                            .font(.custom(nunitoBold, fixedSize: 18))
//                        
//                        HStack {
//                            Text("\(String(format: "%.2f", Double(job.distance ?? "0") ?? 0.0)) Miles")
//                                .font(.custom(nunitoRegular, fixedSize: 15))
//                                .multilineTextAlignment(.leading)
//                            
//                            Spacer()
//                        }
//                    }
//                    .padding(.vertical, 8)
//                    .padding(.horizontal)
//                    .background(.text.opacity(0.05))
//                    
////                    VStack(alignment: .leading, spacing: 8) {
////                        Text("Salary Detail")
////                            .font(.custom(nunitoBold, fixedSize: 18))
////                        
////                        HStack {
////                            Text("Salary Type - ")
////                                .font(.custom(nunitoRegular, fixedSize: 15))
////                                .multilineTextAlignment(.leading)
////                            Text(job.salary_type ?? "")
////                                .font(.custom(nunitoRegular, fixedSize: 15))
////                                .multilineTextAlignment(.leading)
////                        }
////                        
////                        HStack {
////                            Text("Salary - ")
////                                .font(.custom(nunitoRegular, fixedSize: 15))
////                                .multilineTextAlignment(.leading)
////                            Text("\(job.salary?.toCurrency() ?? "")")
////                                .font(.custom(nunitoRegular, fixedSize: 15))
////                                .multilineTextAlignment(.leading)
////                        }
////                    }
////                    .padding(.vertical, 8)
////                    .padding(.horizontal)
//                    
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Requirements")
//                            .font(.custom(nunitoBold, fixedSize: 18))
//                        
//                        HStack {
//                            Text("Field of Education - ")
//                                .font(.custom(nunitoRegular, fixedSize: 15))
//                                .multilineTextAlignment(.leading)
//                            Text(educationField) //job.education?.first?.name ?? "-")
//                                .font(.custom(nunitoRegular, fixedSize: 15))
//                                .multilineTextAlignment(.leading)
//                        }
//                        HStack {
//                            Text("Education Level - ")
//                                .font(.custom(nunitoRegular, fixedSize: 15))
//                                .multilineTextAlignment(.leading)
//                            Text(job.qualification?.name ?? "")
//                                .font(.custom(nunitoRegular, fixedSize: 15))
//                                .multilineTextAlignment(.leading)
//                        }
//                        HStack {
//                            Text("Licensure - ")
//                                .font(.custom(nunitoRegular, fixedSize: 15))
//                                .multilineTextAlignment(.leading)
//                            Text(job.licensure ?? "")
//                                .font(.custom(nunitoRegular, fixedSize: 15))
//                                .multilineTextAlignment(.leading)
//                            Spacer()
//                        }
//                        HStack {
//                            Text("Location Type - ")
//                                .font(.custom(nunitoRegular, fixedSize: 15))
//                                .multilineTextAlignment(.leading)
//                            Text(job.location_type?.type ?? "")
//                                .font(.custom(nunitoRegular, fixedSize: 15))
//                                .multilineTextAlignment(.leading)
//                            Spacer()
//                        }
//                    
//
//
//                        HStack {
//                            Text("Relevant Experience - ")
//                                .font(.custom(nunitoRegular, fixedSize: 15))
//                                .multilineTextAlignment(.leading)
//                            Text("\(job.experience ?? "")")
//                                .font(.custom(nunitoRegular, fixedSize: 15))
//                                .multilineTextAlignment(.leading)
//                        }
//                    }
//                    .padding(.vertical, 8)
//                    .padding(.horizontal)
//                    .background(.text.opacity(0.05))
//                    
//                    VStack(spacing: 20) {
//                        
////                        if !(job.isSaved ?? false) {
////                            PrimaryButton(
////                                title: "Save for later",
////                                isOutLine: true,
////                                onButtonClick: {
////                                    self.onSaveButtonClick?(job.id!)
////                                })
////                        }
//                        
//                        if showTryThis {
//                            HStack {
//                                Spacer()
//                                Text("Not seeing what you are interested in?")
//                                    .font(.custom(nunitoRegular, fixedSize: 12))
//                                    .foregroundStyle(.gray)
//                                Button(action: { withAnimation { navigateToSearch = true } }, label: {
//                                    Text("Try this!")
//                                        .font(.custom(nunitoSemiBold, fixedSize: 12))
//                                        .foregroundStyle(.pinkBtn)
//                                })
//                                Spacer()
//                            }
//                        }
//                    }
//                    .padding(.vertical, 20)
//                    .padding(.horizontal)
//                        //                    .background(.text.opacity(0.05))
//                })
//                
//                CusNavLink(doNavigate: $navigateToCompanyScreen, destination: EmployerProfileScreen(employerId: $selectedCompanyId))
//                CusNavLink(doNavigate: $navigateToSearch, destination: JobCategoriesView())
//            })
//            
//            Spacer()
//            
//            if showSwipeBtn {
//                HStack {
//                    Button(action: {
//                        withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 50, damping: 8, initialVelocity: 0)) {
//                            offset.width = -200
//                            swipeCard(width: offset.width, currentCard: job.title ?? "")
//                            changeColor(width: offset.width)
//                        }
//                    }, label: {
//                        Image(systemName: "xmark.circle.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 25, height: 25)
//                        
//                        Text(isFromHome ? "Swipe Left" : "Reject")
//                            .font(.custom(nunitoBold, fixedSize: 14))
//                    }).tint(.red)
//                    
//                    Spacer()
//
//                    if !(job.isSaved ?? false) {
//                        Button(action: {
//                            onSaveButtonClick?(job.id ?? 0)
//                        }, label: {
//                            
//                            Text("  Save for later ")
//                                .font(.custom(nunitoBold, fixedSize: 16))
//                                .underline()
//                        }).tint(.black)
//                    }
//                    
//                    Spacer()
//                    
//                    Button(action: {
//                        if rightSwipe == 0{
//                            alertType = .sheetType(icon: .alert, title: "Right Swipe Not Found", message: "No more right swipe left, Do you want to purchase 10 right swipe more?", primaryBtnText: "Yes", secondaryBtnText: "No", sheetThemeColor: .pinkBtn)
//                            withAnimation { showSwipeSheet = true }
//                        }else{
//                            withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 50, damping: 8, initialVelocity: 0)) {
//                                offset.width = 200
//                                swipeCard(width: offset.width, currentCard: job.title ?? "")
//                                changeColor(width: offset.width)
//                            }
//                        }
//                    }, label: {
//                        Text(isFromHome ? "Swipe Right" : "Accept")
//                            .font(.custom(nunitoBold, fixedSize: 14))
//                        Image(systemName: "checkmark.circle.fill")
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: 25, height: 25)
//                    }).tint(.green)
//                }
//                .padding(.all)
//                .background(.white)
//            }
//        }
//        .background(color)
//        .offset(x: offset.width * 1, y: offset.height * 0.4)
//        .rotationEffect(.degrees(Double(offset.width / 40)))
//        .onAppear(perform: {
//            showSwipeBtn = ((job.isAccepted ?? false) || (job.isRejected ?? false)) ? false : true
//            if let detail: CombineDataModel = UserDefaultsManager.shared.getModel(forKey: .combineData) {
//                educationField = detail.category.first(where: { "\($0.id)" == (job.qualification_id ?? "1") })?.name ?? " - "
//            }
//        })
//        .gesture(
//            enableSwipe ?
//            DragGesture()
//                .onChanged { gesture in
//                    if abs(gesture.translation.width) > 60 {
//                        withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 50, damping: 8, initialVelocity: 0)) {
//                            offset = gesture.translation
//                            withAnimation {
//                                changeColor(width: offset.width)
//                            }
//                        }
//                    }
//                    
//                }
//                .onEnded { _ in
//                    withAnimation {
//                        swipeCard(width: offset.width, currentCard: job.title ?? "")
//                        changeColor(width: offset.width)
//                    }
//                } : nil
//        )
//        .bottomSheet(isPresented: $showAlert, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: {
//            showAlert = true
//        },  content: {
//            CommonBottomSheet(
//                sheetType: $alertType,
//                onPrimaryClick: {
//                    withAnimation { showAlert = false }
//                    onSaveButtonClick?(job.id ?? 0)
//                }, onSecondaryClick: {
//                    withAnimation { showAlert = false }
//                })
//        })
//        
//        .bottomSheet(isPresented: $showSwipeSheet, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, onDismiss: { showSwipeSheet = true }, content: {
//            CommonBottomSheet(sheetType: $alertType,
//                              onPrimaryClick: {
//                withAnimation { showSwipeSheet = false }
//                withAnimation (.easeInOut){ navigateToSubscription = true }
//            }, onSecondaryClick: {
//                withAnimation { showSwipeSheet = false }
//            })
//        })
//        
//        CusNavLink(doNavigate: $navigateToSubscription, destination: SubscriptionScreen())
//    }
//    
//    func swipeCard(width: CGFloat, currentCard: String) {
//        switch width {
//            case -500...(-150):
//                Log.s("\(currentCard) removed")
//                self.onSwipe?(false, job.id ?? 0)
//                offset = CGSize(width: -500, height: 0)
//            case 150...500:
//                Log.s("\(currentCard) added")
//                self.onSwipe?(true, job.id ?? 0)
//                offset = CGSize(width: 500, height: 0)
//            default:
//                offset = .zero
//        }
//    }
//    
//    func changeColor(width: CGFloat) {
//        switch width {
//            case -500...(-130):
//                color = .red
//            case 130...500:
//                color = .green
//            default:
//                color = .white
//        }
//    }
//}
//
////#Preview {
////    JobPostDetailScreen()
////}
