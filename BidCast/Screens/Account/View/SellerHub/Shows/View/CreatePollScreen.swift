//
//  CreatePollScreen.swift
//  BidCast
//
//  Created by JamTech on 14/11/25.
//

import SwiftUI

import SwiftUI

struct CreatePollScreen: View {
    
    @Binding var isPresented: Bool
    @State private var pollQuestion: String = ""
    @State private var options: [String] = [""]
    @State private var selectedDuration: String = "5 minutes"
    
    @State var durations = ["1 minute", "3 minutes", "5 minutes", "10 minutes"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // MARK: - Header
            HStack {
                Text("Create Poll")
                    .font(.system(size: 24, weight: .bold))
                
                Spacer()
                
                Button(action: { isPresented }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            
            Text("Engage your audience by creating a poll. Ask a question and let viewers vote!")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .padding(.bottom, 4)
            
            // MARK: - Poll Question
            VStack(alignment: .leading, spacing: 6) {
                AuthTextField(floatingLabel: "Poll Question".localized,
                              placeholder: "Enter your poll question here".localized,
                              icon: .menuProfile,
                              text: $pollQuestion,
                              isIconDisplay : false,
                              custFontName : robotoMedium,
                              custFontSize : 14.0,
                              enteredText:  { quantity in
                        pollQuestion = quantity
                })
                .keyboardType(.default)
                .padding([.bottom],12)
            }
            
            // MARK: - Poll Options
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Poll Options")
                        .font(.system(size: 14, weight: .semibold))
                    
                    Spacer()
                    
                    Button(action: {
                        options.append("")
                    }) {
                        Text("+ Add")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                
                ForEach(options.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 4) {
                        AuthTextField(floatingLabel: "Option \(index + 1)".localized,
                                      placeholder: "Enter option \(index + 1)",
                                      icon: .menuProfile,
                                      text: $options[index],
                                      isIconDisplay : false,
                                      custFontName : robotoMedium,
                                      custFontSize : 14.0,
                                      enteredText:  { quantity in
                                options[index] = quantity
                        })
                        .keyboardType(.default)
                        .padding([.bottom],12)
                    }
                }
            }
            
            // MARK: - Poll Duration
            VStack(alignment: .leading, spacing: 6) {
//                Text("Poll Duration")
//                    .font(.system(size: 14, weight: .semibold))
//                
//                NavigationLink(destination: DurationSelectionView(selected: $selectedDuration, durations: durations)) {
//                    HStack {
//                        Text(selectedDuration)
//                            .foregroundColor(.black)
//                        
//                        Spacer()
//                        
//                        Image(systemName: "chevron.right")
//                            .foregroundColor(.gray)
//                    }
//                    .padding()
//                    .background(Color(.systemGray6))
//                    .cornerRadius(10)
//                }
//                
                DropDownSelection(
                    options: $durations, floatingLabel:"Poll Duration",
                    hint: selectedDuration,
                    selected: $selectedDuration,
                    anchor: .bottom,
                    custFontName: robotoMedium,
                    custFontSize:  14.0,
                    custCategory : robotoRegular,
                    custCategorySize : 13.0,
                    onOptionSelected: { value in
                        selectedDuration = value
                    }
                )
                .padding([.leading,.trailing],16)

            }
            
            Spacer()
            
            // MARK: - Create Poll Button
            Button(action: {
                print("Poll Created")
            }) {
                Text("Create Poll")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .ignoresSafeArea(.keyboard)
    }
}

//#Preview {
////    CreatePollScreen()/
//}
