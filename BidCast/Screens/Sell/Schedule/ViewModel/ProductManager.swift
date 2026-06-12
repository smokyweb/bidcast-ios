//
//  ProductManager.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 30/12/25.
//

import Foundation
import SwiftUI

class ProductManager: ObservableObject {
    @Published var products: [ProductDataModel1] = []
    @Published var selectedProductIDs: Set<String> = []
    // Basecamp #9991372302: per-product stream quantity (how many units offered
    // during the show). Keyed by product-id string. When absent the caller
    // should fall back to the product's full available quantity.
    @Published var streamQuantities: [String: Int] = [:]

    func addProduct(_ product: ProductDataModel1) {
        let productIdStr = "\(product.id ?? -1)"
        
        
        if !products.contains(where: { "\($0.id ?? -1)" == productIdStr }) {
            products.append(product)
            selectedProductIDs.insert(productIdStr)
            print("✅ Added product: \(product.title ?? "Unknown") (ID: \(productIdStr))")
            print("   Total products: \(products.count)")
        } else {
           
            if let index = products.firstIndex(where: { "\($0.id ?? -1)" == productIdStr }) {
                products[index] = product
                print("✅ Updated existing product")
            }
        }
    }
    func updateProduct(_ updatedProduct: ProductDataModel1) {
            guard let productId = updatedProduct.id else {
                print("⚠️ Cannot update product - no ID")
                return
            }
            
            // Find and replace the existing product
            if let index = products.firstIndex(where: { $0.id == productId }) {
                products[index] = updatedProduct
                print("🔄 Updated product at index \(index): \(updatedProduct.title ?? "Unknown")")
            } else {
                // Product not found, add it instead
                print("⚠️ Product ID \(productId) not found in list, adding instead")
                addProduct(updatedProduct)
            }
        }
    
    /// Add multiple products from inventory
    func addProducts(_ productList: [ProductDataModel1]) {
        for product in productList {
            addProduct(product)
        }
    }
    
    /// Remove product at index
    func removeProduct(at index: Int) {
        guard products.indices.contains(index) else { return }
        let removedProduct = products.remove(at: index)
        if let id = removedProduct.id {
            let idStr = "\(id)"
            selectedProductIDs.remove(idStr)
            streamQuantities.removeValue(forKey: idStr)
        }
        print("🗑️ Removed product from list. Remaining: \(products.count)")
    }
    
    /// Remove product by ID
    func removeProduct(withId id: String) {
        products.removeAll { "\($0.id ?? -1)" == id }
        selectedProductIDs.remove(id)
        streamQuantities.removeValue(forKey: id)
    }

    /// Set the stream quantity for a product (clamped to 1…availableQty)
    func setStreamQuantity(_ qty: Int, forProductId id: String, max availableQty: Int) {
        let clamped = min(max(1, qty), max(1, availableQty))
        streamQuantities[id] = clamped
    }

    /// Return stream quantities as positional arrays aligned with selectedProductIDs.
    /// Both arrays share the same ordering so the server receives them in lockstep.
    func orderedProductIdsAndQuantities() -> (ids: [String], quantities: [Int]) {
        let ids = Array(selectedProductIDs)
        let qtys = ids.map { id -> Int in
            if let q = streamQuantities[id] { return q }
            // Fallback: product's full available quantity (or 1 when unavailable)
            let product = products.first { "\($0.id ?? -1)" == id }
            return max(1, product?.availableQuantity ?? 1)
        }
        return (ids, qtys)
    }

    /// Clear all products (after successful show creation)
    func clearAll() {
        products.removeAll()
        selectedProductIDs.removeAll()
        streamQuantities.removeAll()
        print("🗑️ Cleared all products")
    }
    
    /// Get comma-separated product IDs for API
    func getProductIDsString() -> String {
        return selectedProductIDs.joined(separator: ",")
    }
    
    /// Toggle product selection
    func toggleSelection(for productId: String) {
        if selectedProductIDs.contains(productId) {
            selectedProductIDs.remove(productId)
        } else {
            selectedProductIDs.insert(productId)
        }
    }
}
