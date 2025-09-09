//
//  ProductWeightScreen.swift
//  BidCast
//
//  Created by JAM_E_329 on 26/05/25.
//

import SwiftUI
import SVProgressHUD

struct ProductWeightScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State var showhud: Bool = false
    @State var hudMsg: String = ""
    @State var showError: Bool = false

    @State var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    @Binding var weight: String
    @Binding var selectedUnit: String
    @Binding var isHazardous: Bool
    
    var unitOptions: [String]
    var quickWeights: [String]
    
    @Binding var request: StoreProductParam
    
    
    @StateObject private var viewModel =  ListProductViewModel()
    
    var onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            PrimaryHeader(
                title: "Product Weight",
                isForLogo: false,
                leadingImgArr: [.icBack],
                trailingImgArr: [],
                onClickLeading: { _ in
                    presentationMode.wrappedValue.dismiss()
                },
                count: .constant(0)
            )
            .background(Color.white)
            .frame(height: 40)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Info
                    HStack(alignment: .top) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("BidCast calculates shipping fees based on the product weight. You can adjust this later if needed.")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Item Weight Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Item Weight")
                            .font(.subheadline)

                        HStack(spacing: 10) {
                            TextField("0.00", text: $weight)
                                .keyboardType(.decimalPad)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .foregroundColor(.black)
                                .cornerRadius(8)

                            Menu {
                                ForEach(unitOptions, id: \.self) { unit in
                                    Button(unit) { selectedUnit = unit }
                                }
                            } label: {
                                HStack {
                                    Text(selectedUnit)
                                    Image(systemName: "chevron.down")
                                }
                                .padding()
                                .foregroundColor(.black)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Quick Weights
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        ForEach(quickWeights, id: \.self) { qw in
                            Button(action: {
                                weight = qw.replacingOccurrences(of: " oz", with: "")
                            }) {
                                Text(qw)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .foregroundColor(.black)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    // Hazardous Toggle
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Hazardous Material")
                                .font(.subheadline)
                            Spacer()
                            Toggle("", isOn: $isHazardous)
                                .labelsHidden()
                        }
                        Text("Items containing flammable, explosive, or other dangerous materials. ")
                            .font(.caption)
                            + Text(" Learn more about hazardous materials")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            
            // Continue Button
            VStack {
                Button(action: {
                    submitProduct()
                }) {
                    Text("Continue")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 1.0, green: 0.4, blue: 0.4))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .background(Color.white)
        }
    }
    
    // MARK: - Submit Product Logic
    private func submitProduct() {
        // attach weight to request
        request.weight = weight + " " + selectedUnit
        
        // validation
        guard !request.category_id.isEmpty else { showValidation("Please select category"); return }
        guard !request.title.isEmpty else { showValidation("Please enter title"); return }
        guard !request.description.isEmpty else { showValidation("Please enter description"); return }
        guard !request.width.isEmpty else { showValidation("Please enter width"); return }
        guard !request.height.isEmpty else { showValidation("Please enter height"); return }
        guard !request.length.isEmpty else { showValidation("Please enter length"); return }
        guard !request.weight.isEmpty else { showValidation("Please enter weight"); return }
        guard !request.mail_class.isEmpty else { showValidation("Please select mail class"); return }
        guard !request.processing_category.isEmpty else { showValidation("Please select processing category"); return }
        
        // API Call
        Task {
            guard Reachability.isConnectedToNetwork() else {
                showValidation("No Internet Connection")
                return
            }
            SVProgressHUD.show()
            if let paramDict = request.dictionary {
                await viewModel.storeProduct(param: paramDict)
            }
            await SVProgressHUD.dismiss()
            
            if viewModel.errorMessage == nil || viewModel.errorMessage == "" {
                onContinue()
            } else {
                showError = true
                alertType = .sheetType(
                    icon: .alert,
                    title: "Failed",
                    message: viewModel.errorMessage ?? "",
                    primaryBtnText: "",
                    secondaryBtnText: AppString.ok.localized
                )
            }
        }
    }
    
    private func showValidation(_ msg: String) {
        hudMsg = msg
        showhud = true
    }
}
extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments))
            as? [String: Any]
    }
}
