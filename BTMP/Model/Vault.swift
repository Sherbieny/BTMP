//
//  Vault.swift
//  BTMP
//
//  Created by Eslam El Sherbieny on 21.04.2020.
//  Copyright © 2020 Sherboapps. All rights reserved.
//  Copyright (c) 2017 dagostini <dejan.agostini@gmail.com>
//

import CloudKit
import Foundation
import StoreKit
import UIKit

open class Vault {
    // MARK: - Properties

    private enum Keys: String, CaseIterable {
        case is_active
        case expiry_date
        case remaining_days
    }

    private let iCloudKey = "icloud_denied"

    public static let shared = Vault()

    private let deviceId = UIDevice.current.identifierForVendor

    private static var userId: String?

    private let config: Config = Config()

    #if DEBUG
        private let debugFlag = true
    #else
        private let debugFlag = false
    #endif

    private let serverUrl = "https://btmp-server.herokuapp.com/api/receipt"
    private let timeUrl = "https://btmp-server.herokuapp.com/api/time"
    private let expiryDateUrl = "https://btmp-server.herokuapp.com/api/expirydate"
    private let errorUrl = "https://btmp-server.herokuapp.com/api/error"

    public var isAutherized: Bool = false

    // MARK: - Init

    private init() {
        isAutherizedForUse { isAuth in
            print("is autherized called in init")
            self.isAutherized = isAuth
            print("is autherized done in init")
        }
    }

//    open subscript(key: String) -> String? {
//        get {
//            return load(withKey: key)
//        } set {
//            DispatchQueue.global().sync(flags: .barrier) {
//                self.save(newValue, forKey: key)
//            }
//        }
//    }

    // MARK: - Keychain Functions

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
        print("checking receipts")
        print(json)
        Keys.allCases.forEach { key in
            if json.index(forKey: key.rawValue) != nil {
                let value = "\(json[key.rawValue]!)"
                save(value, forKey: key.rawValue)
                print("saved value \(value) for key \(key.rawValue)")
            } else {
                print("Notice: key \(key.rawValue) not found in response")
            }
        }

        // update isValid values
        isAutherizedForUse { isAuth in
            print("is autherized called in init")
            self.isAutherized = isAuth
            print("is autherized done in init")
        }
    }

    private func updateExpiryDate(_ date: String) {
        save(date, forKey: Keys.expiry_date.rawValue)
    }

    /**
     invalidate purchase
     */
    private func invalidatePurchase() {
        print("removing purchase from device")
        Keys.allCases.forEach { key in
            save(nil, forKey: key.rawValue)
        }
    }

    // MARK: - Helper Functions

    /**
     make custom error
     */
    private func getError(msg message: String) -> NSError {
        return NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: message])
    }

    /**
     Make HTTP request
     */
    private func httpRequest(with request: URLRequest, completion: @escaping (_ response: Dictionary<String, Any>?) -> Void) {
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if data != nil {
                    print("data received from server")
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? Dictionary<String, Any> {
                        print("Http request success - returning Dictionary")
                        completion(json)
                        return

                    } else {
                        print("Failed to parse json response")
                        completion(nil)
                        return
                    }
                } else {
                    print("error making HTTP request: \(error?.localizedDescription ?? "")")
                    completion(nil)
                    return
                }
            }
        }.resume()
    }

    /**
     parse date string and return Date object
     */
    private func parseDateFromString(from requestDateString: String) -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        guard let date = dateFormatter.date(from: requestDateString) else {
            return nil
        }

        return date
    }

    /**
     get server date and time
     */
    private func getTime(completion: @escaping (_ time: Date?) -> Void) {
        print("getting time")
        var request = URLRequest(url: URL(string: timeUrl)!)
        request.httpMethod = "GET"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")

        httpRequest(with: request) { response in
            if let data = response {
                if data.index(forKey: "time") != nil {
                    if let timeString: String = data["time"] as? String {
                        print("get time successfull - returnin time")
                        completion(self.parseDateFromString(from: timeString))
                        return
                    } else {
                        print("getTime responded with corrupted data")
                        completion(nil)
                        return
                    }

                } else {
                    print("getTime responded with no time data")
                    completion(nil)
                    return
                }
            } else {
                print("Failed to get time - bad response")
                completion(nil)
            }
        }
    }

    /**
     Get logged in iCloud user id (record name)
     */
    private func getUserId(completion: @escaping (_ userId: String?) -> Void) {
        print("getUserId called")

        // check if user denied access
        if isCloudDenied() {
            completion(nil)
            return
        }

        if Vault.userId == nil {
            print("getting user ID fresh")
            CKContainer.default().requestApplicationPermission(.userDiscoverability) { status, error in
                if error == nil {
                    if status == .granted {
                        CKContainer.default().fetchUserRecordID { recordId, _ in
                            if recordId?.recordName != nil {
                                print("user id found - assigning to static")
                                Vault.self.userId = recordId?.recordName
                                completion(recordId?.recordName)
                                return
                            } else {
                                print("username not found")
                                completion(nil)
                                return
                            }
                        }
                    } else if status == .denied {
                        self.saveDeniedAccess()
                        completion(nil)
                        return
                    } else {
                        print("issue getting permission")
                        completion(nil)
                        return
                    }
                } else {
                    print("error requesting record name permission")
                    print(error?.localizedDescription ?? "unkniewn error")
                    completion(nil)
                    return
                }
            }
        } else {
            print("user id already loaded")
            completion(Vault.userId)
            return
        }
    }

    private func getExpiryDateFromDevice() -> Date? {
        if let expiryDate: String = load(withKey: Keys.expiry_date.rawValue) {
            guard let date = parseDateFromString(from: expiryDate) else {
                print("Failed to parse date from string")
                return nil
            }
            print("expiry date from device")
            return date
        } else {
            print("no receipt purchase date found")
            return nil
        }
    }

    /**
     Get expiry date from device or server if possible
     */
    private func getExpiryDate(completion: @escaping (_ expiryDate: Date?) -> Void) {
        // first check if user has an icloud id and you have access
        getUserId { userId in
            if let userId = userId {
                print("user id retrieved - getting expiry date from server if it exists")
                var request = URLRequest(url: URL(string: self.expiryDateUrl)!)
                request.httpMethod = "POST"
                request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
                let requestData = ["id": userId]
                let httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: [])
                request.httpBody = httpBody
                self.httpRequest(with: request) { response in
                    if let data = response {
                        if data.index(forKey: "expiry_date") != nil {
                            if let dateString = data["expiry_date"] as? String {
                                print("expiry date from server \(dateString)")
                                // save new date into device
                                self.updateExpiryDate(dateString)
                                if let date = self.parseDateFromString(from: dateString) {
                                    completion(date)
                                    return
                                } else {
                                    print("Failed to parse date from string")
                                    completion(self.getExpiryDateFromDevice())
                                    return
                                }
                            } else {
                                print("Failed to get date string from response")
                                completion(self.getExpiryDateFromDevice())
                                return
                            }
                        } else {
                            print("response has no expiry_date in it")
                            completion(self.getExpiryDateFromDevice())
                            return
                        }
                    } else {
                        print("getExpiryDate responded with bad data")
                        completion(self.getExpiryDateFromDevice())
                        return
                    }
                }
            } else {
                print("No user ID found - checking device")
                completion(self.getExpiryDateFromDevice())
                return
            }
        }
    }

    // MARK: - Receipt Functions

    /**
     get current date plus one month
     */
    private func isPurchaseDateValid(expiryDate: Date, completion: @escaping (_ isValid: Bool) -> Void) {
        getTime { currentDate in
            if let currentDate = currentDate {
                print("time retrieved from server")
                if let remainingDays = Calendar.current.dateComponents([.day], from: currentDate, to: expiryDate).day {
                    print("difference = \(remainingDays) days")
                    self.save("\(remainingDays)", forKey: Keys.remaining_days.rawValue)
                    if remainingDays <= 0 {
                        self.save("0", forKey: Keys.is_active.rawValue)
                        completion(false)
                    } else {
                        self.save("1", forKey: Keys.is_active.rawValue)
                        completion(true)
                    }
                    return
                } else {
                    self.invalidatePurchase()
                    completion(false)
                    return
                }
            } else {
                print("time retrieved from device")
                let currentDate = Date()
                if let remainingDays = Calendar.current.dateComponents([.day], from: currentDate, to: expiryDate).day {
                    print("difference = \(remainingDays) days")
                    self.save("\(remainingDays)", forKey: Keys.remaining_days.rawValue)
                    if remainingDays <= 0 {
                        self.save("0", forKey: Keys.is_active.rawValue)
                        completion(false)
                    } else {
                        self.save("1", forKey: Keys.is_active.rawValue)
                        completion(true)
                    }
                    return
                } else {
                    self.invalidatePurchase()
                    completion(false)
                    return
                }
            }
        }
    }

    /**
     Get user latest purchase receipt if it exists
     */
    private func getReceipt() -> String? {
        
        // bad case filters
        if Bundle.main.appStoreReceiptURL == nil {
            print("app store receipt URL path is nil")
            return nil
        }
        if FileManager.default.fileExists(atPath: Bundle.main.appStoreReceiptURL!.path) == false {
            print("app store receipt URL path not found on device")
            return nil
        }
        let appStoreReceiptURL = Bundle.main.appStoreReceiptURL
        do {
            let receiptData = try Data(contentsOf: appStoreReceiptURL!, options: .alwaysMapped)
            let receiptString = receiptData.base64EncodedString(options: [])
            return receiptString
        } catch {
            print("failed to get data from receipt \(error.localizedDescription)")
            return nil
        }
    }

    /**
     Send to server a notification that the app store receipt url was not found
     */
    private func reportStoreReceiptError(successfull: Bool) {
        getUserId { userId in
            if let userId = userId {
                var request = URLRequest(url: URL(string: self.errorUrl)!)
                request.httpMethod = "POST"
                request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
                var requestData = ["id": userId, "url": "appStoreReceiptURL is null"]
                if Bundle.main.appStoreReceiptURL != nil {
                    requestData = ["id": userId, "url": Bundle.main.appStoreReceiptURL!.path]
                }

                let httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: [])
                request.httpBody = httpBody
                self.httpRequest(with: request) { response in
                    if response != nil {
                        print("Email sent to admin notifying receipt url failure")
                    }
                }
            } else {
                var request = URLRequest(url: URL(string: self.errorUrl)!)
                request.httpMethod = "POST"
                request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
                let requestData = ["id": "none"]
                let httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: [])
                request.httpBody = httpBody
                self.httpRequest(with: request) { response in
                    if response != nil {
                        print("Email sent to admin notifying receipt url failure")
                    }
                }
            }
        }

        // Save purchase localy on device
        if successfull {
            saveLocalReceipt()
        }
    }

    /**
     Save successfull purchase if validation failed for any reason
     */
    private func saveLocalReceipt() {
        var dayComponent = DateComponents()
        dayComponent.day = 31
        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        let calendar = Calendar.current
        guard let expiryDate = calendar.date(byAdding: dayComponent, to: Date()) else {
            print("Failed to create expiry date")
            return
        }
        let remainingDays = "31"
        let isActive = "1"

        save(formatter.string(from: expiryDate), forKey: Keys.expiry_date.rawValue)
        save(isActive, forKey: Keys.is_active.rawValue)
        save(remainingDays, forKey: Keys.remaining_days.rawValue)
    }

    // MARK: - Public Functions

    /**
     If user denied iCloud account access, do no ask again
     */
    public func saveDeniedAccess() {
        save("1", forKey: iCloudKey)
    }

    /**
     If user changed his mind, remove iCloud access lock
     */
    public func saveGrantAccess() {
        save(nil, forKey: iCloudKey)
    }

    /**
     Check if user denied iCloud access
     */
    public func isCloudDenied() -> Bool {
        return load(withKey: iCloudKey) != nil
    }

    /**
     Check if it should show the subscription notification
     */
    public func showRemainingDays() -> Bool {
        guard let remainingDays: String = load(withKey: Keys.remaining_days.rawValue) else {
            print("remaining days not found")
            return false
        }
        if let remainingInt = Int(remainingDays) {
            print("remaining days into int")
            print(remainingInt)
            return (remainingInt < 11)
        }

        return false
    }

    /**
     Get remaining days on subscription
     */
    public func getRemainingDays() -> String? {
        print("getting remaining days")
        guard let remainingDays: String = load(withKey: Keys.remaining_days.rawValue) else {
            print("remaining days not found")
            return nil
        }
        return remainingDays
    }

    /**
     Check whether the user has a valid subscription
     */
    public func isAutherizedForUse(completion: @escaping (_ isAutherized: Bool) -> Void) {
        // Check first if user finished onboarding, to prevent asking for permission before the iCloud page
        if !config.didUserFinishOnboarding() {
            completion(false)
            return
        }

        // Check on device first to reduce processing time when app start and update device variables in background
        // so next time it would be invalid if subscription was over
        if let isActive: String = load(withKey: Keys.is_active.rawValue) {
            print("local is active string \(isActive == "1")")
            completion(isActive == "1")
        } else {
            // if no value is found - retry receipt validation
            validateReceipt(successfull: false) { success in
                if success {
                    if let isActive: String = self.load(withKey: Keys.is_active.rawValue) {
                        print("server is active string \(isActive == "1")")
                        completion(isActive == "1")
                    }
                }
            }
        }

        print("continuing to expiry date")
        getExpiryDate { date in
            if let date = date {
                self.isPurchaseDateValid(expiryDate: date) { isValid in
                    print("expiry date found - returning is valid")
                    completion(isValid)
                }
            } else {
                print("expiry date return no date")
                self.invalidatePurchase()
                completion(false)
            }
        }
    }

    /**
     get the latest receipt from app store and validate its purchase date
     */
    public func validateReceipt(successfull: Bool, completion: @escaping (_ success: Bool) -> Void) {
        print("validateReceipt called")

        print("app store url found and exists on device - processing receipt data")

        getUserId { userId in
            print("user id called and returned")
            var requestData = [String: Any]()

            // If receipt is found - check for user and proceed normally
            if let receiptString = self.getReceipt() {
                if userId != nil {
                    print("user id found and receipt found")
                    requestData = ["receipt-data": receiptString, "debug": self.debugFlag, "client_id": userId!, "exclude-old-transactions": true]

                } else {
                    requestData = ["receipt-data": receiptString, "debug": self.debugFlag, "exclude-old-transactions": true]
                }
            } else {
                if userId != nil {
                    print("user id found and no receipt exists")
                    requestData = ["receipt-data": "", "debug": self.debugFlag, "client_id": userId!, "exclude-old-transactions": true]

                } else {
                    // if no user found and no receipt exists, exit
                    self.reportStoreReceiptError(successfull: successfull)
                    completion(false)
                    return
                }
            }

            var request = URLRequest(url: URL(string: self.serverUrl)!)
            request.httpMethod = "POST"
            request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
            let httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: [])
            request.httpBody = httpBody

            self.httpRequest(with: request) { response in
                if let data = response {
                    self.parseReceipt(data)
                    completion(true)
                    return
                } else {
                    print("Failed to parse receipt from json")
                    self.reportStoreReceiptError(successfull: successfull)
                    completion(false)
                    return
                }
            }
        }
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
