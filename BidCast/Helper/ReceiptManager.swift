//
//  ReceiptManager.swift
//  Rise Shine Swing
//
//  Created by Vivek-JAM-E-328 on 28/11/24.
//

import Foundation
class ReceiptManager {
    
    static let shared = ReceiptManager()
    
    private var receipt: String?

    private init() {}
    

    func setReceipt(_ receiptString: String) {
        self.receipt = receiptString
    }
    
    func getReceipt() -> String? {
        return self.receipt
    }
    
    func clearReceipt() {
        self.receipt = nil
    }
    func isReceiptCleared() -> Bool {
        return receipt == nil
    }
}
