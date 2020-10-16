//
//  AdHelper.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-10-16.
//  Copyright © 2020 Micah Beech. All rights reserved.
//

import UIKit
import GoogleMobileAds

let testingAdUnitID = "ca-app-pub-3940256099942544/2934735716"

extension GADBannerView {
    
    func setUp(root: UIViewController, adUnitID: String) {
        self.adUnitID = adUnitID
        self.rootViewController = root
        self.backgroundColor = .systemBackground
    }
    
    func addToView(view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    func addToViewAtTop(view: UIView) {
        addToView(view: view)
        
        NSLayoutConstraint.activate([topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)])
    }
    
    func addToViewAtBottom(view: UIView) {
        addToView(view: view)
        
        NSLayoutConstraint.activate([bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])
    }
    
    func load() {
        let request = GADRequest()
        request.keywords = ["Food", "Groceries", "Eating"]
        load(request)
    }
}
