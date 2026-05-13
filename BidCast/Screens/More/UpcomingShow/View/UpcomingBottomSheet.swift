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
    
    // FIX (cmp40t1q000px4axyerrn1bks): format time robustly — try multiple
    // input formats the API may return (HH:mm:ss, HH:mm, h:mm a, etc.).
    private var formattedTime: String {
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")

        let inputFormats = ["HH:mm:ss", "HH:mm", "h:mm a", "h:mm:ss a", "H:mm"]
        for fmt in inputFormats {
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = fmt
            inputFormatter.locale = Locale(identifier: "en_US_POSIX")
            if let date = inputFormatter.date(from: showStartAt.trimmingCharacters(in: .whitespaces)) {
                return outputFormatter.string(from: date)
            }
        }
        return showStartAt.isEmpty ? "--:-- --" : showStartAt
    }

    // FIX (cmp40t1q000px4axyerrn1bks): format date — API returns yyyy-MM-dd;
    // display as "MMM d, yyyy" (e.g. "Dec 25, 2025").
    private var formattedDate: String {
        let inputFormats = ["yyyy-MM-dd", "MM/dd/yyyy", "dd-MM-yyyy", "MM-dd-yyyy"]
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d, yyyy"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")

        for fmt in inputFormats {
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = fmt
            inputFormatter.locale = Locale(identifier: "en_US_POSIX")
            if let date = inputFormatter.date(from: showStartDate.trimmingCharacters(in: .whitespaces)) {
                return outputFormatter.string(from: date)
            }
        }
        return showStartDate.isEmpty ? "TBD" : showStartDate
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
            Text("Show starts on \(formattedDate) at \(formattedTime)")
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
                    .background(Color.defaultTheme)
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
