//
//  Loader.swift
//  imperium
//
//  Created by JAM-E-282 on 18/01/24.
//

import SwiftUI
import ActivityIndicatorView

struct Loader: View {
    
    @Binding var isLoading: Bool
    
    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .center) {
                ActivityIndicatorView(isVisible: $isLoading, type: .scalingDots())
                    .foregroundColor(.text)
                    .frame(width: 40, height: 40)
            }
            Spacer()
        }
        .frame(width: screenWidth, height:screenHeight)
        
        
//        .ignoresSafeArea([.top,.bottom])
        .edgesIgnoringSafeArea([.top,.bottom])
        .background(.text.opacity(0.2))
    }
}

#Preview {
    Loader(isLoading: .constant(true))
}
