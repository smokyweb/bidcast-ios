import SwiftUI
//import FortuneWhee

// MARK: - Main Randomizer View
struct RandomizerView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = RandomizerViewModel()
    
    @State private var showSpinwheel = false
    @State private var isSpinning = false
    @State private var selectedWinner: String?
    @State private var showWinnerAnimation = false
    @State private var wheelKey = UUID() // Key to force wheel recreation
    
    var body: some View {
        ZStack {
            // Background dimmed view
            Color.clear
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    if !isSpinning {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                // Spinwheel overlay (conditionally shown)
                if showSpinwheel {
                    FortuneWheel(
                        titles: viewModel.options,
                        size: 320,
                        onSpinEnd: onSpinEnd,
                        getWheelItemIndex: getWheelItemIndex
                    )
                    .id(wheelKey) // This allows us to recreate the wheel
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(10)
                }
                
                Spacer()
                
                // Bottom control panel
                RandomizerControlPanel(
                    viewModel: viewModel,
                    showSpinwheel: $showSpinwheel,
                    isSpinning: $isSpinning,
                    selectedWinner: $selectedWinner,
                    showWinnerAnimation: $showWinnerAnimation,
                    spinWheelTapped: spinWheel
                )
            }
            
            // Winner announcement overlay
            if showWinnerAnimation, let winner = selectedWinner {
                WinnerAnnouncementView(winner: winner, isShowing: $showWinnerAnimation)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(20)
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showSpinwheel)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showWinnerAnimation)
    }
    
    private func onSpinEnd(index: Int) {
        // This is called when the wheel stops spinning
        guard index >= 0 && index < viewModel.options.count else { return }
        
        let winner = viewModel.options[index]
        selectedWinner = winner
        isSpinning = false
        
        // Show winner announcement after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
                showWinnerAnimation = true
            }
            
            // Auto-hide after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    showWinnerAnimation = false
                }
            }
        }
    }
    
    private func getWheelItemIndex() -> Int {
        // Return random index - the wheel will land on this option
        // You can modify this to return a specific index if needed
        return Int.random(in: 0..<viewModel.options.count)
    }
    
    private func spinWheel() {
        guard !viewModel.options.isEmpty, !isSpinning else { return }
        
        isSpinning = true
        
        // Access the FortuneWheel's view model to trigger the spin
        // We need to use a notification or callback approach
        NotificationCenter.default.post(name: NSNotification.Name("SpinWheel"), object: nil)
    }
}

// MARK: - Control Panel
struct RandomizerControlPanel: View {
    
    @ObservedObject var viewModel: RandomizerViewModel
    @Binding var showSpinwheel: Bool
    @Binding var isSpinning: Bool
    @Binding var selectedWinner: String?
    @Binding var showWinnerAnimation: Bool
    
    @State private var showManualEntry = false
    @State private var newOption = ""
    @FocusState private var isInputFocused: Bool
    
    var spinWheelTapped: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                // Title
                Text("Randomizer")
                    .font(.custom(poppinsBold, size: 24))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                
                // Action buttons
                if showSpinwheel {
                    HStack(spacing: 12) {
                        RandomizerButton(
                            title: "Hide spinwheel",
                            icon: "eye.slash.fill",
                            action: {
                                withAnimation {
                                    showSpinwheel = false
                                }
                            }
                        )
                        
                        RandomizerButton(
                            title: "Shuffle entries",
                            icon: "shuffle",
                            action: {
                                withAnimation {
                                    viewModel.shuffleOptions()
                                }
                            }
                        )
                        
                        RandomizerButton(
                            title: "Spin wheel",
                            icon: "arrow.clockwise",
                            action: {
                                spinWheelTapped?()
                            },
                            isDisabled: isSpinning || viewModel.options.isEmpty
                        )
                    }
                } else {
                    RandomizerButton(
                        title: "Show spinwheel",
                        icon: "circle.grid.cross.fill",
                        action: {
                            withAnimation {
                                showSpinwheel = true
                            }
                        },
                        isFullWidth: true,
                        isDisabled: viewModel.options.isEmpty
                    )
                }
                
                // Options section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Options")
                        .font(.custom(poppinsBold, size: 20))
                        .foregroundColor(.black)
                    
                    Text("Manual Entry")
                        .font(.custom(poppinsSemiBold, size: 16))
                        .foregroundColor(.black.opacity(0.8))
                    
                    // Options list
                    VStack(spacing: 0) {
                        if viewModel.options.isEmpty {
                            Text("No options added yet")
                                .font(.custom(poppinsRegular, size: 14))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                        } else {
                            ScrollView {
                                VStack(spacing: 0) {
                                    ForEach(Array(viewModel.options.enumerated()), id: \.offset) { index, option in
                                        HStack {
                                            Text(option)
                                                .font(.custom(poppinsRegular, size: 15))
                                                .foregroundColor(.black)
                                            
                                            Spacer()
                                            
                                            Button(action: {
                                                viewModel.removeOption(at: index)
                                            }) {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 18))
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        
                                        if index < viewModel.options.count - 1 {
                                            Divider()
                                                .background(Color.gray.opacity(0.3))
                                        }
                                    }
                                }
                            }
                            .frame(maxHeight: 200)
                        }
                        
                        // Add option input
                        if showManualEntry {
                            VStack(spacing: 0) {
                                Divider()
                                    .background(Color.gray.opacity(0.3))
                                
                                HStack(spacing: 12) {
                                    TextField("Enter option...", text: $newOption)
                                        .font(.custom(poppinsRegular, size: 15))
                                        .focused($isInputFocused)
                                        .submitLabel(.done)
                                        .onSubmit {
                                            addOption()
                                        }
                                    
                                    Button(action: addOption) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(.defaultTheme)
                                    }
                                    .disabled(newOption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                            }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    
                    // Add/Remove buttons
                    HStack(spacing: 12) {
                        Button(action: {
                            withAnimation {
                                showManualEntry.toggle()
                                if showManualEntry {
                                    isInputFocused = true
                                }
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: showManualEntry ? "minus.circle.fill" : "plus.circle.fill")
                                    .font(.system(size: 18))
                                
                                Text(showManualEntry ? "Cancel" : "Add Option")
                                    .font(.custom(poppinsMedium, size: 15))
                            }
                            .foregroundColor(.defaultTheme)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.defaultTheme.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.defaultTheme.opacity(0.3), lineWidth: 1)
                            )
                        }
                        
                        if !viewModel.options.isEmpty {
                            Button(action: {
                                withAnimation {
                                    viewModel.removeAllOptions()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 16))
                                    
                                    Text("Remove All")
                                        .font(.custom(poppinsMedium, size: 15))
                                }
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red.opacity(0.1))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
            .background(Color(.systemBackground))
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: -10)
        )
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private func addOption() {
        let trimmed = newOption.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        withAnimation {
            viewModel.addOption(trimmed)
            newOption = ""
        }
    }
}

// MARK: - Randomizer Button
struct RandomizerButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    var isFullWidth: Bool = false
    var isDisabled: Bool = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.custom(poppinsMedium, size: 12))
            }
            .foregroundColor(isDisabled ? .darkGray : .black)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isDisabled ? Color.gray.opacity(0.3) : Color.defaultTheme.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.defaultTheme.opacity(isDisabled ? 0.1 : 0.3), lineWidth: 1)
            )
        }
        .disabled(isDisabled)
    }
}

// MARK: - Winner Announcement View
struct WinnerAnnouncementView: View {
    let winner: String
    @Binding var isShowing: Bool
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        isShowing = false
                    }
                }
            
            // Winner card
            VStack(spacing: 24) {
                // Trophy icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.yellow, Color.orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: .yellow.opacity(0.5), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.white)
                }
                
                // Winner text
                VStack(spacing: 12) {
                    Text("🎉 Winner! 🎉")
                        .font(.custom(poppinsBold, size: 28))
                        .foregroundColor(.white)
                    
                    Text(winner)
                        .font(.custom(poppinsSemiBold, size: 24))
                        .foregroundColor(.yellow)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Confetti animation
                ConfettiView()
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.9), Color.blue.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .black.opacity(0.4), radius: 30, x: 0, y: 15)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
            )
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
        }
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            ForEach(0..<20) { i in
                Circle()
                    .fill(Color.random)
                    .frame(width: CGFloat.random(in: 4...8), height: CGFloat.random(in: 4...8))
                    .offset(
                        x: animate ? CGFloat.random(in: -150...150) : 0,
                        y: animate ? CGFloat.random(in: -150...150) : 0
                    )
                    .opacity(animate ? 0 : 1)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.5)) {
                animate = true
            }
        }
    }
}

// MARK: - View Model
class RandomizerViewModel: ObservableObject {
    @Published var options: [String] = []
    
    func addOption(_ option: String) {
        options.append(option)
    }
    
    func removeOption(at index: Int) {
        guard index < options.count else { return }
        options.remove(at: index)
    }
    
    func removeAllOptions() {
        options.removeAll()
    }
    
    func shuffleOptions() {
        options.shuffle()
    }
}

// MARK: - Extensions
extension Color {
    static var random: Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

//// MARK: - Preview
struct RandomizerView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.clear
            RandomizerView()
        }
    }
}

