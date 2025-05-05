//
//  VideoView.swift
//  imperium
//
//  Created by Maneet-JAM-E-282 on 25/01/24.
//

import SwiftUI
import Photos


struct RecordVideoView: View {
    
    @EnvironmentObject private var appRootManager: AppRootManager
    @Environment(\.presentationMode) var presentationMode
    
    
    @State var isCountdown: Bool = true
    @State var countDown: Int = 5
    @State var showVideoPreviewScreen: Bool = false
	@State var comeFromSignUp : Bool = false
    @State var isMainFlow: Bool = false
    
    var goBackAction: (() -> Void)?
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        if isCountdown {
            Image(.fullBackground)
                .resizable()
                .scaledToFill()
                .frame(width: screenWidth, height: screenHeight)
                .ignoresSafeArea(.all)
                .overlay(alignment: .center, content: {
                    Circle()
                        .strokeBorder(.white, lineWidth: 4)
                        .background(Circle().fill(.gray.opacity(0.4)))
                        .frame(width: screenWidth/2)
                        .overlay {
                            Text("\(countDown)")
                                .font(.custom(nunitoBlack, fixedSize: 100))
                                .foregroundStyle(.white)
                                .padding(.vertical)
                        }
                }).onReceive(timer) { _ in
                    countDown -= 1
                    if countDown == 1 {
                        timer.upstream.connect().cancel()
                        withAnimation(.easeIn) { isCountdown = false }
                    }
                }
        } else if showVideoPreviewScreen {
			ReviewVideoView(comeFromProfile: self.comeFromSignUp,onSuccess: {
                self.goBackAction?()
            })
        } else {
            VideoRecorderHelper(
                isForRecording: true,
                onRecordingCancel: {
                    if isMainFlow {
                        DispatchQueue.main.async {
                            appRootManager.currentRoot = .welcome
                        }
                    } else {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                }, onRecordingSuccess: { vidURL in
                    UserDefaultsManager.shared.setValue(vidURL.absoluteString, forKey: .userVideoResumeURL)
                    print("Confirm >>> \(vidURL)")
                    withAnimation(.snappy) { showVideoPreviewScreen = true }
                })
        }
    }
}

#Preview {
    RecordVideoView()
}
