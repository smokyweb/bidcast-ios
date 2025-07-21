//
//  EndShowBottomSheetView.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI

struct EndShowBottomSheetView: View {
    @Binding var isPresented: Bool
    var onCreateRaid: () -> Void
    var onEndShow: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Text("End Show")
                    .font(.custom(poppinsBold, size: 15.0))
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                        .imageScale(.large)
                }
            }

            // Create a Raid Button
            Button(action: onCreateRaid) {
                HStack {
                    Image(systemName: "person.3.fill")
                        .font(.custom(poppinsSemiBold, size: 13.0))
                        .frame(width: 40,height: 40)
                        .foregroundColor(.black)
                        .imageScale(.medium)
                    Text("Create a raid")
                        .font(.custom(poppinsSemiBold, size: 13.0))
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.custom(poppinsSemiBold, size: 13.0))
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(14)
            }

            // End Show Button
            Button(action: onEndShow) {
                Text("End Show")
                    .font(.custom(poppinsSemiBold, size: 13.0))
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.defaultTheme)
                    .cornerRadius(16)
            }

            Spacer()
        }
        .edgesIgnoringSafeArea(.top)
        .padding()
        .background(Color.white)
        .cornerRadius(20)
    }
}
