////
////  IAPManager.swift
////  imperium
////
////  Created by Maneet-JAM-E-282 on 02/03/24.
////
//
//import Foundation
//import StoreKit
//
//enum IAPManagerAlertType {
//    case isPurchasing
//    case disabled
//    case restored
//    case purchased
//    case failed
//    case invalid
//    case initialized
//    case productLoaded([SubsProductModel])
//    
//    func message() -> String {
//        switch self {
//            case .disabled: return "Purchases are disabled in your device!"
//            case .restored: return "You've successfully restored your purchase!"
//            case .purchased: return "You've successfully bought this purchase!"
//            case .failed: return "Could not complete purchase process.\nPlease try again."
//            case .isPurchasing: return "Loading"
//            case .invalid: return "Request Product Subscription does not exist.\nPlease provide a valid Product Id."
//            case .initialized: return "Stop Loading"
//            case .productLoaded(_): return "Product Loaded"
//        }
//    }
//}
//
//class IAPManager: NSObject {
//    
//        // Singleton instance
//    static let shared = IAPManager()
//    
//        // Product identifiers for your in-app purchases
//    private let productIdentifiers: Set<String> = ["swipe.25.month", "swipe.50.monthly","swipe.100.monthly", "swipe.200.monthly"]
//    
//    private let productIdentifiersUser: Set<String> = ["daily.10.swipes"]
//
//    
//        // Loaded product information
//    private var products: [SKProduct] = []
//    var pendingFetchProduct: String!
//    var fetchAvailableProductsBlock : (([SKProduct]) -> Void)? = nil
//    var purchaseStatusBlock: ((IAPManagerAlertType, SKPaymentTransaction?) -> Void)?
//    
//    private override init() { }
//    
//    func initialize() {
//        requestProducts()
//    }
//    
//    func requestProducts() {
//        if let role: String = UserDefaultsManager.shared.value(forKey: .userRole) {
//            if role == "employer" {
//                let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
//                productRequest.delegate = self
//                productRequest.start()
//            }else{
//                let productRequest = SKProductsRequest(productIdentifiers: productIdentifiersUser)
//                productRequest.delegate = self
//                productRequest.start()
//
//            }
//        }
//
//    }
//    
//    func canMakePurchases() -> Bool { return SKPaymentQueue.canMakePayments() }
//    
//    func purchaseProduct(_ product: String) {
//        
//        if let role: String = UserDefaultsManager.shared.value(forKey: .userRole) {
//            if role == "employer" {
//                
//                if productIdentifiers.contains(product) {
//                    if products.isEmpty {
//                        requestProducts()
//                        pendingFetchProduct = product
//                        return
//                    }
//                    
//                    if canMakePurchases() {
//                        finishUnfinishedTransactions { success in
//                            if success {
//                                for prod in self.products {
//                                    if prod.productIdentifier == product {
//                                        let payment = SKPayment(product: prod)
//                                        SKPaymentQueue.default().add(self)
//                                        SKPaymentQueue.default().add(payment)
//                                    }
//                                }
//                            }
//                        }
//                    } else {
//                        self.purchaseStatusBlock?(.disabled, nil)
//                    }
//                } else {
//                    self.purchaseStatusBlock?(.invalid, nil)
//                }
//            }else{
//                if productIdentifiersUser.contains(product) {
//                    if products.isEmpty {
//                        requestProducts()
//                        pendingFetchProduct = product
//                        return
//                    }
//                    
//                    if canMakePurchases() {
//                        finishUnfinishedTransactions { success in
//                            if success {
//                                for prod in self.products {
//                                    if prod.productIdentifier == product {
//                                        let payment = SKPayment(product: prod)
//                                        SKPaymentQueue.default().add(self)
//                                        SKPaymentQueue.default().add(payment)
//                                    }
//                                }
//                            }
//                        }
//                    } else {
//                        self.purchaseStatusBlock?(.disabled, nil)
//                    }
//                } else {
//                    self.purchaseStatusBlock?(.invalid, nil)
//                }
//                
//            }
//       }
//    }
//    
//        // MARK: - RESTORE PURCHASE
//    func restorePurchase(){
//        self.purchaseStatusBlock?(.isPurchasing, nil)
//        SKPaymentQueue.default().add(self)
//        SKPaymentQueue.default().restoreCompletedTransactions()
//    }
//    
//        // MARK: - Transaction Handling
//    
//    private func completeTransaction(_ transaction: SKPaymentTransaction) {
//            // Handle successful transaction
//        self.purchaseStatusBlock?(.purchased, transaction)
//        finishTransaction(transaction)
//    }
//    
//    private func failedTransaction(_ transaction: SKPaymentTransaction) {
//        if let error = transaction.error as? SKError, error.code != .paymentCancelled {
//            Log.w("Error >>> \(error)")
//        }
//        self.purchaseStatusBlock?(.failed, transaction)
//        finishTransaction(transaction)
//    }
//    
//    private func restoreTransaction(_ transaction: SKPaymentTransaction) {
//            // Handle restored transaction
//        self.purchaseStatusBlock?(.restored, transaction)
//        finishTransaction(transaction)
//    }
//    
//    private func finishTransaction(_ transaction: SKPaymentTransaction) {
//        SKPaymentQueue.default().finishTransaction(transaction)
//        stopObserving()
//    }
//    
//        // MARK: - Other Methods
//    
//    func startObserving() {
//        SKPaymentQueue.default().add(self)
//    }
//    
//    func stopObserving() {
//        SKPaymentQueue.default().remove(self)
//    }
//    
//    private func finishUnfinishedTransactions(completion: @escaping (Bool) -> Void) {
//        var unfinishedTransactionCount = SKPaymentQueue.default().transactions.count
//        if unfinishedTransactionCount == 0 {
//                // No unfinished transactions
//            Log.w("No Unfinished Transaction")
//            completion(true)
//            return
//        }
//        
//        for transaction in SKPaymentQueue.default().transactions {
//            SKPaymentQueue.default().finishTransaction(transaction)
//            unfinishedTransactionCount -= 1
//            
//            if unfinishedTransactionCount == 0 {
//                    // All transactions finished
//                Log.w("All Unfinished Transaction finished")
//                completion(true)
//            }
//        }
//    }
//}
//
//    //MARK: - Transaction Delegate
//extension IAPManager: SKProductsRequestDelegate {
//    
//    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
//        if response.products.count > 0 {
//            products = response.products
//            self.fetchAvailableProductsBlock?(products)
//            var result: [SubsProductModel] = []
//            products.forEach { prod in
//                result.append(SubsProductModel(identifier: prod.productIdentifier, price: "\(prod.price)"))
//            }
//            Log.w("SKProduct Loaded")
//            self.purchaseStatusBlock?(.productLoaded(result), nil)
//            self.purchaseStatusBlock?(.initialized, nil)
//            if let prod = pendingFetchProduct {
//                purchaseProduct(prod)
//            }
//        }
//    }
//    
//    func request(_ request: SKRequest, didFailWithError error: Error) {
//        self.purchaseStatusBlock?(.failed, nil)
//        Log.w("Product Request Failed >>> \(error.localizedDescription)")
//    }
//}
//
//    //MARK: - Transaction Observer
//extension IAPManager: SKPaymentTransactionObserver {
//    
//    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
//        if queue.transactions.first != nil {
//            self.purchaseStatusBlock?(.restored, queue.transactions.first)
//        } else {
//            self.purchaseStatusBlock?(.failed, nil)
//        }
//    }
//    
//    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
//        self.purchaseStatusBlock?(.failed, nil)
//    }
//    
//    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
//        for transaction in transactions {
//            switch transaction.transactionState {
//                case .purchased:
//                    completeTransaction(transaction)
//                    break
//                case .failed:
//                    failedTransaction(transaction)
//                    break
//                case .restored:
//                    restoreTransaction(transaction)
//                    break
//                case .deferred, .purchasing:
//                    self.purchaseStatusBlock?(.isPurchasing, nil)
//                    break
//                @unknown default:
//                    break
//            }
//        }
//    }
//    
//    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
//        if canMakePurchases() {
//            let payment = SKPayment(product: product)
//            SKPaymentQueue.default().add(self)
//            SKPaymentQueue.default().add(payment)
//            return true
//        } else {
//            return false
//        }
//    }
//}
