//
//  CommonBottomSheet.swift
// BidSwipe
//
//  Created by Ankit - JAM - E - 294 on 04/03/24.
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
        buttonWidth: CGFloat = screenWidth/1.5,
        contentSize : CGFloat = 16.0
    )
    
    var icon: ImageResource {
        switch self {
            case .sheetType(icon: let icon, _, _, _, _, _, _, _, _,_):
                return icon
        }
    }
    
    var title: String {
        switch self {
            case .sheetType(_, title: let title, _, _, _, _, _, _, _,_):
                return title
        }
    }
    
    var message: String {
        switch self {
            case .sheetType(_, _, message: let message, _, _, _, _, _, _,_):
                return message
        }
    }
    
    var primaryBtnText: String {
        switch self {
            case .sheetType(_, _, _, primaryBtnText: let primaryBtnText, _, _, _, _, _,_):
                return primaryBtnText
        }
    }
    
    var secondaryBtnText: String {
        switch self {
            case .sheetType(_, _, _, _, secondaryBtnText: let secondaryBtnText, _, _, _, _,_):
                return secondaryBtnText
        }
    }
    
    var sheetThemeColor: ColorResource {
        switch self {
            case .sheetType(_, _, _, _, _, sheetThemeColor: let color, _, _, _,_):
                return color
        }
    }
    
    var isBtnVertical: Bool {
        switch self {
            case .sheetType(_, _, _, _, _, _, isButtonVertical: let isBtnVertical, _, _,_):
                return isBtnVertical
        }
    }
    
    var btnWidth: CGFloat {
        switch self {
            case .sheetType(_, _, _, _, _, _, _, _, buttonWidth: let width,_):
                return width
        }
    }
    
    var btnHeight: CGFloat {
        switch self {
            case .sheetType(_, _, _, _, _, _, _, buttonHeight: let height, _, _):
                return height
        }
    }
    var contentSize: CGFloat {
        switch self {
        case .sheetType(_, _, _, _, _, _, _, _,_,contentSize:let size):
                return size
        }
    }
}

struct CommonBottomSheet: View {
    
    @EnvironmentObject private var appRootManager: AppRootManager
    
    @Binding var sheetType: BottomSheetType

    // MARK: - CallBack Functions
    var onPrimaryClick: (() -> Void)?
    var onSecondaryClick: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 16) {
            
            // MARK: - Icon
            Image(sheetType.icon)
                .renderingMode(.template)
                .resizable()
                .frame(width: 42, height: 42)
                .padding(10)
                .background(Color(sheetType.sheetThemeColor))
                .foregroundColor(.white)
                .clipShape(Circle())
                .padding(.top, 10)
            
            // MARK: - Title
            Text(sheetType.title)
                .font(.custom(poppinsBold, size: 22))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 25)
            
            // MARK: - Message (multi-line friendly)
            Text(sheetType.message)
                .font(.custom(poppinsMedium, size: sheetType.contentSize))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 20)
            
            // MARK: - Buttons Layout
            if sheetType.isBtnVertical {
                VStack(spacing: 10) {   // Reduced spacing for compact look
                    
                    if sheetType.primaryBtnText != "" {
                        PrimaryButton(
                            title: sheetType.primaryBtnText,
                            isOutLine: false,
                            onButtonClick: handlePrimaryAction,
                            width: sheetType.btnWidth,
                            height: sheetType.btnHeight,
                            btnTextColor: .white,
                            btnColor: sheetType.sheetThemeColor
                        )
                    }
                    
                    if sheetType.secondaryBtnText != "" {
                        PrimaryButton(
                            title: sheetType.secondaryBtnText,
                            isOutLine: false,
                            onButtonClick: handleSecondaryAction,
                            width: sheetType.btnWidth,
                            height: sheetType.btnHeight,
                            btnTextColor: .white,
                            btnColor: sheetType.sheetThemeColor
                        )
                    }
                }
                .padding(.bottom, 20)
                
            } else {
                HStack(spacing: 12) {  // Good spacing between horizontal buttons
                    
                    if sheetType.primaryBtnText != "" {
                        PrimaryButton(
                            title: sheetType.primaryBtnText,
                            isOutLine: false,
                            onButtonClick: handlePrimaryAction,
                            width: sheetType.btnWidth,
                            height: sheetType.btnHeight,
                            btnTextColor: .white,
                            btnColor: sheetType.sheetThemeColor
                        )
                    }
                    
                    if sheetType.secondaryBtnText != "" {
                        PrimaryButton(
                            title: sheetType.secondaryBtnText,
                            isOutLine: false,
                            onButtonClick: handleSecondaryAction,
                            width: sheetType.btnWidth,
                            height: sheetType.btnHeight,
                            btnTextColor: .white,
                            btnColor: sheetType.sheetThemeColor
                        )
                    }
                }
                .padding(.bottom, 22)
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    // MARK: - Actions
    private func handlePrimaryAction() {
        if sheetType.message.contains("token") {
            appRootManager.currentRoot = .authentication
        } else {
            onPrimaryClick?()
        }
    }
    
    private func handleSecondaryAction() {
        if sheetType.message.contains("token") {
            appRootManager.currentRoot = .authentication
        } else {
            onSecondaryClick?()
        }
    }
}


//#Preview {
//    CommonBottomSheet()
//}
struct SimpleImageOKBottomSheet: View {
  var image: ImageResource
  var title: String
  var message: String
  var themeColor: ColorResource = .defaultTheme
  var buttonText: String = "OK"
  var onOK: (() -> Void)?

  var body: some View {
    VStack(spacing: 16) {
      Image(image)
        .resizable()
        .frame(width: 40, height: 40)
        .padding()
        .background(Color(themeColor))
        .foregroundStyle(.white)
        .clipShape(Circle())

      Text(title)
        .font(.custom(poppinsBold, fixedSize: 24))
        .multilineTextAlignment(.center)

      Text(message)
        .font(.custom(poppinsMedium, fixedSize: 16))
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)

      PrimaryButton(
        title: buttonText,
        isOutLine: false,
        onButtonClick: {
          onOK?()
        },
        width: screenWidth / 1.5,
        height: 40,
        btnTextColor: .white,
        btnColor: themeColor
      )
      .padding(.top, 10)
    }
    .padding()
  }
}


struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


struct CommonBottomSheet1: View {

    @EnvironmentObject private var appRootManager: AppRootManager
    @Binding var sheetType: BottomSheetType

    var onPrimaryClick: (() -> Void)?
    var onSecondaryClick: (() -> Void)?

    @Binding var measuredHeight: CGFloat     // <-- NEW

    var body: some View {
        VStack(spacing: 14) {

            Image(sheetType.icon)
                .renderingMode(.template)
                .resizable()
                .frame(width: 40, height: 40)
                .padding(6)
                .background(Color(sheetType.sheetThemeColor))
                .foregroundStyle(.white)
                .clipShape(Circle())

            Text(sheetType.title)
                .font(.custom(poppinsBold, fixedSize: 24))
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(sheetType.message)
                .font(.custom(poppinsMedium, fixedSize: sheetType.contentSize))
                .foregroundStyle(.black)
                .padding(.horizontal, 45)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if sheetType.isBtnVertical {
                verticalButtons
            } else {
                horizontalButtons
            }

        }
        .background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: HeightPreferenceKey.self,
                                value: geo.size.height)
            }
        )
        .onPreferenceChange(HeightPreferenceKey.self) { newHeight in
            measuredHeight = newHeight + 40   // padding safety
        }
    }

    private var verticalButtons: some View {
        VStack(spacing: 15) {
            if sheetType.primaryBtnText != "" {
                PrimaryButton(title: sheetType.primaryBtnText) { onPrimaryClick?() }
            }
            if sheetType.secondaryBtnText != "" {
                PrimaryButton(title: sheetType.secondaryBtnText) { onSecondaryClick?() }
            }
        }.padding(.top, 10)
    }

    private var horizontalButtons: some View {
        HStack {
            if sheetType.primaryBtnText != "" {
                PrimaryButton(title: sheetType.primaryBtnText) { onPrimaryClick?() }
            }
            if sheetType.secondaryBtnText != "" {
                PrimaryButton(title: sheetType.secondaryBtnText) { onSecondaryClick?() }
            }
        }.padding(.top, 10)
    }
}
