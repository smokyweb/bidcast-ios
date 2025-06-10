//
//  LiveStream.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 27/05/25.
//

import SwiftUI

import SwiftUI
import SVProgressHUD

struct Comment: Identifiable, Equatable {
    let id = UUID()
    let username: String
    let message: String
}

struct LiveStream: View {
    @State private var commentText = ""
    @State private var comments: [Comment] = [
        Comment(username: "trapwoc212", message: "White gold black diamond black silver"),
        Comment(username: "trapwoc212", message: "White gold"),
        Comment(username: "trapwoc212", message: "White gold"),
        Comment(username: "trapwoc212", message: "White gold"),
        Comment(username: "trapwoc212", message: "White gold")
    ]
    @State var id : String = ""
    @GestureState private var dragOffset = CGSize.zero
    @State var navigateToProfile = false
    @State private var swipeConfirmed = false
    @State private var currentStreamIndex = 0
    @State private var verticalDragOffset = CGSize.zero
    @GestureState private var verticalGestureOffset = CGSize.zero
    let streams = ["Stream 1", "Stream 2", "Stream 3"]
    
    var viewModel = LiveShowsViewModel()
    @State var liveShowsData = [LiveShowsModel]()
    @State var isLoading: Bool = false
    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State var showError: Bool = false
    @Binding var userId : String
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                Image("IMG_1340")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Header with user info and follow button
                    HStack(spacing: 12) {
                        Button(action:{
                            id = userId
                            navigateToProfile = true
                        }){
                        Image("user1")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text("swiftbid")
                                .foregroundColor(.white)
                                .bold()
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.yellow)
                                Text("99")
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                        Spacer()
                        Button(action: {}) {
                            Text("Follow")
                                .foregroundColor(.black)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.yellow)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 30)
                    
                    Spacer()
                    
                    // Floating action icons on the right
                    VStack(spacing: 16) {
                        Button(action: {}) {
                            Image(systemName: "info.circle")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        Button(action: {}) {
                            Image(systemName: "ellipsis.circle")
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                        Button(action: {}) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "cart")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 14, height: 14)
                                    .overlay(Text("7").font(.caption2).foregroundColor(.white))
                            }
                        }
                    }
                    .padding(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    // Comments Section
                    HStack{
                        ScrollViewReader { scrollProxy in
                            ScrollView(.vertical, showsIndicators: false) {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(comments) { comment in
                                        HStack(alignment: .center, spacing: 6) {
                                                Image("defaultUser")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 24, height: 24)
                                                    .clipShape(Circle())
                                            VStack(alignment: .leading) {
                                                Text(comment.username)
                                                    .font(.caption)
                                                    .bold()
                                                    .foregroundColor(.white)
                                                Text(comment.message)
                                                    .font(.footnote)
                                                    .foregroundColor(.white)
                                            }
                                            Spacer()
                                        }
                                        .id(comment.id)
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .onChange(of: comments) { _ in
                                withAnimation {
                                    scrollProxy.scrollTo(comments.last?.id, anchor: .bottom)
                                }
                            }
                            .frame(width:screenWidth - 50,height: 150)
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                        Spacer()
                    }
                    
                    // Item info with tags and thumbnail
                    HStack(spacing: 12) {
                        Image("sports")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipped()
                            .cornerRadius(8)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Item Name")
                                .font(.subheadline)
                                .bold()
                                .foregroundColor(.black)
                            HStack(spacing: 6) {
                                Text("Tag")
                                    .font(.caption)
                                    .padding(4)
                                    .background(Color.purple.opacity(0.7))
                                    .cornerRadius(4)
                                Text("Tag")
                                    .font(.caption)
                                    .padding(4)
                                    .background(Color.pink.opacity(0.7))
                                    .cornerRadius(4)
                            }
                            Text("Lorem ipsum dolor sit amet")
                                .font(.caption2)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        
                    }
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Swipe to Bid Button
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.3))
                            .frame(height: 50)
                        
                        Text("Swipe to Bid")
                            .foregroundColor(.white)
                            .padding(.leading)
                        Spacer()
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.white, lineWidth: 2)
                            .frame(width: 50, height: 40)
                            .overlay(
                                Text(swipeConfirmed ? "✓" : "→")
                                    .foregroundColor(.white)
                                    .bold()
                            )
                            .offset(x: (screenWidth / 2 - 50) + dragOffset.width)
                            .gesture(
                                DragGesture()
                                    .updating($dragOffset) { value, state, _ in
                                        if value.translation.width >= 0 {
                                            // Clamp drag to not exceed right edge minus handle width and padding
                                            let maxDrag = screenWidth - 40 - (screenWidth / 2 - 50)
                                            state = CGSize(width: min(value.translation.width, maxDrag), height: 0)
                                        }
                                    }
                                    .onEnded { value in
                                        let maxDrag = screenWidth - 40 - (screenWidth / 2 - 50)
                                        if value.translation.width > maxDrag * 0.8 {
                                            swipeConfirmed = true
                                            // Trigger bid action here
                                        } else {
                                            swipeConfirmed = false
                                        }
                                    }
                            )
                            .animation(.spring(), value: dragOffset)
                    }
                    .padding(.horizontal)
                    
                    // Comment Input
                    HStack {
                        TextField("Say something...", text: $commentText)
                            .font(.custom(poppinsSemiBold, size: 13.0))
                            .foregroundStyle(.black)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(height: 40)
                        Button(action: {
                            guard !commentText.isEmpty else { return }
                            comments.append(Comment(username: "You", message: commentText))
                            commentText = ""
                        }) {
                            Image(systemName: "paperplane.fill")
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.6))
                }
            }
            .gesture(
                DragGesture()
                    .updating($verticalGestureOffset) { value, state, _ in
                        // Only track vertical drag
                        if abs(value.translation.height) > abs(value.translation.width) {
                            state = value.translation
                        }
                    }
                    .onEnded { value in
                        let verticalAmount = value.translation.height

                        if verticalAmount < -100 { // Swipe Up
                            withAnimation {
                                currentStreamIndex = min(currentStreamIndex + 1, streams.count - 1)
                                print("Switched to stream index: \(currentStreamIndex)")
                            }
                        } else if verticalAmount > 100 { // Swipe Down
                            withAnimation {
                                currentStreamIndex = max(currentStreamIndex - 1, 0)
                                print("Switched to stream index: \(currentStreamIndex)")
                            }
                        }
                    }
            )
            CusNavLink(doNavigate: $navigateToProfile, destination: ProfileScreen(id:$id))
        }
        .foregroundColor(.white)
        .onAppear{
            Task{
                SVProgressHUD.show()
                await self.viewModel.getLiveShows()
                await SVProgressHUD.dismiss()
                await  success()
            }
        }
        
    }
   

    func success() {
        SVProgressHUD.dismiss()
        let response = viewModel.liveShowsResponse
            if response.status == "success" {
                liveShowsData = response.data ?? [LiveShowsModel]()
                
            } else {
                showError = true
                alertType = .sheetType(
                    icon: .alert,
                    title: response.error_type?.capitalized ?? "",
                    message: response.message?.capitalized ?? "",
                    primaryBtnText: "",
                    secondaryBtnText: AppString.ok.localized
                )
            }
            
        
    }
}
