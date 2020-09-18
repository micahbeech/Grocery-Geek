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
    var product: BarcodeProduct?
    var itemToEdit: ListProduct?
    var list: List?
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var toolbarHeight: NSLayoutConstraint!
    @IBOutlet weak var inputStackHeight: NSLayoutConstraint!
    @IBOutlet weak var inputStack: UIStackView!
    @IBOutlet weak var addLabel: UILabel!
    @IBOutlet weak var productName: UITextField!
    @IBOutlet weak var productQuantity: UITextField!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productName.delegate = self
        productQuantity.delegate = self
        
        productName.becomeFirstResponder()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // Get existings barcodes
        var barcodeProducts = [BarcodeProduct]()
        do {
            barcodeProducts = try context.fetch(BarcodeProduct.fetchRequest())
        } catch {
            print("Could not fetch barcodes")
        }
        
        // Check for matches
        if barcode != "" {
            for item in barcodeProducts {
                if item.barcode == barcode {
                    product = item
                    break
                }
            }
        }
        
        // Check if item was scanned
        if let barcodeProduct = product {
            addLabel.text = "Confirm Details"
            productName.text = barcodeProduct.name
            productQuantity.text = barcodeProduct.quantity
            addButton.title = "Confirm"
        
        // Check if item is to be edited
        } else if let item = itemToEdit {
            addLabel.text = "Edit Product"
            productName.text = item.name
            productQuantity.text = item.quantity
            addButton.title = "Confirm"
        
        // Manual addition
        } else {
            addLabel.text = "Add Product"
            addButton.title = "Add"
        }
    }
        
    @objc func keyboardWillShow(notification: NSNotification) {
        
        // Get keyboard size
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        
        // Create new constraints (so elements are visible when keyboard is showing)
        NSLayoutConstraint.deactivate([inputStackHeight, toolbarHeight])
        inputStackHeight = inputStack.bottomAnchor.constraint(equalTo: toolbar.topAnchor, constant: -20)
        toolbarHeight = toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -keyboardFrame.height)
        
        // Set constraints
        UIView.animate(withDuration: 0.6) {
            NSLayoutConstraint.activate([self.toolbarHeight, self.inputStackHeight])
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        // Create new constraints (replace elements once keyboard disappears)
        NSLayoutConstraint.deactivate([inputStackHeight, toolbarHeight])
        inputStackHeight = inputStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        toolbarHeight = toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        // Set constraints
        UIView.animate(withDuration: 0.6) {
            NSLayoutConstraint.activate([self.toolbarHeight, self.inputStackHeight])
            self.view.layoutIfNeeded()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == productName {
            // hit return in name, start typing in quantity
            productQuantity.becomeFirstResponder()
            
        } else if textField == productQuantity {
            // hit return in quantity, add product to list
            addProduct(self)
        }
        
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
            // Copy over old product
            newProduct.index = index
            newProduct.barcode = itemToEdit?.barcode
            
            // Remove old product
            list?.removeFromListProducts(itemToEdit!)
            context.delete(itemToEdit!)
            itemToEdit = nil
        } else {
            newProduct.index = Int32(list!.listProducts!.count)
        }
        
        list?.insertIntoListProducts(newProduct, at: Int(newProduct.index))
        
        if barcode != "" {
            
            if let barcodeProduct = product {
                // Barcode already existed, update product
                newProduct.barcode = barcodeProduct
                
            } else {
                // No barcode, create new one for product
                let barcodeEntity = NSEntityDescription.entity(forEntityName: "BarcodeProduct", in: context)
                let barcodeProduct = NSManagedObject(entity: barcodeEntity!, insertInto: context) as! BarcodeProduct
                barcodeProduct.barcode = barcode
                newProduct.barcode = barcodeProduct
            }
        }
        
        // update info for the scanned barcode
        newProduct.barcode?.name = newProduct.name
        newProduct.barcode?.quantity = newProduct.quantity
        
        if let vc = presentingViewController as? ScannerViewController {
            vc.presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            presentingViewController?.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func cancelAddProduct(_ sender: Any) {
        if let vc = presentingViewController as? ScannerViewController {
            vc.presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    

}
