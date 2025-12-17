//
//  ShowNotesSheet.swift
//  BidCast
//
//  Created by JamTech on 17/12/25.
//

import SwiftUI

struct ShowNotesSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding private var noteText: String = ""
    @FocusState private var isTextEditorFocused: Bool
    
    var onPost: ((String) -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Show Notes")
                    .font(.custom(poppinsBold, size: 18))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    dismiss()
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
            TextEditor(text: $noteText)
                .font(.custom(poppinsRegular, size: 15))
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .focused($isTextEditorFocused)
                .scrollContentBackground(.hidden)
                .background(Color(.systemBackground))
            
            Spacer()
            
            // Post Button
            Button(action: {
                if !noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    onPost?(noteText)
                }
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
                                        noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                            ? Color.gray
                                            : Color.defaultTheme,
                                        noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                            ? Color.gray.opacity(0.8)
                                            : Color.defaultTheme.opacity(0.85)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(
                        color: noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                            ? Color.clear
                            : Color.defaultTheme.opacity(0.3),
                        radius: 12,
                        x: 0,
                        y: 4
                    )
            }
            .disabled(noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
            .padding(.top, 16)
        }
        .background(Color(.systemBackground))
        .onAppear {
            // Auto-focus text editor when sheet appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextEditorFocused = true
            }
        }
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
#Preview {
    ShowNotesSheet(
        onPost: { note in
            print("Posted note: \(note)")
        }
    )
}
