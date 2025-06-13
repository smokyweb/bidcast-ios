//
//  GetStartedScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 17/05/25.
//

import SwiftUI
import RichText
import SVProgressHUD

struct LetsPrepare: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var currentIndex = 0
    @State var prepare =  [LessonModel]()
    @State var isLoading  = false
    var viewModel = ScheduleViewModel()
    
    @State var navigateToTips  = false
    @State var navigateToCreateScreen = false
    @State var navigateToCreateShow = false
    
    private var currentProgress: Double {
        guard !prepare.isEmpty else { return 0 }
        return Double(currentIndex) / Double(prepare.count - 1)
    }
    
    var body: some View {
        VStack(spacing:18){
            VStack{
                PrimaryHeader(
                    title: "Lets Prepare Your show".localized,
                    isForLogo : false, leadingImgArr: [.sideArrow],
                    trailingImgArr: [],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
                .background(.white)
            }.frame(height: 40)
            
            ProgressView(value: currentProgress, total: 1)
                .progressViewStyle(LinearProgressViewStyle())
                .tint(.blue)
                .padding(.horizontal)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment:.leading,spacing: 16) {
                    ForEach(prepare.indices, id: \.self) { idx in
                        StepCard(
                            prepare: prepare[idx],
                            index: idx + 1,
                            isCurrent: idx == currentIndex
                        ) {
                            if idx == 0 {
                                navigateToCreateShow = true
                            }else if idx == 1 {
                                navigateToCreateScreen = true
                            }
//                            goToNextStep()
                        }
                        .onTapGesture {
                            if !prepare[idx].isLocked { currentIndex = idx }
                        }
                    }
                    
                    HStack(alignment: .center,spacing:6) {
                        Spacer()
                        Image(systemName: "questionmark.circle")
                        Text("Need help? Contact our support team")
                        Spacer()
                    }
                    
                    .font(.footnote)
                    .frame(height: 40)
                    .foregroundColor(.gray)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal,18)
                }
                .padding(.all,18)
//                .background(.yellow)
            }
            .padding(.horizontal,18)
//            .background(.green)
            CusNavLink(doNavigate: $navigateToTips, destination: ShowTips())
            CusNavLink(doNavigate: $navigateToCreateShow, destination: ShowTitleTips())
//            CusNavLink(doNavigate: $navigateToCreateScreen, destination: CreateProductScreen())
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(.bg.opacity(0.5))
        .toolbar(.hidden,for: .tabBar)
        .onAppear {
            Task{
                SVProgressHUD.show()
               await viewModel.getLetsPrepare()
                await SVProgressHUD.dismiss()
                success()
            }
        }
        .onReceive(viewModel.$lessonsResponse){ response in
           
        }
    }
  
    
    func success() {
        let dict = viewModel.lessonsResponse
        if dict?.status == "success" {
            prepare = dict?.data ?? [LessonModel]()
            } else {
                print("API error: \(dict?.status ?? "")")
            }
        
    }
    
    private func goToNextStep() {
        if currentIndex < prepare.count - 1 {
            currentIndex += 1
        }else{
            navigateToTips = true
        }
    }
}

#Preview {
    LetsPrepare()
}


