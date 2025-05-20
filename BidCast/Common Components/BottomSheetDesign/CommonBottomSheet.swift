//
//  CommonBottomSheet.swift
// BidSwipe
//
//  Created by Maneet-JAM-E-282 on 04/03/24.
//

import SwiftUI

enum BottomSheetType {
    
    case sheetType(
        icon: ImageResource,
        title: String,
        message: String,
        primaryBtnText: String = "Continue",
        secondaryBtnText: String = "Cancel",
        sheetThemeColor: ColorResource = .defaultTheme,
        isButtonVertical: Bool = true,
        buttonHeight: CGFloat = 40,
        buttonWidth: CGFloat = screenWidth/1.5)
    
    var icon: ImageResource {
        switch self {
            case .sheetType(icon: let icon, _, _, _, _, _, _, _, _):
                return icon
        }
    }
    
    var title: String {
        switch self {
            case .sheetType(_, title: let title, _, _, _, _, _, _, _):
                return title
        }
    }
    
    var message: String {
        switch self {
            case .sheetType(_, _, message: let message, _, _, _, _, _, _):
                return message
        }
    }
    
    var primaryBtnText: String {
        switch self {
            case .sheetType(_, _, _, primaryBtnText: let primaryBtnText, _, _, _, _, _):
                return primaryBtnText
        }
    }
    
    var secondaryBtnText: String {
        switch self {
            case .sheetType(_, _, _, _, secondaryBtnText: let secondaryBtnText, _, _, _, _):
                return secondaryBtnText
        }
    }
    
    var sheetThemeColor: ColorResource {
        switch self {
            case .sheetType(_, _, _, _, _, sheetThemeColor: let color, _, _, _):
                return color
        }
    }
    
    var isBtnVertical: Bool {
        switch self {
            case .sheetType(_, _, _, _, _, _, isButtonVertical: let isBtnVertical, _, _):
                return isBtnVertical
        }
    }
    
    var btnWidth: CGFloat {
        switch self {
            case .sheetType(_, _, _, _, _, _, _, _, buttonWidth: let width):
                return width
        }
    }
    
    var btnHeight: CGFloat {
        switch self {
            case .sheetType(_, _, _, _, _, _, _, buttonHeight: let height, _):
                return height
        }
    }
}

struct CommonBottomSheet: View {
    
    @EnvironmentObject private var appRootManager: AppRootManager
    
    @Binding var sheetType: BottomSheetType
//    
        //MARK: - CallBack Functions
    var onPrimaryClick: (() -> Void)?
    var onSecondaryClick: (() -> Void)?
    
        //MARK: - Logout Sheet View
    var body: some View {
        VStack(spacing: 14) {
            Image(sheetType.icon)
                .renderingMode(.template)
                .resizable()
                .frame(width: 40, height: 40)
                .padding(.all, 6)
                .background(Color(sheetType.sheetThemeColor))
                .foregroundStyle(.white)
                .clipShape(Circle())
            
            Text(sheetType.title)
                .font(.custom(nunitoBlack, fixedSize: 24))
            
            Text(sheetType.message)
                .font(.custom(nunitoRegular, fixedSize: 16))
                .padding(.horizontal, 45)
                .multilineTextAlignment(.center)
            
            if sheetType.isBtnVertical {
                VStack(spacing: 15) {
                    if sheetType.primaryBtnText != "" {
                        PrimaryButton(title: sheetType.primaryBtnText, isOutLine: false, onButtonClick: {
                            self.onPrimaryClick?()
                        }, width: sheetType.btnWidth, height: sheetType.btnHeight,btnTextColor: .white,btnColor: sheetType.sheetThemeColor)
                    }
                    
                    if sheetType.secondaryBtnText != "" {
                        PrimaryButton(title: sheetType.secondaryBtnText, isOutLine: false, onButtonClick: {
                            self.onSecondaryClick?()
                        }, width: sheetType.btnWidth, height: sheetType.btnHeight, btnTextColor: .white, btnColor: sheetType.sheetThemeColor)
                    }
                }.padding(.top, 10)
            } else {
                HStack {
                    if sheetType.primaryBtnText != "" {
                        PrimaryButton(title: sheetType.primaryBtnText, isOutLine: false, onButtonClick: {
                            if sheetType.message.contains("token") {
                                DispatchQueue.main.async {
                                    appRootManager.currentRoot = .authentication
                                }
                            } else {
                                self.onPrimaryClick?()
                            }
                        }, width: sheetType.btnWidth, height: sheetType.btnHeight,btnTextColor: .white, btnColor: sheetType.sheetThemeColor)
                    }
                    
                    if sheetType.secondaryBtnText != "" {
                        PrimaryButton(title: sheetType.secondaryBtnText, isOutLine: false, onButtonClick: {
                            if sheetType.message.contains("token") {
                                DispatchQueue.main.async {
                                    appRootManager.currentRoot = .authentication
                                }
                            } else {
                                self.onSecondaryClick?()
                            }
                        }, width: sheetType.btnWidth, height: sheetType.btnHeight,btnTextColor: .white, btnColor: sheetType.sheetThemeColor)
                    }
                }.padding(.top, 10)
            }
        }
    }
}

//#Preview {
//    CommonBottomSheet()
//}
