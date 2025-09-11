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
import SVProgressHUD

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
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @Binding var backToTabBar : Bool
    @State var comeFromAccount = false
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
            
        }
        .background(.red)
        .frame(height: 40)
            ZStack(alignment: .bottom) {
                if #available(iOS 17.0, *) {
                    Color(Color.bg.opacity(0.4))
                        .ignoresSafeArea()
                } else {
                    // Fallback on earlier versions
                }
                
                if !lessons.isEmpty {
                    let lesson = lessons[currentIndex]
                    
                    VStack(spacing: 24) {
                        // Top bar
                        HStack {
                            Spacer()
                            Text("Lesson \(currentIndex + 1)/\(lessons.count )")
                                .font(.custom(poppinsSemiBold, size: 11.0))
                                .foregroundColor(.black.opacity(0.8))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        
                        // Title & subtitle
                        VStack(spacing: 6) {
                            Text(lesson.title ?? "")
                                .font(.custom(poppinsSemiBold, size: 16.0))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.black)
                            Text("Watch this lesson to unlock the next chapter")
                                .font(.custom(poppinsRegular, size: 12.0))
                                .foregroundColor(.black.opacity(0.7))
                        }
                        .padding(.horizontal, 16)
                        
                        // Video
                        if let player = player {
                            VideoPlayer(player: player)
                                .frame(height: UIScreen.main.bounds.height * 0.5)
//                                .cornerRadius(10)
                                .overlay(
                                    Rectangle()
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
                                   .font(.custom(poppinsSemiBold, size: 13.0))
                                   .padding(.vertical, 10)
                                   .frame(width: 120)
                                   .background(Color.white)
                                   .foregroundColor(.defaultTheme)
                                   .cornerRadius(8)
                                   .shadow(radius: 3)
                               }

                              
                            
                            Spacer()
//                            if showNextButton {
                                    Button("Next") {
                                        goToNextLesson()
                                    }
                                    .font(.custom(poppinsSemiBold, size: 13.0))
                                    .padding(.vertical, 10)
                                    .frame(width: 120)
                                    .background(Color.defaultTheme)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .shadow(radius: 3)
//                                }
                        }
                        .padding(.horizontal, 24)
                        
                        // Controls
                        VStack(spacing: 8) {
                            ProgressView(value: playbackProgress)
                                .tint(.defaultTheme)
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
//                                Image(systemName: "captions.bubble.fill")
                            }
                            .foregroundColor(.black)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 10)
                        }
                        .background(Color.bg.opacity(0.4))
                    }
                } else {
                    ProgressView(value: playbackProgress)
                        .tint(.defaultTheme)
                        .padding(.horizontal, 20)
                }
                
                CusNavLink(doNavigate: $navigateToSell, destination: SellingTips(backToTabBar:$backToTabBar))
            }
            .toolbar(.hidden,for: .tabBar)
            .onAppear {
               
                Task{
                   guard Reachability.isConnectedToNetwork() else {
                        hudMsg = "No Internet Connection"
                        showhud = true
                        return
                    }
                    SVProgressHUD.show()
                    await viewModel.getLesson()
                    await SVProgressHUD.dismiss()
                    success()
                }
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
                if comeFromAccount{
                    showNextButton = true
                    self.presentationMode.wrappedValue.dismiss()
                }else{
                    showNextButton = true
                    navigateToSell = true
                }
                
                print("All lessons finished")
            }
            playbackProgress = 0.0
        }
    
    func goToPreviousLesson() {
        if currentIndex > 0 {
            currentIndex -= 1
            playCurrentVideo()
        }else{
            showPreviousButton = false
        }
        playbackProgress = 0.0
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

        


        func success() {
            if let dict = viewModel.lessonsResponse {
                if dict.status == "success" {
                    lessons = dict.data
                    playCurrentVideo()
                } else {
                    print("API error: \(dict.status ?? "")")
                }
            }
        }

}

//#Preview {
//    LessonScreen()
//}
