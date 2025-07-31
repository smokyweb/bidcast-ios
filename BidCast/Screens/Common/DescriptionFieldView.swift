//
//  DescriptionFieldView.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 17/05/25.
//


import SwiftUI

struct DescriptionFieldView: View {
    @Binding var description: String
    var title : String = "Description"
    var placeholder : String = "Enter your Description"
    @State var custFontName: String = poppinsBold
    @State var custFontSize: Double = 13.0
    @State var custPlaceHolderName : String = poppinsRegular
    @State var custPlaceHolderFontSize : Double = placeHolder
    var enteredText: ((String) -> Void)?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.custom(custFontName, size: custFontSize))
                .foregroundColor(.black)
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .background(Color.white)
                    .frame(minHeight: 100)
                
                if description.isEmpty {
                    Text(placeholder)
                        .foregroundColor(Color.gray)
                        .padding(.all, 8)
                }

                TextEditor(text: $description)
                    .font(.custom(custPlaceHolderName, size: custPlaceHolderFontSize))
                    .padding(.all, 4)
                    .background(Color.clear)
                    .frame(minHeight: 100)
                    .opacity(description.isEmpty ? 0.6 : 1)
                    .onChange(of: description) { newValue in
                           self.enteredText?(newValue)
                    }
            }
        }
        .padding([.top,.bottom], 4)
        .padding([.leading,.trailing],16)
    }
}
