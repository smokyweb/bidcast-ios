//
//  UserImageSelectionScreen.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 31/01/24.
//

import SwiftUI
import Kingfisher
import BottomSheet
import AlertToast

struct UserImageSelectionScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var selectedImagesURL: [Imagee] = []
    
    @State var showActionSheet: Bool = false
    @State var showImagePicker: Bool = false
    @State var imageSelectorSource: UIImagePickerController.SourceType = .photoLibrary
    @State var isLoading: Bool = false
    @State var showAlert: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    
    var viewModal = UpdateUserProfileViewModal()
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                PrimaryHeader(
                    title: "Images",
                    trailingImgArr: [.cancel],
                    onClickTrailing: {
                        _ in
                        self.presentationMode.wrappedValue.dismiss()
                    }, count: .constant(0))
                
                VStack(spacing: 16) {
                    TitleWithLine(title: "Images")
                    
                    Button(action: { withAnimation { showActionSheet = true } }, label: {
                        HStack {
                            Spacer()
                            VStack(spacing: 12) {
                                Image(systemName: "camera.fill")
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.gray)
                                
                                Text("Add Photo")
                                    .font(.custom(nunitoRegular, fixedSize: 14))
                                    .foregroundStyle(.gray)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 25)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                            //    .fill(.backGround)
                                .shadow(color: .gray, radius: 1, x: 0, y: 0))
                    })
                    
                    ScrollView(showsIndicators: false, content: {
                        ForEach(selectedImagesURL.indices, id: \.self) {
                            ind in
                            ImageContainerWithName(
                                imageName: $selectedImagesURL[ind],
                                onTrashClick: {
                                    val in
                                    withAnimation(.easeIn) {
                                        selectedImagesURL.removeAll(where: { $0.image == val.image })
                                    }
                                })
                        }
                    })
                    
                    Spacer()
                    
                    PrimaryButton(title: "Save", isOutLine: false, onButtonClick: {
                        print("Selected Images >> \(selectedImagesURL)")
                        if selectedImagesURL.count > 0 {
                            self.viewModal.uploadImages(parameter: selectedImagesURL.map({ return $0.image }))
                        } else {
                            hudMsg = "Please select image to add to your profile"
                            showhud = true
                        }
                    })
                    
                    PrimaryButton(title: "Cancel", onButtonClick: {
                        self.presentationMode.wrappedValue.dismiss()
                    })
                    
                }
                .padding(.all)
                .padding(.top, -topPadding)
                
                Spacer()
            }.sheet(isPresented: $showImagePicker, content: {
                ImageSelector(sourceType: $imageSelectorSource, isPresented: $showImagePicker) { image, imageURL in
                    if let url = imageURL {
                        withAnimation(.easeOut) {
                            selectedImagesURL.append(Imagee(image: url))
                            showImagePicker = false
                        }
                    }
                }
            })
            .actionSheet(isPresented: $showActionSheet) { () -> ActionSheet in
                ActionSheet(title: Text("Select Image"), buttons: [ActionSheet.Button.default(Text("Take a Photo").font(.custom(nunitoRegular, fixedSize: 14)), action: {
                    imageSelectorSource = .camera
                    showImagePicker = true
                }), ActionSheet.Button.default(Text("Choose from Gallery"), action: {
                    imageSelectorSource = .photoLibrary
                    showImagePicker = true
                }), ActionSheet.Button.cancel()])
            }
            .toast(isPresenting: $showhud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)}
            .bottomSheet(isPresented: $showAlert, height: screenHeight/2, topBarCornerRadius: 25, showTopIndicator: false, content: {
                CommonBottomSheet(
                    sheetType: $alertType,
                    onPrimaryClick: {
                        withAnimation { showAlert = false }
                    }, onSecondaryClick: {
                        withAnimation { showAlert = false }
                    })
            })
            
            if isLoading {
                Loader(isLoading: $isLoading)
            }
            
//            if showAlert {
//                AlertPopUp(
//                    presentAlert: $showAlert,
//                    alertType: alertType,
//                    leftButtonAction: {
//                        withAnimation(.interactiveSpring) { showAlert = false }
//                    },
//                    rightButtonAction: {
//                        withAnimation(.interactiveSpring) { showAlert = false }
//                    })
//            }
        }.onAppear(perform: {
            
            if let userDetail: UserDetailModal 
                = UserDefaultsManager.shared.getModel(forKey: .userDetail) {
                selectedImagesURL = userDetail.images ?? []
            }
            
            observe()
        })
    }
    
    func observe() {
        self.viewModal.eventHandler = {
            event in
            switch event {
                case .loading:
                    isLoading = true
                case .stopLoading:
                    isLoading = false
                case .dataLoaded:
                    handleSuccess()
                case .error(let error):
                    alertType = .sheetType(icon: .alert, title: "Error", message: error?.localizedDescription ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showAlert = true
            }
        }
    }
    
    func handleSuccess() {
        if viewModal.requestType == "AddImageToProfile" {
            if let response = viewModal.skillResponse {
                if response.status == "success" {
                    alertType = .sheetType(icon: .success, title: response.status?.capitalized ?? "", message: "Image updated successfully.", primaryBtnText: "Ok", secondaryBtnText: "", sheetThemeColor: .green)
                    showAlert = true
                } else {
                    alertType = .sheetType(icon: .alert, title: response.status?.capitalized ?? "", message: response.message?.capitalized ?? "", primaryBtnText: "", secondaryBtnText: "Ok", sheetThemeColor: .pinkBtn)
                    showAlert = true
                }
            }
        }
    }
}

struct ImageContainerWithName: View {
    
    @Binding var imageName: Imagee
    
    var onTrashClick: ((Imagee) -> Void)?
    
    var body: some View {
        HStack {
            
            KFImage.url( imageName.image.contains("media/") ? getMediaURL(url: imageName.image) : URL(string: imageName.image)! )
                .placeholder({
                    Image(.imgPlaceholder)
                        .resizable()
                        .blur(radius: 1.5)
                        .foregroundStyle(.text.opacity(0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                })
                .retry(maxCount: 3, interval: .seconds(5))
                .cacheOriginalImage()
                .resizable()
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 5))
            
            Text(imageName.image.split(separator: "/").last ?? "")
                .font(.custom(nunitoMedium, fixedSize: 14))
                .foregroundStyle(.black.opacity(0.8))
            
            Spacer()
            
            Button(action: { withAnimation(.easeIn) { self.onTrashClick?(imageName) } }, label: {
                Image(.trash)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            })
        }
        .padding(.all, 10)
  //      .background(.backGround)
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

#Preview {
    UserImageSelectionScreen()
}
