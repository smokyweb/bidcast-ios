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
//    @Binding var backToPrepare : Bool
    
    @State private var isLoadingThumbnail = false
       @State private var thumbnailURL: String = ""
    
    
    @EnvironmentObject var coordinator: LetsPrepareCoordinator
    var body: some View {
        VStack{
            VStack{
                PrimaryHeader(
                    title: "Select Thumbnail".localized,
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
                    UploadThumbnailView(onTap: {
                        print("thumbnail upload")
                        showPickerOptions = true
                    }, image: selectedMedia, thumbnailURL: thumbnailURL, isLoadingThumbnail: isLoadingThumbnail  )
                    
                    
                    VStack(alignment:.leading,spacing: 24){
                        let tipsData = tip.tips ?? [TipsData]()
                        let example = tip.example ?? [String]()
                        Text("Tips for a Great Thumbnail")
                            .font(.custom(poppinsBold, size: 16.0))
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
                
            },cornerRadius: 32, btnTextColor: .white)
            .padding(.top , 10)
            
            CusNavLink(doNavigate: $navigateToSelectTime, destination: SelectShowScreen(request:$request,thumbNail: $thumbNail, comeFromPrepareScreen: .constant(false)))
            
//            CusNavLink(doNavigate: $navigateToProuct, destination: AddProductsScreen(request:$request,thumbNail: $thumbNail,fromPrepare: $fromPrepare,backToPrepare: $backToPrepare,delegate: delegate))
            
            CusNavLink(
                doNavigate: $navigateToProuct,
                destination: AddProductsScreen(
                    request: $request,
                    thumbNail: $thumbNail,
                    fromPrepare: $fromPrepare,
                    NavFromProductLibrary: .constant(false),
                    backToCreateProduct: $navigateToProuct,
                    didTapBack: { _,_,_ in },
                    didTapEdit: { _,_ in }
                )
            )
        }
        .edgesIgnoringSafeArea(.bottom)
        .background(.backGround)
        .toolbar(.hidden,for: .tabBar)
        .onChange(of: coordinator.shouldNavigateBackToPrepare) { shouldNavigate in
            guard shouldNavigate, fromPrepare else { return }
            navigateToProuct = false
            navigateToSelectTime = false
        }
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
            loadExistingThumbnail()
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
    
    func loadExistingThumbnail() {
            // Check if thumbNail binding already has a value (local file path)
            if !thumbNail.isEmpty {
                // If it's a local file path, load it as UIImage
                if let image = UIImage(contentsOfFile: thumbNail) {
                    selectedMedia = image
                    print("✅ Loaded thumbnail from local path: \(thumbNail)")
                }
            }
            // If no local thumbnail, check if request has a thumbnail URL
            else if let thumbnailUrlString = getThumbnailFromRequest(), !thumbnailUrlString.isEmpty {
                thumbnailURL = thumbnailUrlString
                thumbNail = thumbnailUrlString // Set thumbNail to the URL
                isLoadingThumbnail = true
                print("✅ Loading thumbnail from URL: \(thumbnailUrlString)")
                
                // Download the image
                Task {
                    await downloadThumbnail(from: thumbnailUrlString)
                }
            }
        }
    func getThumbnailFromRequest() -> String? {
           // If your StoreScheduleShowRequest has a thumbnail property, use it
           // For example: return request.thumbnail
           // For now, returning nil - you'll need to add this property to your request model
        if request.thumbnail != ""{
            return request.thumbnail ?? ""
        }
        
           return nil
       }
    func downloadThumbnail(from urlString: String) async {
           guard let url = URL(string: urlString) else {
               isLoadingThumbnail = false
               return
           }
           
           do {
               let (data, _) = try await URLSession.shared.data(from: url)
               if let image = UIImage(data: data) {
                   await MainActor.run {
                       selectedMedia = image
                       isLoadingThumbnail = false
                       print("✅ Successfully downloaded thumbnail image")
                   }
               }
           } catch {
               await MainActor.run {
                   isLoadingThumbnail = false
                   print("❌ Failed to download thumbnail: \(error.localizedDescription)")
               }
           }
       }
}



struct UploadThumbnailView: View {
    var onTap: () -> Void
    var image = UIImage()
    var thumbnailURL: String = ""
       var isLoadingThumbnail: Bool = false
    var body: some View {
        Button(action: {
            onTap()
        }) {
            VStack(spacing: 8) {
                if image != UIImage(){
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                } else if isLoadingThumbnail {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(width: 40, height: 40)
                    
                    Text("Loading thumbnail...")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                // ⭐ Priority 3: Show thumbnail from URL
                else if !thumbnailURL.isEmpty {
                    AsyncImage(url: URL(string: thumbnailURL)) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .cornerRadius(8)
                        case .failure(_):
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.orange)
                                
                                Text("Failed to load thumbnail")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                
                                Text("Tap to upload new")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray.opacity(0.6))
                            }
                        case .empty:
                            ProgressView()
                                .scaleEffect(1.5)
                        @unknown default:
                            EmptyView()
                        }
                    }
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
