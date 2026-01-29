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
            selectedProductIDs.remove("\(id)")
        }
        print("🗑️ Removed product from list. Remaining: \(products.count)")
    }
    
    /// Remove product by ID
    func removeProduct(withId id: String) {
        products.removeAll { "\($0.id ?? -1)" == id }
        selectedProductIDs.remove(id)
    }
    
    /// Clear all products (after successful show creation)
    func clearAll() {
        products.removeAll()
        selectedProductIDs.removeAll()
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
