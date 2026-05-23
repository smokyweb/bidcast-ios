//
//  AuthTextField.swift
// BidSwipe
//
//  Created by JAM-E-282 on 18/01/24.
//

import SwiftUI

struct AuthTextField: View {
    
    enum FocusableField: Hashable {
      case field
    }
    
    @State var floatingLabel: String = ""
    @State private var rawPriceDigits: String = ""
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
    var cornerRadius : CGFloat = 32.0
    
     var isForCVV: Bool = false
     var isForExpiry: Bool = false
     var isForCardNumber: Bool = false
     var custFontName: String = poppinsBold
     var custFontSize: Double = 13.0
    var custPlaceHolderName : String = robotoRegular
     var custPlaceHolderFontSize : Double = placeHolder
    
    // New optional properties for keyboard navigation
    var submitLabel: SubmitLabel = .next
    var onSubmit: (() -> Void)?
    
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
                                .foregroundColor(.gray)
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
                                            .stroke(isFocused ? Color.defaultTheme.opacity(0.6) : .mediumLightGray, lineWidth: 1)
                                    )
                                    .shadow(color: .gray.opacity(0.5), radius: 1, x: 0, y: 0)
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
                                .submitLabel(submitLabel)
                                .accentColor(.text)
                                .focused($isFocused)
                                .onChange(of: text, perform: { value in
                                    self.enteredText?(value)
                                })
                                .onSubmit {
                                    if let onSubmit = onSubmit {
                                        onSubmit()
                                    } else {
                                        self.enteredText?(text)
                                    }
                                }
                                .ignoresSafeArea(.keyboard, edges: .bottom)
                        }
                        else {
                            HStack(spacing: 0) {
                                if isForPrice && (Double(text) ?? 0.0) > 0{
                                    Text("$")
                                        .font(.custom(custPlaceHolderName, fixedSize: custPlaceHolderFontSize))
                                        .foregroundStyle(.text)
                                        .padding(.leading, 4)
                                }
                                TextField(placeholder, text: $text)
                                
                                    .font(.custom(custPlaceHolderName, fixedSize: custPlaceHolderFontSize))
                                    .autocorrectionDisabled(true)
                                    .autocapitalization(.none)
//                                    .padding(.leading, isIconDisplay ? 16 : 8)
                                    .foregroundStyle(.text)
                                    .submitLabel(submitLabel)
                                    .accentColor(.text)
                                    .focused($isFocused)
                                    .frame(height: height)
                                    .onAppear {
                                        if isForPrice {
                                            // If text is a plain number without decimal (e.g., "43" from database)
                                            if !text.isEmpty && !text.contains(".") {
                                                // Initialize rawPriceDigits and format it
                                                rawPriceDigits = text.filter { $0.isNumber }
                                                
                                                var digitsToFormat = rawPriceDigits
                                                while digitsToFormat.count > 1 && digitsToFormat.first == "0" {
                                                    digitsToFormat.removeFirst()
                                                }
                                                
                                                if digitsToFormat.isEmpty {
                                                    text = ""
                                                } else if digitsToFormat.count == 1 {
                                                    text = "0.0\(digitsToFormat)"
                                                } else if digitsToFormat.count == 2 {
                                                    text = "0.\(digitsToFormat)"
                                                } else {
                                                    let index = digitsToFormat.index(digitsToFormat.endIndex, offsetBy: -2)
                                                    let beforeDecimal = digitsToFormat[..<index]
                                                    let afterDecimal = digitsToFormat[index...]
                                                    text = "\(beforeDecimal).\(afterDecimal)"
                                                }
                                                self.enteredText?(text)
                                            } else if !text.isEmpty {
                                                // Initialize rawPriceDigits from existing formatted text
                                                rawPriceDigits = text.filter { $0.isNumber }
                                            }
                                        }
                                    }
                                    .onChange(of: text, perform: { value in
                                        if isForPrice && !value.isEmpty && !value.contains(".") {
                                                   // Check if this looks like a plain number (not user typing)
                                                   let filtered = value.filter { $0.isNumber }
                                                   if filtered == value && value.count >= 1 {
                                                       text = value + ".00"
                                                       self.enteredText?(text)
                                                       return
                                                   }
                                               }
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
                                            let newFiltered = value.filter { $0.isNumber }
                                                   
                                                   // Only update if the filtered digits actually changed
                                                   // This prevents infinite loops and handles deletions properly
                                                   if newFiltered != rawPriceDigits {
                                                       rawPriceDigits = newFiltered
                                                       
                                                       // Remove leading zeros except if the number is just "0"
                                                       var digitsToFormat = rawPriceDigits
                                                       while digitsToFormat.count > 1 && digitsToFormat.first == "0" {
                                                           digitsToFormat.removeFirst()
                                                       }
                                                       
                                                       // Format with decimal point
                                                       let formattedText: String
                                                       if digitsToFormat.isEmpty {
                                                           formattedText = ""
                                                       } else if digitsToFormat.count == 1 {
                                                           formattedText = "0.0\(digitsToFormat)"
                                                       } else if digitsToFormat.count == 2 {
                                                           formattedText = "0.\(digitsToFormat)"
                                                       } else {
                                                           // Insert decimal point 2 places from the end
                                                           let index = digitsToFormat.index(digitsToFormat.endIndex, offsetBy: -2)
                                                           let beforeDecimal = digitsToFormat[..<index]
                                                           let afterDecimal = digitsToFormat[index...]
                                                           formattedText = "\(beforeDecimal).\(afterDecimal)"
                                                       }
                                                       
                                                       // Only update text if it actually changed to prevent recursion
                                                       if text != formattedText {
                                                           text = formattedText
                                                           self.enteredText?(text)
                                                       }
                                                   }
                                        }else{
                                            filtered = String(filtered.prefix(maxDigits))
                                            self.enteredText?(value)
                                        }
                                        
                                        
                                        
                                    } )
                                    .onSubmit {
                                        if let onSubmit = onSubmit {
                                            onSubmit()
                                        } else {
                                            self.enteredText?(text)
                                        }
                                    }
                                    .onAppear {
                                    if isForPrice {
                                        // Initialize rawPriceDigits from existing text
                                        rawPriceDigits = text.filter { $0.isNumber }
                                        
                                        // Format initial value if needed
                                        if !text.isEmpty && !text.contains(".") {
                                            text = text + ".00"
                                            self.enteredText?(text)
                                        }
                                    }
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
//                            .overlay(
//                                RoundedRectangle(cornerRadius: cornerRadius)
//                                    .stroke(.gray.opacity(0.5), lineWidth: 1)
//                            )
                            .shadow(color: .gray.opacity(0.7), radius: 1, x: 0, y: 0)
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

//#Preview {
//    AuthTextField(icon: .gradCap, text: .constant(""))
//}
