//
//  AlertPopUp.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 23/01/24.
//

import SwiftUI

struct AlertPopUp: View {
    
    @EnvironmentObject private var appRootManager: AppRootManager
    
    @Binding var presentAlert: Bool
    
    @State var alertType: AlertType = .success(title: "", message: "", leftBtnText: "", rightBtnText: "")
    
    var isShowVerticalButtons = false
    
    var leftButtonAction: (() -> ())?
    var rightButtonAction: (() -> ())?
    
    let verticalButtonsHeight: CGFloat = 80
    
    var body: some View {
        
        ZStack {
            Color.black.opacity(0.75)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        presentAlert = false
                    }
                }
            
            VStack(spacing: 0) {
                
                if alertType.title() != "" {
                    Text(alertType.title())
                        .font(.custom(nunitoBold, size: 20))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.center)
                        .frame(height: 25)
                        .padding(.top, 16)
                        .padding(.bottom, 8)
                        .padding(.horizontal, 16)
                }
                
                Text(alertType.message())
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .font(.custom(nunitoMedium, size: 18))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .minimumScaleFactor(0.5)
                
                Divider()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 0.5)
                    .padding(.all, 0)
                
                if !isShowVerticalButtons {
                    HStack(spacing: 0) {
                        
                        if (!alertType.leftActionText.isEmpty) {
                            Button {
                                leftButtonAction?()
                            } label: {
                                Text(alertType.leftActionText)
                                    .font(.custom(nunitoSemiBold, size: 18))
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            }
                            Divider()
                                .frame(minWidth: 0, maxWidth: 0.5, minHeight: 0, maxHeight: .infinity)
                        }
                        
                        if (!alertType.rightActionText.isEmpty) {
                            Button {
                                rightButtonAction?()
                            } label: {
                                Text(alertType.rightActionText)
                                    .font(.custom(nunitoSemiBold, size: 18))
                                    .foregroundColor(.pink)
                                    .multilineTextAlignment(.center)
                                    .padding(15)
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            }
                        }
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 55)
                    .padding([.horizontal, .bottom], 0)
                    
                } else {
                    VStack(spacing: 0) {
                        Spacer()
                        Button {
                            if alertType.leftActionText == "Login Again" {
                                DispatchQueue.main.async {
                                    appRootManager.currentRoot = .authentication
                                }
                            }
                            leftButtonAction?()
                        } label: {
                            Text(alertType.leftActionText)
                                .font(.custom(nunitoSemiBold, size: 18))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        }
                        Spacer()
                        
                        Divider()
                        
                        Spacer()
                        Button {
                            rightButtonAction?()
                        } label: {
                            Text(alertType.rightActionText)
                                .font(.custom(nunitoSemiBold, size: 18))
                                .foregroundColor(.pink)
                                .multilineTextAlignment(.center)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        }
                        Spacer()
                        
                    }
                    .frame(height: verticalButtonsHeight)
                }
                
            }
            .frame(width: 270, height: alertType.height(isShowVerticalButtons: isShowVerticalButtons))
            .background(
                Color.white
            )
            .cornerRadius(4)
        }
        .zIndex(2)
        .interactiveDismissDisabled()
    }
}

#Preview {
    AlertPopUp(presentAlert: .constant(true))
}
