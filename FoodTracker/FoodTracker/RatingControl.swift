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
    
    var rating = 0 {
        //add a property observer to perform work immediately before or after the value changes
        didSet {
            // call to trigger a layout update every time the rating changes
            setNeedsLayout()
        }
    }
    var ratingButtons = [UIButton]()
    let spacing = 1
    let starCount = 5

    // MARK: Initialization
    
    // Every UIView subclass that implements an initializer must include an implementation of init?(coder:)
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        let filledStarImage = UIImage(named: "filledStar")
        let emptyStarImage = UIImage(named: "emptyStar")
        
        // add a for loop to create 5 buttons
        for _ in 0..<starCount {
            
            // this initializes the button
            let button = UIButton()
            
            // empty star image appears when a button is unselected (.Normal state).
            button.setImage(emptyStarImage, forState: .Normal)
            //filled-in star image appears when the button is selected (.Selected state)
            button.setImage(filledStarImage, forState: .Selected)
            // user in process of tapping the button
            button.setImage(filledStarImage, forState: [.Highlighted, .Selected])
            
            //make sure that the image doesn’t show an additional highlight during the state change
            button.adjustsImageWhenHighlighted = false
            
            // attach the action method to the button obj
            button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(_:)), forControlEvents: .TouchDown)
            
            // As you create each button, you add it to the ratingButtons array to keep track of it.
            ratingButtons += [button]
            
            
            // method adds the created button you to the RatingControl view.
            addSubview(button)
            
        }
        
    }
    
    // method called at the appropriate time gives UIView subclasses a chance to perform a precise layout of their subviews.
    override func layoutSubviews() {
        
        // Set the button's width and height to a square the size of the frame's height.
        let buttonSize = Int(frame.size.height)
        
        var buttonFrame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        
        // Offset each button's origin by the length of the button plus spacing.
        for (index, button) in ratingButtons.enumerate() {
            buttonFrame.origin.x = CGFloat(index * (buttonSize + 5))
            button.frame = buttonFrame
        }
        
        // call to update buttons when button tapped and when view is being layed out (loaded)
        updateButtonSelectionStates()
    }
    
    // tells the stack view how to lay out your button
    override func intrinsicContentSize() -> CGSize {
        
        let buttonSize = Int(frame.size.height)
        let width = (buttonSize * starCount) + (spacing * (starCount - 1))
        
        return CGSize(width: width, height: buttonSize)
    }
    
    // MARK: Button Action
    
    func ratingButtonTapped(button: UIButton) {
        
        // add 1 rating per button
        rating = ratingButtons.indexOf(button)! + 1
        
        // call to update buttons when button tapped and when view is being layed out (loaded)
        updateButtonSelectionStates()
    }
    
    // helper method that you’ll use to update the selection state of the buttons
    func updateButtonSelectionStates() {
        
        //iterate through ratingButtons array to set each buttons state
        //If index < rating is true, button’s state set to selected. Otherwise, the button is unselected and shows the empty star
        for (index, button) in ratingButtons.enumerate() {
            // If the index of a button is less than the rating, that button should be selected.
            button.selected = index < rating
        }
    }


}
