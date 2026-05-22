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
        sheetSecondaryColor: ColorResource = .defaultTheme,
        secondaryTextColor: Color = .white,
        isButtonVertical: Bool = true,
        buttonHeight: CGFloat = 40,
        buttonWidth: CGFloat = screenWidth/1.5,
        contentSize : CGFloat = 13.0
    )
    
    var icon: ImageResource {
        switch self {
            case .sheetType(icon: let icon, _, _,_, _, _, _, _, _, _, _,_):
                return icon
        }
    }
    
    var title: String {
        switch self {
            case .sheetType(_, title: let title, _,_, _, _, _, _, _,_, _,_):
                return title
        }
    }
    
    var message: String {
        switch self {
            case .sheetType(_, _, message: let message, _,_, _, _,_, _, _, _,_):
                return message
        }
    }
    
    var primaryBtnText: String {
        switch self {
            case .sheetType(_, _, _, primaryBtnText: let primaryBtnText, _,_, _,_, _, _, _,_):
                return primaryBtnText
        }
    }
    
    var secondaryBtnText: String {
        switch self {
            case .sheetType(_, _, _, _, secondaryBtnText: let secondaryBtnText,_, _, _,_, _, _,_):
                return secondaryBtnText
        }
    }
    
    var sheetThemeColor: ColorResource {
        switch self {
            case .sheetType(_, _, _, _, _, sheetThemeColor: let color, _,_, _,_, _,_):
                return color
        }
    }
    
    var sheetSecondaryColor: ColorResource {
        switch self {
            case .sheetType(_, _, _, _, _,_,sheetSecondaryColor: let color,_,_, _, _,_):
                return color
        }
    }
    var secondaryTextColor: Color {
        switch self {
            case .sheetType(_, _, _, _, _,_,_, secondaryTextColor: let color,_, _, _,_):
                return color
        }
    }
    
    var isBtnVertical: Bool {
        switch self {
            case .sheetType(_, _, _, _, _, _,_,_, isButtonVertical: let isBtnVertical, _, _,_):
                return isBtnVertical
        }
    }
    
    var btnWidth: CGFloat {
        switch self {
            case .sheetType(_, _, _, _, _,_, _, _,_, _, buttonWidth: let width,_):
                return width
        }
    }
    
    var btnHeight: CGFloat {
        switch self {
            case .sheetType(_, _, _, _,_, _, _,_, _, buttonHeight: let height, _, _):
                return height
        }
    }
    var contentSize: CGFloat {
        switch self {
        case .sheetType(_, _, _, _, _, _,_, _,_, _,_,contentSize:let size):
                return size
        }
    }
}

//struct CommonBottomSheet: View {
//    
//    @EnvironmentObject private var appRootManager: AppRootManager
//    
//    @Binding var sheetType: BottomSheetType
//
//    // MARK: - CallBack Functions
//    var onPrimaryClick: (() -> Void)?
//    var onSecondaryClick: (() -> Void)?
//    
//    var body: some View {
//        VStack(spacing: 16) {
//            
//            // MARK: - Icon
//            Image(sheetType.icon)
//                .renderingMode(.template)
//                .resizable()
//                .frame(width: 42, height: 42)
//                .padding(10)
//                .background(Color(sheetType.sheetThemeColor))
//                .foregroundColor(.white)
//                .clipShape(Circle())
//                .padding(.top, 10)
//            
//            // MARK: - Title
//            Text(sheetType.title)
//                .font(.custom(poppinsBold, size: 22))
//                .foregroundColor(.black)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 25)
//            
//            // MARK: - Message (multi-line friendly)
//            Text(sheetType.message)
//                .font(.custom(poppinsMedium, size: sheetType.contentSize))
//                .foregroundColor(.black)
//                .multilineTextAlignment(.center)
//                .padding(.horizontal, 30)
//                .fixedSize(horizontal: false, vertical: true)
//            
//            Spacer(minLength: 20)
//            
//            // MARK: - Buttons Layout
//            if sheetType.isBtnVertical {
//                VStack(spacing: 10) {   // Reduced spacing for compact look
//                    
//                    if sheetType.primaryBtnText != "" {
//                        PrimaryButton(
//                            title: sheetType.primaryBtnText,
//                            isOutLine: false,
//                            onButtonClick: handlePrimaryAction,
//                            width: sheetType.btnWidth,
//                            height: sheetType.btnHeight,
//                            btnTextColor: .white,
//                            btnColor: sheetType.sheetThemeColor
//                        )
//                    }
//                    
//                    if sheetType.secondaryBtnText != "" {
//                        PrimaryButton(
//                            title: sheetType.secondaryBtnText,
//                            isOutLine: false,
//                            onButtonClick: handleSecondaryAction,
//                            width: sheetType.btnWidth,
//                            height: sheetType.btnHeight,
//                            btnTextColor: .white,
//                            btnColor: sheetType.sheetThemeColor
//                        )
//                    }
//                }
//                .padding(.bottom, 20)
//                
//            } else {
//                HStack(spacing: 12) {  // Good spacing between horizontal buttons
//                    
//                    if sheetType.primaryBtnText != "" {
//                        PrimaryButton(
//                            title: sheetType.primaryBtnText,
//                            isOutLine: false,
//                            onButtonClick: handlePrimaryAction,
//                            width: sheetType.btnWidth,
//                            height: sheetType.btnHeight,
//                            btnTextColor: .white,
//                            btnColor: sheetType.sheetThemeColor
//                        )
//                    }
//                    
//                    if sheetType.secondaryBtnText != "" {
//                        PrimaryButton(
//                            title: sheetType.secondaryBtnText,
//                            isOutLine: false,
//                            onButtonClick: handleSecondaryAction,
//                            width: sheetType.btnWidth,
//                            height: sheetType.btnHeight,
//                            btnTextColor: .white,
//                            btnColor: sheetType.sheetThemeColor
//                        )
//                    }
//                }
//                .padding(.bottom, 22)
//            }
//        }
//        .padding(.horizontal, 20)
//        .frame(maxWidth: .infinity, alignment: .center)
//    }
//    
//    // MARK: - Actions
//    private func handlePrimaryAction() {
//        if sheetType.message.contains("token") {
//            appRootManager.currentRoot = .authentication
//        } else {
//            onPrimaryClick?()
//        }
//    }
//    
//    private func handleSecondaryAction() {
//        if sheetType.message.contains("token") {
//            appRootManager.currentRoot = .authentication
//        } else {
//            onSecondaryClick?()
//        }
//    }
//}

struct CommonBottomSheet: View {
    
    @EnvironmentObject private var appRootManager: AppRootManager
    @Binding var sheetType: BottomSheetType
    
    var onPrimaryClick: (() -> Void)?
    var onSecondaryClick: (() -> Void)?
    
    var body: some View {
        // MC cmpfokeoh0019oohgosv0s5ic (2026-05-22): wrap the icon + title
        // + message section in a ScrollView so long error bodies don't
        // push the action buttons below the bottom-sheet's fixed frame.
        // The buttons stay outside the ScrollView so they remain pinned
        // at the bottom regardless of message length.
        VStack(spacing: 8) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 8) {
                    // MARK: - Icon (Improved but same size)
                    ZStack {
                        Circle()
                            .fill(Color(sheetType.sheetThemeColor).opacity(0.12))
                            .frame(width: 70, height: 70)
                            .blur(radius: 4)

                        Circle()
                            .fill(Color(sheetType.sheetThemeColor))
                            .frame(width: 58, height: 58)
                            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)

                        Image(sheetType.icon)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.white)
                            .transition(.opacity)
                    }
                    .padding(.top, 8)

                    // MARK: - Title
                    Text(sheetType.title)
                        .font(.custom(poppinsBold, size: 22))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 22)

                    // MARK: - Message
                    Text(sheetType.message)
                        .font(.custom(poppinsSemiBold, size: sheetType.contentSize))
                        .foregroundColor(.darkGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 28)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 8)
            
            // MARK: - Buttons (same structure, just improved aesthetics)
            if sheetType.isBtnVertical {
                
                VStack(spacing: 4) {
                    
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
                        .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
                        .animation(.easeInOut(duration: 0.15), value: sheetType.primaryBtnText)
                    }
                    
                    if sheetType.secondaryBtnText != "" {
                        PrimaryButton(
                            title: sheetType.secondaryBtnText,
                            isOutLine: false,
                            onButtonClick: handleSecondaryAction,
                            width: sheetType.btnWidth,
                            height: sheetType.btnHeight,
//                            btnTextColor: sheetType.sheetThemeColor,
//                            btnColor: Color.gray.opacity(0.12)
                            btnTextColor: sheetType.secondaryTextColor,
                            btnColor: sheetType.sheetSecondaryColor
                        )
                    }
                }
                .padding(.bottom, 18)
                
            } else {
                HStack(spacing: 12) {
                    
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
                        .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
                    }
                    
                    if sheetType.secondaryBtnText != "" {
                        PrimaryButton(
                            title: sheetType.secondaryBtnText,
                            isOutLine: false,
                            onButtonClick: handleSecondaryAction,
                            width: sheetType.btnWidth,
                            height: sheetType.btnHeight,
//                            btnTextColor: sheetType.sheetThemeColor,
//                            btnColor: Color.gray.opacity(0.12)
                            btnTextColor: sheetType.secondaryTextColor,
                            btnColor: sheetType.sheetSecondaryColor
                            
                        )
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .frame(maxWidth: .infinity)
//        .background(
//            Color.white
//                .cornerRadius(25)
//                .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: -4)
//                .transition(.move(edge: .bottom).combined(with: .opacity))
//        )
    }
    
    // MARK: - BUTTON ACTION HANDLERS
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

//struct CommonBottomSheet: View {
//    @EnvironmentObject private var appRootManager: AppRootManager
//    @Binding var sheetType: BottomSheetType
//    var onPrimaryClick: (() -> Void)?
//    var onSecondaryClick: (() -> Void)?
//    @State private var appear = false
//
//    private var isDestructive: Bool {
//        sheetType.title.lowercased().contains("block") ||
//        sheetType.primaryBtnText.lowercased().contains("block")
//    }
//
//    var body: some View {
//        VStack(spacing: 0) {
//            Capsule()
//                .fill(Color(.systemGray5))
//                .frame(width: 36, height: 5)
//                .padding(.top, 8)
//                .padding(.bottom, 6)
//
//            VStack(spacing: 14) {
//                ZStack {
//                    Circle()
//                        .fill(isDestructive ? ColorResource.danger : ColorResource.defaultTheme)
//                        .frame(width: 72, height: 72)
//                    Circle()
//                        .fill(isDestructive ?  ColorResource.danger : sheetType.sheetThemeColor)
//                        .frame(width: 56, height: 56)
//                        .shadow(color: Color.black.opacity(0.14), radius: 8, x: 0, y: 4)
//                    Image(sheetType.icon)
//                        .renderingMode(.template)
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 28, height: 28)
//                        .foregroundStyle(.white)
//                }
//                .padding(.top, 6)
//
//                Text(sheetType.title)
//                    .font(.custom(poppinsBold, size: 20))
//                    .foregroundColor(.primary)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 22)
//
//                Text(sheetType.message)
//                    .font(.custom(poppinsMedium, size: sheetType.contentSize))
//                    .foregroundColor(.secondary)
//                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 26)
//                    .fixedSize(horizontal: false, vertical: true)
//
//                if sheetType.isBtnVertical {
//                    VStack(spacing: 12) {
//                        if sheetType.primaryBtnText != "" {
//                            PrimaryButton(
//                                title: sheetType.primaryBtnText,
//                                isOutLine: false,
//                                onButtonClick: { handlePrimaryAction() },
//                                width: sheetType.btnWidth,
//                                height: sheetType.btnHeight,
//                                btnTextColor: .white,
//                                btnColor: isDestructive ? ColorResource.danger : sheetType.sheetThemeColor
//                            )
//                            .shadow(color: (isDestructive ? Color.red.opacity(0.16) : Color.black.opacity(0.12)), radius: 8, x: 0, y: 4)
//                        }
//
//                        if sheetType.secondaryBtnText != "" {
//                            PrimaryButton(
//                                title: sheetType.secondaryBtnText,
//                                isOutLine: true,
//                                onButtonClick: { handleSecondaryAction() },
//                                width: sheetType.btnWidth,
//                                height: sheetType.btnHeight,
//                                btnTextColor: .primary,
//                                btnColor: ColorResource.mediumLightGray
//                            )
//                        }
//                    }
//                    .padding(.horizontal, 10)
//                    .padding(.vertical, 6)
//                } else {
//                    HStack(spacing: 12) {
//                        if sheetType.secondaryBtnText != "" {
//                            PrimaryButton(
//                                title: sheetType.secondaryBtnText,
//                                isOutLine: true,
//                                onButtonClick: { handleSecondaryAction() },
//                                width: (sheetType.btnWidth - 12) / 2,
//                                height: sheetType.btnHeight,
//                                btnTextColor: .primary,
//                                btnColor: Color(UIColor.systemGray5)
//                            )
//                        }
//
//                        if sheetType.primaryBtnText != "" {
//                            PrimaryButton(
//                                title: sheetType.primaryBtnText,
//                                isOutLine: false,
//                                onButtonClick: { handlePrimaryAction() },
//                                width: (sheetType.btnWidth - 12) / 2,
//                                height: sheetType.btnHeight,
//                                btnTextColor: .white,
//                                btnColor: isDestructive ? ColorResource.danger : sheetType.sheetThemeColor
//                            )
//                            .shadow(color: (isDestructive ? Color.red.opacity(0.16) : Color.black.opacity(0.12)), radius: 8, x: 0, y: 4)
//                        }
//                    }
//                    .padding(.horizontal, 14)
//                    .padding(.vertical, 8)
//                }
//            }
//            .padding(.horizontal, 18)
//            .padding(.bottom, 12)
//            .background(
//                RoundedRectangle(cornerRadius: 16, style: .continuous)
//                    .fill(Color(UIColor.systemBackground))
//            )
//            .padding(.horizontal, 16)
//            .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 8)
//            .opacity(appear ? 1 : 0)
//            .scaleEffect(appear ? 1 : 0.995)
//            .animation(.spring(response: 0.36, dampingFraction: 0.78, blendDuration: 0), value: appear)
//            .onAppear { withAnimation { appear = true } }
//            .onDisappear { withAnimation { appear = false } }
//        }
//        .frame(maxWidth: .infinity)
//    }
//
//    private func handlePrimaryAction() {
//        if sheetType.message.contains("token") {
//            appRootManager.currentRoot = .authentication
//        } else {
//            onPrimaryClick?()
//        }
//    }
//
//    private func handleSecondaryAction() {
//        if sheetType.message.contains("token") {
//            appRootManager.currentRoot = .authentication
//        } else {
//            onSecondaryClick?()
//        }
//    }
//}



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

