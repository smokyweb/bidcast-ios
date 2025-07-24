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
    var onTapDefault : () -> () = { }
    var onTapDelete : () -> () = { }
    
    @State var isDefault : Bool = false
    var body: some View {
        HStack {
            Image(systemName: image)
                .resizable()
                .frame(width: 40, height: 25)
                .foregroundColor(Color.defaultTheme)
            VStack(alignment: .leading) {
                Text("•••• \(cardNo)")
                    .font(.custom(poppinsSemiBold, size: 12.0))
                Text("Expires \(expires)")
                    .font(.custom(poppinsRegular, size: 12.0))
                    .foregroundColor(.gray)
            }
            if isDefault{
                Text("Default")
                    .font(.custom(poppinsSemiBold, size: 13.0))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .background(.lightBlue)
                    .foregroundColor(.black)
                    .cornerRadius(8)
            }
            Spacer()

            Menu {
                Button(action: {
                   
                    onTapDefault()
                }){
                    Text("Set as default")
                        .font(.custom(poppinsSemiBold, size: 11))
                }
                
                Button(role: .destructive, action: {
                 
                    onTapDelete()
                }){
                    Text("Delete")
                        .font(.custom(poppinsSemiBold, size: 11))
                }
                
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
