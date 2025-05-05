//
//  MultiSelectionDropDownTextField.swift
//  imperium
//
//  Created by JAM-E-221 on 23/01/25.
//

import SwiftUI

struct MultiSelectionDropDownTextField: View {

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
@State private var textFieldValue: String = ""
@State private var isDropdownExpanded: Bool = false
@State private var selectedItems: Set<String> = []
@FocusState var isFocused: Bool
    

    //MARK: - Callback Initializer's
var onOptionSelected: ((String) -> Void)?
var onCancelClicked: ((String) -> Void)?
var isRequiredValues: ((Int) -> Void)?

    //MARK: - Static Variable Initializer
var maxWidth: CGFloat = screenWidth - 30
var cornerRadius: CGFloat = 25
//var anchor: Anchor = .bottom

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
              VStack(alignment: .leading, spacing: 5) {
                  
                  // TextField with a dropdown icon
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
                      TextField(hint, text: $textFieldValue)
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
                          .frame(height: 50 )
                          .onTapGesture {
                              withAnimation {
                                  isDropdownExpanded.toggle()
                              }
                          }
                      
                  })
                  .padding(.horizontal, 8)
                  .background(scheme == .dark ? .black : .white)
                  .contentShape(.rect)
                  .zIndex(10)
                  .overlay(
                    HStack {
                        Spacer()
                        Image(systemName: isDropdownExpanded ? "chevron.up" : "chevron.down")
                            .padding(.trailing, 8)
                    }
                  )
                  
                  
                  
                  // Dropdown list
                  if isDropdownExpanded {
                      ScrollView {
                          VStack {
                              ForEach(options, id: \.self) { option in
                                  HStack {
                                      Text(option)
                                      Spacer()
                                      if selectedItems.contains(option) {
                                          Image(systemName: "checkmark.square.fill")
                                              .foregroundColor(.black)
                                      }
                                  }
                                  .frame(height: 40)
                                  .foregroundStyle(selected == option ? Color.primary : Color.gray)
                                  .animation(.easeIn, value: selected)
                                  .contentShape(.rect)
                                  .padding(.horizontal)
                                  .background(Color.white)
                                  .cornerRadius(8)
                                  .font(.custom(nunitoMedium, fixedSize: 16))
                                  .onTapGesture {
                                      // Toggle selection
                                      if selectedItems.contains(option) {
                                          selectedItems.remove(option)
                                      } else {
                                          selectedItems.insert(option)
                                      }
                                      
                                      // Update the TextField value
                                      textFieldValue = selectedItems.joined(separator: ", ")
                                  }
                              }
                          }
                          .padding()
                          .background(Color.white)
                          .cornerRadius(8)
                      }
                      .frame(maxHeight: 200)
                  }
              }
              .clipped()
              .background((scheme == .dark ? Color.black : Color.white))
              .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
              .shadow(color: .gray, radius: 1, x: 0, y: 0)
              //          .frame(height: size.height, alignment: .)
              .padding(-2)
              }

      }
  }

#Preview {
    MultiSelectionDropDownTextField(text: .constant(String()), options: .constant([]))
        .preferredColorScheme(.light)
}
