//
//  ShareShowSheet.swift
//  BidCast
//
//  Created by JAM_E_329 on 28/05/25.
//

import SwiftUI

struct ShareOption: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
    let backgroundColor: Color
    let action: () -> Void
}

struct ExtraShareAction: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
    let action: () -> Void
}

struct ShowDetails {
    let title: String
    let username: String
    let image: Image
    let description: String
}

struct ShareShowSheet: View {
    let show: ShowDetails
    let shareOptions: [ShareOption]
    let extraActions: [ExtraShareAction]
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Share Show")
                    .font(.title2).bold()
                Spacer()
                Button(action: {
                    onClose()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
            }

            // Show Preview Card
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())

                    VStack(alignment: .leading) {
                        Text(show.title)
                            .font(.headline)
                        Text("@\(show.username)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                show.image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)

                Text(show.description)
                    .font(.body)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)

            // Share Options
            HStack(spacing: 24) {
                ForEach(shareOptions) { option in
                    VStack(spacing: 6) {
                        Button(action: option.action) {
                            Circle()
                                .fill(option.backgroundColor)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    Image(systemName: option.iconName)
                                        .foregroundColor(.white)
                                )
                        }
                        Text(option.title)
                            .font(.footnote)
                    }
                }
            }

            // Extra Actions
            VStack(spacing: 12) {
                ForEach(extraActions) { action in
                    Button(action: action.action) {
                        HStack {
                            Image(systemName: action.iconName)
                                .foregroundColor(.primary)
                            Text(action.title)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .padding()
    }
}
