//
//  UIStoryBoardSegueFromTop.swift
//  Grocery Geek
//
//  Created by Micah Beech on 2020-04-26.
//  Copyright © 2020 Micah Beech. All rights reserved.
//

import UIKit

class UIStoryBoardSegueFromTop: UIStoryboardSegue {
    override func perform() {
        let src = self.source as UIViewController
        let dst = self.destination as UIViewController
        
        src.modalPresentationStyle = .fullScreen
        dst.modalPresentationStyle = .fullScreen

        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.transform = CGAffineTransform(translationX: 0, y: -src.view.frame.size.height)
        
        UIView.animate(withDuration: 0.5, animations: {
            dst.view.transform = CGAffineTransform(translationX: 0, y: 0)

            }) { (Finished) in
                src.present(dst, animated: false, completion: nil)
        }
    }
}
