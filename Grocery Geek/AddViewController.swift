//
//  AddViewController.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-04-25.
//  Copyright © 2020 Micah Beech. All rights reserved.
//

import UIKit
import CoreData

class AddViewController: UIViewController {
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var productModel: ProductModel!
    var barcode = ""
    
    @IBOutlet weak var addLabel: UILabel!
    @IBOutlet weak var productName: UITextField!
    @IBOutlet weak var productQuantity: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
        
        productModel = ProductModel(context: context)
        
        let product = productModel.getFromBarcode(barcode: barcode)
        if product != nil {
            addLabel.text = "Confirm Details"
            productName.text = product?.name
            productQuantity.text = product?.quantity
        } else {
            addLabel.text = "Add Product"
        }
    }
    
    @IBAction func addProduct(_ sender: Any) {
        // Guard against bad input
        if productName.text == nil || productName.text == "" {
            let warning = UIAlertController(title: "Cannot add item", message: "Item must have a name", preferredStyle: .alert)
            warning.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(warning, animated: true, completion: nil)
            return
        }
         
        productModel.addToList(productName: productName.text, productQuantity: productQuantity.text, barcode: barcode)
        
        
        if let parent = presentingViewController?.presentingViewController {
            parent.dismiss(animated: false, completion: nil)
        } else {
            dismiss(animated: false, completion: nil)
        }
    }
    
    @IBAction func cancelAddProduct(_ sender: Any) {
        if let parent = presentingViewController?.presentingViewController {
            parent.dismiss(animated: false, completion: nil)
        } else {
            dismiss(animated: false, completion: nil)
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let destinationVC = segue.destination as! ViewController
//        destinationVC.context = context
//    }

}
