//
//  GetStartedScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 17/05/25.
//

import SwiftUI
import RichText
import SwiftfulLoadingIndicators

struct SelectThumbnailScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State private var currentIndex = 0
    @State var tip =  TitleTipsModel()
    @State var isLoading  = false
    var viewModel = ScheduleViewModel()
    @State var title = ""
    @State var navigateToSelectCategory  = false
    @State private var showCameraPicker = false
    @State private var showPhotoLibrary = false
    @State private var showPickerOptions = false
    @State private var selectedMedia =  UIImage()
    
    var body: some View {
        VStack(spacing:18){
            VStack{
                PrimaryHeader(
                    title: "Select Thumbnail".localized,
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
                    UploadThumbnailView(onTap: {
                        print("thumbnail upload")
                        showPickerOptions = true
                    }, image: selectedMedia)
                    
                    Text("Tips for a Great Thumbnail")
                        .font(.custom(poppinsBold, size: 16.0))
                    VStack(alignment:.leading,spacing: 24){
                        let tipsData = tip.tips ?? [TipsData]()
                        let example = tip.example ?? [String]()
                       
                        ForEach(tipsData.indices, id: \.self) { tip in
                            let tips = tipsData[tip]
                            VStack(spacing:12){
                            TipsCardView(image:tips.icon ?? "" , title: tips.title ?? "", description: tips.description ?? "")
                            }
                            .padding(.all,Leading/2)
                            .background(.white)
                            .cornerRadius(10)
                            
                        }
                        
                       
                        VStack(alignment:.leading){
                            Text("Good Example")
                                .font(.custom(poppinsBold, size: 16.0))
                            HStack(spacing:20){
                                ForEach(example.indices, id: \.self) { index in
                                    let text = example[index]
                                    AsyncImage(url: URL(string: text)) { phase in
                                        switch phase {
                                        case .success(let image):
                                            image.resizable()
                                        default:
                                            Image(systemName: "photo")
                                                .resizable()
                                        }
                                    }
                                    .frame(width: screenWidth/2 - 30, height: 140)
                                    .cornerRadius(10)
                                }
                            }
                        }
                        
                        .padding(.all,Leading/2)
                        
                    }
                    
                }
                //                .padding(.horizontal,Leading)
                //                .background(.red.opacity(0.4))
                
                
            }
            .padding(.top,10)
            .padding(.horizontal,Leading)
            //            .background(.green)
            PrimaryButton(title: "Continue to next step",isOutLine: false,onButtonClick: {
                
             
            },cornerRadius: 12, btnTextColor: .white)
            
//            CusNavLink(doNavigate: $navigateToSelectCategory, destination: SelectCategoryScreen(title: $title))
            if isLoading{
                LoadingIndicator()
            }
        }
        .edgesIgnoringSafeArea([.top,.bottom])
        .background(.bg.opacity(0.5))
        .toolbar(.hidden,for: .tabBar)
        .confirmationDialog("Select Media Source", isPresented: $showPickerOptions) {
            Button("Camera") {
                showCameraPicker = true
            }
            Button("Photo Library") {
                showPhotoLibrary = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showCameraPicker) {
            ImagePicker(sourceType: .camera) { image,url in
                if let image = image{
                    selectedMedia = image
                }
            }
        }
        .sheet(isPresented: $showPhotoLibrary) {
            ImagePicker(sourceType: .photoLibrary){ image,url in
                if let image = image{
                    selectedMedia = image
                }
            }
        }
        .onAppear {
            observe()
            
            viewModel.getTitleTips(param: TipParam(type: "thumbnail"))
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
   
}



struct UploadThumbnailView: View {
    var onTap: () -> Void
    var image = UIImage()
    var body: some View {
        Button(action: {
            onTap()
        }) {
            VStack(spacing: 8) {
                if image != UIImage(){
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                }else{
                    Image(systemName: "photo.on.rectangle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                    
                    Text("Tap to upload thumbnail")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("Recommended size: 1280 x 720px")
                        .font(.system(size: 14))
                        .foregroundColor(.gray.opacity(0.6))
                }
            }
            .frame(maxWidth: .infinity, minHeight: 180)
            .padding()
            .background(Color.gray.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2))
                    .foregroundColor(.gray)
            )
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
