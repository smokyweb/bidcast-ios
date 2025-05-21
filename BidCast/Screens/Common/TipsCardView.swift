//
//  TipsCardView.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 21/05/25.
//

import SwiftUICore
import SwiftUI
import RichText


struct TipsCardView: View {
    var image = ""
    var title = ""
    var description = ""
    
    var body: some View {
        HStack(spacing: 12){
            AsyncImage(url: URL(string: image)) { phase in
                switch phase {
                case .success(let image):
                    image.resizable()
                default:
                    Image(systemName: "photo")
                        .resizable()
                }
            }
            .frame(width: 24, height: 24)
            .clipShape(Circle())
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.custom(poppinsBold, size: 15.0))
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
    }
}
