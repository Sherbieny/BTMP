//
//  Vault.swift
//  BTMP
//
//  Created by Eslam El Sherbieny on 21.04.2020.
//  Copyright © 2020 Sherboapps. All rights reserved.
//  Copyright (c) 2017 dagostini <dejan.agostini@gmail.com>
//

import Foundation
import StoreKit
import UIKit

open class Vault {
    // MARK: - Properties

    private enum Keys: String, CaseIterable {
        case is_in_intro_offer_period
        case expires_date
        case original_transaction_id
        case original_purchase_date_pst
        case is_trial_period
        case quantity
        case purchase_date_pst
        case expires_date_pst
        case web_order_line_item_id
        case product_id
        case original_purchase_date_ms
        case purchase_date
        case transaction_id
        case purchase_date_ms
        case original_purchase_date
        case expires_date_ms
        case cancellation_date
        case cancellation_date_ms
        case cancellation_date_pst
        case cancellation_reason
        case is_upgraded
        case promotional_offer_id
        case subscription_group_identifier
    }
    
    public enum PurchaseKeys: String {
        case transactionDate
        case productIdentifier
        case transactionIdentifier
        case originalTransactionIdentifier
        case originalTransactionDate
    }

    public static let shared = Vault()

    private let deviceId = UIDevice.current.identifierForVendor

    #if DEBUG
        private let verificationUrl = "https://sandbox.itunes.apple.com/verifyReceipt"
    #else
        private let verificationUrl = "https://buy.itunes.apple.com/verifyReceipt"
    #endif

    // MARK: - Init

    private init() {}

//    open subscript(key: String) -> String? {
//        get {
//            return load(withKey: key)
//        } set {
//            DispatchQueue.global().sync(flags: .barrier) {
//                self.save(newValue, forKey: key)
//            }
//        }
//    }

    // MARK: - Private Functions

    private func load(withKey key: String) -> String? {
        let query = keychainQuery(withKey: key)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnData as String)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnAttributes as String)

        var result: CFTypeRef?
        let status = SecItemCopyMatching(query, &result)

        guard
            let resultsDict = result as? NSDictionary,
            let resultsData = resultsDict.value(forKey: kSecValueData as String) as? Data,
            status == noErr
        else {
            print("Load status: \(status)")
            return nil
        }
        return String(data: resultsData, encoding: .utf8)
    }

    private func save(_ string: String?, forKey key: String) {
        let query = keychainQuery(withKey: key)
        let objectData: Data? = string?.data(using: .utf8, allowLossyConversion: false)

        if SecItemCopyMatching(query, nil) == noErr {
            if let dictData = objectData {
                let status = SecItemUpdate(query, NSDictionary(dictionary: [kSecValueData: dictData]))
                print("Update status: \(status)")
            } else {
                let status = SecItemDelete(query)
                print("Delete status: \(status)")
            }
        } else {
            if let dictData = objectData {
                query.setValue(dictData, forKey: kSecValueData as String)
                let status = SecItemAdd(query, nil)
                print("Update status: \(status)")
            }
        }
    }

    private func keychainQuery(withKey key: String) -> NSMutableDictionary {
        let result = NSMutableDictionary()
        result.setValue(kSecClassGenericPassword, forKey: kSecClass as String)
        result.setValue(key, forKey: kSecAttrService as String)
        result.setValue(kSecAttrAccessibleWhenUnlockedThisDeviceOnly, forKey: kSecAttrAccessible as String)
        return result
    }

    private func parseReceipt(_ json: Dictionary<String, Any>) {
        guard let receipts_array = json["latest_receipt_info"] as? [Dictionary<String, String>] else {
            print("failed to parse receipt")
            return
        }

        print("receipts count = \(receipts_array.count)")
        for receipt in receipts_array {
            print("checking receipts")
            print(receipt)
            let productID = receipt.index(forKey: Keys.product_id.rawValue) != nil ? receipt["product_id"] : nil

            if productID != nil && receipt.index(forKey: Keys.expires_date_ms.rawValue) != nil {
                guard let expiryDate = parseDateFromReceipt(from: receipt, key: Keys.expires_date_ms.rawValue) else {
                    print("failed to parse expiry date from receipt")
                    return
                }
                if expiryDate > Date() {
                    // save date into vault for each product if it is not expired
                    Keys.allCases.forEach { key in
                        if receipt.index(forKey: key.rawValue) != nil {
                            let value = receipt[key.rawValue]!
                            save(value, forKey: key.rawValue)
                            print("saved value \(value) for key \(key.rawValue)")
                        } else {
                            print("Notice: key \(key.rawValue) not found in receipt")
                        }
                    }
                } else {
                    print("subscription for product \(String(describing: productID)) expired")
                    // clear saved receipt
                    Keys.allCases.forEach { key in
                        save(nil, forKey: key.rawValue)
                        print("deleted for key \(key.rawValue)")
                    }
                }

            } else {
                print("Error: corrupted receipt found")
                // clear saved receipt
                Keys.allCases.forEach { key in
                    save(nil, forKey: key.rawValue)
                    print("deleted for key \(key.rawValue)")
                }
            }
        }
    }

    // MARK: - Helper Functions

    /**
     Get expiry date string from receipt and return Date object
     */
    private func parseDateFromReceipt(from receiptInfo: Dictionary<String, Any>, key: String) -> Date? {
        guard
            let requestDateString = receiptInfo[key] as? String,
            let requestDateMs = Double(requestDateString) else {
            return nil
        }
        return Date(timeIntervalSince1970: requestDateMs / 1000)
    }

    /**
     parse date string and return Date object
     */
    private func parseDateFromString(from requestDateString: String) -> Date? {
        guard
            let requestDateMs = Double(requestDateString) else {
            return nil
        }
        return Date(timeIntervalSince1970: requestDateMs / 1000)
    }

    // MARK: - Public Functions

    /**
     Check whether the user has a valid subscription
     */
    public func isAutherizedForUse() -> Bool {
        var isAutherized: Bool = false

        if let expiryDate: String = load(withKey: Keys.expires_date_ms.rawValue) {
            guard let date = parseDateFromString(from: expiryDate) else {
                print("Failed to parse date from string")
                return false
            }
            if date > Date() {
                isAutherized = true
            }

        } else {
            print("no receipt expiry date found")
        }

        return isAutherized
    }

    /**
     get the latest receipt from app store and validate its expiry date
     */
    public func validateReceipt() {
        print("validateReceipt called")
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            do {
                print("begin")
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                let receiptString = receiptData.base64EncodedString(options: [])
                let requestData = ["receipt-data": receiptString, "password": "48ce8a9c398e489291db9c4c77108853", "exclude-old-transactions": true] as [String: Any]
                var request = URLRequest(url: URL(string: verificationUrl)!)
                request.httpMethod = "POST"
                request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
                let httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: [])
                request.httpBody = httpBody

                URLSession.shared.dataTask(with: request) { data, _, error in
                    DispatchQueue.main.async {
                        if data != nil {
                            if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) {
                                self.parseReceipt(json as! Dictionary<String, Any>)
                                return
                            }
                        } else {
                            print("error validating receipt: \(error?.localizedDescription ?? "")")
                        }
                    }
                }.resume()
                // Read receiptData
            } catch { print("Couldn't read receipt data with error: " + error.localizedDescription) }
        }
    }

    /**
     Get latest purchased Transaction
     */
    public func getPurchasedProductDetails() -> [String: Any]? {
        guard let productId = load(withKey: Keys.product_id.rawValue) else {
            return nil
        }
        // Create dummy transaction and payment
        
        var data = [String:Any]()
                
        data[PurchaseKeys.productIdentifier.rawValue] = productId
                
        guard let transactionId = load(withKey: Keys.transaction_id.rawValue) else {
            return nil
        }
        data[PurchaseKeys.transactionIdentifier.rawValue] = transactionId
        guard let dateString = load(withKey: Keys.purchase_date_ms.rawValue) else {
            return nil
        }

        guard let date = parseDateFromString(from: dateString) else {
            return nil
        }
        
        data["transactionDate"] = date
        
        // Add original purchase data if applicable
        if let originalTransactionId = load(withKey: Keys.original_transaction_id.rawValue) {
            
            if let originalTransactionDate = load(withKey: Keys.original_purchase_date_ms.rawValue), let originalDate = parseDateFromString(from: originalTransactionDate) {
                
                data[PurchaseKeys.originalTransactionDate.rawValue] = originalDate
            }
            
            data[PurchaseKeys.originalTransactionIdentifier.rawValue] = originalTransactionId
        }

        return data
    }
    
    public func getPurchasedProductId() -> String? {
        return load(withKey: Keys.product_id.rawValue)
    }

    public func hasPurchasedTransaction() -> Bool {
        return load(withKey: Keys.product_id.rawValue) != nil
    }
}

extension Date {
    init?(millisecondsSince1970: String) {
        guard let millisecondsNumber = Double(millisecondsSince1970) else {
            return nil
        }
        self = Date(timeIntervalSince1970: millisecondsNumber / 1000)
    }
}
