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
     var custPlaceHolderName : String = poppinsMedium
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
                            .font(.custom(poppinsMedium, fixedSize: placeHolder))
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
                                        if let number = Double(value) {
                                            
                                            text = String(format: "%.2f", number)
                                        } else {
                                           
                                            var filteredText = value.filter { $0.isNumber }

                                           
                                            while filteredText.count > 1 && filteredText.first == "0" {
                                                filteredText.removeFirst()
                                            }

                                            if filteredText.isEmpty {
                                                text = "0.00"
                                            } else if filteredText.count == 1 {
                                                text = "0.0" + filteredText
                                            } else if filteredText.count == 2 {
                                                text = "0." + filteredText
                                            } else {
                                                let integerPart = String(filteredText.dropLast(2))
                                                let decimalPart = String(filteredText.suffix(2))
                                                text = "\(integerPart).\(decimalPart)"
                                            }
                                        }
                                        
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
