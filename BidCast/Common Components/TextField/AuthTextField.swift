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
                                        // Basecamp #9940184831 (2026-05-29 RETURN): gate the dollar-
                                        // normalisation on synchronous prefill. onAppear only fires
                                        // once so it handles values that were already set before the
                                        // view appeared (sync prefill). Async prefill (value arrives
                                        // after onAppear) is handled by the isFocused-gated onChange.
                                        if isForPrice && !text.isEmpty {
                                            if let dollars = Double(text) {
                                                let normalized = String(format: "%.2f", dollars)
                                                rawPriceDigits = normalized.filter { $0.isNumber }
                                                if text != normalized {
                                                    text = normalized
                                                    self.enteredText?(text)
                                                }
                                            }
                                        }
                                    }
                                    .onChange(of: text, perform: { value in
                                        // Basecamp #9940184831 (2026-05-29 RETURN): root-cause fix.
                                        //
                                        // The PREVIOUS fix (round 1) put the dollar-normalisation in
                                        // onAppear. That only helped when text was already set at view
                                        // creation time. When the product is fetched asynchronously
                                        // (common path), onAppear fires while text is still empty, then
                                        // `request.pricing` is set later → onChange fires. The old
                                        // onChange ALWAYS ran the cents-accumulation formatter
                                        // (strip decimal, treat all digits as cents) regardless of
                                        // whether the field was focused. So "50.0" became "500" → "5.00".
                                        //
                                        // FIX: gate the cents-accumulation formatter on isFocused.
                                        // • !isFocused  → programmatic write (async/sync prefill).
                                        //                  Interpret value as dollars, normalise %.2f.
                                        // • isFocused   → user is actively typing. Run cent-accumulation.
                                        if isForPrice {
                                            if !isFocused {
                                                // Programmatic prefill — value is a dollar amount.
                                                // Normalise without rescaling.
                                                if let dollars = Double(value) {
                                                    let normalized = String(format: "%.2f", dollars)
                                                    rawPriceDigits = normalized.filter { $0.isNumber }
                                                    if text != normalized {
                                                        text = normalized
                                                        self.enteredText?(text)
                                                    }
                                                }
                                                // If Double(value) fails (e.g. empty string), leave it.
                                                return
                                            }
                                            // isFocused == true → user is typing → cent-accumulation.
                                            let newFiltered = value.filter { $0.isNumber }
                                            if newFiltered != rawPriceDigits {
                                                rawPriceDigits = newFiltered
                                                var digitsToFormat = rawPriceDigits
                                                while digitsToFormat.count > 1 && digitsToFormat.first == "0" {
                                                    digitsToFormat.removeFirst()
                                                }
                                                let formattedText: String
                                                if digitsToFormat.isEmpty {
                                                    formattedText = ""
                                                } else if digitsToFormat.count == 1 {
                                                    formattedText = "0.0\(digitsToFormat)"
                                                } else if digitsToFormat.count == 2 {
                                                    formattedText = "0.\(digitsToFormat)"
                                                } else {
                                                    let idx = digitsToFormat.index(digitsToFormat.endIndex, offsetBy: -2)
                                                    let beforeDecimal = digitsToFormat[..<idx]
                                                    let afterDecimal = digitsToFormat[idx...]
                                                    formattedText = "\(beforeDecimal).\(afterDecimal)"
                                                }
                                                if text != formattedText {
                                                    text = formattedText
                                                    self.enteredText?(text)
                                                }
                                            }
                                            return
                                        }
                                        // Non-price field handling (CVV / expiry / card number / plain)
                                        var filtered = value.filter { $0.isNumber }
                                        if isForCVV {
                                            filtered = String(filtered.prefix(3))
                                            text = filtered
                                            self.enteredText?(text)
                                        } else if isForExpiry {
                                            // MC cmpaj2fex0000w5hgq64jp9k4 (2026-05-24):
                                            // Format expiry as MM/YY (industry-standard
                                            // credit-card display). User types 4 digits
                                            // (MMYY); we insert the slash after the 2nd.
                                            // Was: YYYYMM → YYYY-MM which was inconsistent
                                            // with the card preview that already showed MM/YY.
                                            filtered = String(filtered.prefix(4)) // MMYY
                                            if filtered.count >= 3 {
                                                let month = filtered.prefix(2)
                                                let year = filtered.suffix(filtered.count - 2)
                                                filtered = "\(month)/\(year)"
                                            }
                                            text = filtered
                                            self.enteredText?(text)
                                        } else if isForCardNumber {
                                            filtered = String(filtered.prefix(16))
                                            var formatted = ""
                                            for (_, char) in filtered.enumerated() {
                                                formatted.append(char)
                                            }
                                            text = formatted
                                            self.enteredText?(text)
                                        } else {
                                            filtered = String(filtered.prefix(maxDigits))
                                            self.enteredText?(value)
                                        }
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
