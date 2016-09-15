//
//  RatingControl.swift
//  FoodTracker
//
//  Created by Jonathon Fishman on 9/15/16.
//  Copyright © 2016 GoYoJo. All rights reserved.
//

import UIKit

class RatingControl: UIView {
    
    // MARK: Properties
    
    var rating = 0
    var ratingButtons = [UIButton]()

    // MARK: Initialization
    
    // Every UIView subclass that implements an initializer must include an implementation of init?(coder:)
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        // add a for loop to create 5 buttons
        for _ in 0..<5 {
            
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            button.backgroundColor = UIColor.redColor()
            
            // attach the action method to the button obj
            button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(_:)), forControlEvents: .TouchDown)
            
            // As you create each button, you add it to the ratingButtons array to keep track of it.
            ratingButtons += [button]
            
            
            // method adds the created button you to the RatingControl view.
            addSubview(button)
            
        }
        
        // method called at the appropriate time gives UIView subclasses a chance to perform a precise layout of their subviews.
        func layoutSubviews() {
            
            var buttonFrame = CGRect(x: 0, y: 0, width: 44, height: 44)
            
            // Offset each button's origin by the length of the button plus spacing.
            for (index, button) in ratingButtons.enumerate() {
                buttonFrame.origin.x = CGFloat(index * (44 + 5))
                button.frame = buttonFrame
            }
        }
        
    }
    
    // tells the stack view how to lay out your button
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 240, height: 44)
    }
    
    // MARK: Button Action
    
    func ratingButtonTapped(button: UIButton) {
        print("Button pressed 👍")
    }


}
