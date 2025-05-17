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
            ScrollView{
                if !lessons.isEmpty{
                    let lesson = lessons[currentIndex]
                    Text("Step 1 of 7")
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
                }
            }
            .edgesIgnoringSafeArea(.top)
            .background(.bg.opacity(0.5))
            
        }
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
