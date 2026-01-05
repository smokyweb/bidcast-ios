import SwiftUI

// MARK: - Main Randomizer View
struct RandomizerView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = RandomizerViewModel()
    @Binding var showid : String
    @State private var showSpinwheel = false
    @State private var isSpinning = false
    @State private var selectedWinner: FreebieUser?
    @State private var showWinnerAnimation = false
    @State private var wheelKey = UUID()
    @State private var offset: CGFloat = UIScreen.main.bounds.height
    @State private var targetWinnerIndex: Int? = nil // 🆕 Store the winner index
    @State private var wheelIdMain = "mainWheel" // 🆕 Unique ID for this wheel
    
    var didTapSpin : (Bool) -> () = {_ in}
    var didSpinWheel : () -> () = {}
    var onWinnerSelected: (FreebieUser) -> () = {_ in}
    @Binding var usersName : [String]
    
    @State var usersData : [FreebieUser] = []
    
    @StateObject var socketManager = SocketManagerService.shared
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.01)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    if showSpinwheel {
                        FortuneWheel(
                            titles: viewModel.options,
                            size: screenWidth/1.5,
                            onSpinEnd: onSpinEnd,
                            getWheelItemIndex: getWheelItemIndex,
                            wheelId: "mainWheel" // 🆕 Add unique identifier
                        )
                        .background(.clear)
                        .id(wheelKey)
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(10)
                        .padding()
                    }
                    
                    ScrollView {
                        RandomizerControlPanel(
                            viewModel: viewModel,
                            showSpinwheel: $showSpinwheel,
                            isSpinning: $isSpinning,
                            showWinnerAnimation: $showWinnerAnimation,
                            spinWheelTapped: spinWheel,
                            didTapSpin: { value in
                                didTapSpin(value)
                            }
                        )
                    }
                    .background(Color.backGround)
                }
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.clear)
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: -10)
                )
                .cornerRadius(24, corners: [.topLeft, .topRight])
                .offset(y: offset)
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            if gesture.translation.height > 0 {
                                offset = gesture.translation.height
                            }
                        }
                        .onEnded { gesture in
                            if gesture.translation.height > 100 {
                                dismissView()
                            } else {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    offset = 0
                                }
                            }
                        }
                )
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                offset = 0
            }
            if usersName.count != 0{
                viewModel.options = usersName
            }
            
            socketManager.listenForFreebie { freebie, users in
                let showID = freebie.show_id ?? ""
                guard showid == showID else { return }
                
                usersData = users
                let titles = users.map { $0.name ?? ""}
                viewModel.options = titles
                usersName = viewModel.options
                print("Freebie data \(freebie) for showId : \(showid)")
            }
            
            // 🆕 Listen for winner and set target index BEFORE spinning
            socketManager.listenForFreebieWinner { user in
                if let winnerIndex = usersData.firstIndex(where: { $0.id == user.id }) {
                    selectedWinner = usersData[winnerIndex]
                    targetWinnerIndex = winnerIndex // Store the index
                    print("✅ Winner received: \(user.name ?? ""), index: \(winnerIndex)")
                    
                    // 🆕 Trigger the wheel spin after receiving winner
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        NotificationCenter.default.post(
                            name: NSNotification.Name("SpinWheel"),
                            object: nil,
                            userInfo: ["wheelId": wheelIdMain]
                        )
                    }
                } else {
                    print("⚠️ Winner user not found for id:", user.id ?? "")
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showSpinwheel)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showWinnerAnimation)
    }
    
    private func dismissView() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            offset = UIScreen.main.bounds.height
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    private func onSpinEnd(index: Int) {
        guard index >= 0 && index < viewModel.options.count else { return }
        
        // Use the winner we already know
        if let winner = selectedWinner {
            isSpinning = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation {
                    showWinnerAnimation = true
                    onWinnerSelected(winner)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    withAnimation {
                        showWinnerAnimation = false
                    }
                }
            }
        } else {
            print("⚠️ Winner not set when spin ended")
        }
    }
    
    // 🆕 Return the target winner index
    private func getWheelItemIndex() -> Int {
        if let targetIndex = targetWinnerIndex {
            print("🎯 Targeting winner at index: \(targetIndex)")
            return targetIndex
        }
        // Fallback to random if no winner set yet
        return Int.random(in: 0..<viewModel.options.count)
    }
    
    private func spinWheel() {
        guard !viewModel.options.isEmpty, !isSpinning else { return }
        didSpinWheel()
        isSpinning = true
        
        // 🆕 Post notification with wheel ID
//        NotificationCenter.default.post(
//            name: NSNotification.Name("SpinWheel"),
//            object: nil,
//            userInfo: ["wheelId": "mainWheel"]
//        )
    }
}

// MARK: - Control Panel
struct RandomizerControlPanel: View {
    
    @ObservedObject var viewModel: RandomizerViewModel
    @Binding var showSpinwheel: Bool
    @Binding var isSpinning: Bool
    @Binding var showWinnerAnimation: Bool
    
    @State private var showManualEntry = false
    @State private var newOption = ""
    @FocusState private var isInputFocused: Bool
    
    var spinWheelTapped: (() -> Void)?
    var didTapSpin: ((Bool) -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                Text("Freebie")
                    .font(.custom(poppinsBold, size: 24))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 12)
                
                if showSpinwheel {
                    HStack(spacing: 12) {
                        RandomizerButton(
                            title: "Hide spinwheel",
                            icon: "eye.slash.fill",
                            action: {
                                withAnimation {
                                    showSpinwheel = false
                                    didTapSpin?(showSpinwheel)
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
                                didTapSpin?(showSpinwheel)
                            }
                        },
                        isFullWidth: true,
                        isDisabled: viewModel.options.isEmpty
                    )
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Options")
                        .font(.custom(poppinsBold, size: 20))
                        .foregroundColor(.black)
                    
                    Text("Manual Entry")
                        .font(.custom(poppinsSemiBold, size: 16))
                        .foregroundColor(.black.opacity(0.8))
                    
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
                                                    .foregroundColor(.black)
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
                                    .fill(Color.defaultThemeLight)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.defaultTheme, lineWidth: 1)
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
        }
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

// MARK: - Randomizer Live View
struct RandomizerLiveView: View {

    @Binding var isPresented: Bool
    @Binding var showid : String
    @StateObject private var viewModel = FreebieViewModel()
    @State private var isSpinning = false
    @State private var selectedWinner: String?

    var onWinnerSelected: (String) -> Void = { _ in }
    var didEnterFreBie : () -> () = { }

    @StateObject var socketManager = SocketManagerService.shared
    @State private var wheelIdLive = "liveWheel" // 🆕 Different ID from main wheel
      @State private var usersData: [FreebieUser] = [] // 🆕 Store full user data
      @State private var targetWinnerIndex: Int? = nil
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            VStack(spacing: 24) {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.black)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)

                // 🆕 Add wheelId parameter
                FortuneWheel(
                    titles: viewModel.options,
                    size: screenWidth / 1.5,
                    onSpinEnd: onSpinEnd,
                    getWheelItemIndex: {
                        Int.random(in: 0..<viewModel.options.count)
                    },
                    wheelId: "liveWheel" // 🆕 Different ID
                )
                .padding(.top, 10)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Participants")
                        .font(.custom(poppinsBold, size: 18))

                    if viewModel.options.isEmpty {
                        Text("No users added")
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 40)
                    } else {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(viewModel.options, id: \.self) { option in
                                    HStack {
                                        Text(option.capitalizingFirstLetter())
                                            .font(.custom(poppinsRegular, size: 15))
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    Divider()
                                }
                            }
                        }
                        .frame(maxHeight: 140)
                    }

                    Button(action: {
                        didEnterFreBie()
                    }) {
                        Text("Enter")
                            .font(.custom(poppinsSemiBold, size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(
                                RoundedRectangle(cornerRadius: 32)
                                    .fill(Color.defaultTheme)
                            )
                    }
                }
                .padding()
                .background(.backGround)
                .cornerRadius(24)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            socketManager.listenForFreebie { freebie, users in
                let showID = freebie.show_id ?? ""
                guard showid == showID else { return }
                
                usersData = users // 🆕 Store full user data
                let titles = users.map { $0.name ?? ""}
                viewModel.options = titles
                print("Freebie data \(freebie) for showId : \(showid)")
            }
            
            // 🆕 Listen for winner and trigger spin
            socketManager.listenForFreebieWinner { user in
                if let winnerIndex = usersData.firstIndex(where: { $0.id == user.id }) {
                    targetWinnerIndex = winnerIndex
                    print("✅ Live view - Winner received: \(user.name ?? ""), index: \(winnerIndex)")
                    
                    // 🆕 Trigger wheel spin
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        NotificationCenter.default.post(
                            name: NSNotification.Name("SpinWheel"),
                            object: nil,
                            userInfo: ["wheelId": wheelIdLive]
                        )
                    }
                } else {
                    print("⚠️ Live view - Winner user not found for id:", user.id ?? "")
                }
            }
        }
    }

    private func dismiss() {
        withAnimation {
            isPresented = false
        }
    }

    private func onSpinEnd(index: Int) {
        // This wheel doesn't need to do anything on spin end
    }
}

// MARK: - Supporting Views & Models
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
                    .foregroundStyle(.defaultTheme)
            }
            .foregroundColor(isDisabled ? .darkGray : .defaultTheme)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isDisabled ? Color.gray.opacity(0.3) : Color.defaultThemeLight)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.defaultTheme.opacity(isDisabled ? 0.1 : 1.0), lineWidth: 1)
            )
        }
        .disabled(isDisabled)
    }
}

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

class FreebieViewModel : ObservableObject {
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

extension Color {
    static var random: Color {
        Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}





struct TikTokStyleWinnerView: View {
    let winner: String
    let winnerImage: String
    @Binding var isShowing: Bool

    @State private var confettiPieces: [ConfettiPiece] = []
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            if isShowing {
                content
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: isShowing)
    }

    // MARK: - Main Content
    private var content: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            confettiLayer

            winnerContent
        }
        .onAppear {
            startAnimations()
            autoDismiss()
        }
    }

    // MARK: - Subviews
    private var confettiLayer: some View {
        ZStack {
            ForEach(confettiPieces) { piece in
                ConfettiShape(shape: piece.shape)
                    .fill(piece.color)
                    .frame(width: piece.size.width, height: piece.size.height)
                    .rotationEffect(.degrees(piece.rotation))
                    .position(piece.position)
                    .opacity(piece.opacity)
            }
        }
    }

    private var winnerContent: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: winnerImage)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundColor(.gray)
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(
                    LinearGradient(
                        colors: [.pink, .purple, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4
                )
            )

            VStack(spacing: 8) {
                Text(winner)
                    .font(.custom(poppinsBold, size: 32))
                    .foregroundColor(.white)

                Text("has won the auction!")
                    .font(.custom(poppinsSemiBold, size: 24))
                    .foregroundColor(.white)
            }
        }
        .scaleEffect(scale)
        .opacity(opacity)
    }

    // MARK: - Logic
    private func startAnimations() {
        generateConfetti()
        animateConfetti()

        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            scale = 1
            opacity = 1
        }
    }

    private func autoDismiss() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if isShowing {
                dismiss()
            }
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) {
            scale = 0.8
            opacity = 0
            isShowing = false
        }
    }


    
    private func generateConfetti() {
        let shapes: [ConfettiShapeType] = [.circle, .square, .triangle, .rectangle]
        let colors: [Color] = [.red, .pink, .yellow, .orange, .purple, .blue, .green]
        
        for _ in 0..<60 {
            let randomX = CGFloat.random(in: 0...UIScreen.main.bounds.width)
            let randomY = CGFloat.random(in: -100...UIScreen.main.bounds.height)
            
            let piece = ConfettiPiece(
                shape: shapes.randomElement()!,
                color: colors.randomElement()!,
                size: CGSize(
                    width: CGFloat.random(in: 8...15),
                    height: CGFloat.random(in: 8...15)
                ),
                position: CGPoint(x: randomX, y: randomY),
                rotation: Double.random(in: 0...360),
                opacity: 1.0
            )
            
            confettiPieces.append(piece)
        }
    }
    
    private func animateConfetti() {
        for index in confettiPieces.indices {
            let delay = Double.random(in: 0...0.5)
            let duration = Double.random(in: 2.0...4.0)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeOut(duration: duration)) {
                    // Move down and fade out
                    confettiPieces[index].position.y += UIScreen.main.bounds.height + 200
                    confettiPieces[index].opacity = 0
                    confettiPieces[index].rotation += Double.random(in: 360...720)
                }
            }
        }
    }
}

// MARK: - Confetti Models
struct ConfettiPiece: Identifiable {
    let id = UUID()
    let shape: ConfettiShapeType
    let color: Color
    let size: CGSize
    var position: CGPoint
    var rotation: Double
    var opacity: Double
}

enum ConfettiShapeType {
    case circle, square, triangle, rectangle
}

struct ConfettiShape: Shape {
    let shape: ConfettiShapeType
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        switch shape {
        case .circle:
            path.addEllipse(in: rect)
            
        case .square:
            path.addRect(rect)
            
        case .triangle:
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.closeSubpath()
            
        case .rectangle:
            let narrowRect = CGRect(
                x: rect.minX,
                y: rect.minY,
                width: rect.width,
                height: rect.height * 0.6
            )
            path.addRect(narrowRect)
        }
        
        return path
    }
}
