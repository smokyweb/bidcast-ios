//
//  GetStartedScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 17/05/25.
//

import SwiftUI
import RichText
import AVKit

//struct SellingTips: View {
//    
//    var viewModel = ScheduleViewModel()
//    @State var lessons =  [LessonModel]()
//    
//    @State var currentIndex = 0
//    @State var isLoading: Bool = false
//    
//    @State var navigateToPrepare = false
//    @State  var showNextButton = false
//    
//    @Environment(\.presentationMode) var presentationMode
//    
//    var body: some View {
//        VStack(spacing:18){
//            VStack{
//                PrimaryHeader(
//                    title: "How to Sell".localized,
//                    isForLogo : false, leadingImgArr: [.sideArrow],
//                    trailingImgArr: [],
//                    onClickLeading: { _ in
//                        self.presentationMode.wrappedValue.dismiss()
//                    },
//                    count: .constant(0)
//                )
//                .background(.white)
//            }.frame(height: 40)
//            ScrollView(showsIndicators:false){
//                if !lessons.isEmpty{
//                    let lesson = lessons[currentIndex]
//                    Text("Step \(currentIndex + 1) of \(lessons.count)")
//                        .foregroundColor(.red)
//                        .font(.subheadline)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.horizontal)
//                        .padding(.top,8)
//                    Text(lesson.title ?? "")
//                        .font(.title2)
//                        .bold()
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                        .padding(.horizontal)
//                    
//                    if let imageUrl = URL(string: lesson.image ?? "") {
//                        AsyncImage(url: imageUrl) { image in
//                            image
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .cornerRadius(12)
//                        } placeholder: {
//                            ProgressView()
//                        }
//                        .padding(.horizontal)
//                    }
//                    RichText(html:lesson.description ?? "")
//                        .foregroundColor(.white)
//                        .padding()
//                    HStack{
//                        
//                        Button("Back") {
//                            if currentIndex > 0 { currentIndex -= 1 }
//                        }
//                        .disabled(currentIndex == 0)
//                        .buttonStyle(.bordered)
//                        .frame(width: 100.0)
//                      
//                        
//                       Spacer()
//                        
//                        Button("Next") {
//                            if currentIndex < lessons.count - 1 { currentIndex += 1 }
//                        }
//                        .disabled(currentIndex == lessons.count - 1)
//                        .buttonStyle(.borderedProminent)
//                        .frame(width: 100.0)
//                        .tint(.red)
//                        
//                    }
//                    .padding(.horizontal,16)
//                    if currentIndex == lessons.count - 1{
//                        PrimaryButton(title: "Continue",isOutLine: false,onButtonClick: {
//                            navigateToPrepare = true
//                        },cornerRadius: 12, btnTextColor: .white)
////                            .disabled(currentIndex < lessons.count - 1)
//                    }
//                    
//                }
//            }
//            
//            .background(.bg.opacity(0.5))
//            if isLoading {
//                Loader(isLoading: $isLoading)
//            }
//        }
//        
//        CusNavLink(doNavigate: $navigateToPrepare, destination: LetsPrepare())
//            .edgesIgnoringSafeArea(.bottom)
//        .toolbar(.hidden,for: .tabBar)
//        .onAppear {
//            observe()
//            
//            viewModel.getSellingTips()
//        }
//    }
//    
//    func observe() {
//        self.viewModel.eventHandler = { event in
//            switch event {
//            case .loading:
//                self.isLoading = true
//            case .stopLoading:
//                self.isLoading = false
//            case .dataLoaded:
//                success()
//            case .error(let error):
//                print("Error: \(error?.localizedDescription ?? "Unknown")")
//            }
//        }
//    }
//    
//    func success() {
//        if let dict = viewModel.getLessonDict {
//            if dict.status == "success" {
//                lessons = dict.data
//            } else {
//                print("API error: \(dict.status ?? "")")
//            }
//        }
//    }
//    
//}
//
//#Preview {
//    SellingTips()
//}


enum LearningContent {
    case lesson(LessonModel)
    case tip(LessonModel)
}


//import SwiftUI
//import AVKit
//import RichText

struct CombinedLessonTipsView: View {
    var viewModel = ScheduleViewModel()

    @State private var lessonList: [LessonModel] = []
    @State private var tipList: [LessonModel] = []
    @State private var combinedList: [LearningContent] = []

    @State private var currentIndex = 0
    @State private var player: AVPlayer? = nil
    @State private var isPlaying = true
    @State private var timeObserverToken: Any?
    @State private var playbackProgress: Double = 0.0

    @State private var isLoading = false
    @State private var navigateToNext = false

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 0) {
            PrimaryHeader(
                title: "How It Works".localized,
                isForLogo : false,
                leadingImgArr: [.sideArrow],
                trailingImgArr: [],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .background(.white)
            .frame(height: 40)

            if isLoading {
                Loader(isLoading: $isLoading)
            } else if !combinedList.isEmpty {
                let item = combinedList[currentIndex]

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        Text("Step \(currentIndex + 1) of \(combinedList.count)")
                            .foregroundColor(.defaultTheme)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 10)

                        switch item {
                        case .lesson(let lesson):
                            VStack(spacing: 12) {
                                Text(lesson.title ?? "")
                                    .font(.title2.bold())
                                    .foregroundColor(.black)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)

                                Text("Watch this lesson to unlock the next chapter")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)

                                if let url = URL(string: lesson.video ?? "") {
                                    VideoPlayer(player: player)
                                        .frame(minHeight: 250,maxHeight:screenHeight/2 )
                                        .cornerRadius(12)
                                        .onAppear {
                                            playVideo(from: url)
                                        }
                                }

                                if let desc = lesson.description {
                                    RichText(html: desc)
                                        .foregroundColor(.black)
                                        .padding()
//                                        .background(Color.white)
//                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                }
                                Spacer()
                                VStack{
//                                    Spacer()
                                   Spacer()
                                    ProgressView(value: playbackProgress)
                                        .tint(.red)
//                                        .padding(.horizontal, 16)
                                    
                                    HStack {
                                        Button {
                                            refreshPlaybackIfNeeded()
                                        } label: {
                                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                        }
                                        Spacer()
                                        Label("Sound", systemImage: "speaker.wave.2.fill")
                                        Spacer()
                                        Image(systemName: "captions.bubble.fill")
                                    }
                                    .foregroundColor(.black)
//                                    .padding(.horizontal, 24)
//                                    .padding(.top, 70)
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 100)
                            }

                        case .tip(let tip):
                            VStack(spacing: 12) {
                                Text(tip.title ?? "")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal)

                                if let imageUrl = URL(string: tip.image ?? "") {
                                    AsyncImage(url: imageUrl) { image in
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .cornerRadius(12)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .padding(.horizontal)
                                }

                                if let desc = tip.description {
                                    RichText(html: desc)
                                        .foregroundColor(.white)
                                        .padding()
//                                        .background(Color.white)
//                                        .cornerRadius(10)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }

                  
                    HStack {
                        Button("Back") {
                            if currentIndex > 0 {
                                currentIndex -= 1
                                refreshPlaybackIfNeeded()
                            }
                        }
                        .disabled(currentIndex == 0)
                        .foregroundColor(.white)
                        .padding()
                        .background(currentIndex == 0 ? Color.gray : Color.blue)
                        .cornerRadius(8)

                        Spacer()

                        Button(currentIndex < combinedList.count - 1 ? "Next" : "Finish") {
                            if currentIndex < combinedList.count - 1 {
                                currentIndex += 1
                                refreshPlaybackIfNeeded()
                            } else {
                                navigateToNext = true
                            }
                        }
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
//                    .padding(.bottom, -50)
                }
                .background(.bg.opacity(0.5))
                .padding(.bottom,-20)
                .edgesIgnoringSafeArea(.top)
                .edgesIgnoringSafeArea(.bottom)
                
            }

            CusNavLink(doNavigate: $navigateToNext, destination: LetsPrepare())
        }
        .onAppear {
            currentIndex = 0
            observe()
            viewModel.getLesson()
        }
        .onDisappear {
            cleanupPlayer()
        }
        .toolbar(.hidden, for: .tabBar)
    }

    func observe() {
        viewModel.eventHandler = { event in
            switch event {
            case .loading:
                self.isLoading = true
            case .stopLoading:
                self.isLoading = false
            case .dataLoaded:
                self.mergeData()
            case .error(let error):
                print("Error: \(error?.localizedDescription ?? "Unknown")")
            }
        }
    }

    func mergeData() {
        if viewModel.request == "lesson" {
            if let lessonDict = viewModel.getLessonDict,
               lessonDict.status == "success" {
                self.lessonList = lessonDict.data
                self.viewModel.getSellingTips()
            }
        } else {
            if let tipDict = viewModel.getLessonDict,
               tipDict.status == "success" {
                self.tipList = tipDict.data

                let count = max(lessonList.count, tipList.count)
                var result: [LearningContent] = []

                for i in 0..<count {
                    if i < lessonList.count {
                        result.append(.lesson(lessonList[i]))
                    }
                    if i < tipList.count {
                        result.append(.tip(tipList[i]))
                    }
                }
                self.combinedList = result
            }
        }
    }

    func playVideo(from url: URL) {
        cleanupPlayer()
        player = AVPlayer(url: url)
        player?.play()
        isPlaying = true

        timeObserverToken = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.5, preferredTimescale: 600), queue: .main) { time in
            guard let duration = player?.currentItem?.duration.seconds, duration > 0 else { return }
            playbackProgress = time.seconds / duration
        }

        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { _ in
            isPlaying = false
        }
    }

    func cleanupPlayer() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
        player?.pause()
        player = nil
    }

    func refreshPlaybackIfNeeded() {
        if case .lesson(let lesson) = combinedList[currentIndex],
           let url = URL(string: lesson.video ?? "") {
            playVideo(from: url)
        } else {
            cleanupPlayer()
        }
    }
}

#Preview {
    CombinedLessonTipsView()
}
