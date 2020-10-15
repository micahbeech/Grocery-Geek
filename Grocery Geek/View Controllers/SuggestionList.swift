//
//  SuggestionList.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-10-15.
//  Copyright © 2020 Micah Beech. All rights reserved.
//

import UIKit

extension AddViewController : UITableViewDelegate, UITableViewDataSource {
    
    override func viewDidLayoutSubviews() {
        updateSuggestionListHeight()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return }
        
        // Close the list and hide the keyboard when tapped outside of view
        if touch.view != suggestionList {
            productName.endEditing(true)
            productQuantity.endEditing(true)
            suggestionList.isHidden = true
        }
    }
    
    @objc func textFieldActive() {
        UIView.animate(withDuration: 0.6) {
            self.suggestionList.isHidden = !self.suggestionList.isHidden
        }
    }
    
    @objc func textFieldDidChange() {
        
        // Get the section and filter it
        let section = list.getSection(index: self.section)
        filteredValues = section?.searchRecent(text: productName.text!) ?? []
        
        // Update the suggestion list
        suggestionList.reloadData()
        updateSuggestionListHeight()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredValues.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Get a resuable cell
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier)!
        
        // Update the cell contents
        cell.textLabel?.text = filteredValues[indexPath.row].name
        cell.textLabel?.font = productName.font
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Fill in the text field with the text from the selected row
        productName.text = filteredValues[indexPath.row].name
        
        // Close the suggestions and keyboard
        tableView.isHidden = true
        productName.endEditing(true)
    }
    
    func updateSuggestionListHeight() {
        
        // Size the suggest list to be as large as the number of rows, but not go past the toolbar
        heightConstraint.constant = min(suggestionList.contentSize.height, toolbar.frame.minY - inputStack.frame.midY - 20)
    }
}
