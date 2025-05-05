//
//  MultilineTextField.swift
//  imperium
//
//  Created by JAM-E-282 on 20/01/24.
//

import SwiftUI
import MarkupEditor
import RichText

struct MultilineTextField: View {
    @State var floatingLabel: String = ""
    @State var placeholder: String = ""
    
    @Binding var text: String
    
    @State var isForDescription: Bool = false
    
    var enteredText: ((String) -> Void)?
    
    @State var navigateToDescription: Bool = false
    @State private var rawText = NSAttributedString(string: "")
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if floatingLabel != "" {
                Text(floatingLabel)
                    .font(.custom(nunitoBold, fixedSize: 15))
                    .bold()
                    .foregroundStyle(.text)
            }
            
            ZStack(alignment: .topLeading) {
                
                if isForDescription {
                    if text == "" {
                        TextEditor(text: $text)
                            .font(.custom(nunitoMedium, fixedSize: 15))
                            .foregroundStyle(.text)
                            .frame(height: screenHeight/7)
                            .padding(.all, 3)
                            .ignoresSafeArea(.keyboard, edges: .bottom)
                            .disabled(true)
                    } else {
                        RichText(html: text)
                            .customCSS("""
            body {
                font-size: 15px;
            }
        """)
                            .foregroundStyle(.text)
                            .padding(.all, 3)
                            .ignoresSafeArea(.keyboard, edges: .bottom)
                    }
                } else {
                    TextEditor(text: $text)
                        .font(.custom(nunitoMedium, fixedSize: 15))
                        .keyboardType(.emailAddress)
                        .keyboardShortcut(.cancelAction)
                        .foregroundStyle(.text)
                        .submitLabel(.next)
                        .accentColor(.text)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .frame(height: screenHeight/7)
                        .padding(.all, 3)
                        .onChange(of: text, perform: { value in
                            self.enteredText?(value)
                        })
                        .onSubmit {
                            self.enteredText?(text)
                        }
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                }
                
                if text.count == 0 {
                    Text(placeholder)
                        .font(.custom(nunitoMedium, fixedSize: 13))
                        .foregroundStyle(.gray)
                        .padding([.top, .leading], 10)
                }
            }
            .padding([.top, .bottom], 3)
            .padding([.leading, .trailing], 6)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.white)
                    .shadow(color: .gray, radius: 1, x: 0, y: 0)
            )
            .onTapGesture {
                if isForDescription {
                    navigateToDescription.toggle()
                }
            }
        }
        .fullScreenCover(isPresented: $navigateToDescription, content: {
            DescriptionEditor(
                description: $text,
                onSubmitClick: {
                    value in
                    text = value
                })
        })
    }
}

#Preview {
    MultilineTextField(text: .constant(""))
}
