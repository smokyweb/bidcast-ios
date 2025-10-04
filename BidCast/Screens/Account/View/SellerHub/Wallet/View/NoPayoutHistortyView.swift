//
//  NoPayoutHistortyView.swift
//  BidCast
//
//  Created by JamTech on 04/10/25.
//

import SwiftUI

struct NoDataFoundView: View {
    let image: String
    let title: String

    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .center, spacing: 16) {
                Spacer()

                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .foregroundColor(.gray.opacity(0.6))

                Text(title)
                    .font(.custom(poppinsSemiBold, size: 13))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)

                Spacer()
            }
            Spacer()
        }
    }
}


#Preview {
    NoDataFoundView(image: "noData", title: AppString.NoPayoutHistoryFound)

}
