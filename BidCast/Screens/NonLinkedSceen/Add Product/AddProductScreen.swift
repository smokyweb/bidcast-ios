//
//  AddProductScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 29/05/25.
//

import SwiftUI

struct AddProductsScreen: View {
    @State private var productCount = 1
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 16) {
            
            // Header
            VStack{
                PrimaryHeader(
                    title: "Add Products".localized,
                    isForLogo : false ,
                    trailingImgArr: [.cancel],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
            }.frame(height:40)
                .background(.white)
            ScrollView{
            // Placeholder for banner/image box
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 80)
                .padding(.horizontal)
            Spacer()
            // Added Product Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Added Product")
                    .fontWeight(.semibold)
                
                HStack {
                    Image("fashion") // Replace with actual image asset
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("White Sneakers")
                            .fontWeight(.semibold)
                        Text("Sports & Lifestyle")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("Quantity: 1")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        // Edit product
                    }) {
                        Image(systemName: "square.and.pencil")
                    }
                    
                    Button(action: {
                        // Delete product
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3))
                )
            }
            .padding(.horizontal)
            
                Spacer()
            // Add More Section
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Add More Products")
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(productCount)/100")
                        .foregroundColor(.gray)
                        .font(.footnote)
                }
                
                VStack(spacing: 16) {
                    addProductOption(text: "Add another product")
                    addProductOption(text: "Select from product Inventory")
                }
            }
            .padding(.horizontal)
        }
            

            // Finish Button
            Button(action: {
                // Finish action
            }) {
                Text("Finish")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding([.horizontal, .bottom])
        }
        .navigationBarHidden(true)
    }

    // MARK: - Add Product Tile
    private func addProductOption(text: String) -> some View {
        VStack {
            Image(systemName: "plus")
                .foregroundColor(.gray)
            Text(text)
                .foregroundColor(.gray)
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4]))
        )
    }
}

#Preview {
    AddProductsScreen()
}
