//
//  NewsCard.swift
//  imperium
//
//  Created by Abdul-JAM-E-157 on 20/01/24.
//

import SwiftUI
import RichText

struct NewsCard: View {
    
    @State var newsDetail: NewsResponseModel = NewsResponseModel()
    
    var body: some View {
        Button(action: {
            
        }, label: {
            VStack(alignment: .leading, spacing: 8) {
               
                HStack {
                    Text(newsDetail.title ?? " - ")
                        .font(.custom(nunitoBold, fixedSize: 18))
                        .bold()
                        .foregroundStyle(.black)
                    
                    Spacer()
                }
                
                Text("\(newsDetail.created_at?.toDate().today() ?? " - ")")
                    .font(.custom(nunitoRegular, fixedSize: 14))
                    .bold()
                    .foregroundStyle(.gray)
                
                RichText(html: newsDetail.description ?? " - ")
                    .customCSS("""
            body {
                font-size: 14px;
            }
        """)
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.leading)
            }
            .padding(.all)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .shadow(color: .gray.opacity(0.3), radius: 2, x: 0, y: 0))
        })
    }
}

#Preview {
    NewsCard()
}
