//
//  ProfileScreen.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 29/05/25.
//

import SwiftUI


struct ProfileScreen: View {
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    ProfileHeaderView()
                    ProfileActionsView()
                    ProfileTabsView()
                    SearchAndFiltersView()
                    ProductListView()
                }
//                .padding()
            }
            .edgesIgnoringSafeArea(.top)
           
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

struct ProfileHeaderView: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ZStack(alignment: .topLeading) {
                   // Background image
                   VStack(spacing: 0) {
                       Image("IMG_2678") // Replace with your image
                           .resizable()
                           .scaledToFill()
                           .frame(height: 200)
                           .clipped()
                       Spacer()
                   }

                   
                   Button(action: {
                       presentationMode.wrappedValue.dismiss()
                   }) {
                       Image(systemName: "chevron.left")
                           .font(.system(size: 20, weight: .bold))
                           .foregroundColor(.white)
                           .padding(10)
                           .background(Color.black.opacity(0.6))
                           .clipShape(Circle())
                           .shadow(radius: 4)
                   }
                   .padding(.top, 30)
                   .padding(.leading, 16)
                   .zIndex(1)

                   // Foreground content
                   VStack(alignment: .leading, spacing: 4) {
                       HStack {
                           Image("user1")
                               .resizable()
                               .clipShape(Circle())
                               .overlay(Circle().stroke(Color.white, lineWidth: 2))
                               .frame(width: 80, height: 80)
                               .offset(x: 16, y: 160)

                           Spacer()

                          
                       }
                   }
               }
               .frame(height: 220) // Height of header section
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Sarah Williams").font(.title3).fontWeight(.bold)
            Text("@sarahwilliams").foregroundColor(.gray)
            
            HStack(spacing: 16) {
                Text("2.4K Followers").bold()
                Text("856 Following").foregroundColor(.gray)
            }
            
            Text("Professional photographer specializing in portrait and wedding photography. Available for bookings worldwide.")
                .font(.body)
                .foregroundColor(.gray)
        }
    }
}

struct ProfileActionsView: View {
    var body: some View {
        HStack(spacing: 16) {
            Button("Unfollow") {
                // Handle unfollow
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(UIColor.systemGray5))
            .cornerRadius(12)

            Button("Message") {
                // Handle message
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)

            Button(action: {
                // Handle action
            }) {
                Image(systemName: "dollarsign.circle")
                    .foregroundColor(.primary)
                    .font(.title2)
            }
        }
        .padding(.horizontal,13)
    }
}

struct ProfileTabsView: View {
    let tabs = ["Shop", "Shows", "Reviews", "Clips"]
    @State private var selectedTab = "Shop"

    var body: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                VStack {
                    Text(tab)
                        .fontWeight(selectedTab == tab ? .bold : .regular)
                        .foregroundColor(selectedTab == tab ? .blue : .gray)
                    if selectedTab == tab {
                        Capsule().fill(Color.blue).frame(height: 3)
                    } else {
                        Capsule().fill(Color.clear).frame(height: 3)
                    }
                }
                .onTapGesture {
                    selectedTab = tab
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal,13)
    }
}

struct SearchAndFiltersView: View {
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                TextField("What are you looking for?", text: .constant(""))
                    .padding(.leading, 12)
                Image(systemName: "slider.horizontal.3")
                    .padding(.trailing, 12)
            }
            .frame(height: 44)
            .background(Color(UIColor.systemGray5))
            .cornerRadius(10)
            
            HStack {
                ForEach(["Filter", "Sort", "Buy Now", "Category"], id: \.self) { title in
                    Button(title) {
                        // Handle filter
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(UIColor.systemGray5))
                    .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal,13)
    }
}

struct ProductListView: View {
    var body: some View {
        VStack(spacing: 12) {
            ProductCardView(imageName: "ic_bidder")
            ProductCardView(imageName: "ic_bidder")
        }
    }
}

struct ProductCardView: View {
    var imageName: String?

    var body: some View {
        HStack {
            if let imageName = imageName {
                Image(imageName)
                    .resizable()
                    .frame(width: 80, height: 80)
                    .cornerRadius(10)
            }

            VStack(alignment: .leading) {
                Text("Product Name").fontWeight(.semibold)
                Text("Category - Condition").foregroundColor(.gray).font(.subheadline)
                Text("$2").fontWeight(.bold)
            }
            Spacer()
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
    }
}


struct TabIcon: View {
    var title: String
    var systemImage: String
    var selected: Bool = false

    var body: some View {
        VStack {
            Image(systemName: systemImage)
                .foregroundColor(selected ? .purple : .gray)
            Text(title)
                .font(.caption)
                .foregroundColor(selected ? .purple : .gray)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ProfileScreen()
}
