//
//  TipsCardView.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 21/05/25.
//

import SwiftUI
import RichText

struct TipsCardView: View {
    var image = ""
    var title = ""
    var description = ""
    
    var body: some View {
        HStack(spacing: 12){
            TipIconImage(
                            urlString: image,
                            tint: .defaultTheme,
                            size: 24
                        )
//            .clipShape(Circle())
            VStack(alignment: .leading, spacing: 6) {
//                Text(title)
//                    .font(.custom(poppinsBold, size: 15.0))
                RichText(html: description)
                    .customCSS("""
                        body {
                        font-size: 14px;
                        line-height: 1.4;
                        margin: 0;
                        padding: 0;
                        }
                        p {
                        margin: 0 0 6px 0;
                        }
                        ul {
                        margin: 0;
                        padding-left: 16px;
                        }
                        li {
                        margin-bottom: 4px;
                        list-style-type: disc;
                        }
                        """
                    )
            }
            
            
        }
        .padding(.horizontal,Leading)
    }
}
struct TipIconImage: View {
    let urlString: String
    let tint: Color
    let size: CGFloat

    var body: some View {
        AsyncImage(
            url: URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
        ) { phase in
            switch phase {

            case .success(let image):
                image
                    .renderingMode(.template) // ✅ REQUIRED for tint
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(tint)
                    .frame(width: size, height: size)

            case .failure(_):
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(tint)
                    .frame(width: size, height: size)

            default:
                Color.gray.opacity(0.3)
                    .frame(width: size, height: size)
                    .cornerRadius(4)
            }
        }
    }
}
