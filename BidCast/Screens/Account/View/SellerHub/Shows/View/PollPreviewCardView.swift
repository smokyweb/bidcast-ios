//
//  PollPreviewCardView.swift
//  BidCast
//
//  Created by JamTech on 20/11/25.
//

import SwiftUI

struct PollPreviewCardView: View {
    
    var poll: PollModel
    var remainingTime: Int
    var onPollCardTapped: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 14) {
            
            // MARK: - Poll Icon
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.defaultThemeLight)
                
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(.defaultTheme)
                    .font(.system(size: 22, weight: .semibold))
            }
            .frame(width: 48, height: 48)
            
            // MARK: - Text Content
            VStack(alignment: .leading, spacing: 6) {
                
                // Poll Question
                Text(poll.question.capitalizingFirstLetter())
                    .font(.custom(poppinsMedium, size: 15))
                    .foregroundColor(.black)
                    .lineLimit(2)
                
                HStack(spacing: 12) {
                    
                    // Timer
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 13))
                            .foregroundColor(.red.opacity(0.9))
                        
                        Text(timeString(from: remainingTime))
                            .font(.custom(poppinsMedium, size: 13))
                            .foregroundColor(.red.opacity(0.9))
                    }
                    
                    // Votes count
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: 4, height: 4)
                        
                        Text("\(poll.totalVotes) votes")
                            .font(.custom(poppinsRegular, size: 13))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.backGround)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(.backGround, lineWidth: 0.6)
                )
                .shadow(color: .backGround, radius: 1, x: 0, y: 3)
        )
        .padding(.horizontal,12)
        .padding(.vertical, 12)
        .onTapGesture {
            onPollCardTapped?()
        }
    }
    
    // MARK: - Timer format
    private func timeString(from seconds: Int) -> String {
        return String(format: "%02d:%02d", seconds/60, seconds%60)
    }
}
