//
//  CreateProductScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 29/05/25.
//

import SwiftUI

struct CreateProductScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedCategory = ""
    @State private var title = ""
    @State private var description = ""
    @State private var quantity = 1
    @State var imageUrls : [String] = [""]
    @State var navigateToSalesFormat = false
    var body: some View {
        VStack(spacing: 16) {
            // Header
            VStack{
                PrimaryHeader(
                    title: "Create Product".localized,
                    isForLogo : false ,leadingImgArr: [.icBack],
                    onClickLeading: { _ in
                        self.presentationMode.wrappedValue.dismiss()
                    },
                    count: .constant(0)
                )
            }.frame(height:40)
                .background(.white)
            ScrollView{
                // Info box
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    Text("Detailed product listings help buyers make informed decisions and increase your chances of making a sale.")
                        .font(.footnote)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
                
                // Photos
                VStack(alignment: .leading, spacing: 8) {
                    Text("Photos")
                        .font(.subheadline).bold()
                    
                    MediaPickerView(title:"",uploadedImageUrls: $imageUrls)
                        .frame(height:150)
                        .padding(.horizontal,-12)
                    
                    Text("Add up to 8 photos")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.horizontal)
                
                // Category Picker
                VStack(alignment: .leading, spacing: 4) {
                    Text("Category")
                        .font(.subheadline).bold()
                    
                    Menu {
                        Button("Electronics", action: { selectedCategory = "Electronics" })
                        Button("Apparel", action: { selectedCategory = "Apparel" })
                        Button("Other", action: { selectedCategory = "Other" })
                    } label: {
                        HStack {
                            Text(selectedCategory.isEmpty ? "Select category" : selectedCategory)
                                .foregroundColor(selectedCategory.isEmpty ? .gray : .black)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.white))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
                
                // Title
                VStack(alignment: .leading, spacing: 4) {
                    Text("Title")
                        .font(.subheadline).bold()
                    
                    TextField("Enter product title", text: $title)
                        .padding()
                        .background(Color(.white))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Description
                VStack(alignment: .leading, spacing: 4) {
                    Text("Description")
                        .font(.subheadline).bold()
                    
                    TextEditor(text: $description)
                        .frame(height: 100)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Quantity Selector
                HStack{
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Quantity Available")
                            .font(.subheadline).bold()
                        
                        HStack(spacing: 12) {
                            Button(action: { if quantity > 1 { quantity -= 1 } }) {
                                Image(systemName: "minus")
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .clipShape(Circle())
                            }
                            
                            Text("\(quantity)")
                                .font(.headline)
                                .frame(width: 40)
                            
                            Button(action: { quantity += 1 }) {
                                Image(systemName: "plus")
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button(action: {
                        // Use Product Library
                    }) {
                        Text("Use Product Library")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        navigateToSalesFormat = true
                    }) {
                        Text("Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            CusNavLink(doNavigate: $navigateToSalesFormat, destination: SalesFormatScreen())
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}
