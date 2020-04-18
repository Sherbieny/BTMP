//
//  SubscriptionViewController.swift
//  BTMP
//
//  Created by Eslam El Sherbieny on 17.04.2020.
//  See License folder for this code licensing information.
//

import UIKit

class SubscriptionViewController: UIViewController {
    // MARK: - Types

    fileprivate enum Segment: Int {
        case products, purchases
    }

    // MARK: - Properties

    @IBOutlet fileprivate var containerView: UIView!
    @IBOutlet fileprivate var segmentedControl: UISegmentedControl!
    @IBOutlet fileprivate var restoreButton: UIBarButtonItem!

    fileprivate var utility = Utilities()

    fileprivate lazy var products: Products = {
        let identifier = ViewControllerIdentifiers.products
        guard let controller = storyboard?.instantiateViewController(withIdentifier: identifier) as? Products
        else { fatalError("\(Messages.unableToInstantiateProducts)") }
        return controller
    }()

    fileprivate lazy var purchases: Purchases = {
        let identifier = ViewControllerIdentifiers.purchases
        guard let controller = storyboard?.instantiateViewController(withIdentifier: identifier) as? Purchases
        else { fatalError("\(Messages.unableToInstantiatePurchases)") }
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Disable or hide item.
        restoreButton.disable()

        StoreManager.shared.delegate = self
        StoreObserver.shared.delegate = self

        // Fetch product information.
        fetchProductInformation()
    }

    // MARK: - Switching Between View Controllers

    /// Adds a child view controller to the container.
    fileprivate func addBaseViewController(_ viewController: BaseViewController) {
        addChild(viewController)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.frame = containerView.bounds
        containerView.addSubview(viewController.view)

        NSLayoutConstraint.activate([viewController.view.topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor),
                                     viewController.view.bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor),
                                     viewController.view.leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor),
                                     viewController.view.trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor)])
        viewController.didMove(toParent: self)
    }

    /// Removes a child view controller from the container.
    fileprivate func removeBaseViewController(_ viewController: BaseViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }

    /// Switches between the Products and Purchases view controllers.
    fileprivate func switchToViewController(segment: Segment) {
        switch segment {
        case .products:
            removeBaseViewController(purchases)
            addBaseViewController(products)
        case .purchases:
            removeBaseViewController(products)
            addBaseViewController(purchases)
        }
    }

    // MARK: - Fetch Product Information

    /// Retrieves product information from the App Store.
    fileprivate func fetchProductInformation() {
        // First, let's check whether the user is allowed to make purchases. Proceed if they are allowed. Display an alert, otherwise.
        if StoreObserver.shared.isAuthorizedForPayments {
            restoreButton.enable()

            let resourceFile = ProductIdentifiers()
            
            print("resource file")
            print(resourceFile)
            
            guard let identifiers = resourceFile.identifiers else {
                // Warn the user that the resource file could not be found.
                alert(with: Messages.status, message: resourceFile.wasNotFound)
                return
            }

            if !identifiers.isEmpty {
                switchToViewController(segment: .products)
                // Refresh the UI with identifiers to be queried.
                products.reload(with: [Section(type: .invalidProductIdentifiers, elements: identifiers)])

                // Fetch product information.
                StoreManager.shared.startProductRequest(with: identifiers)
            } else {
                // Warn the user that the resource file does not contain anything.
                alert(with: Messages.status, message: resourceFile.isEmpty)
            }
        } else {
            // Warn the user that they are not allowed to make purchases.
            alert(with: Messages.status, message: Messages.cannotMakePayments)
        }
    }

    // MARK: - Display Alert

    /// Creates and displays an alert.
    fileprivate func alert(with title: String, message: String) {
        let alertController = utility.alert(title, message: message)
        navigationController?.present(alertController, animated: true, completion: nil)
    }

    // MARK: - Restore All Appropriate Purchases

    /// Called when tapping the "Restore" button in the UI.
    @IBAction func restore(_ sender: UIBarButtonItem) {
        // Calls StoreObserver to restore all restorable purchases.
        StoreObserver.shared.restore()
    }

    // MARK: - Handle Segmented Control Tap

    /// Called when tapping any segmented control in the UI.
    @IBAction func segmentedControlSelectionDidChange(_ sender: UISegmentedControl) {
        guard let segment = Segment(rawValue: sender.selectedSegmentIndex)
        else { fatalError("\(Messages.unknownSelectedSegmentIndex)\(sender.selectedSegmentIndex)).") }

        switchToViewController(segment: segment)

        switch segment {
        case .products: fetchProductInformation()
        case .purchases: purchases.reload(with: utility.dataSourceForPurchasesUI)
        }
    }

    // MARK: - Handle Restored Transactions

    /// Handles successful restored transactions. Switches to the Purchases view.
    fileprivate func handleRestoredSucceededTransaction() {
        utility.restoreWasCalled = true

        // Refresh the Purchases view with the restored purchases.
        switchToViewController(segment: .purchases)
        purchases.reload(with: utility.dataSourceForPurchasesUI)
        segmentedControl.selectedSegmentIndex = 1
    }
}

// MARK: - StoreManagerDelegate

/// Extends SubscriptionViewController to conform to StoreManagerDelegate.
extension SubscriptionViewController: StoreManagerDelegate {
    func storeManagerDidReceiveResponse(_ response: [Section]) {
        switchToViewController(segment: .products)
        // Switch to the Products view controller.
        products.reload(with: response)
        segmentedControl.selectedSegmentIndex = 0
    }

    func storeManagerDidReceiveMessage(_ message: String) {
        alert(with: Messages.productRequestStatus, message: message)
    }
}

// MARK: - StoreObserverDelegate

/// Extends SubscriptionViewController to conform to StoreObserverDelegate.
extension SubscriptionViewController: StoreObserverDelegate {
    func storeObserverDidReceiveMessage(_ message: String) {
        alert(with: Messages.purchaseStatus, message: message)
    }

    func storeObserverRestoreDidSucceed() {
        handleRestoredSucceededTransaction()
    }
}