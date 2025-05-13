//
//  AuthTextField.swift
//  imperium
//
//  Created by JAM-E-282 on 18/01/24.
//

import SwiftUI

struct AuthTextField: View {
    
    @State var floatingLabel: String = ""
    @State var isRequired: Bool = false
    @State var isMandatory: Bool = false
    @State var placeholder: String = ""
    @State var icon: ImageResource
    @State var maxDigits: Int = 10
    @Binding var text: String
    @State var isPassword: Bool = false
    @State var showPassword: Bool = true
    @FocusState var isFocused: Bool
    
    var enteredText: ((String) -> Void)?
    var isRequiredValue: ((Int) -> Void)?
    var width: CGFloat = screenWidth - 30
    var height: CGFloat = 40
    var cornerRadius : CGFloat = 8.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            if floatingLabel != "" {
                Text(floatingLabel)
                    .font(.custom(nunitoBold, fixedSize: 15))
                    .bold()
                    .foregroundStyle(.text)
            }
            
            ZStack(alignment: .trailing, content: {
                HStack(alignment: .center, spacing: 10) {
                    Image(icon)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.text.opacity(0.45))
                        .padding(.all, 10)
                        //.background(.text.opacity(0.1))
                        //.clipShape(Circle())
                    
                    if showPassword && isPassword {
                        SecureField(placeholder, text: $text)
                            .font(.custom(nunitoMedium, fixedSize: 15))
                            .autocorrectionDisabled(true)
                            .autocapitalization(.none)
                            .foregroundStyle(.text)
                            .submitLabel(.next)
                            .accentColor(.text)
                            .focused($isFocused)
                            .onChange(of: text, perform: { value in
                                self.enteredText?(value)
                            })
                            .onSubmit {
                                self.enteredText?(text)
                            }
                            .ignoresSafeArea(.keyboard, edges: .bottom)
                    } else {
                        TextField(placeholder, text: $text)
                        
                            .font(.custom(nunitoMedium, fixedSize: 15))
                            .autocorrectionDisabled(true)
                            .autocapitalization(.none)
                            .foregroundStyle(.text)
                            .submitLabel(.next)
                            .accentColor(.text)
                            .focused($isFocused)
                            .frame(height: height)
                            .onChange(of: text, perform: { value in
                                self.enteredText?(value)
                            })
                            .onSubmit {
                                self.enteredText?(text)
                            }
                            .ignoresSafeArea(.keyboard, edges: .bottom)
    
                    }
                    
                    Spacer()
                }
                .frame(width: width,height: height)
                .padding(.all, 6)
                .background(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.text.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(.mediumLightGray, lineWidth: 2) 
                        )
                        .shadow(color: .ultraLightGray, radius: 1, x: 0, y: 0)
                )
                .onTapGesture {
                    isFocused = true
                }
                
                if isPassword {
                    Button(action: { withAnimation(.bouncy) { showPassword.toggle() } }, label: {
                        Image(!showPassword ? .eyeOpen : .eyeClose)
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25, height: 20)
                            .foregroundStyle(.black.opacity(0.5))
                            .clipShape(Circle())
                            .padding(.trailing)
                    })
                }
            })
            if isMandatory{
                HStack{
                    
                    Button(action: {
                        isRequired.toggle()
                        if isRequired{
                            self.isRequiredValue?(1)
                        }else{
                            self.isRequiredValue?(0)
                        }
                    }, label: {
                        Image(systemName: isRequired ? "checkmark.square.fill":"square")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.text)
                        
                        Text("It's required")
                            .font(.custom(nunitoRegular, fixedSize: 15))
                            .foregroundStyle(.text)
                    })
                    
                    Spacer()
                    
                }
                .padding(.top,1.5)
                .padding(.leading,0)
            }
        }.onTapGesture {
            isFocused = true
        }
        .onDisappear {
            isFocused = false
        }
    }
    
    
}

#Preview {
    AuthTextField(icon: .gradCap, text: .constant(""))
}
