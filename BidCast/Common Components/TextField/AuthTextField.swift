//
//  AuthTextField.swift
// BidSwipe
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
    var isIconDisplay : Bool = true
    var isForDescription: Bool = false
    @FocusState var isFocused: Bool
    @State var isForPrice: Bool = false
   
    var isRequiredValue: ((Int) -> Void)?
    var width: CGFloat = screenWidth - 30
    var height: CGFloat = 40
    var cornerRadius : CGFloat = 8.0
    
     var isForCVV: Bool = false
     var isForExpiry: Bool = false
     var isForCardNumber: Bool = false
     var custFontName: String = poppinsBold
     var custFontSize: Double = 13.0
    var custPlaceHolderName : String = robotoRegular
     var custPlaceHolderFontSize : Double = placeHolder
    
    
    var enteredText: ((String) -> Void)?
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            if floatingLabel != "" {
                Text(floatingLabel)
                    .font(.custom(custFontName, fixedSize: custFontSize))
                    .foregroundStyle(.text)
            }
            
            ZStack(alignment: .trailing, content: {
                
                if isForDescription {
                    ZStack(alignment: .topLeading) {

                        // Placeholder
                        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text(placeholder)
                                .font(.custom(custPlaceHolderName, fixedSize: custPlaceHolderFontSize))
                                .foregroundColor(.mediumLightGray)
                                .padding(.top, 12)
                                .padding(.leading, isIconDisplay ? 40 : 8)
                        }

                        // Multiline TextEditor
                        TextEditor(text: $text)
                            .font(.custom(custPlaceHolderName, fixedSize: custPlaceHolderFontSize))
                            .focused($isFocused)
                            .scrollContentBackground(.hidden)
                            .padding(.all, 6)
                            .frame(minHeight: 120, maxHeight: 200)
                            .background(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: cornerRadius)
                                            .stroke(isFocused ? Color.blue.opacity(0.6) : .mediumLightGray, lineWidth: 1)
                                    )
                                    .shadow(color: .ultraLightGray, radius: 1)
                            )
                            .onChange(of: text) { value in
                                enteredText?(value)
                            }
                    }
                    .padding(.vertical, 4)
                }
                
                else  {
                    HStack(alignment: .center, spacing: 10) {
                        if isIconDisplay{
                            Image(icon)
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.text.opacity(0.45))
                                .padding(.all, 10)
                        }
                        if showPassword && isPassword {
                            SecureField(placeholder, text: $text)
                                .font(.custom(custPlaceHolderName, fixedSize: placeHolder))
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
                        }
                        else {
                            HStack(spacing: 0) {
                                if isForPrice && (Int(text) ?? 0) > 0{
                                    Text("$")
                                        .font(.custom(custPlaceHolderName, fixedSize: custPlaceHolderFontSize))
                                        .foregroundStyle(.text)
                                        .padding(.leading, 4)
                                }
                                TextField(placeholder, text: $text)
                                
                                    .font(.custom(custPlaceHolderName, fixedSize: custPlaceHolderFontSize))
                                    .autocorrectionDisabled(true)
                                    .autocapitalization(.none)
                                    .foregroundStyle(.text)
                                    .submitLabel(.next)
                                    .accentColor(.text)
                                    .focused($isFocused)
                                    .frame(height: height)
                                    .onChange(of: text, perform: { value in
                                        var filtered = value.filter { $0.isNumber }
                                        if isForCVV {
                                            filtered = String(filtered.prefix(3))
                                            text = filtered
                                            self.enteredText?(text)
                                        } else if isForExpiry {
                                            filtered = String(filtered.prefix(6)) // only keep YYYYMM
                                            
                                            if filtered.count == 6 {
                                                let year = filtered.prefix(4)
                                                let month = filtered.suffix(2)
                                                filtered = "\(year)-\(month)"
                                            }
                                            
                                            text = filtered
                                            self.enteredText?(text)
                                        } else if isForCardNumber {
                                            filtered = String(filtered.prefix(16))
                                            var formatted = ""
                                            for (index, char) in filtered.enumerated() {
                                                //                                            if index != 0 && index % 4 == 0 {
                                                //                                                formatted.append("-")
                                                //                                            }
                                                formatted.append(char)
                                            }
                                            filtered = formatted
                                            text = filtered
                                            self.enteredText?(text)
                                        } else if isForPrice {
                                            let trimmed = value.trimmingCharacters(in: .whitespaces)
                                                var filtered = ""

                                                var dotAdded = false
                                                for char in trimmed {
                                                    if char.isNumber {
                                                        filtered.append(char)
                                                    } else if char == "." && !dotAdded {
                                                        filtered.append(char)
                                                        dotAdded = true
                                                    }
                                                    // ignore extra dots
                                                }

                                                // Limit to 2 decimals if dot exists
                                                if let dotIndex = filtered.firstIndex(of: ".") {
                                                    let decimals = filtered.suffix(from: filtered.index(after: dotIndex))
                                                    if decimals.count > 2 {
                                                        filtered = String(filtered.prefix(filtered.distance(from: filtered.startIndex, to: dotIndex) + 3))
                                                    }
                                                }

                                                text = filtered
                                                self.enteredText?(text)
                                        }else{
                                            filtered = String(filtered.prefix(maxDigits))
                                            self.enteredText?(value)
                                        }
                                        
                                        
                                        
                                    })
                                    .onSubmit {
                                        self.enteredText?(text)
                                    }
                                    .ignoresSafeArea(.keyboard, edges: .bottom)
                            }
                        }
                        
                        Spacer()
                    }
                    .frame(/*width: width,*/height: height)
                    .padding(.all, 6)
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.white)
    //                        .fill(.text.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(.mediumLightGray, lineWidth: 1)
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
                                .frame(width: 32, height: 20)
                                .foregroundStyle(.black.opacity(0.5))
                                .clipShape(Circle())
                                .padding(.trailing)
                        })
                    }
                }
            })
        }.onTapGesture {
            isFocused = true
        }
        .onDisappear {
            isFocused = false
        }
        .padding([.leading,.trailing],Leading)
    }
    
    
}

#Preview {
    AuthTextField(icon: .gradCap, text: .constant(""))
}
