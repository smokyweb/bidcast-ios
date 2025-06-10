//
//  GetStartedScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 17/05/25.
//

import SwiftUI
import RichText
import AVFoundation
import AVKit

struct LessonScreen: View {
    
    var viewModel = ScheduleViewModel()
    @State var lessons =  [LessonModel]()
    @State var currentIndex: Int = 0
    @State var isPlaying = false
    @State var isLoading: Bool = false
    @State var playbackProgress: Double = 0.0
    @State var timeObserverToken: Any?
    
    @State  var showNextButton = false
    @State  var showPreviousButton = false
    @State private var player: AVPlayer? = nil
    @State var navigateToSell = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            PrimaryHeader(
                title: "Lesson".localized,
                isForLogo : false, leadingImgArr: [.sideArrow],
                trailingImgArr: [],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .background(.white)
//            .frame(height: 80)
//            CusNavLink(doNavigate: $navigateToSell, destination: SellingTips())
        }
        .background(.red)
        .frame(height: 40)
            ZStack(alignment: .bottom) {
                Color(#colorLiteral(red: 0.17, green: 0.22, blue: 0.28, alpha: 1)).ignoresSafeArea()
                
                if !lessons.isEmpty {
                    let lesson = lessons[currentIndex]
                    
                    VStack(spacing: 24) {
                        // Top bar
                        HStack {
                            Spacer()
                            Text("Lesson \(currentIndex + 1)/\(lessons.count )")
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        
                        // Title & subtitle
                        VStack(spacing: 6) {
                            Text(lesson.title ?? "")
                                .font(.title3.bold())
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                            Text("Watch this lesson to unlock the next chapter")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 16)
                        
                        // Video
                        if let player = player {
                            VideoPlayer(player: player)
                                .frame(height: UIScreen.main.bounds.height * 0.5)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                        }
                        
                        // Description
                        ScrollView {
                            if let desc = lesson.description {
                                RichText(html: desc)
                                    .foregroundColor(.white)
                                    .padding()
                            }
                        }
                        
                        Spacer()
                        
                        // Next button
                        HStack {
                            if showPreviousButton {
                                   Button("Previous") {
                                       goToPreviousLesson()
                                   }
                                   .font(.headline)
                                   .padding(.vertical, 10)
                                   .frame(width: 120)
                                   .background(Color.gray)
                                   .foregroundColor(.white)
                                   .cornerRadius(8)
                                   .shadow(radius: 3)
                               }

                              
                            
                            Spacer()
                            if showNextButton {
                                    Button("Next") {
                                        goToNextLesson()
                                    }
                                    .font(.headline)
                                    .padding(.vertical, 10)
                                    .frame(width: 120)
                                    .background(Color(red: 1, green: 0.42, blue: 0.46))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .shadow(radius: 3)
                                }
                        }
                        .padding(.horizontal, 24)
                        
                        // Controls
                        VStack(spacing: 8) {
                            ProgressView(value: playbackProgress)
                                .tint(.blue)
                                .padding(.horizontal, 20)
                            
                            HStack {
                                Button {
                                    togglePlayPause()
                                } label: {
                                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                }
                                Spacer()
                                Label("Sound", systemImage: "speaker.wave.2.fill")
                                Spacer()
                                Image(systemName: "captions.bubble.fill")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 10)
                        }
                        .background(Color.black.opacity(0.85))
                    }
                } else {
                    ProgressView(value: playbackProgress)
                        .tint(.blue)
                        .padding(.horizontal, 20)
                }
            }
            .toolbar(.hidden,for: .tabBar)
            .onAppear {
                observe()
                
//                viewModel.getLesson()
            }
            .onDisappear {
                if let token = timeObserverToken, let currentPlayer = player {
                    currentPlayer.removeTimeObserver(token)
                    timeObserverToken = nil
                }
                NotificationCenter.default.removeObserver(self)
            }
        }
        
        func goToNextLesson() {
            if currentIndex < lessons.count - 1 {
                currentIndex += 1
                playCurrentVideo()
            } else {
                showNextButton = true
                navigateToSell = true
                print("All lessons finished")
            }
        }
    
    func goToPreviousLesson() {
        if currentIndex > 0 {
            currentIndex -= 1
            playCurrentVideo()
        }else{
            showPreviousButton = false
        }
    }
        
        func togglePlayPause() {
            isPlaying.toggle()
            if isPlaying {
                player?.play()
            } else {
                player?.pause()
            }
        }
        
    func playCurrentVideo() {
        // Remove old time observer from the current player before replacing it
        if let oldPlayer = player, let token = timeObserverToken {
            oldPlayer.removeTimeObserver(token)
            timeObserverToken = nil
        }

        guard lessons.indices.contains(currentIndex),
              let urlString = lessons[currentIndex].video,
              let url = URL(string: urlString) else { return }

        player = AVPlayer(url: url)
        isPlaying = true
        player?.play()

        showNextButton = false
        showPreviousButton = currentIndex > 0

        // Remove previous notification observer before adding a new one
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)

        // Observe when video ends
        if let currentItem = player?.currentItem {
            NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                   object: currentItem,
                                                   queue: .main) {  _ in
                showNextButton = true
                isPlaying = false
            }
        }

        // Add a single periodic time observer for progress update
        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC)),
                                                           queue: .main) {  time in
                 guard let duration = player?.currentItem?.duration.seconds,duration > 0 else { return }

            let currentTime = time.seconds
            self.playbackProgress = currentTime / duration
        }
    }

        
        func observe() {
//            self.viewModel.eventHandler = { event in
//                switch event {
//                    case .loading:
//                        self.isLoading = true
//                    case .stopLoading:
//                        self.isLoading = false
//                    case .dataLoaded:
//                        success()
//                    case .error(let error):
//                        print("Error: \(error?.localizedDescription ?? "Unknown")")
//                }
//            }
        }

        func success() {
//            if let dict = viewModel.getLessonDict {
//                if dict.status == "success" {
//                    lessons = dict.data
//                    playCurrentVideo()
//                } else {
//                    print("API error: \(dict.status ?? "")")
//                }
//            }
        }

}

#Preview {
    LessonScreen()
}
