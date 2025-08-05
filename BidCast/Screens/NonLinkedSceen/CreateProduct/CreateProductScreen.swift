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
    @State var navigateToAddProduct = false
    @Binding var request : StoreScheduleShowRequest
    @Binding var thumbNail : String
    @Binding var backToPrepare : Bool
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
            }
            
            ScrollView{
                
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    Text("Detailed product listings help buyers make informed decisions and increase your chances of making a sale.")
                        .font(.custom(poppinsRegular, size: 11.0))
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                .padding(.horizontal)
                
                // Photos
                VStack(alignment: .leading, spacing: 8) {
                    
                    
                    MediaPickerView(title:"Photos",uploadedImageUrls: $imageUrls)
                        .frame(height:180)
                        .padding(.horizontal,-12)
                    
                    Text("Add up to 8 photos")
                        .font(.custom(poppinsRegular, size: 11.0))
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
                        navigateToAddProduct = true
                    }) {
                        Text("Use Product Library")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .padding()
                            .background(Color.defaultTheme)
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
                            .background(.gray)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                    }
                    .disabled(true)
                }
                .padding(.horizontal)
//                .padding(.bottom, 16)
            }
            .edgesIgnoringSafeArea(.all)
            CusNavLink(doNavigate: $navigateToAddProduct, destination: AddProductsScreen(request:$request,thumbNail: $thumbNail,fromPrepare: .constant(false),backToPrepare: $backToPrepare))
            CusNavLink(doNavigate: $navigateToSalesFormat, destination: SalesFormatScreen())
        }
        .background(Color.bg.opacity(0.4).ignoresSafeArea())
    }
}
