//
//  ShowsScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI
import AlertToast

// MARK: - Show Model
struct Show: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let time: String
    let rsvps: Int
}

// MARK: - Shows Screen View
struct ShowsScreen: View {
    @State private var segment: ShowScreenSegment = .shows
    @State private var showError: Bool = false
    @State private var isLoading: Bool = false
    @State private var showhud: Bool = false
    @State private var hudMsg: String = ""
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var appRootManager: AppRootManager

    // Sample data
    let shows = [
        Show(title: "MTG Cards Sale", date: "Feb 15, 2025", time: "8:00 PM EST", rsvps: 156),
        Show(title: "Show Name", date: "Feb 15, 2025", time: "8:00 PM EST", rsvps: 156)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Top Header (fixed)
            PrimaryHeader(
                title: "",
                isForLogo: true,
                leadingImgArr: [.appName],
                trailingImgArr: [.search, .notification],
                onClickLeading: { _ in
                    self.presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .padding(.horizontal)
            .padding(.bottom, 10)
            .frame(height: 50)

            // MARK: - Segmented Control
            CustomSegmentedControl(preselectedIndex: $segment, options: ShowScreenSegment.allCases)
                .padding(.horizontal)

            // MARK: - Scrollable Content
            ScrollView {
                VStack(spacing: 10) {
                    if isLoading {
                        ProgressView().padding()
                    } else if shows.isEmpty {
                        Text("No shows available.")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(shows) { show in
                            ShowCardView(show: show)
                        }
                    }
                    Spacer().frame(height: 80)
                }
                .padding(.top)
            }
            .safeAreaInset(edge: .bottom) {
                // MARK: - Fixed Bottom Button
                PrimaryButton(
                    title: AppString.submit.localized,
                    isOutLine: false,
                    onButtonClick: {
                        // Action
                    },
                    btnTextColor: .white
                )
                .padding(.horizontal)
                .padding(.vertical, 0)
                .background(Color(UIColor.systemGroupedBackground))
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .toast(isPresenting: $showhud) {
            AlertToast(type: .regular, title: hudMsg)
        }
    }
}

// MARK: - Segment Enum
enum ShowScreenSegment: String, CaseIterable, CustomStringConvertible {
    case shows = "Shows"
    case pastShows = "Past Shows"

    var description: String {
        NSLocalizedString(rawValue, comment: "")
    }
}

// MARK: - Preview
#Preview {
    ShowsScreen()
}
