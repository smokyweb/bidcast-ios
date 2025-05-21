//
//  GetStartedScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 17/05/25.
//

import SwiftUI
import RichText
import SwiftfulLoadingIndicators

struct ShowTitleTips: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var currentIndex = 0
    @State var tip =  TitleTipsModel()
    @State var isLoading  = false
    var viewModel = ScheduleViewModel()
    @State var title = ""
    @State var navigateToSelectCategory  = false
    
    
    
    var body: some View {
        VStack(spacing:18){
           
            VStack{
                PrimaryHeader(
                    title: "Show Title".localized,
                    isForLogo : false, leadingImgArr: [.sideArrow],
                    trailingImgArr: [],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
                .background(.white)
            }.frame(height: 80)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment:.leading,spacing: 16) {
                    AuthTextField(floatingLabel: "Show Title".localized, placeholder: "Enter title".localized, icon: .alert, text:$title  ,isIconDisplay : false) { text in
                        title = text
                    }
                    .keyboardType(.alphabet)
                    .padding([.leading,.trailing],-16)
                    Text("Tips for a Great Title")
                        .font(.custom(poppinsBold, size: 16.0))
                    VStack(alignment:.leading,spacing: 24){
                        let tipsData = tip.tips ?? [TipsData]()
                        let example = tip.example ?? [String]()
                        VStack{
                            ForEach(tipsData.indices, id: \.self) { tip in
                                let tips = tipsData[tip]
                                TipsCardView(image:tips.icon ?? "" , title: tips.title ?? "", description: tips.description ?? "")
                            }
                            
                        }
                        .padding(.all,Leading/2)
                        .background(.lightBlue)
                        .cornerRadius(10)
                        
                        VStack(alignment:.leading){
                            Text("Good Example")
                                .font(.custom(poppinsBold, size: 16.0))
                            ForEach(example.indices, id: \.self) { index in
                                let text = example[index]
                                RichText(html:text)
                                    .customCSS("""
                                    body {
                                        font-size: 14px;
                                        line-height: 1.4;
                                        margin: 0;
                                        padding: 0;
                                    }
                                    p {
                                        margin: 0 0 6px 0; 
                                    }
                                    ul {
                                        margin: 0;
                                        padding-left: 16px;
                                    }
                                    li {
                                        margin-bottom: 4px;
                                        list-style-type: disc;
                                    }
                                """)
                            }
                        }
                        
                        .padding(.all,Leading/2)
                        
                        .background(.white)
                        .cornerRadius(10)
                    }
                    
                }
                //                .padding(.horizontal,Leading)
                //                .background(.red.opacity(0.4))
                
                
            }
            .padding(.top,10)
            .padding(.horizontal,Leading)
            //            .background(.green)
            PrimaryButton(title: "Continue to next step",isOutLine: false,onButtonClick: {
                
                navigateToSelectCategory = true
            },cornerRadius: 12, btnTextColor: .white)
            
            CusNavLink(doNavigate: $navigateToSelectCategory, destination: SelectCategoryScreen(title: $title))
            if isLoading{
                LoadingIndicator()
            }
        }
    
        .edgesIgnoringSafeArea([.top,.bottom])
        .background(.bg.opacity(0.5))
        .toolbar(.hidden,for: .tabBar)
        .onAppear {
            observe()
            
            viewModel.getTitleTips(param: TipParam(type: "title"))
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
        if let dict = viewModel.getTipsDict {
            if dict.status == "success" {
                tip = dict.data.first ?? TitleTipsModel()
            } else {
                print("API error: \(dict.status ?? "")")
            }
        }
    }
    //    private func goToNextStep() {
    //        if currentIndex < prepare.count - 1 {
    //            currentIndex += 1
    //        }else{
    //            navigateToTips = true
    //        }
    //    }
}

#Preview {
    LetsPrepare()
}



