//
//  FAQScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 16/05/25.
//

import SwiftUI

// Expandable Item Model
struct ExpandableItem: Codable, Identifiable {
    var id: Int
    var question: String?
    var answer: String?
}

// FAQ Screen
struct FAQScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedButton: FAQButton = .AllFAQ
    @State private var items: [ExpandableItem] = []
    @State private var expandedItemID: Int? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Primary Header
            PrimaryHeader(
                title: "FAQ",
                isForLogo: false,
                leadingImgArr: [.icBack],
                trailingImgArr: [.search],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .frame(height: 50)
            .background(Color.white)
            .shadow(radius: 2)

            // Segmented Control
            SegmentedControlView(segments: FAQButton.allCases, selectedSegment: $selectedButton, isWithBorder: true)
                .padding(.top, 20)

            // FAQ List
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(items) { item in
                        FAQCell(
                            title: item.question ?? "",
                            content: item.answer ?? "",
                            isExpanded: expandedItemID == item.id,
                            onTap: {
                                expandedItemID = (expandedItemID == item.id) ? nil : item.id
                            }
                        )
                    }
                }
                .padding(.all, 20)
            }
        }
        .background(Color.pearl)
        .onAppear {
            loadFAQData(for: selectedButton)
        }
        .onChange(of: selectedButton) { newValue in
            loadFAQData(for: newValue)
        }
    }

    // Simulate API data loading based on segment selection
    func loadFAQData(for type: FAQButton) {
        switch type {
        case .AllFAQ:
            items = [
                ExpandableItem(id: 1, question: "All: What is this?", answer: "This is an answer."),
                ExpandableItem(id: 2, question: "All: How to use it?", answer: "Here's how."),
                ExpandableItem(id: 3, question: "All: Why does it work?", answer: "It works because of this."),
            ]
        case .biding:
            items = [
                ExpandableItem(id: 4, question: "Bidding: How do I bid?", answer: "Use the bidding system."),
            ]
        case .payment:
            items = [
                ExpandableItem(id: 5, question: "Payment: How do I pay?", answer: "Use a credit card."),
            ]
        }
    }
}

// Enum for FAQ segments
enum FAQButton: String, CaseIterable, CustomStringConvertible {
    case AllFAQ = "ALL FAQs"
    case biding = "Bidding"
    case payment = "Payment"
    
    var description: String {
        return rawValue
    }
}

// Preview for the FAQ Screen
#Preview {
    FAQScreen()
}

