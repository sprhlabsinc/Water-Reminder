//
//  IAPViewController.swift
//  WaterReminder
//
//  Created by Andrey Aksenov on 7/5/15.
//  Copyright (c) 2015 Suwao Ltd (suwao.com). All rights reserved.
//

import Foundation
import StoreKit

class IAPViewController: UIViewController, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        SKPaymentQueue.default().add(self)
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        if (products.count > 0)  {
            let product = products[0]
            print("Product: \"\(product.localizedTitle)\" found, total: \(products.count )")
            //            let payment: SKPayment = SKPayment(product: product)
            SKPaymentQueue.default().add(SKPayment(product: product))
        } else {
            productsNotFound(response.invalidProductIdentifiers as AnyObject!)
        }
    }
    
    func buyProduct(_ name: String) {
        print("Buying: \(name)")
        if SKPaymentQueue.canMakePayments() {
            let productID = NSSet(object: name)
            let request = SKProductsRequest(productIdentifiers:  (productID as! Set<String>))
            request.delegate = self
            request.start()
        }
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for object: AnyObject in transactions {
            if let transaction: SKPaymentTransaction = object as? SKPaymentTransaction {
                switch transaction.transactionState {
                case .purchasing:
                    print("Purchasing")
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction)
                    productPurchased(transaction.payment.productIdentifier)
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction)
                    //if Int(transaction.error!._code) == SKError.Code.paymentCancelled.rawValue {
                    //    print("Failed \\ Cancelled")
                    //    productCancelled(transaction.payment.productIdentifier)
                    //} else {
                        print("Failed \\ Error")
                        productFailed(transaction.payment.productIdentifier, error: transaction.error! as NSError)
                    //}
                case .restored:
                    SKPaymentQueue.default().restoreCompletedTransactions()
                    productRestored(transaction.payment.productIdentifier)
                default:
                    break
                }
            }
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("Restore finished, elements in queue: \(queue.transactions.count)")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("Restore completed transactions failed with error: \(error)")
        productFailed(nil, error: error as NSError)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Fail with error: \(error.localizedDescription)")
        productFailed(nil, error: error as NSError)
    }
    
    func productsNotFound(_ products: AnyObject!) {
        print("Product: \(products) not found")
    }
    
    func productPurchased(_ product: String) {
        print("Purchased")
    }
    
    func productRestored(_ product: String) {
        print("Restored")
    }
    
    func productFailed(_ product: String?, error: NSError) {
        print("Failed")
    }
    
    func productCancelled(_ product: String) {
        print("Payment cancelled")
    }
}
