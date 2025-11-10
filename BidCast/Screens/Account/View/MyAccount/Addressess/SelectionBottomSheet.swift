//
//  SelectionBottomSheet.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 30/07/25.
//
import SwiftUI

struct SelectionBottomSheet: View {
    var title: String = ""
    var message: String = ""
    @Binding var options: [String]
    var themeColor: ColorResource = .defaultTheme
    var isMultiSelect: Bool = false

    @Binding var selectedOptions: Set<String>
    var onSelectionDone: (([Int]) -> Void)? = nil

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.custom(poppinsBold, fixedSize: 24))
                .multilineTextAlignment(.center)

            Text(message)
                .font(.custom(poppinsMedium, fixedSize: 16))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            ScrollView {
                VStack(spacing: 0) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            toggleSelection(option)
                        }) {
                            HStack {
                                Text(option)
                                    .font(.custom(poppinsMedium, fixedSize: 16))
                                    .foregroundColor(.black)
                                    .padding()

                                Spacer()

                                if selectedOptions.contains(option) {
                                    Image(systemName: isMultiSelect ? "checkmark.square.fill" : "checkmark.circle.fill")
                                        .resizable()
                                        .frame(width: 25, height: 25)
                                        .foregroundColor(Color(themeColor))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(maxHeight: selectedOptions.count < 4 ? 550 : screenHeight/2)

            PrimaryButton(
                title: isMultiSelect ? "Done" : "OK",
                isOutLine: false,
                onButtonClick: {
                    let selectedIndexes = selectedOptions.compactMap { selected in
                        options.firstIndex(of: selected)
                    }
                    onSelectionDone?(selectedIndexes)
                },
                width: screenWidth - 24,
                height: 40,
                btnTextColor: .white,
                btnColor: themeColor
            )
            .padding(.top, 10)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
    }

    private func toggleSelection(_ option: String) {
        if isMultiSelect {
            if selectedOptions.contains(option) {
                selectedOptions.remove(option)
            } else {
                selectedOptions.insert(option)
            }
        } else {
            selectedOptions = [option]
        }
    }
}
