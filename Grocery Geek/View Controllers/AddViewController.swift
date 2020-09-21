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
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var barcodeProduct: BarcodeProduct?
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
        
        // Check if item was scanned
        if let barcode = barcodeProduct {
            addLabel.text = "Confirm Details"
            productName.text = barcode.name
            productQuantity.text = barcode.quantity
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
        
        moveFields(toolbarOffset: -keyboardFrame.height, inputOffset: -20)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        moveFields(toolbarOffset: 0, inputOffset: 0)
    }
    
    func moveFields(toolbarOffset: CGFloat, inputOffset: CGFloat) {
        // Create new constraints
        NSLayoutConstraint.deactivate([inputStackHeight, toolbarHeight])
        inputStackHeight = inputStack.bottomAnchor.constraint(equalTo: toolbar.topAnchor, constant: inputOffset)
        toolbarHeight = toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: toolbarOffset)
        
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
        newProduct.name = productName.text
        newProduct.quantity = productQuantity.text
        
        if itemToEdit != nil {
            // Copy over old product
            newProduct.index = itemToEdit!.index
            newProduct.barcode = itemToEdit!.barcode
            
            // Remove old product
            list?.removeFromListProducts(itemToEdit!)
            context.delete(itemToEdit!)
            itemToEdit = nil
            
        } else {
            newProduct.index = Int32(list!.listProducts!.count)
            newProduct.barcode = barcodeProduct
            
        }
        
        list?.insertIntoListProducts(newProduct, at: Int(newProduct.index))
        
        // update info for the barcode
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
