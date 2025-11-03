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

struct SelectThumbnailScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State private var currentIndex = 0
    @State var tip =  TitleTipsModel()
    @State var isLoading  = false
    var viewModel = ScheduleViewModel()
    @State var title = ""
    @State var navigateToSelectTime  = false
    @State private var showCameraPicker = false
    @State private var showPhotoLibrary = false
    @State private var showPickerOptions = false
    @State private var selectedMedia =  UIImage()
    @Binding var request : StoreScheduleShowRequest
    @State var navigateToProuct = false
    @State var thumbNail = ""
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @Binding var fromPrepare : Bool
    @Binding var backToPrepare : Bool
    var delegate: ShowStepDelegate?
    var body: some View {
        VStack{
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
                
            }
            
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
                            //                            .padding(.all,Leading/2)
                            .background(.white)
                            .cornerRadius(10)
                            
                        }
                        
                        
                        VStack(alignment:.leading){
                            Text("Good Example")
                                .font(.custom(poppinsBold, size: 16.0))
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 16) {
                                    ForEach(example.indices, id: \.self) { index in
                                        let text = example[index]
                                        CustomProfileImage(url: text, isCircular: false, size: 120, defaultImage: "photo")
//                                        AsyncImage(url: URL(string: text)) { phase in
//                                            switch phase {
//                                            case .success(let image):
//                                                image
//                                                    .resizable()
//                                            default:
//                                                Image(systemName: "photo")
//                                                    .resizable()
//                                            }
//                                        }
//                                        .frame(width: 120, height: 120)
//                                        .cornerRadius(10)
                                    }
                                }
                            }
                        }
                    }
                    
                }
            }
            .padding(.top,10)
            .padding(.horizontal,Leading)
            //            .background(.green)
            PrimaryButton(title: "Continue",isOutLine: false,onButtonClick: {
                print("request \(request)")
                guard !request.title.isEmpty else {
                    hudMsg = "Please enter title"
                        showhud = true
                        return
                }
                guard !request.category_id.isEmpty else {
                    hudMsg = "Please enter category type"
                        showhud = true
                        return
                }
                guard !request.auction_type_id.isEmpty else {
                    hudMsg = "Please enter auction type"
                        showhud = true
                        return
                }
                guard !thumbNail.isEmpty else {
                    hudMsg = "Please select thumbnail image"
                        showhud = true
                        return
                }
                if fromPrepare{
//                    delegate?.didUpdateRequest(request)
//                    presentationMode.wrappedValue.dismiss()
                    navigateToProuct = true
                }else{
                    navigateToSelectTime = true
                }
                
            },cornerRadius: 12, btnTextColor: .white)
            .padding(.top , 10)
            
            CusNavLink(doNavigate: $navigateToSelectTime, destination: SelectShowScreen(request:$request,thumbNail: $thumbNail, comeFromPrepareScreen: .constant(false),backToPrepare: $backToPrepare))
            
//            CusNavLink(doNavigate: $navigateToProuct, destination: AddProductsScreen(request:$request,thumbNail: $thumbNail,fromPrepare: $fromPrepare,backToPrepare: $backToPrepare,delegate: delegate))
            
            CusNavLink(doNavigate: $navigateToProuct, destination: CreateProductScreen(requests: $request, thumbNail: $thumbNail,backToPrepare: $backToPrepare,fromPrepare: $fromPrepare,delegate: delegate))
        }
        .edgesIgnoringSafeArea(.bottom)
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
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
        .fullScreenCover(isPresented: $showCameraPicker) {
            ImagePicker(sourceType: .camera) { image,url in
                if let image = image{
                    selectedMedia = image
                    thumbNail.removeAll()
                    thumbNail = url ?? ""
                }
            }
            .ignoresSafeArea()
        }
        .fullScreenCover(isPresented:  $showPhotoLibrary) {
            ImagePicker(sourceType: .photoLibrary){ image,url in
                if let image = image{
                    selectedMedia = image
                    thumbNail.removeAll()
                    thumbNail = url ?? ""
                }
            }
            .ignoresSafeArea()
        }
        .onAppear {
            
            Task{
               guard Reachability.isConnectedToNetwork() else {
                    hudMsg = "No Internet Connection"
                    showhud = true
                    return
                }
                SVProgressHUD.show()
                await viewModel.getTitleTips(param: TipParam(type: "thumbnail"))
                await SVProgressHUD.dismiss()
                success()
            }
        }
    }
    
    
    func success() {
        SVProgressHUD.dismiss()
        let dict = viewModel.tipsResponse
        if dict?.status == "success" {
            tip = dict?.data ?? TitleTipsModel()
        } else {
            print("API error: \(dict?.status ?? "")")
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
