//
//  StepCard.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 19/05/25.
//

import SwiftUI
import RichText

struct StepCard: View {
    let prepare :  LessonModel
    let index: Int
    let isCurrent: Bool
    var action: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack(alignment: .top, spacing: 8) {
                ZStack {
                    Circle()
                        .fill(prepare.isLocked ? Color(.systemGray4) : Color.defaultTheme)
                        .frame(width: 32, height: 32)
                    
                    if prepare.isLocked {
                           Image(systemName: "lock.fill")
                               .foregroundColor(.white)
                       } else if prepare.isDone ?? false {
                           Image(systemName: "checkmark")
                               .foregroundColor(.white)
                       } else {
                        Text("\(index)")
                            .foregroundColor(.white)
                            .font(.custom(poppinsSemiBold, size: 13.0))
                    }
                }
                .padding(.leading,8)
                VStack(alignment: .leading, spacing: 4) {
                    Text(prepare.title ?? "")
                        .font(.custom(poppinsSemiBold, size: 13.0))
                        .foregroundColor(prepare.isLocked ? .gray : .defaultTheme)
                    RichText(html: prepare.description ?? "")
                        .customCSS(
 """
 body {
 font-size: 12px;
 }                      
 """
                        )
                        .font(.custom(poppinsRegular, fixedSize: 12))
                    
                }
//                Spacer()
            }
            
            .padding(.all,12)
            if isCurrent && !prepare.isLocked {
                PrimaryButton(title: "Continue",isOutLine: false,onButtonClick: {
                    action()
                },cornerRadius: 32,btnTextColor: .white)
                .padding(.horizontal,8)
                .padding(.bottom,8)
//                .padding(.horizontal,12)
            }
        }

        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrent ? Color.defaultTheme : Color.clear, lineWidth: 2)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white)
                        .opacity(prepare.isLocked ? 0.6 : 1)
                )
                .padding(.horizontal,12)
        )
               
    }
    

  
}
