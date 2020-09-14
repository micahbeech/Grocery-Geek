//
//  AddViewController.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-04-25.
//  Copyright © 2020 Micah Beech. All rights reserved.
//

import UIKit
import CoreData

class AddViewController: UIViewController, UITextFieldDelegate {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var barcode = ""
    var product:BarcodeProduct? = nil
    var existingBarcodes = [BarcodeProduct]()
    var groceryListData = [ListProduct]()
    var itemToEdit: ListProduct? = nil
    
    @IBOutlet weak var addLabel: UILabel!
    @IBOutlet weak var productName: UITextField!
    @IBOutlet weak var productQuantity: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productName.delegate = self
        productQuantity.delegate = self
        
        productName.becomeFirstResponder()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        do {
            groceryListData = try context.fetch(ListProduct.fetchRequest())
            existingBarcodes = try context.fetch(BarcodeProduct.fetchRequest())
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for item in existingBarcodes {
            if (item.barcode == barcode) {
                product = item
                break
            }
        }
        if let barcodeProduct = product {
            addLabel.text = "Confirm Details"
            productName.text = barcodeProduct.name
            productQuantity.text = barcodeProduct.quantity
        } else if let item = itemToEdit {
            addLabel.text = "Edit Product"
            productName.text = item.name
            productQuantity.text = item.quantity
        } else {
            addLabel.text = "Add Product"
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y == 0{
            self.view.frame.origin.y -= keyboardFrame.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        if self.view.frame.origin.y != 0{
            self.view.frame.origin.y += keyboardFrame.height
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @IBAction func addProduct(_ sender: Any) {
        // Guard against bad input
        if productName.text == nil || productName.text == "" {
            let warning = UIAlertController(title: "Cannot add item", message: "Item must have a name", preferredStyle: .alert)
            warning.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(warning, animated: true, completion: nil)
            return
        }
        
        // add product for core data
        let entity = NSEntityDescription.entity(forEntityName: "ListProduct", in: context)
        let newProduct = NSManagedObject(entity: entity!, insertInto: context) as! ListProduct
         
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
        
        if let index = itemToEdit?.index {
            newProduct.index = index
            context.delete(itemToEdit!)
        } else {
            newProduct.index = Int32(groceryListData.count)
        }
        
        if barcode != "" {
            if let barcodeProduct = product {
                barcodeProduct.name = newProduct.name
                barcodeProduct.quantity = newProduct.quantity
            } else {
                let barcodeEntity = NSEntityDescription.entity(forEntityName: "BarcodeProduct", in: context)
                let barcodeProduct = NSManagedObject(entity: barcodeEntity!, insertInto: context) as! BarcodeProduct
                barcodeProduct.name = newProduct.name
                barcodeProduct.quantity = newProduct.quantity
                barcodeProduct.barcode = barcode
            }
        }
        
        performSegue(withIdentifier: "confirmAddProduct", sender: self)
    }

}
