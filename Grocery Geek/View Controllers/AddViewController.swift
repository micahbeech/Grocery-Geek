//
//  AddViewController.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-04-25.
//  Copyright © 2020 Micah Beech. All rights reserved.
//

import UIKit

class AddViewController: UIViewController, UITextFieldDelegate {
    var filteredValues = [Product]()
    
    var barcodeProduct: Barcode?
    var itemToEdit: Product?
    var list: List!
    var section: Int!
    
    let cellReuseIdentifier = "cell"
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var toolbarHeight: NSLayoutConstraint!
    @IBOutlet weak var inputStackHeight: NSLayoutConstraint!
    @IBOutlet weak var inputStack: UIStackView!
    @IBOutlet weak var addLabel: UILabel!
    @IBOutlet weak var productName: UITextField!
    @IBOutlet weak var productQuantity: UITextField!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var suggestionList: UITableView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        productName.delegate = self
        productQuantity.delegate = self
        
        self.suggestionList.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)

        suggestionList.delegate = self
        suggestionList.dataSource = self
        suggestionList.isHidden = itemToEdit != nil
        suggestionList.layer.cornerRadius = 10
        
        productName.addTarget(self, action: #selector(textFieldActive), for: .touchDown)
        productName.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        productName.becomeFirstResponder()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
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
        
        let section = list.getSection(index: self.section)
        filteredValues = section?.searchRecent(text: productName.text!) ?? []
    }
        
    @objc func keyboardWillShow(notification: NSNotification) {
        
        // Get keyboard size
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
        let keyboardFrame = keyboardSize.cgRectValue
        
        // Create new constraints
        NSLayoutConstraint.deactivate([inputStackHeight, toolbarHeight])
        inputStackHeight = inputStack.bottomAnchor.constraint(equalTo: toolbar.topAnchor, constant: -100)
        toolbarHeight = toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -keyboardFrame.height)
        
        // Set constraints
        UIView.animate(withDuration: 0.6) {
            NSLayoutConstraint.activate([self.toolbarHeight, self.inputStackHeight])
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        // Create new constraints
        NSLayoutConstraint.deactivate([inputStackHeight, toolbarHeight])
        inputStackHeight = inputStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        toolbarHeight = toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -view.safeAreaInsets.bottom)
        
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
            suggestionList.isHidden = true
            
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
        
        if itemToEdit != nil {
            
            itemToEdit?.edit(name: productName.text!, quantity: productQuantity.text)
            
        } else {
            
            list.addListProduct(section: section!, name: productName.text!, quantity: productQuantity.text)
            
        }
        
        barcodeProduct?.edit(name: productName.text, quantity: productQuantity.text)
        
        dismissToList()
        
    }
    
    @IBAction func cancelAddProduct(_ sender: Any) {
        
        dismissToList()
    }
    
    func dismissToList() {
        if let vc = presentingViewController as? ScannerViewController {
            vc.presentingViewController?.dismiss(animated: true, completion: nil)
        } else {
            presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    

}
