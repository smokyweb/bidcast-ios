//
//  RehearsalScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 16/06/25.
//

import SwiftUI
import Foundation
import SVProgressHUD

struct RehearsalScreen: View {
    @Binding var showUd: String
    var roomID: String = ""
   @State  var streamId = ""
    var isLocal: Bool = true
    @Environment(\.presentationMode) var presentaionMode
    @State var viewModel = ShowsViewModel()
    
    var body: some View {
        ZStack {
            
            ZegoRehearsalScreen()
//                .edgesIgnoringSafeArea(.all)
            
            // Top overlay
            VStack {
                HStack {
                    HStack(spacing: 8) {
                        Image("profile_icon")
                            .resizable()
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("swiftbid")
                                .foregroundColor(.white)
                                .font(.caption)
                            
                            Text("Show Time 00:00:01")
                                .foregroundColor(.white)
                                .font(.caption2)
                        }
                        
                        Spacer()
                        Text("Rehearsal")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.red)
                            .cornerRadius(4)
                            .foregroundColor(.white)
                        
                        Button(action: {
                            self.presentaionMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 40)
                
                Spacer()
            }
            
            VStack {
                Spacer()
                VStack(spacing: 20) {
                    Button(action: {
                        // Mic test logic
                    }) {
                        VStack {
                            Image(systemName: "mic.fill")
                            Text("Mic Test")
                        }
                        .padding(8)
                        .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        // Camera switch logic
                    }) {
                        VStack {
                            Image(systemName: "arrow.triangle.2.circlepath.camera")
                            Text("Switch")
                        }
                        .padding(8)
                        .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        
                    }) {
                        ZStack {
                            VStack {
                                Image(systemName: "bag.fill")
                                Text("Shop")
                            }
                            .padding(8)
                            .foregroundColor(.white)
                            
                            Circle()
                                .fill(Color.red)
                                .frame(width: 20, height: 20)
                                .overlay(Text("7").foregroundColor(.white).font(.caption))
                                .offset(x: 12, y: -30)
                        }
                    }
                }
                .padding(.trailing)
                .padding(.bottom, 100)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            
           
            VStack {
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "person.crop.circle")
                        Text("goodgirlsteph97").bold()
                        Text("Mod").padding(4).background(Color.gray.opacity(0.3)).cornerRadius(4)
                        Text("🔥 XL").foregroundColor(.orange)
                    }
                    .foregroundColor(.white)
                    
                    HStack {
                        Text("trapwoc212")
                            .bold()
                        Text("White gold")
                    }
                    .foregroundColor(.white)
                }
                .padding(.horizontal)
                
                Button(action: {
                    Task{
                        SVProgressHUD.show()
                        await viewModel.UpdateLiveShows(param: LiveShowUpdateRequest(schedule_show_id: showUd, is_live: "true"))
                        await SVProgressHUD.dismiss()
                        await success()
                    }
                }) {
                    Text("Start Show")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }
    
    func success(){
        let response = viewModel.updateStatusRespone
        if response?.status == "success"{
            self.streamId = "\(response?.data?.id ?? 0)"
        }
    }
}
