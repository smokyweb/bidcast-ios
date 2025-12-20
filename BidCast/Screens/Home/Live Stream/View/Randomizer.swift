//
//  Randomizer.swift
//  BidCast
//
//  Created by JamTech on 20/12/25.
//

import SwiftUI
//
//import SwiftUI
//
//// MARK: - Randomizer Screen
//struct RandomizerScreen: View {
//    @Environment(\.presentationMode) var presentationMode
//    
//    @State private var manualEntries: [String] = ["Option 1", "Option 2", "Option3"]
//    @State private var isSpinwheelHidden = false
//    @State private var newEntry = ""
//    @FocusState private var isTextFieldFocused: Bool
//    
//    var body: some View {
//        ZStack {
//            Color.black.ignoresSafeArea()
//            
//            VStack(spacing: 0) {
//                // Header
//                headerView
//                
//                // Content
//                ScrollView(showsIndicators: false) {
//                    VStack(spacing: 24) {
//                        randomizerSection
//                        optionsSection
//                    }
//                    .padding(.horizontal, 16)
//                    .padding(.vertical, 20)
//                }
//            }
//        }
//        .navigationBarHidden(true)
//    }
//    
//    // MARK: - Header
//    private var headerView: some View {
//        HStack {
//            Button(action: {
//                presentationMode.wrappedValue.dismiss()
//            }) {
//                Image(systemName: "chevron.left")
//                    .font(.system(size: 20, weight: .semibold))
//                    .foregroundColor(.white)
//            }
//            
//            Spacer()
//            
//            Text("Randomizer")
//                .font(.custom(poppinsBold, size: 20))
//                .foregroundColor(.white)
//            
//            Spacer()
//            
//            // Placeholder for symmetry
//            Image(systemName: "chevron.left")
//                .font(.system(size: 20))
//                .opacity(0)
//        }
//        .padding(.horizontal, 20)
//        .padding(.vertical, 16)
//    }
//    
//    // MARK: - Randomizer Section
//    private var randomizerSection: some View {
//        VStack(spacing: 12) {
//            Text("Randomizer")
//                .font(.custom(poppinsBold, size: 18))
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity, alignment: .leading)
//            
//            HStack(spacing: 12) {
//                ActionView(
//                    title: "Hide spinwheel",
//                    isSelected: isSpinwheelHidden
//                ) {
//                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//                        isSpinwheelHidden.toggle()
//                    }
//                }
//                
//                ActionView(
//                    title: "Shuffle entries",
//                    isSelected: false
//                ) {
//                    shuffleEntries()
//                }
//                
//                ActionView(
//                    title: "Spin wheel",
//                    isSelected: false
//                ) {
//                    spinWheel()
//                }
//            }
//        }
//    }
//    
//    // MARK: - Options Section
//    private var optionsSection: some View {
//        VStack(spacing: 16) {
//            Text("Options")
//                .font(.custom(poppinsBold, size: 18))
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity, alignment: .leading)
//            
//            VStack(spacing: 12) {
//                manualEntryCard
//                removeAllButton
//            }
//        }
//    }
//    
//    // MARK: - Manual Entry Card
//    private var manualEntryCard: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            Text("Manual Entry")
//                .font(.custom(poppinsSemiBold, size: 16))
//                .foregroundColor(.white)
//            
//            VStack(spacing: 8) {
//                ForEach(Array(manualEntries.enumerated()), id: \.offset) { index, entry in
//                    ManualEntryRow(
//                        text: entry,
//                        isLast: index == manualEntries.count - 1,
//                        onRemove: {
//                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//                                manualEntries.remove(at: index)
//                            }
//                        }
//                    )
//                }
//                
//                addEntryField
//            }
//            .padding(16)
//            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white))
//            .overlay(
//                RoundedRectangle(cornerRadius: 16)
//                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
//            )
//        }
//        .padding(16)
//        .background(
//            RoundedRectangle(cornerRadius: 16)
//                .fill(Color.white.opacity(0.1))
//        )
//    }
//
//    
//    // MARK: - Remove All Button
//    private var removeAllButton: some View {
//        Button(action: {
//            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//                manualEntries.removeAll()
//            }
//        }) {
//            Text("Remove All")
//                .font(.custom(poppinsSemiBold, size: 16))
//                .foregroundColor(.white)
//                .frame(maxWidth: .infinity)
//                .frame(height: 54)
//                .background(
//                    RoundedRectangle(cornerRadius: 16)
//                        .fill(Color.white.opacity(0.15))
//                )
//                .overlay(
//                    RoundedRectangle(cornerRadius: 16)
//                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
//                )
//        }
//    }
//    
//    // MARK: - Actions
//    private func addNewEntry() {
//        guard !newEntry.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
//        
//        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//            manualEntries.append(newEntry)
//            newEntry = ""
//            isTextFieldFocused = false
//        }
//    }
//    
//    private func shuffleEntries() {
//        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//            manualEntries.shuffle()
//        }
//    }
//    
//    private func spinWheel() {
//        // Spin wheel logic
//        print("Spinning wheel...")
//    }
//}
//
//// MARK: - Action Button
//struct ActionView: View {
//    let title: String
//    let isSelected: Bool
//    let action: () -> Void
//    
//    @State private var isPressed = false
//    
//    var body: some View {
//        Button(action: {
//            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
//                action()
//            }
//        }) {
//            Text(title)
//                .font(.custom(poppinsMedium, size: 14))
//                .foregroundColor(.white)
//                .lineLimit(1)
//                .minimumScaleFactor(0.8)
//                .frame(maxWidth: .infinity)
//                .frame(height: 52)
//                .background(
//                    RoundedRectangle(cornerRadius: 16)
//                        .fill(isSelected ? Color.defaultTheme.opacity(0.3) : Color.white.opacity(0.15))
//                )
//                .overlay(
//                    RoundedRectangle(cornerRadius: 16)
//                        .stroke(
//                            isSelected ? Color.defaultTheme.opacity(0.5) : Color.white.opacity(0.3),
//                            lineWidth: isSelected ? 1.5 : 1
//                        )
//                )
//                .scaleEffect(isPressed ? 0.96 : 1.0)
//        }
//        .buttonStyle(PlainButtonStyle())
//        .simultaneousGesture(
//            DragGesture(minimumDistance: 0)
//                .onChanged { _ in
//                    withAnimation(.easeInOut(duration: 0.1)) {
//                        isPressed = true
//                    }
//                }
//                .onEnded { _ in
//                    withAnimation(.easeInOut(duration: 0.1)) {
//                        isPressed = false
//                    }
//                }
//        )
//    }
//}
//
//// MARK: - Preview
//struct RandomizerScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            RandomizerScreen()
//        }
//        .preferredColorScheme(.dark)
//    }
//}
