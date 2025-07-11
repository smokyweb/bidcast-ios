//
//  ShowCardView.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import Foundation
import SwiftUICore
import SwiftUI

// MARK: - Show Card View
struct ShowCardView: View {
    let show: HomeModel
    var onTap : () -> () = { }
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: show.img_thumbnail?.first ?? "")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 60, height: 60)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .cornerRadius(8.0)
                case .failure:
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.gray)
                        .cornerRadius(8.0)
                @unknown default:
                    EmptyView()
                }
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(show.title?.capitalizingFirstLetter() ?? "")
                    .font(.custom(poppinsBold, size: 14.0))

                Text(show.date ?? "")
                    .font(.custom(poppinsSemiBold, size: 13.0))
                    .foregroundColor(.gray)

                HStack {
                    Label(show.time ?? "", systemImage: "clock")
                        .font(.custom(poppinsSemiBold, size: 13.0))
                    Label("\(show.viewer_count ?? 0) RSVPs", systemImage: "person.3")
                        .font(.custom(poppinsSemiBold, size: 13.0))
                }
            }
            Spacer()
            Image(systemName: "ellipsis")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
        .onTapGesture {
            onTap()
        }
    }
}


// MARK: - Show Card View
struct ShowMyScheduleCardView: View {
    let show: GetMyScheduleShowModel
    var onTap : () -> () = { }
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: show.imgThumbnail?.first ?? "")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 60, height: 60)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .cornerRadius(8.0)
                case .failure:
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.gray)
                        .cornerRadius(8.0)
                @unknown default:
                    EmptyView()
                }
            }
            VStack(alignment: .leading, spacing: 5) {
                Text(show.title?.capitalizingFirstLetter() ?? "")
                    .font(.custom(poppinsBold, size: 14.0))

                Text(show.date ?? "")
                    .font(.custom(poppinsSemiBold, size: 13.0))
                    .foregroundColor(.gray)

                HStack {
                    Label(show.time ?? "", systemImage: "clock")
                        .font(.custom(poppinsSemiBold, size: 13.0))
                    Label("\(show.viewerCount ?? 0) RSVPs", systemImage: "person.3")
                        .font(.custom(poppinsSemiBold, size: 13.0))
                }
            }
            Spacer()
            Image(systemName: "ellipsis")
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
        .onTapGesture {
            onTap()
        }
    }
}

