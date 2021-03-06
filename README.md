# Dish-Rater
Track and rate meals

This doc contains helpful links, tips and tricks that I learned/discovered while creating this app.

---------------------------------------------------------------
#Skip to "Main Scene" 
*bypass login each time app opens

See notes in AppDelegate


---------------------------------------------------------------
#Use a Regular Expression to check if email field is in proper format

See Utility

	static func isValidEmail(emailAddress: String) -> Bool {
	    
	    let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
	    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
	    return emailPredicate.evaluate(with: emailAddress)
	}


-----------------------------------------------------------------
#Singleton Pattern 
*only one instance of a singleton class can exist

See Utility and BackendlessManager

	class BackendlessManager {
    
    // This gives access to the one and only instance.
    static let sharedInstance = BackendlessManager()
    
    // This prevents others from using the default '()' initializer for this class.
    private init() {}


----------------------------------------------------------------
#Passing data to a VC inside a TabBarController and UINavigationContoller

see RegisterViewController and MealTableViewController:

	// After registering, let TV Scene know so we can load sample data one time from this segue
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	    
	    let barVC = segue.destination as! UITabBarController
	    let navVC = barVC.viewControllers![0] as! UINavigationController
	    let destinationVC = navVC.topViewController as! MealTableViewController
	    
	    destinationVC.isPresentingVCRegister = true
	}

	// Create an optional to capture the value in the destinationVC
	var isPresentingVCRegister: Bool? = false


-----------------------------------------------------------------
#Leave a VC presented in 2 different ways, dismiss or pop?

see MealViewController

	let isPresentingInAddMealMode = presentingViewController is UINavigationController

	if isPresentingInAddMealMode {
	    dismiss(animated: true, completion: nil)
	} else {
	    navigationController!.popViewController(animated: true)
	}


----------------------------------------------------------------
#NSCache Image Cacheing

see MealTableViewController

More info on NSCache:
http://nshipster.com/nscache/
    
http://stackoverflow.com/questions/10502809/objective-c-benefits-of-using-nscache-over-a-static-nsmutabledictionary
    
http://blog.csdn.net/chuanyituoku/article/details/17336443
    
	// Create a cache that uses keys of type NSString to point to value types of UIImage.
	// NSCache will dump old cache if we get memory warnings
	var imageCache = NSCache<NSString, UIImage>()

	in viewDidLoad:
	// NSCache has built in functions like countLimit
	imageCache.countLimit = 50 // Cache up to 50 UIImage(s)

	in tableView...cellForRowAt indexPath:
	// For NSCache, if we have the cache key we put it on the cell when it gets created
	if BackendlessManager.sharedInstance.isUserLoggedIn() && meal.thumbnailUrl != nil {

	if imageCache.object(forKey: meal.thumbnailUrl! as NSString) != nil {
	    
	    // If the URL for the thumbnail is in the cache already - get the UIImage that belongs to it.
	    cell.photoImageView.image = imageCache.object(forKey: meal.thumbnailUrl! as NSString)
	    
	}
	...
	// Set new image to be cached
	// Since we went to the trouble of pulling down the image data and
	// building a UIImage lets cache the UIImage using the URL as the key.
	self.imageCache.setObject(image, forKey: meal.thumbnailUrl! as NSString)


----------------------------------------------------------------
#Implement Pull-to-refresh

See MealTableViewCell:

Interface Builder (IB):

VC (yellow icon) > atin > Table View Controller > Refreshing: Enabled
	
creates a "Refresh Control" 

Add Title if desired

in TableViewController:

	// Create a refresh func to call when refresh action taken
	func refresh(sender: AnyObject) {
	        
	    if BackendlessManager.sharedInstance.isUserLoggedIn() {
	        
	        // Call the loadMeals from 
	        // Updated loadMeals in BEManager to throw error if fails
	        BackendlessManager.sharedInstance.loadMeals(
	            
	            completion: { mealData in
	                
	                // remove the += or else we duplicate the meals
	                self.meals = mealData
	                self.tableView.reloadData()
	                self.refreshControl?.endRefreshing()
	            },
	            
	            error: {
	                self.tableView.reloadData()
	                self.refreshControl?.endRefreshing()
	        })
	    }
	}

in viewDidLoad:

	// Add support for pull-to-refresh on the table view.
	self.refreshControl?.addTarget(self, action: #selector(refresh(sender:)), for: UIControlEvents.valueChanged)

	// Check if user is logged in then refresh
	if BackendlessManager.sharedInstance.isUserLoggedIn() {
	            
	    refresh(sender: self)
	            
	} else Load any saved meals, or load sample data


----------------------------------------------------------------
#Fix the Edit button on Navbar of TableView Programmatically

see MealTableViewController

	// Add for action selector on custom UIBarButtonItem
	func onEditButton(sender: UIBarButtonItem) {
	    
	    self.tableView.isEditing = !self.tableView.isEditing
	}

in viewDidLoad:

	// Disble the Edit button animation
	let leftBarButtonItemImage = UIImage(named: "edit-symbol")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
	        
	// Create the desired button
	let leftBarButtonItem = UIBarButtonItem(image: leftBarButtonItemImage,
		            style: .plain,
		            target: self,
		            action: #selector(onEditButton(sender: )))
	        
	// Set the button on the navbar
	self.navigationItem.leftBarButtonItem = leftBarButtonItem



----------------------------------------------------------------
#Fixing Stack Views 
*AL issues

Stack View > Pin > Update Frames: Items of New Constraints

Do this with the objects causing issues:

select the object go to siin (size inspector)
at bottom: 
intrinsic size: Placeholder


----------------------------------------------------------------
#Configuring text field’s keyboard

Make sure the text field is selected.

In Atin (attributes inspector) > Return Key
	select Done
		Makes the default "Return" key show "Done"

In Atin, 
	select: Auto-enable Return Key
		Makes it impossible to tap "Done" key before typing text
			ensures users can never enter an empty string


------------------------------------------------------------------
#UITextFieldDelegate

https://developer.apple.com/library/content/referencelibrary/GettingStarted/DevelopiOSAppsSwift/Lesson3.html#//apple_ref/doc/uid/TP40015214-CH22-SW1

*When accepting user input from a text field, you need some help from a text field delegate

About Delegates:

A delegate is an object that acts on behalf of, or in coordination with, another object

*The delegating object: "the text field" 
	—keeps a reference for the other object, which is:
	—the delegate — "the ViewController"

*At the appropriate time, the delegating object sends a message to the delegate
	-The message tells the delegate about an event that the delegating object is about to handle or has just handled. 
		
	-The delegate may respond by for example: 
		* updating the appearance or state of itself or of other objects in the app
		* or returning a value that affects how an impending event is handled.

A text field’s delegate communicates with the text field while its text is being edited, and knows when important events occur
	— such as when a user starts or stops editing text. 
The delegate can use this information to: 
	save or clear data at the right time, dismiss the keyboard, and so on.

Any object can serve as a delegate for another object as long as it conforms to the appropriate protocol: the UITextFieldDelegate. 

In this case, because ViewController keeps a reference to the text field, you’ll make ViewController the text field’s delegate.


-------------------------------------------------------------

#Set up the UITextFieldDelegate

We need the ViewController to adopt the UITextFieldDelegate protocol:

	class ViewController: UIViewController, UITextFieldDelegate

Set VC as the delegate of the text field and implement some of its behavior to handle the text field's user input

In viewDidLoad():
	
	nameTextField.delegate = self

The "self" refers to the ViewController class, because it’s referenced inside the scope of the ViewController class definition.

NOW the VC is a delegate for nameTextField


-----------------------------------------------
#First Responders

See MealViewController

When the user taps a text field, it automatically becomes first responder, which is an object that is first on the line for receiving many kinds of app events, 
	*includes key events, motion events, and action messages, among others. 
In other words, many of the events generated by the user are initially routed to the first responder.

When user finishes editing the text field, it needs to resign its first-responder status because the text field will no longer be the active object. Events need to get routed to a more appropriate object.


-----------------------------------------------------------------
#Work With View Controllers

UIViewController methods get called as follows:

viewDidLoad()—
	Called when the view controller’s content view (the top of its view hierarchy) is created and loaded from a storyboard. 
	This method is intended for initial setup. However, because views may be purged due to limited resources in an app, there is no guarantee that it will be called only once.

viewWillAppear()—
	Intended for any operations that you want always to occur before the view becomes visible. 
	Because a view’s visibility may be toggled or obscured by other views, this method is always called immediately before the content view appears onscreen.

viewDidAppear()—
	Intended for any operations that you want to occur as soon as the view becomes visible, such as fetching data or showing an animation. 
	Because a view’s visibility may be toggled or obscured by other views, this method is always called immediately after the content view appears onscreen.


-------------------------------------------------------------------
#Image View Aspect Ratios & Interactions

Pin:
Select: Aspect Ratio.
	Your image view now has a 1:1 aspect ratio, 
		so it will always show a square.

In Atin > Interaction
	select: User Interaction Enabled checkbox



---------------------
#Tap gesture recognizer

Object library:
Tap Gesture Recognizer object
Drag and place it on top of the image view (or whatever)
The Tap Gesture Recognizer appears in the scene dock

To connect the gesture recognizer to the ViewController.swift code:

Control-drag from the gesture recognizerto SC
	*Connection: Action
	*Type: UITapGestureRecognizer
	*Name: selectImageFromPhotoLibrary


-------------------------------------------------
#Create an Image Picker to Respond to User Taps

An image picker controller manages a UI for taking pictures and for choosing saved images to use in your app.
	
Just as you need a text field delegate when you work with a text field, you need a UIImagePickerControllerDelegate to work with an image picker controller.

Set up:

UIImagePickerControllerDelegate and UINavigationControllerDelegate protocols

After an image picker controller is presented, its behavior is handed off to its delegate. To give users the ability to select a picture, you’ll need to implement two of the delegate methods defined in 

UIImagePickerControllerDelegate:

	func imagePickerControllerDidCancel

	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])


---------------------------------------------------------------
#Implement A Custom Control

https://developer.apple.com/library/content/referencelibrary/GettingStarted/DevelopiOSAppsSwift/Lesson5.html#//apple_ref/doc/uid/TP40015214-CH19-SW1


Custom UIView

Every UIView subclass that implements an initializer must include an implementation of init?(coder:).

	class RatingControl: UIView {

	    // MARK: Initialization
	    
	    required init?(coder aDecoder: NSCoder) {
	        
	        super.init(coder: aDecoder)
	    }
	}

Add a new View to SB and add the idin class

*Add Buttons to the View (programmatically)

under super.init(coder: aDecoder)
Add:

	let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
    button.backgroundColor = UIColor.redColor()
    addSubview(button)


Layout the buttons:
Use code:

	override func intrinsicContentSize() -> CGSize {
    return CGSize(width: 240, height: 44)
	}


Add action:

	func ratingButtonTapped(button: UIButton) {
	}


In init?(coder:)
Before the addSubview(button) line, add this:

	button.addTarget(self, action: #selector(RatingControl.ratingButtonTapped(_:)), forControlEvents: .TouchDown)

You’re familiar with the target-action pattern because you’ve used it to link elements in your storyboard to action methods in your code. Above, you’re doing the same thing, except you’re creating the connection in code. 

You’re attaching the ratingButtonTapped(_:) action method 
to the button object, which will be triggered whenever the .TouchDown event occurs. 

This event signifies that the user has pressed on a button. 

You set the target to self, which in this case is the RatingControl class, because that’s where the action is defined.
	
The #selector expression returns the Selector value for the provided method. 
		
A selector is an opaque value that identifies the method. 
			
Older APIs used selectors to dynamically invoke methods at runtime. While newer APIs have largely replaced selectors with blocks, many older methods—like performSelector(_:) and addTarget(_:action:forControlEvents:)—still take selectors as arguments. 

In this example, the #selector(RatingControl.ratingButtonTapped(_:)) expression returns the selector for your ratingButtonTapped(_:) action method. 

This lets the system call your action method when the button is tapped.

Note that because you’re not using Interface Builder, you don’t need to define your action method with the IBAction attribute; you just define the action like any other method.

	override func layoutSubviews() {
    	var buttonFrame = CGRect(x: 0, y: 0, width: 44, height: 44)
    
    // Offset each button's origin by the length of the button plus spacing.
    for (index, button) in ratingButtons.enumerate() {
        buttonFrame.origin.x = CGFloat(index * (44 + 5))
        button.frame = buttonFrame
    	}
	}

This code creates a frame, and uses a for-in loop to iterate over all of the buttons to set their frames.

* The enumerate() method returns a collection that contains elements in the ratingButtons array paired with their indexes. 

This is a collection of tuples—groupings of values—and in this case, each tuple contains an index and a button. 
	
For each tuple in the collection, the for-in loop binds the values of the index and button in that tuple to local variables, index and button. 
	
You use the index variable to compute a new location for the button frame and set it on the button variable. 

The frame locations are set equal to a standard button size of 44 points and 5 points of padding, multiplied by index.


*Implement the Button Action

The indexOf(_:) method attempts to find the selected button in the array of buttons and to return the index at which it was found. 

This method returns an optional Int because the instance you’re searching for might not exist in the collection you’re searching. 
	
However, because the only buttons that trigger this action are the ones you created and added to the array yourself, you can be sure that searching for the button will return a valid index. 

In this case, you can use the force unwrap operator (!) to access the underlying index value. 
	
You add 1 to that index to get the corresponding rating. You need to add 1 because arrays are indexed starting with 0.

Update the rating property to include this property observer:
	
	var rating = 0 {
		didSet {
    		setNeedsLayout()
		}
	}

A property observer (didSet) observes and responds to changes in a property’s value. 
Property observers are called every time a property’s value is set, and can be used to perform work immediately before or after the value changes.  
	
Here, you include a call to setNeedsLayout(), which will trigger a layout update every time the rating changes. 
		
This ensures that the UI is always showing an accurate representation of the rating property value.


---------------------------------------------------------------
#Define Your Data Model

https://developer.apple.com/library/content/referencelibrary/GettingStarted/DevelopiOSAppsSwift/Lesson6.html#//apple_ref/doc/uid/TP40015214-CH20-SW1

Test Your Data

Unit Tests

Add yourself:
First of all just add new Target via 
File > New > Target... 
select iOS Unit Testing Bundle. 
Done.


-----------------------------------------------------------------
#Create a Table View

https://developer.apple.com/library/content/referencelibrary/GettingStarted/DevelopiOSAppsSwift/Lesson7.html#//apple_ref/doc/uid/TP40015214-CH8-SW1

*Turn off Cell highlighting when user taps

Outline > TV > Cell > atin > Selection: None

*Turn off user interaction with cell contents but allow click to segue

Outline > TV > Cell > atin > Interaction > 
	deselect the User Interaction Enabled checkbox.

The custom rating control class set to be interactive, but it doesn’t need to be interactive when it’s displayed in this table view cell. 


------------------------------------------------------------
#UITableViewDataSource protocol and UITableViewDelegate protocol

Before you can display dynamic data in your table view cells, you need to create outlet connections between the views (objects) in your storyboard and the code that represents the table view cell in MealTableViewCell.swift.


To display dynamic data, a table view needs two important helpers: 
a data source and a delegate. 

*A table view data source, as name implies, supplies the table view with the data it needs to display. 

*A table view delegate helps the table view manage cell selection, row heights, and other aspects related to displaying the data. 

By default, UITableViewController and its subclasses adopt:
UITableViewDataSource & UITableViewDelegate protocols

	// Optional
	func numberOfSections(in tableView: UITableView) -> Int 
	
Tells table view how many sections to display. 

Sections are visual groupings of cells within table views, which is especially useful in table views with a lot of data. 
		

	// Req.
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int

Tells the table view how many rows to display in a given section. 
A table view defaults to having a single section 

Each meal should have its own row in that section. 
That means that the number of rows should be the number of Meal objects in your meals array.


	// Req.
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell

Configures and provides a cell to display for a given row. 
		
Each row in a table view has one cell, and that cell determines the content that appears in that row and how that content is laid out.

For table views with a small number of rows, all rows may be onscreen at once, so this method gets called for each row in your table. 
	
But table views with a large number of rows display only a small fraction of their total items at a given time. 

It’s most efficient for table views to only ask for the cells for rows that are being displayed, and that’s what tableView(_:cellForRowAtIndexPath:) allows the table view to do.

For any given row in the table view, you configure the cell by fetching the corresponding Meal in the meals array, and then setting the cell’s properties to corresponding values from the Meal class.


--------------------------------------------------------------
#Implement Navigation

https://developer.apple.com/library/content/referencelibrary/GettingStarted/DevelopiOSAppsSwift/Lesson8.html#//apple_ref/doc/uid/TP40015214-CH16-SW1

--------------------------------------------------------------
#Create an Unwind Segue 1/2

Store New Meals in the Meal List

In MealVC

*Update: Created manual unwind segue:

	@IBAction func save(_ sender: UIBarButtonItem)

In the if statement, add the following code:

	let name = nameTextField.text ?? ""
	let photo = photoImageView.image
	let rating = ratingControl.rating

This code creates constants from the current text field text, selected image, and rating in the scene.
	
The nil coalescing operator (??) is used to return the value of an optional if the optional has a value, or return a default value otherwise. 

Here, the operator unwraps the optional String returned by nameTextField.text (which is optional because there may or may not be text in the text field), and returns that value if it’s a valid string. But if it’s nil, the operator the returns the empty string ("") instead.

In MealTableViewController:

	@IBAction func unwindToMealList(_ sender: UIStoryboardSegue)

This code uses the optional type cast operator (as?) to try to downcast the source view controller of the segue to type MealViewController.

You need to downcast because sender.source is of type UIViewController, but you need to work with MealViewController.

The operator returns an optional value, which will be nil if the downcast wasn’t possible. 

If the downcast succeeds, the code assigns that view controller to the local constant sourceViewController, and checks to see if the meal property on sourceViewController is nil. 

If the meal property is non-nil, the code assigns the value of that property to the local constant meal and executes the if statement.

If either the downcast fails or the meal property on sourceViewController is nil, the condition evaluates to false and the if statement doesn’t get executed.

This code computes the location in the table view where the new table view cell representing the new meal will be inserted, and stores it in a local constant called newIndexPath.

Now you need to create the actual unwind segue to trigger this method.

---------------------------------------------
#Disable Saving When the User Doesn't Enter an Item Name

	// method gets called when an editing session begins, or when the keyboard gets displayed.
	// This code disables the Save button while the user is editing the text field.
	func textFieldDidBeginEditing(_ textField: UITextField) {
    	// Disable the Save button while editing.
    	saveButton.isEnabled = false
	}

	// helper method to disable the Save button if the text field is empty.
	func checkValidMealName() {
    	// Disable the Save button if the text field is empty.
    	let text = nameTextField.text ?? ""
    	saveButton.enabled = !text.isEmpty
	}

	// first line calls checkValidMealName() to check if the text field has text in it, which enables the Save button if it does. 
	// The second line sets the title of the scene to that text.
	func textFieldDidEndEditing(_ textField: UITextField) {
    	// helper method to check if text field has text, enables save button if so
    	checkValidMealName()
    	// sets title of scene to textfield
    	navigationItem.title = textField.text
	}

In viewDidLoad:
	// Enable the Save button only if the text field has a valid Meal name.
	checkValidMealName()


--------------------------------------------------------
#Implement Edit and Delete Behavior in TVC

https://developer.apple.com/library/content/referencelibrary/GettingStarted/DevelopiOSAppsSwift/Lesson9.html#//apple_ref/doc/uid/TP40015214-CH9-SW1

See MealTableViewController

Recall from earlier that the prepare(for segue: _) method is called before any segue gets executed. 
	
You can use this method to identify which segue is occurring, and display the appropriate information in the meal scene. 

Segueus differentiated based on the identifiers
*addItem (modal segue) 
*ShowDetail (show segue)

	let mealDetailViewController = segue.destination as! MealViewController

This code tries to downcast the destination view controller of the segue to a MealViewController using the forced type cast operator (as!). 
	
Only use a forced cast if you’re absolutely certain that the cast will succeed—and that if it fails, something has gone wrong in the app and it should crash. Otherwise, downcast using as?.

	// Get the cell that generated this segue.
	if let selectedMealCell = sender as? MealTableViewCell {
	}
	
This tries to downcast sender to a MealCell using the optional type cast operator (as?).

If cast is successful, the local constant selectedMealCell gets assigned the value of sender cast as type MealTableViewCell, and the if statement proceeds to execute. If the cast is unsuccessful, the expression evaluates to nil and the if statement isn’t executed.


-------------------------------------------------
#Update the implementation of unwindToMealList(_:) to add or replace meals 2/2


See MealTableViewController

in unwindToMealList(_:):

	if let selectedIndexPath = tableView.indexPathForSelectedRow {
	}

This code checks whether a row in the table view is selected. If it is, that means a user tapped one of the table views cells to edit a meal. In other words, this if statement gets executed if an existing meal is being edited.


--------------------------------------
#Cancel an Edit to an Existing Meal

This creates a Boolean value that indicates whether the view controller that presented this scene is of type UINavigationController. 

As the constant name isPresentingInAddMealMode indicates, this means that the meal scene was presented using the Add button. 

This is because the meal scene is embedded in its own navigation controller when it’s presented in this manner, which means that navigation controller is what presents it.

	dismiss(animated: true, completion: nil) 
	
happens anytime the cancel(_:) method got called, it now only happens when isPresentingInAddMealMode is true.

	navigationController!.popViewController(animated: true)
	
pops the current view controller (meal scene) off the navigation stack of navigationController and performs an animation of the transition.


--------------------------------------------
#Support Deletion in Navbar of TV

Add Edit button to TV

In viewDidLoad():
	
	navigationItem.leftBarButtonItem = editButtonItem

creates a special type of bar button item that has editing behavior built into it. 
It then adds this button to the left side of the navigation bar in the meal list scene.

To delete a meal

In TVController

	meals.remove(at: indexPath.row)

This code removes the Meal object to be deleted from meals. The line after it, which is part of the template implementation, deletes the corresponding row from the table view.


----------------------------------------------------------------
#Persist Data for non-logged in users

see MealData

*Collecting a small amount of information without needing a database

Create a Swift file to hold data you want to persist
ex: MealData

The class needs to conform to to the NSCoding protocol. 

which needs NSObject subclass 

*NSObject is considered a base class that defines a basic interface to the runtime system.

*NSCoding protocol declares two methods that any class that adopts to it must implement so that instances of that class can be encoded and decoded:

	func encode(with aCoder: NSCoder)
	
prepares the class’s information to be archived

	required convenience init?(coder aDecoder: NSCoder)

initializer unarchives the data when the class is created
it decodes the encoded data

You need to implement both for the data to save and load properly.

* required keyword means this initializer must be implemented on every subclass of the class that defines this initializer.

Convenience initializers are secondary, supporting initializers that need to call one of their class’s designated initializers. 

Designated initializers are the primary initializers for a class. 
	
They fully initialize all properties introduced by that class and call a superclass initializer to continue the initialization process up the superclass chain. 

Here, you’re declaring this initializer as a convenience initializer because it only applies when there’s saved data to be loaded.
	
The question mark (?) means that this is a failable initializer that might return nil.

decodeObject(forKey:...) method unarchives the stored information about an object.
	
The return value is AnyObject, which you downcast in the code above as a String to assign it to a name constant. 
		
You downcast the return value using the forced type cast operator (as!) because if the object can’t be cast as a String, or if it’s nil, something has gone wrong and the error should cause a crash at runtime.

You downcast as a UIImage to be assigned to a photo constant. In this case, you downcast using the optional type cast operator (as?), because the photo property is an optional, so the value might be a UIImage, or it might be nil. You need to account for both cases.

As a convenience initializer, this initializer is required to call one of its class’s "designated initializers" before completing:

	self.init

As the initializer’s arguments, you pass in the values of the constants you created while archiving the saved data.

Because the other initializer you defined on the MealData class, init?(name:photo:rating:), is a designated initializer, its implementation needs to call to its superclass’s initializer.

	super.init()

Next, you need a persistent path on the file system where data will be saved and loaded, so you know where to look for it.

To create a file path to data:

	// MARK: Archiving Paths
 
	static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!

	static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("meals")

You mark these constants with the static keyword, which means they apply to the class instead of an instance of the class. Outside of the Meal class, you’ll access the path using the syntax Meal.ArchiveURL.path!.


*Save and Load the Meal List

Now that you can save and load an individual meal, you need to save and load the meal list whenever a user adds, edits, or removes a meal.

*To implement the method to save the meal list

in MealTableViewController
see:
		
	// MARK: NSCoding

	func saveMealsToArchiver()

attempts to archive the meals array (created at top) to a specific location, and returns true if it’s successful. 
		
uses the constant .ArchiveURL that was defined in the MealData class to identify where to save the information.


*To implement the method to load the meal list

	func loadMealsFromArchiver() 

This method has a return type of an optional array, meaning that it might return an array of MealData objects or might return nothing (nil).

This method attempts to unarchive the object stored at the path MealData.ArchiveURL.path and downcast that object to an array of Meal objects.

uses the as? operator so that it can return nil when appropriate. Because the array may or may not have been stored, it’s possible that the downcast will fail, in which case the method should return nil.

With these methods implemented, you need to add code to save and load the list of meals whenever a user adds, removes, or edits a meal.

in unwindToMealList(_:)

	// Save the meals to archiver
	saveMealsToArchiver()

in override func tableView(_ tableView: UITableView, commit editingStyle:

	// Save the archivers meals array when deleted
	saveMealsToArchiver()

Now that meals are saved at the appropriate times, you need to make sure that meals get loaded at the appropriate time. This should happen every time the meal list scene loads, which means the appropriate place to load the stored data is in viewDidLoad.

