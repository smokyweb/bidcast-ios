//
//  UpcomingBottomSheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//
import SwiftUI

struct UpcomingBottomSheet: View {
    var profileImage: String
    var username: String
    var showStartAt: String
    var showStartDate: String
    var onDismiss: () -> Void
    
    // Format time
    private var formattedTime: String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm:ss"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"
        
        if let date = inputFormatter.date(from: showStartAt) {
            return outputFormatter.string(from: date)
        }
        return showStartAt
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // ---------- HEADER ----------
            HStack {
                HStack(spacing: 12) {
                    AsyncImage(url: URL(string: profileImage)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 36, height: 36)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 36, height: 36)
                                .clipShape(Circle())
                        case .failure:
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 36, height: 36)
                                .clipShape(Circle())
                        @unknown default:
                            EmptyView()
                        }
                    }
                    
                    Text("@\(username)")
                        .font(.custom("Poppins-SemiBold", size: 14))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Button(action: { onDismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            }
            
            // ---------- MESSAGE ----------
            Text("Show starts on \(showStartDate) at \(formattedTime)")
                .font(.custom("Poppins-Bold", size: 14))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 0)
            
            // ---------- BUTTON ----------
            Button(action: { onDismiss() }) {
                Text("Okay")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(30)
            }
            .padding(.top, 10)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .bottom)
        .background(Color.white)
        .cornerRadius(20)
        .ignoresSafeArea(edges: .bottom)
    }
}
