//
//  SellerScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 23/10/25.
//

import SwiftUI


struct SellerScreen: View {
    @Binding var sellers: [SellerUserModel]
//    @Binding var selectedSellers: Set<Int>
    @Binding var selectedSellerID: Int?
    @State var selectedSellerData : SellerUserModel? = nil
    var onRaidCreated: (SellerUserModel?) -> Void // Closure to pass back selected sellers
    
    @State private var isRaidCreating = false
    var onCancel: () -> Void
    var body: some View {
        VStack {
            // Header
            HStack {
                Text("Select Live Seller for Raid")
                    .font(.custom(poppinsSemiBold, size: 14.0))
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
                Button(action: {
                    onCancel() // Call the closure to dismiss the sheet
                }) {
                    
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 15, height: 15)
                        .font(.title)
                        .foregroundStyle(.defaultTheme)
                        .padding(.trailing, 25)
                        
                }
            }
            
            // Seller List
//            ScrollView {
                List(sellers, id: \.id) { seller in
                    HStack {
                        
                        CustomProfileImage(url: seller.profile_image, isCircular: true, size: 40)
                            .padding()
                        Text(seller.name ?? "")
                            .font(.custom(poppinsSemiBold, size: 13.0))
                        Spacer()
                        
                        if selectedSellerID == seller.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.defaultTheme)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                        }
                    }
                    .onTapGesture {
                        //                    if selectedSellers.contains(seller.id ?? 0) {
                        //                        selectedSellers.remove(seller.id ?? 0)
                        //                    } else {
                        //                        selectedSellers.insert(seller.id ?? 0)
                        //                    }
                        if selectedSellerID == seller.id {
                            selectedSellerID = nil
                            selectedSellerData = nil
                        } else {
                            selectedSellerID = seller.id
                            selectedSellerData = seller
                        }
                    }
                }
                .listStyle(PlainListStyle())
//            }
            Spacer()
            
            // Create Raid Button
            Button(action: {
                createRaid()
            }) {
                Text(isRaidCreating ? "Creating Raid..." : "Create Raid")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(selectedSellerID == nil ? Color.gray : .defaultTheme)
                    .cornerRadius(10)
            }
            .disabled(selectedSellerID == nil || isRaidCreating)
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
//        .padding(.top)
    }
    
    private func createRaid() {
        isRaidCreating = true // Disable button and show loading state
        print("Creating raid with selected sellers: \(selectedSellerID)")
        
        // Simulate a delay (replace with real raid creation logic)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Raid created successfully, trigger closure with selected sellers
            onRaidCreated(selectedSellerData)
            isRaidCreating = false
        }
    }
    
    // Back Button
    private var backButton: some View {
        Button(action: {
            // Action to go back, pop this view
            print("Back button pressed")
        }) {
            HStack {
                Image(systemName: "arrow.left")
                    .font(.title)
                Text("Back")
                    .font(.body)
                    .fontWeight(.medium)
            }
        }
    }
}
