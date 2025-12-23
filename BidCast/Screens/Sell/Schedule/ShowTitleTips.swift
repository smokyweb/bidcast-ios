//
//  GetStartedScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 17/05/25.
//

import SwiftUI
import RichText
import SwiftfulLoadingIndicators
import SVProgressHUD
import AlertToast

struct ShowTitleTips: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var request : StoreScheduleShowRequest
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var currentIndex = 0
    @State var tip =  TitleTipsModel()
    @State var isLoading  = false
    var viewModel = ScheduleViewModel()
    @State var title = ""
    @State var navigateToSelectCategory  = false
    @Binding var fromPrepare : Bool
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @Binding var backToPrepare : Bool
    @Binding var showId : Int
    
    @State private var titleCharCount: Int = 0
    
    
    private let maxTitleCharCount: Int = 100
    
    var delegate: ShowStepDelegate?
    
    var body: some View {
        VStack(spacing:18){
           
            VStack{
                PrimaryHeader(
                    title: "Show Title".localized,
                    isForLogo : false, leadingImgArr: ["chevron.left"],
                    trailingImgArr: [],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
                
            }
            
            ScrollView(showsIndicators: false) {
                VStack(alignment:.leading,spacing: 16) {
                    AuthTextField(floatingLabel: "Show Title".localized, placeholder: "Enter title".localized, icon: .alert, text:$title  ,isIconDisplay : false, enteredText:  { text in
                        // Limit input to 100 characters
                        if text.count <= maxTitleCharCount {
                            title = text
                        } else {
                            // Trim extra characters
                            title = String(text.prefix(maxTitleCharCount))
                        }
                        titleCharCount = title.count
                    })
                    .keyboardType(.alphabet)
                    .padding([.leading,.trailing],-16)
                    HStack{
                        Spacer()
                        Text("\(titleCharCount)/\(maxTitleCharCount)")
                            .font(.custom(poppinsBold, fixedSize: 14))
                            .fontWeight(.regular)
                            .foregroundStyle(.gray)
                    }
                    .padding(.trailing, 16)
                    .padding(.top, -10)
                   
                    Text("Tips for a Great Title")
                        .font(.custom(poppinsBold, size: 16.0))
                    VStack(alignment:.leading,spacing: 24){
                        let tipsData = tip.tips ?? [TipsData]()
                        let example = tip.example ?? [String]()
                        VStack{
                            ForEach(tipsData.indices, id: \.self) { tip in
                                let tips = tipsData[tip]
                                TipsCardView(image:tips.icon ?? "" ,title: tips.title ?? "", description: tips.description ?? "")
                            }
                            
                        }
                        .padding(.all,Leading/2)
                        .background(.lightBlue)
                        .cornerRadius(10)
                        
                        Text("Good Example")
                            .font(.custom(poppinsBold, size: 16.0))
                        
                        VStack(alignment:.leading){
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
                                    .padding(.all,Leading/2)
                                    .background(.white)
                                    .cornerRadius(10)
                            }
                        }
                        
                        .padding(.top,Leading/2)
                        .background(.clear)
                    }
                    
                }
                //                .padding(.horizontal,Leading)
                //                .background(.red.opacity(0.4))
                
                
            }
            .padding(.top,10)
            .padding(.horizontal,Leading)
            //            .background(.green)
            PrimaryButton(title: "Continue",isOutLine: false,onButtonClick: {
                request.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !request.title.isEmpty else {
                    hudMsg = "Please enter title"
                        showhud = true
                        return
                }
                print(request)
                
                navigateToSelectCategory = true
            },cornerRadius: 12, btnTextColor: .white)
            
            CusNavLink(doNavigate: $navigateToSelectCategory, destination: SelectCategoryScreen(request:$request,title: $title,fromPrepare: $fromPrepare,backToPrepare: $backToPrepare, delegate: delegate))
           
        }
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
        .edgesIgnoringSafeArea(.bottom)
        .background(.bg.opacity(0.5))
        .toolbar(.hidden,for: .tabBar)
        .onAppear {
            getTilteTips()
            
        }
        
    }
    
    func getTilteTips() {
        Task {
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            
            SVProgressHUD.show()
            await viewModel.getTitleTips(param: TipParam(type: "title"))
            await SVProgressHUD.dismiss()
            success()
            if showId != 0{
                getShowsData()
            }
        }
    }
    func getShowsData() {
        Task {
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"
                showhud = true
                return
            }
            
            SVProgressHUD.show()
            let request = getShowRequest(show_id: showId)
            await viewModel.getScheduleShowData(param: request)
            await SVProgressHUD.dismiss()
            if self.viewModel.errorMessage == nil || viewModel.errorMessage == ""{
                scheduleShowSuccess()
            }else{
                showhud = true
                hudMsg = "Somwthing went wrong"
            }
        }
    }
    func scheduleShowSuccess(){
        let dict = viewModel.scheduledShow
        if dict?.status == "success" {
            
//            tip = dict?.data ?? TitleTipsModel()
            let showData = dict?.data ?? HomeModel()
            request = StoreScheduleShowRequest(title: showData.title ?? "",
                                               date: showData.date ?? "",
                                               time: showData.time ?? "",
                                               category_id: "\(showData.category_id ?? 0)",
                                               auction_type_id: "\(showData.auction_type_id ?? 0)",
                                               product_ids: showData.product_ids?.first ?? "",
                                               isExplicitContent: showData.is_explicit ?? false,
                                               discoverablitity: showData.show_discoverability ?? "",
                                               primaryLanguage: showData.language ?? "",
                                               repeats: showData.repeat_value ?? "")
            title = showData.title ?? ""
//            request.title = title
//            request.date = showData.date ?? ""
//            request.time = showData.time ?? ""
//            request.category_id = "\(showData.category_id ?? 0)"
//            request.auction_type_id = "\(showData.auction_type_id ?? 0)"
//            request.isExplicitContent = showData.is_explicit ?? false
//            request.repeats = showData.repeat_value ?? ""
//            request.discoverablitity = showData.show_discoverability ?? ""
            print(request)
            
        } else {
            print("API error: \(dict?.status ?? "")")
        }
    }
    
    func success() {
        let dict = viewModel.tipsResponse
        if dict?.status == "success" {
            tip = dict?.data ?? TitleTipsModel()
        } else {
            print("API error: \(dict?.status ?? "")")
        }
    }
}
//
//#Preview {
//    LetsPrepare()
//}
//
//
//
