//
//  CustomProfileImage.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 20/06/25.
//
import SwiftUI
import Foundation

struct CustomProfileImage: View {
    let url: String?
    var isCircular: Bool = true
    var cornerRadius: CGFloat = 8
    var size: CGFloat = 40
    
    var body: some View {
        if let url = url, !url.isEmpty {
            AsyncImage(url: URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")) { phase in
                switch phase {
                case .empty:
                    Color.gray.opacity(0.3)
                        .frame(width: size, height: size)
                        .applyClip(isCircular: isCircular, cornerRadius: cornerRadius)
                        .shimmer()
                     
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size, height: size)
                        .applyClip(isCircular: isCircular, cornerRadius: cornerRadius)
                        .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
                case .failure:
                    if url.contains("http") {
                        Image("defaultUser")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: size, height: size)
                            .applyClip(isCircular: isCircular, cornerRadius: cornerRadius)
                            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
                    } else {
                        Image(url)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size, height: size)
                            .applyClip(isCircular: isCircular, cornerRadius: cornerRadius)
                            .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
                    }
                    
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            Image("defaultUser")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .applyClip(isCircular: isCircular, cornerRadius: cornerRadius)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
    }
}
extension View {
    func applyClip(isCircular: Bool, cornerRadius: CGFloat) -> some View {
        Group {
            if isCircular {
                self.clipShape(Circle())
            } else {
                self.clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
        }
    }
}
