//
//  SalesTaxScreen.swift
//  BidCast
//
//  MC Wave 4 cmpbefoaj00033ghgs38av42u — #41 Tax Exemption Application
//  Replaced stub with live form that calls POST /api/tax-exemption/apply
//

import SwiftUI
import SVProgressHUD
import AlertToast

struct SalesTaxScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel = OrderStatusViewModel()

    @State private var businessName: String = ""
    @State private var taxId: String = ""
    @State private var businessType: String = ""
    @State private var showhud = false
    @State private var hudMsg = ""
    @State private var showError = false
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @State private var isSubmitting = false
    @State private var submitted = false
    @State private var submittedApp: TaxExemptionApplicationData? = nil

    let businessTypes = ["LLC", "S-Corp", "C-Corp", "Sole Proprietor", "Non-Profit", "Partnership", "Other"]

    var body: some View {
        VStack(spacing: 0) {
            PrimaryHeader(
                title: "Sales Tax Exemption",
                isForLogo: false,
                leadingImgArr: ["chevron.left"],
                trailingImgArr: [],
                onClickLeading: { _ in presentationMode.wrappedValue.dismiss() },
                count: .constant(0)
            )
            .background(Color.white)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if submitted, let app = submittedApp {
                        // Show submitted status
                        submittedView(app: app)
                    } else {
                        applicationForm
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 20)
            }
        }
        .background(Color.backGround.ignoresSafeArea())
        .toast(isPresenting: $showhud) {
            AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
        }
    }

    // MARK: - Application Form
    @ViewBuilder
    var applicationForm: some View {
        VStack(spacing: 8) {
            Image(systemName: "doc.badge.gearshape")
                .font(.system(size: 48))
                .foregroundColor(.defaultTheme)
                .padding(.top, 8)
            Text("Apply for Tax Exemption")
                .font(.custom(poppinsBold, size: 20))
                .foregroundColor(.black)
            Text("Submit your business details to apply for a sales tax exemption on your purchases.")
                .font(.custom(poppinsMedium, size: 13))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 8)

        VStack(alignment: .leading, spacing: 6) {
            Text("Business Name")
                .font(.custom(poppinsSemiBold, size: 13))
                .foregroundColor(.black)
            TextField("e.g. Acme Corp LLC", text: $businessName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.words)
        }

        VStack(alignment: .leading, spacing: 6) {
            Text("Tax ID / EIN")
                .font(.custom(poppinsSemiBold, size: 13))
                .foregroundColor(.black)
            TextField("e.g. 12-3456789", text: $taxId)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.asciiCapable)
        }

        VStack(alignment: .leading, spacing: 6) {
            Text("Business Type")
                .font(.custom(poppinsSemiBold, size: 13))
                .foregroundColor(.black)
            Menu {
                ForEach(businessTypes, id: \.self) { bt in
                    Button(bt) { businessType = bt }
                }
            } label: {
                HStack {
                    Text(businessType.isEmpty ? "Select business type..." : businessType)
                        .foregroundColor(businessType.isEmpty ? .gray : .black)
                        .font(.custom(poppinsMedium, size: 14))
                    Spacer()
                    Image(systemName: "chevron.down").foregroundColor(.gray)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.gray.opacity(0.4))
                )
            }
        }

        Button(action: submitApplication) {
            HStack {
                if isSubmitting {
                    ProgressView().tint(.white)
                } else {
                    Image(systemName: "paperplane.fill")
                }
                Text(isSubmitting ? "Submitting..." : "Submit Application")
                    .font(.custom(poppinsSemiBold, size: 15))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(formIsValid ? Color.defaultTheme : Color.gray)
            .cornerRadius(28)
        }
        .disabled(!formIsValid || isSubmitting)
        .padding(.top, 8)

        VStack(alignment: .leading, spacing: 8) {
            Label("Applications are reviewed within 3–5 business days.", systemImage: "info.circle")
                .font(.custom(poppinsMedium, size: 12))
                .foregroundColor(.gray)
            Label("You may be asked to provide a certificate PDF by email.", systemImage: "doc.text")
                .font(.custom(poppinsMedium, size: 12))
                .foregroundColor(.gray)
        }
        .padding(12)
        .background(Color.gray.opacity(0.08))
        .cornerRadius(10)
    }

    var formIsValid: Bool {
        !businessName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !taxId.trimmingCharacters(in: .whitespaces).isEmpty &&
        !businessType.isEmpty
    }

    // MARK: - Submitted status view
    @ViewBuilder
    func submittedView(app: TaxExemptionApplicationData) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 56))
                .foregroundColor(.green)
            Text("Application Submitted!")
                .font(.custom(poppinsBold, size: 22))
            Text("Your tax exemption application has been received. You'll be notified when it's reviewed.")
                .font(.custom(poppinsMedium, size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            VStack(alignment: .leading, spacing: 10) {
                infoRow(label: "Business Name", value: app.businessName ?? "")
                infoRow(label: "Tax ID", value: app.taxId ?? "")
                infoRow(label: "Business Type", value: app.businessType ?? "")
                infoRow(label: "Status", value: (app.status ?? "pending").capitalized)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4)
        }
        .padding(.top, 20)
    }

    @ViewBuilder
    func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label).font(.custom(poppinsMedium, size: 13)).foregroundColor(.gray)
            Spacer()
            Text(value).font(.custom(poppinsSemiBold, size: 13)).foregroundColor(.black)
        }
        Divider()
    }

    // MARK: - Submit
    func submitApplication() {
        guard formIsValid else { return }
        Task {
            guard Reachability.isConnectedToNetwork() else {
                hudMsg = "No Internet Connection"; showhud = true; return
            }
            isSubmitting = true
            SVProgressHUD.show()
            let param = TaxExemptionApplyRequest(
                business_name: businessName.trimmingCharacters(in: .whitespaces),
                tax_id: taxId.trimmingCharacters(in: .whitespaces),
                business_type: businessType
            )
            await viewModel.taxExemptionApply(parameters: param)
            await SVProgressHUD.dismiss()
            isSubmitting = false
            if let err = viewModel.errorMessage, !err.isEmpty {
                hudMsg = err; showhud = true; return
            }
            let resp = viewModel.taxExemptionResponse
            if resp.status == "success" {
                submittedApp = resp.data
                submitted = true
                hudMsg = "Application submitted ✔️"
                showhud = true
            } else {
                hudMsg = resp.message ?? "Submission failed"; showhud = true
            }
        }
    }
}

#Preview {
    SalesTaxScreen()
}
