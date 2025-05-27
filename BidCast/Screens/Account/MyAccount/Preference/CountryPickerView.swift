//
//  CountryPickerView.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 27/05/25.
//
import SwiftUI

struct CountryPickerView: View {
    @Binding var selectedCountry: String
    @Environment(\.dismiss) var dismiss

    let countries = Locale.isoRegionCodes
        .compactMap { Locale.current.localizedString(forRegionCode: $0) }
        .sorted()

    var body: some View {
        NavigationView {
            List(countries, id: \.self) { country in
                Button {
                    selectedCountry = country
                    dismiss()
                } label: {
                    HStack {
                        Text(country)
                            .foregroundColor(.black)
                        if country == selectedCountry {
                            Spacer()
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Select Country")
            .searchable(text: .constant(""))
        }
    }
}
