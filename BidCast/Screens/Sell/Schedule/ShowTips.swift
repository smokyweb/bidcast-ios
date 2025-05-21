//
//  GetStartedScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 17/05/25.
//

import SwiftUI
import RichText

struct ShowTips: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var currentIndex = 0
    @State var tips =  [LessonModel]()
    @State var isLoading  = false
    var viewModel = ScheduleViewModel()
    @State var navigateToSelectCategory = false
    @State var navigateToShowTitle = false
    
    private var currentProgress: Double {
        guard !tips.isEmpty else { return 0 }
        return Double(currentIndex) / Double(tips.count - 1)
    }
    
    var body: some View {
        VStack(spacing:12){
            VStack{
                PrimaryHeader(
                    title: "Show Tips".localized,
                    isForLogo : false, leadingImgArr: [.sideArrow],
                    trailingImgArr: [],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
                .background(.white)
            }.frame(height: 30)
//            ProgressView(value: currentProgress, total: 1)
//                .progressViewStyle(LinearProgressViewStyle())
//                .tint(.blue)
//                .padding(.horizontal)
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(tips.indices, id: \.self) { idx in
                        TipCard(tip: tips[idx], isCurrent: idx == currentIndex)
                            .onTapGesture { currentIndex = idx }
                    }
                    
                }
                .padding(.top,18)
                .padding(.horizontal)
                .padding(.bottom, 20)
                
            }
            .background(.bg.opacity(0.5))
            .padding(.top,18)
            .padding(.bottom,-18)
            PrimaryButton(title: "Continue to next step",isOutLine: false,onButtonClick: {
//              navigateToSelectCategory = true
                navigateToShowTitle = true
            },cornerRadius: 12, btnTextColor: .white)
//            CusNavLink(doNavigate: $navigateToSelectCategory, destination: SelectCategoryScreen())
            CusNavLink(doNavigate: $navigateToShowTitle, destination: ShowTitleTips())
        }
        .edgesIgnoringSafeArea(.bottom)
        .toolbar(.hidden,for: .tabBar)
        .onAppear {
            observe()
            
            viewModel.getShowTips()
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
                tips = dict.data
            } else {
                print("API error: \(dict.status ?? "")")
            }
        }
    }
}

#Preview {
    HowToSell()
}


struct TipCard: View {
    let tip: LessonModel
    var isCurrent: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 12) {
                if let imageUrl = URL(string: tip.image ?? "") {
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.white)
                            .frame(width: 32, height: 32)
                    } placeholder: {
                        ProgressView()
                    }
                    .padding(.horizontal)
                }
                Text(tip.title ?? "")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            RichText(html:tip.description ?? "")
        }
        .cornerRadius(12)
        .padding()
//        .background(.white)
//        .background(
//            RoundedRectangle(cornerRadius: 12)
//                .stroke(isCurrent ? Color.clear : Color.clear, lineWidth: 2)
//                .background(.white)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white)
                )
//        )
    }
    
}
