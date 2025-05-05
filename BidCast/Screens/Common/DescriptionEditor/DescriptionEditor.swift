//
//  DescriptionEditor.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 24/04/24.
//

import SwiftUI
import MarkupEditor
import AlertToast
import RegexBuilder
import WebKit
import UIKit

struct DescriptionEditor: View {
    
    @Environment(\.dismiss) var dismiss
    
    @Binding var description: String
    @State var showHud: Bool = false
    @State var isKeyboArdActive: Bool = false
    @State var hudMessage: String = ""
    @State var keyboardHeight: CGFloat = 0
    
    var onSubmitClick: ((String) -> Void)?
    
    func attributedString(from string: String) -> NSAttributedString {
        var attributes = [NSAttributedString.Key: AnyObject]()
        attributes[.foregroundColor] = UIColor.label
        attributes[.font] = UIFont.monospacedSystemFont(ofSize: StyleContext.P.fontSize, weight: .regular)
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            PrimaryHeader(
                title: "Add Description",
                trailingImgArr: [.cancel],
                onClickTrailing: { _ in
                    UIApplication.shared.endEditing()
                    dismiss()
                }, count: .constant(0))
            
            ScrollView(showsIndicators: false) {
                MarkupEditorView(
                    html: $description,
                    placeholder: "Enter your description here ... ")
                .frame(height: isKeyboArdActive ? screenHeight * 0.35 : screenHeight * 0.7 )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .shadow(color: .gray, radius: 2, x: 0, y: 0)
                )
                .padding()
                
                
                PrimaryButton(
                    title: "Submit",
                    isOutLine: false,
                    onButtonClick: {
                        UIApplication.shared.endEditing()
                        MarkupEditor.selectedWebView?.getHtml({ text in
                            let plainText = text?.htmlToString.trim ?? ""
                            if plainText == "" {
                                hudMessage = "Please provide description"
                                showHud = true
                            } else {
                                onSubmitClick?(attributedString(from: text ?? "").string)
                                dismiss()
                            }
                        })
                    })
            
            }.padding(.top, -topPadding)
            
            
            Spacer()
        }
        .onTapGesture(perform: {
            UIApplication.shared.endEditing()
        })
        .onAppear {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                if let userInfo = notification.userInfo,
                   let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                    keyboardHeight = frame.cgRectValue.height
                    isKeyboArdActive = true
                }
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                keyboardHeight = 0
                isKeyboArdActive = false
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
        .toast(isPresenting: $showHud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMessage, style: alertStlye)}
    }
}
