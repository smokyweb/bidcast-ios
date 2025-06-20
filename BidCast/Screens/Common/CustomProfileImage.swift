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
        AsyncImage(url: URL(string: url ?? "")) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: size, height: size)

            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .applyClip(isCircular: isCircular, cornerRadius: cornerRadius)

            case .failure:
                Image("defaultUser")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .applyClip(isCircular: isCircular, cornerRadius: cornerRadius)

            @unknown default:
                EmptyView()
            }
        }
    }
}
private extension View {
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
