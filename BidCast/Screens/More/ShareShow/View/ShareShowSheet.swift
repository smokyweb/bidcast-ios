//
//  ShareShowSheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI


struct ShareShowBottomSheetView: View {
    @Binding var isPresented: Bool
    var showTitle: String
    var username: String
    var showImage: Image
    var message: String
    var onShare: (String) -> Void
    var onSavePDF: () -> Void
    var onShareEmail: () -> Void
    
    let shareOptions = [
        ("WhatsApp", "message.fill"),
        ("Facebook", "person.2.fill"),
        ("Twitter", "paperplane.fill"),
        ("Copy Link", "link")
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false){
            VStack(spacing: 16) {
                // Header
                HStack {
                    Text("Share Show")
                        .font(.custom(poppinsBold, size: 15.0))
                    Spacer()
                    Button { isPresented = false } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                            .imageScale(.large)
                    }
                }
                
                // Show Preview
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 40, height: 40)
                            .overlay(Image(systemName: "person.crop.circle.fill").resizable().scaledToFit().padding(6))
                        VStack(alignment: .leading) {
                            Text(showTitle)
                                .font(.custom(poppinsSemiBold, size: 13.0))
                            Text("@\(username)")
                                .font(.custom(poppinsSemiBold, size: 11.0))
                                .foregroundColor(.gray)
                        }
                    }
                    
                    HStack {
                        Spacer()
                        showImage
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .cornerRadius(12)
                        Spacer()
                    }
                    
                    Text(message)
                        .padding()
                        .font(.custom(poppinsSemiBold, size: 11.0))
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil) // Allow unlimited lines
                        .fixedSize(horizontal: false, vertical: true) // Ensure it wraps
                    
                }
                
                //            .padding()
                .background(Color(.systemGray6))
                .cornerRadius(20)
                
                // Share Icons
                HStack(spacing: 24) {
                    ForEach(shareOptions, id: \.0) { name, icon in
                        VStack {
                            Button { onShare(name) } label: {
                                Circle()
                                    .fill(Color(.systemGray6))
                                    .frame(width: 50, height: 50)
                                    .overlay(Image(systemName: icon))
                            }
                            Text(name)
                                .font(.custom(poppinsRegular, size: 11.0))
                        }
                    }
                }
                
                // Actions
                VStack(spacing: 12) {
                    Button(action: onSavePDF) {
                        HStack {
                            Image(systemName: "doc.richtext")
                                .foregroundColor(.red)
                            Text("Save as PDF")
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(14)
                    }
                    
                    Button(action: onShareEmail) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)
                            Text("Share via Email")
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(14)
                    }
                }
                
                Spacer()
            }
                    .edgesIgnoringSafeArea(.top)
            .padding()
            .background(Color.white)
            .cornerRadius(20)
        }
    }
}


//import SwiftUI
//
//struct ShareShowBottomSheetView: View {
//    @Binding var isPresented: Bool
//    var showTitle: String
//    var username: String
//    var showImage: Image
//    var message: String
//    var onShare: (String) -> Void
//    var onSavePDF: () -> Void
//    var onShareEmail: () -> Void
//
//    // Assumes these are image asset names in Assets.xcassets
//    let shareOptions = [
//        ("WhatsApp", "whatsapp"),
//        ("Facebook", "facebook"),
//        ("Twitter", "twitter"),
//        ("Copy Link", "link")
//    ]
//
//    var body: some View {
//        VStack(spacing: 16) {
//            // Header
//            HStack {
//                Text("Share Show")
//                    .font(.title2).bold()
//                Spacer()
//                Button { isPresented = false } label: {
//                    Image(systemName: "xmark")
//                        .foregroundColor(.gray)
//                        .imageScale(.large)
//                }
//            }
//
//            // Show Preview
//            VStack(alignment: .leading, spacing: 12) {
//                HStack(spacing: 12) {
//                    Circle()
//                        .fill(Color.gray.opacity(0.3))
//                        .frame(width: 40, height: 40)
//                        .overlay(
//                            Image(systemName: "person.crop.circle.fill")
//                                .resizable()
//                                .scaledToFit()
//                                .padding(6)
//                        )
//                    VStack(alignment: .leading) {
//                        Text(showTitle)
//                            .font(.headline)
//                        Text("@\(username)")
//                            .font(.subheadline)
//                            .foregroundColor(.gray)
//                    }
//                }
//
//                showImage
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(height: 100)
//                    .cornerRadius(12)
//
//                Text(message)
//                    .font(.subheadline)
//                    .fixedSize(horizontal: false, vertical: true)
//                    .multilineTextAlignment(.leading)
//            }
//            .padding()
//            .background(Color(.systemGray6))
//            .cornerRadius(20)
//
//            // Share Icons
//            HStack(spacing: 24) {
//                ForEach(shareOptions, id: \.0) { name, icon in
//                    VStack {
//                        Button { onShare(name) } label: {
//                            Circle()
//                                .fill(Color(.systemGray6))
//                                .frame(width: 50, height: 50)
//                                .overlay(
//                                    Image(icon) // Use asset images here
//                                        .resizable()
//                                        .scaledToFit()
//                                        .padding(12)
//                                )
//                        }
//                        Text(name)
//                            .font(.caption)
//                    }
//                }
//            }
//
//            // Actions
//            VStack(spacing: 12) {
//                Button(action: onSavePDF) {
//                    HStack {
//                        Image(systemName: "doc.richtext")
//                            .foregroundColor(.red)
//                        Text("Save as PDF")
//                            .foregroundColor(.black)
//                        Spacer()
//                        Image(systemName: "chevron.right")
//                            .foregroundColor(.gray)
//                    }
//                    .padding()
//                    .background(Color(.systemGray6))
//                    .cornerRadius(14)
//                }
//
//                Button(action: onShareEmail) {
//                    HStack {
//                        Image(systemName: "envelope")
//                            .foregroundColor(.gray)
//                        Text("Share via Email")
//                            .foregroundColor(.black)
//                        Spacer()
//                        Image(systemName: "chevron.right")
//                            .foregroundColor(.gray)
//                    }
//                    .padding()
//                    .background(Color(.systemGray6))
//                    .cornerRadius(14)
//                }
//            }
//
//            Spacer()
//        }
//        .padding()
//        .background(Color.white)
//        .cornerRadius(20)
//    }
//}
