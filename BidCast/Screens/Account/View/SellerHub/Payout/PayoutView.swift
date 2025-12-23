//
//  PayoutView.swift
//  BidCast
//
//  Created by Vivek-JAM_E-328 on 04/10/25.
//

import SwiftUI
import SVProgressHUD
import AlertToast

struct PayoutView: View {
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var enteredAmount: String = "0.00"
    private let walletAmount: Double = 62.0
    @State var sellerID: String = ""
    
    @StateObject private var tipsViewModel = TipsViewModel()
    @State private var sendTipsData: SendTipAmountModel?
    
    @State private var showError: Bool = false
    @State private var showhud: Bool = false
    @State private var hudMsg: String = ""
    @State private var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    
    let minPayout = 10.0
    let maxPayout = 500.0
    
    // Keypad Buttons
    let buttons: [[String]] = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "⌫"]
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0){
                // MARK: Top-Header (fixed)
                PrimaryHeader(
                    title: AppString.Payout,
                    isForBoth: true,
                    leadingImgArr: [.icBack,.appName],
                    onClickLeading: { _ in presentationMode.wrappedValue.dismiss() },
                    count: .constant(0)
                )
            }
            // MARK: - Wallet Display Card
            VStack(spacing: 10) {
                Text("Wallet Amount : $\(String(format: "%.1f", walletAmount))")
                    .font(.custom(poppinsRegular, size: 16.0))
                    .foregroundColor(.black)
                
                Text("$\(enteredAmount)")
                    .font(.custom(poppinsSemiBold, size: 40.0))
                    .foregroundColor(.gray)
                
                Text("Minimum payout $\(Int(minPayout)), maximum $\(Int(maxPayout))")
                    .font(.custom(poppinsRegular, size: 12.0))
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.defaultTheme.opacity(0.1))
            .cornerRadius(16)
            .padding()
            
            // MARK: - Keypad
            VStack(spacing: 16) {
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 16) {
                        ForEach(row, id: \.self) { item in
                            Button(action: {
                                handleTap(item)
                            }) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white)
                                        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                                        .frame(height: 60)
                                    
                                    Text(item)
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundColor(.black)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 32)
            
            // MARK: - Payout Button
            Button(action: {
                print("Payout tapped for $\(enteredAmount)")
                Task {
                    await sendTipsAmountData()
                }
            }) {
                Text("Payout")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.defaultTheme)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.vertical, 32)
            .toast(isPresenting: $showhud) {
                AlertToast(displayMode: .hud, type: .regular, title: hudMsg, style: alertStlye)
                
            }
        }
        .background(Color(UIColor.systemGray6).opacity(0.5))
        .ignoresSafeArea(edges: .bottom)
        Spacer()
            
    }
    
    // MARK: - Handle Button Tap
      private func handleTap(_ value: String) {
          switch value {
          case "⌫":
              if !enteredAmount.isEmpty {
                  enteredAmount.removeLast()
                  if enteredAmount.isEmpty { enteredAmount = "0" }
              }
          case ".":
              if !enteredAmount.contains(".") {
                  enteredAmount += "."
              }
          default:
              if enteredAmount == "0.00" || enteredAmount == "0" {
                  enteredAmount = value
              } else {
                  enteredAmount += value
              }
          }
      }
    
    private func sendTipsAmountData() async {
        guard Reachability.isConnectedToNetwork() else {
            hudMsg = "No Internet Connection"
            showhud = true
            return
        }
        SVProgressHUD.show()
        let request = TipAmountRequest(seller_id: sellerID,
                                       amount: enteredAmount,
                                       card_number: "4242")
        await tipsViewModel.sendTipsAmountData(request: request)
        await SVProgressHUD.dismiss()
        
        if tipsViewModel.sendTipAmountResponse?.status != "success" {
            alertType = .sheetType(
                icon: .alert,
                title: "Error",
                message: tipsViewModel.sendTipAmountResponse?.message ?? "Something went wrong.",
                primaryBtnText: "",
                secondaryBtnText: "OK",
                sheetThemeColor: .pinkBtn
            )
            withAnimation(.snappy) { showError = true }
        } else {
            hudMsg = "Tip Amount Send successfully!!"
            showhud = true
            sendTipsData = tipsViewModel.sendTipAmountResponse?.data
            presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    PayoutView()
}
