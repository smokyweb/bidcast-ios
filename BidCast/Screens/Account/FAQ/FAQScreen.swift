//
//  FAQScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 16/05/25.
//

import SwiftUI

struct ExpandableItem: Codable,Identifiable {
    var id : Int?
    var question: String?
    var answer: String?
}


struct FAQScreen: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedButton: FAQButton = .AllFAQ
    @State private var items: [ExpandableItem] = []

    var body: some View {
        VStack(spacing: 0){
            PrimaryHeader(
                title: "FAQ",
                isForLogo : false, leadingImgArr: [.icBack],
                trailingImgArr: [.search],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .frame(height: 50)
            .background(Color.white)
            .shadow(radius: 2)
            
            // Header and SegmentedControl...
            SegmentedControlView(segments: FAQButton.allCases, selectedSegment:$selectedButton, isWithBorder: true)
                .padding(.top ,20)

            ScrollView {
                VStack(spacing: 20) {
                    ForEach(items) { item in
                        FAQCell(title: item.question ?? "", content: item.answer ?? "")
                    }
                }
                .padding(.top ,20)
                .padding(.leading ,0)
            }
        }
        .onAppear {
            loadFAQData(for: selectedButton)
        }
        .onChange(of: selectedButton) { newValue in
            loadFAQData(for: newValue)
        }
    }

    func loadFAQData(for type: FAQButton) {
        switch type {
        case .AllFAQ:
            items = [
                ExpandableItem(id: 1, question: "All: What is this?", answer: "This is an answer."),
                ExpandableItem(id: 2, question: "All: How to use it?", answer: "Here's how.")
            ]
        case .biding:
            items = [
                ExpandableItem(id: 3, question: "Bidding: How do I bid?", answer: "Use the bidding system."),
            ]
        case .payment:
            items = [
                ExpandableItem(id: 4, question: "Payment: How do I pay?", answer: "Use a credit card."),
            ]
        }
    }
}


#Preview {
    FAQScreen()
}

enum FAQButton: String, CaseIterable, CustomStringConvertible {
    case AllFAQ = "ALL FAQs"
    case biding = "Bidding"
    case payment = "Payment"
    var description: String {
        return rawValue
    }
}


