//
//  CompleteProfileScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 29/05/25.
//

import SwiftUI

struct CompleteProfileScreen: View {
    @State private var fullName = ""
    @State private var username = ""
    @State private var bio = "Tell Us about yourself"
    @State private var profileImage: Image? = nil
    @Environment(\.presentationMode)  var presentationMode
    var body: some View {
        VStack(spacing: 20) {
            VStack{
                PrimaryHeader(
                    title: "Complete Profile".localized,
                    isForLogo : false ,leadingImgArr: [.icBack],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
            }.frame(height:40)
                .background(.white)
            ScrollView{
                VStack{
                    Text("Complete Your Profile")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Let others know who you are")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    ZStack(alignment: .bottomTrailing) {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 100, height: 100)
                            .overlay(
                                profileImage?
                                    .resizable()
                                    .scaledToFill()
                                    .clipShape(Circle())
                            )
                        
                        Button(action: {
                            // Add image picker logic here
                        }) {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(radius: 1)
                        }
                        .offset(x: 5, y: 5)
                    }
                    
                    Text("Upload photo")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                    
                    VStack(spacing: 16) {
                        LabeledInputField(label: "Full Name", placeholder: "Enter your full name", systemImage: "person", text: $fullName)
                        
                        LabeledInputField(label: "Username", placeholder: "Choose a username", systemImage: "at", text: $username)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Bio")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            TextEditor(text: $bio)
                                .frame(height: 80)
//                                .padding(10)
                                .background(Color.gray.opacity(0.05))
                                .cornerRadius(10)
                                .foregroundStyle(Color.gray.opacity(0.5))
                        }
                    }
                    
                    Spacer()
                    
                }
                .padding()
                .frame(maxWidth: 400)
                .background(.clear)
                .cornerRadius(12)
                //                        .padding()
                
            } .background(.clear)
            
            Button(action: {
                // Continue logic
            }) {
                Text("Continue")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .background(.bg.opacity(0.5))
    }
}

struct LabeledInputField: View {
    var label: String
    var placeholder: String
    var systemImage: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack {
                Image(systemName: systemImage)
                    .foregroundColor(.gray)
                TextField(placeholder, text: $text)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(10)
        }
    }
}
