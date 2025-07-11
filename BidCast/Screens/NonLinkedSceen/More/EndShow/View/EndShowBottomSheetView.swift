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
                    .font(.title2).bold()
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
                        .foregroundColor(.black)
                        .imageScale(.medium)
                    Text("Create a raid")
                        .foregroundColor(.black)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(14)
            }

            // End Show Button
            Button(action: onEndShow) {
                Text("End Show")
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.defaultTheme)
                    .cornerRadius(16)
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
    }
}
