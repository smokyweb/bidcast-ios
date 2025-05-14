//
//  DropDownTextField.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 29/01/24.
//

import SwiftUI

struct DropDownTextField: View {
    
        //MARK: Variables Initialized
    var hint: String = ""
    var floatingLabel: String = ""
    @Binding var text: String
    @Binding var options: [String]
    
    @State var selected: String = ""
    @State var showOption: Bool = false
    @State var isRequired: Bool = false
    @State var isMandatory: Bool = false
    @State var leadingIcon: ImageResource = .userDummy
    @State var showCancel: Bool = false
    @State var showLeadingIcon: Bool = false
    @State var showTrailingIcon: Bool = true
    @State var showDropDownIcon: Bool = false
    
    @FocusState var isFocused: Bool
    
        //MARK: - Callback Initializer's
    var onOptionSelected: ((String) -> Void)?
    var onCancelClicked: ((String) -> Void)?
    var isRequiredValues: ((Int) -> Void)?
    
        //MARK: - Static Variable Initializer
    var maxWidth: CGFloat = screenWidth - 30
    var cornerRadius: CGFloat = 25
    var anchor: Anchor = .bottom
    
    @State var filterOptions: [String] = []
    
    @Environment(\.colorScheme) private var scheme
    @SceneStorage("drop_down_zindex") private var index = 1000.0
    @State var zIndex = 1200.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
                Text(floatingLabel)
                    .font(.custom(nunitoBold, fixedSize: 15))
                    .bold()
                    .foregroundStyle(.text)
                
            
                GeometryReader {
                    let size = $0.size
                    VStack(spacing: 0, content: {
                        
                            //MARK: - DropDown
                        if isFocused && anchor == .top {
                            optionView().background(.white)
                        }
                        
                        HStack(spacing: 0, content: {
                            
                            if showLeadingIcon {
                                Image(leadingIcon)
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.text.opacity(0.45))
                                    .padding(.all, 10)
                                    .background(.text.opacity(0.1))
                                    .clipShape(Circle())
                                    .padding(.trailing, 10)
                                
                            }
                            
                                //MARK: - Text Input field
                            TextField(hint, text: $text)
                                .font(.custom(nunitoMedium, fixedSize: 16))
                                .foregroundStyle(.text)
                                .keyboardShortcut(.cancelAction)
                                .autocorrectionDisabled(true)
                                .autocapitalization(.none)
                                .foregroundStyle(.text)
                                .submitLabel(.next)
                                .keyboardType(.emailAddress)
                                .ignoresSafeArea(.keyboard, edges: .bottom)
                            
                                .accentColor(.text)
                                .focused($isFocused)
                                .onChange(of: text, perform: { value in
                                    self.onOptionSelected?(value)
                                        //                                selected = ""
                                })
                                .onSubmit {
                                    self.onOptionSelected?(text)
                                }
                            Spacer()
                            
                                //MARK: - Cancel Button
                            if showCancel && showTrailingIcon {
                                Button(action: { self.onCancelClicked?(text) }, label: {
                                    Image(systemName: "minus.circle.fill")
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 20, height: 20)
                                        .foregroundStyle(.red)
                                })
                            }
                            
                                //                        if showDropDownIcon {
                                //
                                //                            Image(.arrowForward)
                                //                                .renderingMode(.template)
                                //                                .resizable()
                                //                                .scaledToFill()
                                //                                .frame(width: 16, height: 16)
                                //                                .foregroundStyle(.text)
                                //                                .rotationEffect(.init(degrees: isFocused ? anchor == .top ? -90 : 90 : 0))
                                //                        }
                            
                            if showDropDownIcon {
                                Button(action: {
                                    withAnimation {
                                        showOption.toggle()
                                        isFocused.toggle()
                                    }
                                }) {
                                    Image(.arrowForward)
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 16, height: 16)
                                        .tint(.black)
                                        .rotationEffect(.degrees(showOption ? 180 : 0)) // Rotate icon when open
                                        .padding(.trailing, 10)
                                }
                            }
                        })
                        .padding(.horizontal, 8)
                        .frame(width: size.width, height: size.height)
                        .background(scheme == .dark ? .black : .white)
                        .contentShape(.rect)
                        .zIndex(10)
                        
                            //MARK: - DropDown
                        if isFocused && anchor == .bottom {
                            optionView().background(.white)
                        }
                    })
                    .clipped()
                    .background((scheme == .dark ? Color.black : Color.white))
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                    .shadow(color: .gray, radius: 1, x: 0, y: 0)
                    .frame(height: size.height, alignment: anchor == .top ? .bottom : .top)
                    .onChange(of: text) { value in
                        index += 1
                        zIndex = index
                        if text == "" {
                            withAnimation(.easeOut) {
                                showCancel = false
                                showOption = false
                            }
                        } else {
                            if selected == text {
                                withAnimation(.easeOut) { showOption = false }
                            } else if text != "" {
                                withAnimation(.easeOut) { showCancel = true }
                                if !options.contains(where: { $0 == text }) {
                                    withAnimation(.easeOut) { showOption = true }
                                }
                            } else {
                                withAnimation(.snappy) { showOption = true }
                            }
                        }
                        withAnimation(.easeInOut(duration: 0.25)) {
                            if (options.first(where: { $0 == text }) != nil) {
                                filterOptions = options
                            } else {
                                filterOptions = text == "" ? options : options.filter({ $0.lowercased().contains(text.lowercased()) })
                            }
                        }
                    }
                }
                .frame(width: maxWidth, height: 50)
                .zIndex(zIndex)
            if floatingLabel != "Select Location"{
                if isMandatory{
                    HStack{
                        
                        Button(action: {
                            isRequired.toggle()
                            if isRequired{
                                self.isRequiredValues?(1)
                            }else{
                                self.isRequiredValues?(0)
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
                    .padding(.leading,-0.5)
                }
            }
        
        }.onAppear {
            filterOptions = options
        }.onChange(of: options) { newValue in
            filterOptions = options
        }
    }
    
    @ViewBuilder
    func optionView() -> some View {
        VStack(spacing: 4) {
            ScrollView(showsIndicators: false) {
                ForEach(filterOptions, id: \.self) {
                    ind in
                    HStack(spacing: 0, content: {
                        Text(ind)
                            .lineLimit(1)
                            .font(.custom(nunitoMedium, fixedSize: 16))
                        Spacer()
                        Image(systemName: "checkmark")
                            .opacity(selected == ind ? 1 : 0)
                    })
                    .frame(height: 40)
                    .foregroundStyle(selected == ind ? Color.primary : Color.gray)
                    .animation(.easeIn, value: selected)
                    .contentShape(.rect)
                    .onTapGesture {
                        withAnimation(.snappy) {
                            selected = ind
                            showOption = false
                            isFocused = false
                            text = selected
                            self.onOptionSelected?(selected)
                        }
                    }
                }
            }
        }
        .frame(height: filterOptions.count > 3 ? 180 : CGFloat(filterOptions.count) * 42)
        .padding(.horizontal)
        .transition(.move(edge: anchor == .top ? .bottom : .top))
        .background(.white)
    }
    
    enum Anchor {
        case top
        case bottom
    }
}

#Preview {
    DropDownTextField(text: .constant(String()), options: .constant([]))
        .preferredColorScheme(.light)
}
