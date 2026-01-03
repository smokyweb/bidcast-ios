//
//  ShowNotesSheet.swift
//  BidCast
//
//  Created by JamTech on 17/12/25.
//

import SwiftUI

struct ShowNotesSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var noteText: String 
    @FocusState private var isTextEditorFocused: Bool
    
    @State var attributedText = NSAttributedString(string: "")
    @State private var isBold = false
    @State private var isItalic = false
    @State private var isUnderline = false
    @State private var isStrikethrough = false
    @State private var isBullet = false
    @State private var isNumbered = false
    
    @Binding var forHost : Bool
    
    @State private var textViewRef: UITextView?
    var onPost: ((String) -> Void)?
    var didTapCancel : () -> () = { }
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Show Notes")
                    .font(.custom(poppinsBold, size: 18))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    didTapCancel()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color(.systemGray6))
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            Divider()
            
            // Text Editor
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    formattingButton("B", isBold) {
                        isBold.toggle()
                        textViewRef?.applyCurrentStylesImmediately()
                    }
                    .bold()
                    formattingButton("I", isItalic) {
                        isItalic.toggle()
                        textViewRef?.applyCurrentStylesImmediately()
                    }
                    .italic()
                    formattingButton("U", isUnderline) {
                        isUnderline.toggle()
                        textViewRef?.applyCurrentStylesImmediately()
                    }
                    formattingButton("S", isStrikethrough) {
                        isStrikethrough.toggle()
                        textViewRef?.applyCurrentStylesImmediately()
                    }
                    
                    Divider().frame(height: 30)
                    
                    formattingButton("•", isBullet) {
                        toggleBullet()
                        textViewRef?.applyCurrentStylesImmediately()
                    }
                    formattingButton("1.", isNumbered) {
                        toggleNumbered()
                        textViewRef?.applyCurrentStylesImmediately()
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            }
            .frame(height: 50)
            
            Divider()
            
            // Editor
            RichTextView(
                attributedText: $attributedText,
                isBold: $isBold,
                isItalic: $isItalic,
                isUnderline: $isUnderline,
                isStrikethrough: $isStrikethrough,
                isBullet: $isBullet,
                isNumbered: $isNumbered,
                textViewRef: $textViewRef
            )
            .padding()
            .background(Color.white)
            
            Spacer()
            
            // Post Button
            if forHost{
                Button(role: nil, action: {
                    onPost?(attributedText.string.trimmingCharacters(in: .whitespacesAndNewlines))
                }) {
                    Text("Post")
                        .font(.custom(poppinsSemiBold, size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 28)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            attributedText.plainTextTrimmed.isEmpty
                                            ? Color.gray
                                            : Color.defaultTheme,
                                            attributedText.plainTextTrimmed.isEmpty
                                            ? Color.gray.opacity(0.8)
                                            : Color.defaultThemeLight
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .shadow(
                            color: attributedText.plainTextTrimmed.isEmpty
                            ? Color.clear
                            : Color.defaultThemeLight,
                            radius: 12,
                            x: 0,
                            y: 4
                        )
                }
                .disabled(attributedText.plainTextTrimmed.isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
                .padding(.top, 16)
            }
        }
        .background(Color(.systemBackground))
        .onAppear {
            // Auto-focus text editor when sheet appears
            attributedText = NSAttributedString(string: noteText)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextEditorFocused = false
            }
        }
    }
    private func formattingButton(_ title: String, _ active: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .frame(width: 36, height: 36)
                .background(active ? Color.defaultTheme : Color.clear)
                .foregroundColor(active ? .white : .black)
                .cornerRadius(6)
                .animation(.easeInOut, value: active)
        }
    }

    private func toggleBullet() {
        isBullet.toggle()
        if isBullet { isNumbered = false }
    }

    private func toggleNumbered() {
        isNumbered.toggle()
        if isNumbered { isBullet = false }
    }
}
extension NSAttributedString {
    var plainTextTrimmed: String {
        string.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

//// MARK: - Usage Example
//struct ContentView_ShowNotes: View {
//    @State private var showNotesSheet = false
//    @State private var savedNotes: [String] = []
//    
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 16) {
//                Button("Add Show Note") {
//                    showNotesSheet = true
//                }
//                .buttonStyle(.borderedProminent)
//                
//                List(savedNotes, id: \.self) { note in
//                    Text(note)
//                        .font(.custom(poppinsRegular, size: 14))
//                }
//            }
//            .navigationTitle("Show Notes")
//        }
//        .sheet(isPresented: $showNotesSheet) {
//            ShowNotesSheet(
//                onPost: { note in
//                    savedNotes.append(note)
//                    print("Posted note: \(note)")
//                }
//            )
//            .presentationDetents([.large])
//            .presentationDragIndicator(.visible)
//        }
//    }
//}
//#Preview {
//    ShowNotesSheet(
//        onPost: { note in
//            print("Posted note: \(note)")
//        }
//    )
//}
