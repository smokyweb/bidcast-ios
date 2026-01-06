//
//  SellerScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 23/10/25.
//

import SwiftUI


struct UserScreenFreeBie: View {
    @Binding var users: [FreebieUser]
//    @Binding var selectedSellers: Set<Int>
    @Binding var selectedSellerID: [Int]
    var onSelected: (FreebieUser?) -> Void
    var onCancel: () -> Void
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Text("Select Live User for Freebie")
                    .font(.custom(poppinsSemiBold, size: 14.0))
                    .fontWeight(.bold)
                    .padding()
                
                Spacer()
                Button(action: {
                    onCancel()
                }) {
                    
                    Image(systemName: "xmark.circle.fill")
                        .font(.custom(poppinsSemiBold, size: 28.0))
                        .foregroundColor(.defaultTheme)
                        .padding(.trailing, 25)
                        
                }
            }
            .padding()
                       .background(Color.white)
            .overlay(Divider(), alignment: .bottom)
            
            // Seller List
//            ScrollView {
                List(users, id: \.id) { user in
                    let isSelected = selectedSellerID.contains(user.id ?? 0)

                    HStack {
                        
                        CustomProfileImage(url: user.profile_image, isCircular: true, size: 40)
                            .padding()
                        Text(user.name?.capitalizingFirstLetter() ?? "")
                            .font(.custom(poppinsSemiBold, size: 13.0))
                        Spacer()
                        Button {
                            onSelected(user)
                        } label: {
                            Text(isSelected ? "Selected" : "Select")
                                .font(.custom(poppinsSemiBold, size: 13))
                                .foregroundColor(isSelected ? .defaultTheme : .white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(isSelected ? Color.defaultTheme.opacity(0.15) : Color.defaultTheme)
                                )
                        }
                        .buttonStyle(.plain)
                        .padding(.trailing,4)
                       
                    }
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                    .background(
                        isSelected
                        ? Color.defaultThemeLight
                               : Color.clear
                           )
                }
                .listStyle(PlainListStyle())
//            }
            
           
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
//        .padding(.top)
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
