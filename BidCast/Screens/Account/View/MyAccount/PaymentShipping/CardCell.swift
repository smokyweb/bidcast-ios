//
//  CardCell.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 27/05/25.
//
import SwiftUI

struct CardCell: View {
    var image = ""
    var cardNo = ""
    var expires = ""
  
    var onTapDelete : () -> () = { }
    var body: some View {
        HStack {
            Image(systemName: image)
                .resizable()
                .frame(width: 40, height: 25)
                .foregroundColor(.blue)
            VStack(alignment: .leading) {
                Text("•••• \(cardNo)")
                    .font(.body)
                Text("Expires \(expires)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            Menu {
                Button("Delete", role: .destructive, action: {
//                    print("Delete \(address.name ?? "")")
                    onTapDelete()
                })
            } label: {
                Image(systemName: "ellipsis")
                    .rotationEffect(.degrees(90))
                    .foregroundColor(.gray)
                    .padding(8)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
