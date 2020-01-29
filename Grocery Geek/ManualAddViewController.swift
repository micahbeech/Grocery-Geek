//
//  ManualAddViewController.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2019-05-07.
//  Copyright © 2019 Micah Beech. All rights reserved.
//

import UIKit
import CoreData

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

class ManualAddViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var productName: UITextField!
    @IBOutlet weak var productQuantity: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        NotificationCenter.default.addObserver(self, selector: Selector(("keyboardWillShow:")), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: Selector(("keyboardWillHide:")), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.hideKeyboardWhenTappedAround()
        self.productQuantity.delegate = self
        self.productName.delegate = self
        
    }
    
//    @objc func keyboardWillShow(notification: NSNotification) {
//        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y == 0 {
//                self.view.frame.origin.y -= keyboardSize.height
//            }
//        }
//    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        if self.view.frame.origin.y != 0 {
//            self.view.frame.origin.y = 0
//        }
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func addProduct(_ sender: Any) {
        // Guard against bad input
        if productName.text == "" {
            let alert = UIAlertController(title: "Cannot add item", message: "Please fill in all fields", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(alertAction)
            present(alert, animated: true, completion: nil)
            return
        }
        
        // add product for core data
        let newProduct = Product.init(entity: NSEntityDescription.entity(forEntityName: "Product", in: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)!, insertInto: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
        
        // set the product's properties
        if let name = productName.text {
            newProduct.name = name
        } else {
            print("No text available for name")
            return
        }
        if let quantity = productQuantity.text {
            newProduct.quantity = quantity
        } else {
            print("No text available for quantity")
        }
        newProduct.index = ProductModel.groceryListData.count as NSNumber
        
        ProductModel.groceryListData.append(newProduct)
    }

    
}
