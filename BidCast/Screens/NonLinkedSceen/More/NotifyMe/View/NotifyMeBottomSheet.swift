//
//  NotifyMeBottomSheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI

struct NotifyMeBottomSheet: View {
    @Binding var isPresented: Bool
    var profileImage: Image
    var username: String
    var onNotify: () -> Void
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Header with close button
            HStack {
                HStack(spacing: 12) {
                    profileImage
                        .resizable()
                        .scaledToFill()
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                    
                    Text("@\(username)")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                }

                Spacer()

                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Color.red)
                        .clipShape(Circle())
                }
            }

            // Message
            VStack(alignment: .leading) {
                Text("Would you like to be notified when @\(username) goes live?")
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.black)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true) 
                    .padding(.horizontal)
            }


            // Action buttons
            VStack(spacing: 12) {
                Button(action: {
                    onNotify()
                }) {
                    Text("Yes, notify me")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(30)
                }

                Button(action: {
                    onDismiss()
                    isPresented = false
                }) {
                    Text("No, thanks")
                        .fontWeight(.regular)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .foregroundColor(.black)
                        .cornerRadius(30)
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
    }
}
