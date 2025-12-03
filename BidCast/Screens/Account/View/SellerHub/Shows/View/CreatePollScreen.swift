//
//  CreatePollScreen.swift
//  BidCast
//
//  Created by JamTech on 14/11/25.
//

import SwiftUI

struct CreatePollScreen: View {
    
    @Binding var isPresented: Bool
    var onCreatePoll: ((PollModel) -> Void)?
    
    @State private var pollQuestion: String = ""
    @State private var options: [String] = [""]
    @State private var selectedDuration: String = "5 minutes"
    var roomId: String = ""
    
    @State var durations = ["1 minute", "3 minutes", "5 minutes", "10 minutes", "15 minutes", "30 minutes"]
    
    // --- Convert duration into seconds ---
    private func durationToSeconds(_ str: String) -> String {
        if str.contains("1 minute") { return "01:00" }
        if str.contains("3 minutes") { return "03:00" }
        if str.contains("5 minutes") { return "05:00" }
        if str.contains("10 minutes") { return "10:00" }
        if str.contains("15 minutes") { return "15:00" }
        if str.contains("30 minutes") { return "30:00" }
        return "05:00"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            // MARK: Header
            HStack {
                Text("Create Poll")
                    .font(.custom(poppinsBold, size: 22))
                
                Spacer()
                
                Button(action: {
                    hideKeyboard()
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            Text("Engage your audience by creating a poll. Ask a question and let viewers vote!")
                .font(.custom(poppinsRegular, size: 14))
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            // MARK: Poll Question
            AuthTextField(
                floatingLabel: "Poll Question",
                placeholder: "Enter your poll question here",
                icon: .menuProfile,
                text: $pollQuestion,
                isIconDisplay: false,
                custFontName: robotoMedium,
                custFontSize: 14
            )
            .padding(.horizontal)
            .padding(.bottom, 12)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 14) {
                    
                    // MARK: Poll Options Header
                    HStack {
                        Text("Poll Options")
                            .font(.custom(poppinsSemiBold, size: 14))
                        
                        Spacer()
                        
                        Button(action: {
                            options.append("")
                        }) {
                            Text("+ Add")
                                .font(.custom(poppinsSemiBold, size: 14))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    // MARK: Option Inputs
                    ForEach(options.indices, id: \.self) { index in
                        AuthTextField(
                            floatingLabel: "Option \(index + 1)",
                            placeholder: "Enter option",
                            icon: .menuProfile,
                            text: $options[index],
                            isIconDisplay: false,
                            custFontName: robotoMedium,
                            custFontSize: 14
                        )
                        .padding(.horizontal)
                    }
                    
                    
                    // MARK: Duration Dropdown
                    DropDownSelection(
                        options: $durations,
                        floatingLabel: "Poll Duration",
                        hint: selectedDuration,
                        selected: $selectedDuration,
                        anchor: .bottom,
                        custFontName: robotoMedium,
                        custFontSize: 14,
                        custCategory: robotoRegular,
                        custCategorySize: 13,
                        onOptionSelected: { value in
                            selectedDuration = value
                        }
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            
            // MARK: Create Poll Button
            Button(action: {
                hideKeyboard()
                createPoll()
                
            }) {
                Text("Create Poll")
                    .font(.custom(poppinsSemiBold, size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .onTapGesture { hideKeyboard() }
    }
    
    // MARK: Create Poll Model
    private func createPoll() {
        
        // 🔐 Validation
        guard !pollQuestion.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        let cleanOptions = options
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        guard cleanOptions.count >= 1 else { return }
        
        // 🔥 Prepare PollOption list
        let pollOptions = cleanOptions.map { text in
            PollOption(text: text, voteCount: 0, percentage: 0)
        }
        
        let poll = PollModel(
            pollId: generateNextPollId(),
            roomId: roomId,
            question: pollQuestion,
            options: pollOptions,
            totalVotes: 0,
            remainingTime: durationToSeconds(selectedDuration),
            isActive: true
        )
        
        // Send Poll Upward
        onCreatePoll?(poll)
        
        // Close Sheet
        isPresented = false
    }
    
    // MARK: Keyboard Helper
    private func hideKeyboard() {
         UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
     }
 }

//
//struct CreatePollScreen: View {
//    
//    @Binding var isPresented: Bool
//    @State private var pollQuestion: String = ""
//    @State private var options: [String] = [""]
//    @State private var selectedDuration: String = "5 minutes"
//    
//    @State var durations = ["1 minute", "3 minutes", "5 minutes", "10 minutes"]
//    @FocusState private var focusedField: Field?
//    
//    enum Field: Hashable {
//        case question
//        case option(Int)
//    }
//    
//    var body: some View {
//        GeometryReader { geometry in
//            VStack(alignment: .leading, spacing: 20) {
//                
//                // MARK: - Header (Fixed at top)
//                HStack {
//                    Text("Create Poll")
//                        .font(.custom(poppinsBold, size: 22.0))
//                    Spacer()
//                    
//                    Button(action: {
//                        hideKeyboard()
//                        isPresented.toggle()
//                    }) {
//                        Image(systemName: "xmark")
//                            .font(.custom(poppinsBold, size: 18.0))
//                            .foregroundColor(.black)
//                    }
//                }
//                .padding(.horizontal)
//                .padding(.top, 16)
//                
//                Text("Engage your audience by creating a poll. Ask a question and let viewers vote!")
//                    .font(.custom(poppinsRegular, size: 14.0))
//                    .foregroundColor(.gray)
//                    .padding(.horizontal)
//                
//                // MARK: - Scrollable Content
//                ScrollView(showsIndicators: false) {
//                    VStack(alignment: .leading, spacing: 12) {
//                        
//                        // MARK: - Poll Question
//                        PollTextField(floatingLabel: "Poll Question".localized,
//                                      placeholder: "Enter your poll question here".localized,
//                                      text: $pollQuestion,
//                                      custFontName : robotoMedium,
//                                      custFontSize : 14.0,
//                                      enteredText:  { quantity in
//                            pollQuestion = quantity
//                        })
//                        .keyboardType(.default)
//                        .padding(.bottom, 12)
//                        
//                        // MARK: - Poll Options Header
//                        HStack {
//                            Text("Poll Options")
//                                .font(.custom(poppinsSemiBold, size: 14.0))
//                            
//                            Spacer()
//                            
//                            Button(action: {
//                                hideKeyboard()
//                                options.append("")
//                            }) {
//                                Text("+ Add")
//                                    .font(.custom(poppinsSemiBold, size: 14.0))
//                                    .foregroundColor(.white)
//                                    .padding(.horizontal, 16)
//                                    .padding(.vertical, 8)
//                                    .background(Color.blue)
//                                    .cornerRadius(8)
//                            }
//                        }
//                        .padding(.horizontal, 12)
//                        
//                        // MARK: - Options List
//                        ForEach(options.indices, id: \.self) { index in
//                            VStack(alignment: .leading, spacing: 4) {
//                                PollTextField(floatingLabel: "Option \(index + 1)".localized,
//                                              placeholder: "Enter option \(index + 1)",
//                                              text: $options[index],
//                                              custFontName : robotoMedium,
//                                              custFontSize : 14.0,
//                                              enteredText:  { quantity in
//                                    options[index] = quantity
//                                })
//                                .keyboardType(.default)
//                                .padding(.bottom, 12)
//                            }
//                        }
//                        
//                        // MARK: - Poll Duration
//                        DropDownSelection(
//                            options: $durations,
//                            floatingLabel: "Poll Duration",
//                            hint: selectedDuration,
//                            selected: $selectedDuration,
//                            anchor: .bottom,
//                            custFontName: robotoMedium,
//                            custFontSize: 14.0,
//                            custCategory: robotoRegular,
//                            custCategorySize: 13.0,
//                            onOptionSelected: { value in
//                                selectedDuration = value
//                            }
//                        )
//                        .padding([.leading, .trailing], 16)
//                        .padding(.bottom, 20)
//                        
//                        // MARK: - Create Poll Button
//                        Button(action: {
//                            hideKeyboard()
//                            print("Poll Created")
//                        }) {
//                            Text("Create Poll")
//                                .font(.custom(poppinsSemiBold, size: 16.0))
//                                .foregroundColor(.white)
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .background(Color.blue)
//                                .cornerRadius(12)
//                        }
//                        .padding(.horizontal)
//                        .padding(.bottom, 20)
//                    }
//                }
//            }
//            .frame(width: geometry.size.width, height: geometry.size.height)
//            .padding(.top)
//            .background(Color.white)
//            .cornerRadius(20)
//            .ignoresSafeArea(edges: .bottom)
//        }
//        .onTapGesture {
//            hideKeyboard()
//        }
//    }
//    
//    private func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//}
//
//
//struct PollTextField: View {
//    var floatingLabel: String
//    var placeholder: String
//    @Binding var text: String
//    var custFontName: String
//    var custFontSize: Double
//    var enteredText: ((String) -> Void)?
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            if floatingLabel != "" {
//                Text(floatingLabel)
//                    .font(.custom(custFontName, fixedSize: custFontSize))
//                    .foregroundStyle(.text)
//            }
//            
//            TextField(placeholder, text: $text)
//                .font(.custom(robotoRegular, fixedSize: 14.0))
//                .autocorrectionDisabled(true)
//                .foregroundStyle(.text)
//                .submitLabel(.next)
//                .frame(height: 40)
//                .padding(.horizontal, 12)
//                .background(
//                    RoundedRectangle(cornerRadius: 8)
//                        .fill(.white)
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 8)
//                                .stroke(.mediumLightGray, lineWidth: 1)
//                        )
//                        .shadow(color: .ultraLightGray, radius: 1)
//                )
//                .onChange(of: text) { value in
//                    enteredText?(value)
//                }
//        }
//        .padding([.leading, .trailing], 16)
//    }
//}

func generateNextPollId() -> Int {
    let current = UserDefaults.standard.integer(forKey: "last_poll_id")
    let next = current + 1
    UserDefaults.standard.set(next, forKey: "last_poll_id")
    return next
}
