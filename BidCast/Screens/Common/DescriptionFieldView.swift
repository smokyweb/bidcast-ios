//
//  DescriptionFieldView.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 17/05/25.
//


import SwiftUI

struct DescriptionFieldView: View {
    @State private var description: String = ""
    var title : String = "Description"
    var placeholder : String = "Enter your Description"
    var enteredText: ((String) -> Void)?
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
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
                    .font(.custom(nunitoBlack, size: 14.0))
                    .padding(.all, 4)
                    .background(Color.clear)
                    .frame(minHeight: 100)
                    .opacity(description.isEmpty ? 0.6 : 1)
                    .onChange(of: description) { newValue in
                           self.enteredText?(newValue)
                    }
            }
        }
        .padding()
    }
}
