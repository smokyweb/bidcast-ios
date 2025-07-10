//
//  GetStartedScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 17/05/25.
//

import SwiftUI
import RichText
import SVProgressHUD

struct LetsPrepare: View,ShowStepDelegate {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var currentIndex = 0
    @State var prepare =  [LessonModel]()
    @State var isLoading  = false
    var viewModel = ScheduleViewModel()
    @State var request : StoreScheduleShowRequest = StoreScheduleShowRequest(title: "", date: "", time: "", category_id: "", auction_type_id: "", product_ids: "")
    @State var navigateToTips  = false
    @State var navigateToCreateScreen = false
    @State var navigateToCreateShow = false
    @State var thumbNAil = ""
    @State var navigateToSelectShow = false
    @State var didLoadPrepare = false
    @State var navigateToshowTitle = false
    
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
                
            }
            
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
                                navigateToSelectShow = true
//                                navigateToCreateShow = true
                            }else if idx == 1 {
                                
                                navigateToshowTitle = true
//                                navigateToCreateScreen = true
                            }
                            //                            goToNextStep()
                        }
                        .onTapGesture {
                          if !prepare[idx].isLocked {
                            currentIndex = idx
                          }
                        }
                    }
                    
                    
                }
                .padding(.all,18)
                //                .background(.yellow)
            }
            .padding(.horizontal,16)
            
            HStack(alignment: .center,spacing:6) {
                Spacer()
                Image(systemName: "questionmark.circle")
                Text("Need help? Contact our support team")
                    .font(.custom(poppinsRegular, size: 11.0))
                Spacer()
            }
            
            .frame(height: 40)
            .foregroundColor(.gray)
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal,16)
            
            
            
            CusNavLink(doNavigate: $navigateToSelectShow, destination: SelectShowScreen(request: $request, thumbNail: $thumbNAil, comeFromPrepareScreen: .constant(true),delegate: self))
            
            CusNavLink(doNavigate: $navigateToshowTitle, destination: ShowTitleTips(request : $request,fromPrepare:.constant(true),backToPrepare: $navigateToshowTitle, delegate: self))
            
            
            
            CusNavLink(doNavigate: $navigateToTips, destination: ShowTips())
//            CusNavLink(doNavigate: $navigateToCreateShow, destination: ShowTitleTips(fromPrepare:.constant(true),backToPrepare: .constant(false), delegate: self))
            
            
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(.bg.opacity(0.5))
        .toolbar(.hidden,for: .tabBar)
        .onAppear {
            if !didLoadPrepare {
                didLoadPrepare = true
                Task{
                    SVProgressHUD.show()
                    await viewModel.getLetsPrepare()
                    await SVProgressHUD.dismiss()
                    success()
                }
            }
        }
        .refreshable {
            didLoadPrepare = false
        }
       
    }
    func didUpdateRequest(_ request: StoreScheduleShowRequest) {
        didLoadPrepare = true
            self.request = request
            print("✅ Parent got updated request:", request)
        if prepare.indices.contains(currentIndex) {
              prepare[currentIndex].isDone = true
          }

          // ✅ Unlock next step:
          let nextIndex = currentIndex + 1
          if prepare.indices.contains(nextIndex) {
              prepare[nextIndex].status = "unlocked"
          }

          currentIndex = nextIndex
          print("🔓 Next unlocked: ", prepare)
        }
    
    func success() {
        let dict = viewModel.lessonsResponse
        if dict?.status == "success" {
            var steps = dict?.data ?? []
                 
                    if steps.indices.contains(0) {
                        steps[0].status = "unlocked"
                    }

                    for idx in 1..<steps.count {
                        steps[idx].status = "locked"
                    }

                    prepare = steps
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
    
    private func unlockNextStep() {
        let nextIndex = currentIndex + 1
        if prepare.indices.contains(nextIndex) {
            prepare[currentIndex].isDone = true
            prepare[nextIndex].status = "unlocked"
            currentIndex = nextIndex
        }
    }
}

#Preview {
    LetsPrepare()
}




protocol ShowStepDelegate {
    func didUpdateRequest(_ request: StoreScheduleShowRequest)
}
