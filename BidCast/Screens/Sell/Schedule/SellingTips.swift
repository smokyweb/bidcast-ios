//
//  GetStartedScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 17/05/25.
//

import SwiftUI
import RichText

struct SellingTips: View {
    
    var viewModel = ScheduleViewModel()
    @State var lessons =  [LessonModel]()
    
    @State var currentIndex = 0
    @State var isLoading: Bool = false
    
    @State var navigateToPrepare = false
    @State  var showNextButton = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing:18){
            VStack{
                PrimaryHeader(
                    title: "How to Sell".localized,
                    isForLogo : false, leadingImgArr: [.sideArrow],
                    trailingImgArr: [],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
                .background(.white)
            }.frame(height: 40)
            ScrollView(showsIndicators:false){
                if !lessons.isEmpty{
                    let lesson = lessons[currentIndex]
                    Text("Step \(currentIndex + 1) of \(lessons.count)")
                        .foregroundColor(.red)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top,8)
                    Text(lesson.title ?? "")
                        .font(.title2)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    if let imageUrl = URL(string: lesson.image ?? "") {
                        AsyncImage(url: imageUrl) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(12)
                        } placeholder: {
                            ProgressView()
                        }
                        .padding(.horizontal)
                    }
                    RichText(html:lesson.description ?? "")
                        .foregroundColor(.white)
                        .padding()
                    HStack{
                        
                        Button("Back") {
                            if currentIndex > 0 { currentIndex -= 1 }
                        }
                        .disabled(currentIndex == 0)
                        .buttonStyle(.bordered)
                        .frame(width: 100.0)
                      
                        
                       Spacer()
                        
                        Button("Next") {
                            if currentIndex < lessons.count - 1 { currentIndex += 1 }
                        }
                        .disabled(currentIndex == lessons.count - 1)
                        .buttonStyle(.borderedProminent)
                        .frame(width: 100.0)
                        .tint(.red)
                        
                    }
                    .padding(.horizontal,16)
                    if currentIndex == lessons.count - 1{
                        PrimaryButton(title: "Continue",isOutLine: false,onButtonClick: {
                            navigateToPrepare = true
                        },cornerRadius: 12, btnTextColor: .white)
//                            .disabled(currentIndex < lessons.count - 1)
                    }
                    
                }
            }
            
            .background(.bg.opacity(0.5))
            if isLoading {
                Loader(isLoading: $isLoading)
            }
        }
        
        CusNavLink(doNavigate: $navigateToPrepare, destination: LetsPrepare())
            .edgesIgnoringSafeArea(.bottom)
        .toolbar(.hidden,for: .tabBar)
        .onAppear {
            observe()
            
            viewModel.getSellingTips()
        }
    }
    
    func observe() {
        self.viewModel.eventHandler = { event in
            switch event {
            case .loading:
                self.isLoading = true
            case .stopLoading:
                self.isLoading = false
            case .dataLoaded:
                success()
            case .error(let error):
                print("Error: \(error?.localizedDescription ?? "Unknown")")
            }
        }
    }
    
    func success() {
        if let dict = viewModel.getLessonDict {
            if dict.status == "success" {
                lessons = dict.data
            } else {
                print("API error: \(dict.status ?? "")")
            }
        }
    }
    
}

#Preview {
    SellingTips()
}
