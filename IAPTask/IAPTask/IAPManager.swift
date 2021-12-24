//
//  IAPManager.swift
//  IAPTask
//
//  Created by Halil Ibrahim Kasapoglu on 16.12.2021.
//

import UIKit
import StoreKit

class IAPManager: NSObject, SKProductsRequestDelegate , SKPaymentTransactionObserver {
    
    fileprivate var productPurchaseCallback: (() -> Void)?

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        print("whats happanning")
                
        for transaction in transactions {
            if transaction.error != nil {
                print("transaction error")
            }
            switch transaction.transactionState {
            case .purchasing:
                print("handle purchasing state")
                break;
            case .purchased:
                productPurchaseCallback?()
                queue.finishTransaction(transaction)
                productPurchaseCallback = nil
                print("handle purchased state")
                break;
            case .restored:
                print("handle restored state")
                break;
            case .failed:
                print("handle failed state")
                break;
            case .deferred:
                print("handle deferred state")
                break;
            @unknown default:
                print("Fatal Error");
            }
        }
        
    }
    
    
    private var productRequest: SKProductsRequest?
    private let productIdentifiers = Set(
        arrayLiteral: "com.temporary.premium_membership"
    )
    var products: [SKProduct]?
    
    static var manager: IAPManager = {
        return IAPManager()
    }()
    
    func initialize() {
        requestProducts()
        SKPaymentQueue.default().add(self)

    }
    
    private func requestProducts() {
        productRequest?.cancel()
        
        let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productRequest.delegate = self
        productRequest.start()
        
        self.productRequest = productRequest
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        guard !response.products.isEmpty else {
            print("Found 0 products")
            return
        }
        
        for product in response.products {
            print("Found product: \(product.productIdentifier)")
        }
        
        products = response.products
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load products with error:\n \(error)")
    }
    
    
    func purchase(productParam : SKProduct , completion: @escaping ()->(Void)) {
        guard let products = products, products.count > 0 else {
            print("Failed purchase request")
            return
        }

        productPurchaseCallback = completion
        
        let payment = SKPayment(product: productParam)
        SKPaymentQueue.default().add(payment)
        
        return
    }
    
}
