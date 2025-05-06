
//
//  IAP.swift
//  BidCast
//
//  Created by Fazal-JAM-E-329 on 11/12/24.
//

import Foundation
import StoreKit
import SVProgressHUD
import UIKit

// Model for Subscription Product
struct SubsProductModel: Codable {
    var identifier: String
    var price: String
    var name: String
    var currencySymbol: String
}

// Enum for different alert types in the IAPManager
enum IAPManagerAlertType {
    case isPurchasing
    case disabled
    case restored
    case purchased
    case failed
    case invalid
    case initialized
    case productLoaded([SubsProductModel])
    
    func message() -> String {
        switch self {
        case .disabled: return "Purchases are disabled in your device!"
        case .restored: return "You've successfully restored your purchase!"
        case .purchased: return "You've successfully bought this purchase!"
        case .failed: return "Could not complete purchase process.\nPlease try again."
        case .isPurchasing: return "Loading"
        case .invalid: return "Request Product Subscription does not exist.\nPlease provide a valid Product Id."
        case .initialized: return "Stop Loading"
        case .productLoaded(_): return "Product Loaded"
        }
    }
}

class IAPManager: NSObject {
    
    static let shared = IAPManager()
    var presentingViewController: UIViewController?

    // Set of product identifiers to request from App Store
    private let productIdentifiers: Set<String> = ["io.monthly", "io.annually"]
    private var products: [SKProduct] = []
    var pendingFetchProduct: String!
    var fetchAvailableProductsBlock: (([SKProduct]) -> Void)? = nil
    var purchaseStatusBlock: ((IAPManagerAlertType, SKPaymentTransaction?) -> Void)?
    
    private override init() { }
    
    // Initialize the manager and start requesting products
    func initialize() {
        requestProducts()
        startObserving() // Start observing transactions
    }

    // Request products from the App Store
    func requestProducts() {
        let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productRequest.delegate = self
        productRequest.start()
    }

    // Check if the device can make purchases
    func canMakePurchases() -> Bool { return SKPaymentQueue.canMakePayments() }

    // Purchase a specific product
    func purchaseProduct(_ product: String) {
        if productIdentifiers.contains(product) {
            removeAllUnfinishedTransactions()

            if products.isEmpty {
                //dismiss
                SVProgressHUD.dismiss()
                requestProducts()
                pendingFetchProduct = product
                return
            }

            if canMakePurchases() {
                finishUnfinishedTransactions { success in
                    guard success else {
                        self.purchaseStatusBlock?(.failed, nil)
                        return
                    }

                    guard let prod = self.products.first(where: { $0.productIdentifier == product }) else {
                        self.purchaseStatusBlock?(.invalid, nil)
                        return
                    }

                    let ongoingTransactions = SKPaymentQueue.default().transactions.filter {
                        $0.transactionState == .purchasing
                    }

                    if ongoingTransactions.isEmpty {
                        self.startPurchase(for: prod)
                    } else {
                        debugLog("A transaction is already in progress.")
                        self.purchaseStatusBlock?(.isPurchasing, nil)
                    }
                }
            } else {
                self.purchaseStatusBlock?(.disabled, nil)
            }
        } else {
            self.purchaseStatusBlock?(.invalid, nil)
        }
    }

    // Start the purchase process for a product
    private func startPurchase(for product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    // Complete a successful transaction
    private func completeTransaction(_ transaction: SKPaymentTransaction) {
        self.purchaseStatusBlock?(.purchased, transaction)
        finishTransaction(transaction)
    }

    // Finish a transaction and remove from the queue
    private func finishTransaction(_ transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    // Start observing the payment queue for transactions
    func startObserving() {
        SKPaymentQueue.default().add(self)
    }

    // Stop observing the payment queue for transactions
    func stopObserving() {
        SKPaymentQueue.default().remove(self)
    }

    // Restore previous purchases
    func restorePurchase(completion: @escaping (Bool) -> Void) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    // Remove unfinished transactions from the queue
//    func removeAllUnfinishedTransactions() {
//        let transactions = SKPaymentQueue.default().transactions
//        if transactions.isEmpty {
//            debugLog("No unfinished transactions to remove.")
//            return
//        }
//
//        for transaction in transactions {
//            if transaction.transactionState == .purchasing || transaction.transactionState == .deferred {
//                debugLog("Removing unfinished transaction: \(transaction.transactionIdentifier ?? "unknown")")
//                finishTransaction(transaction)
//            }
//        }
//    }
    // Remove unfinished transactions from the queue
    func removeAllUnfinishedTransactions() {
        let transactions = SKPaymentQueue.default().transactions
        if transactions.isEmpty {
            print("No unfinished transactions to remove.")
            return
        }
        
        for transaction in transactions {
            if transaction.transactionState == .purchasing || transaction.transactionState == .deferred || transaction.transactionState == .purchased {
                print("Removing unfinished transaction: \(transaction.transactionIdentifier ?? "unknown")")
                print("transaction state \(transaction.transactionState)")
                finishTransaction(transaction)
            }
            print(">>>>>>>>>>Removing unfinished transaction: \(transaction.transactionIdentifier ?? "unknown")")
        }
    }

    // Finish any unfinished transactions
    func finishUnfinishedTransactions(completion: @escaping (Bool) -> Void) {
        let transactions = SKPaymentQueue.default().transactions
        var allTransactionsFinished = true
        
        for transaction in transactions {
            if transaction.transactionState == .purchasing || transaction.transactionState == .deferred || transaction.transactionState == .failed{
                SKPaymentQueue.default().finishTransaction(transaction)
                debugLog("Finished transaction with identifier: \(transaction.transactionIdentifier ?? "unknown")")
            }
        }
        completion(allTransactionsFinished)
    }

    // Handle failed transactions
    private func failedTransaction(_ transaction: SKPaymentTransaction) {
        if let error = transaction.error as? SKError {
            if error.code != .paymentCancelled {
                debugLog("Error >>> \(error.localizedDescription)")
                SVProgressHUD.dismiss()
                self.purchaseStatusBlock?(.failed, transaction)
            } else {
                SVProgressHUD.dismiss()
                removeAllUnfinishedTransactions()
                debugLog("Transaction was cancelled by the user.")
            }
        }
        finishTransaction(transaction)
    }

    // Handle restored transactions
    private func restoreTransaction(_ transaction: SKPaymentTransaction) {
        self.purchaseStatusBlock?(.restored, transaction)
        finishTransaction(transaction)
    }
}

// MARK: - SKProductsRequestDelegate
extension IAPManager: SKProductsRequestDelegate {
    // Products request response
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0 {
            products = response.products
            self.fetchAvailableProductsBlock?(products)
            
            var result: [SubsProductModel] = []
            products.forEach { prod in
                let productName = prod.localizedTitle
                
                let priceFormatter = NumberFormatter()
                priceFormatter.numberStyle = .currency
                priceFormatter.locale = prod.priceLocale
                
                let numericPrice = priceFormatter.string(from: prod.price) ?? "\(prod.price)"
                let currencySymbol = priceFormatter.currencySymbol ?? ""
                
                result.append(SubsProductModel(
                    identifier: prod.productIdentifier,
                    price: numericPrice,
                    name: productName,
                    currencySymbol: currencySymbol
                ))
            }
            
            debugLog("SKProduct Loaded")
            self.purchaseStatusBlock?(.initialized, nil)
            self.purchaseStatusBlock?(.productLoaded(result), nil)
            
            if let prod = pendingFetchProduct {
                purchaseProduct(prod)
            }
        } else {
            DispatchQueue.main.async {
                if let presentingVC = self.presentingViewController {
                    let alert = UIAlertController(
                        title: "Oops! No Subscription Plans Found",
                        message: "It seems like there’s an issue with the subscription plans. This could be due to a mismatch in product identifiers on App Store Connect. Please check your settings or contact support if the issue continues.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    presentingVC.present(alert, animated: true, completion: nil)
                }
            }
            debugLog("No products found. Check your product identifiers in App Store Connect.")
        }
    }
    
    // Product request failed
    func request(_ request: SKRequest, didFailWithError error: Error) {
        self.purchaseStatusBlock?(.failed, nil)
        debugLog("Product Request Failed >>> \(error.localizedDescription)")
    }
}

// MARK: - SKPaymentTransactionObserver
extension IAPManager: SKPaymentTransactionObserver {
    // Handle restored transactions
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if queue.transactions.first != nil {
            self.purchaseStatusBlock?(.restored, queue.transactions.first)
        } else {
            self.purchaseStatusBlock?(.failed, nil)
        }
    }
    
    // Handle failure in restoring transactions
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("Handle failure in restoring transactions")
        self.purchaseStatusBlock?(.failed, nil)
    }
    
    // Handle updated transactions
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        SVProgressHUD.dismiss()
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                print("Transaction purchased:")
                completeTransaction(transaction)
            case .failed:
                print("Transaction failed:")
                failedTransaction(transaction)
            case .restored:
                print("Transaction restored:")
                restoreTransaction(transaction)
            case .deferred:
                print("Transaction deferred:")
                break
                // Handle deferred transactions, do not finish them right away
                debugLog("Transaction deferred: \(transaction.transactionIdentifier ?? "unknown")")
            case .purchasing:
                print("Transaction purchasing:")
                self.purchaseStatusBlock?(.isPurchasing, nil)
            @unknown default:
                print("Transaction default:")
                break
            }
        }
    }
    
    // Handle store payments
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        // Return true if the transaction should be processed by the App Store, or false to defer processing.
        print("Return true if the transaction should be processed by the App Store, or false to defer processing.")
        if canMakePurchases() {
            SKPaymentQueue.default().add(payment)
            return true
        } else {
            return false
        }
    }

    
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
           print("Called when transactions are removed from the queue (e.g., after being restored)")
       }
}


