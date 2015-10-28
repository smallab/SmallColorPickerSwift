//
//  ViewController.swift
//  USColorPickerSwiftProject
//
//  Created by USER STUDIO on 23/10/2015.
//  Copyright © 2015 User Studio. All rights reserved.
//

import UIKit

class ViewController: UIViewController, USColorPickerControllerDelegate {

    var usColorPickerCtrl:USColorPickerController = USColorPickerController(nibName: "USColorPickerController", bundle: nil)
    var previousColorPickerColor:UIColor = UIColor()
    var previousColorPickerPosition:CGPoint = CGPoint()
    var colorPickerPresentationBtn:UIButton = UIButton()
    
    init() {
        super.init(nibName: nil, bundle:nil)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.view.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        
        let colorLabel:UILabel = UILabel(frame: CGRectMake(0, 30, self.view.frame.size.width, 50))
        colorLabel.text = "Click on the following button:"
        colorLabel.textAlignment = NSTextAlignment.Center
        
        // Set current color
        let colorToDisplay:UIColor = UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 82.0/255.0, alpha: 1.0)
        previousColorPickerColor = colorToDisplay
        
        // Create the color choosing (modal) view
        usColorPickerCtrl.delegate = self // USColorPickerControllerDelegate
        let view:UIView = usColorPickerCtrl.view // Preload
        usColorPickerCtrl.colorPicker.lastColor = colorToDisplay
        usColorPickerCtrl.colorPicker.findPositionForColor("#ff0052")
        usColorPickerCtrl.colorPicker.applyPosition(usColorPickerCtrl.colorPicker.lastPosition, color: colorToDisplay)
        previousColorPickerPosition = usColorPickerCtrl.colorPicker.lastPosition;

        // Button
        colorPickerPresentationBtn = UIButton(frame: CGRectMake(self.view.frame.size.width/10*1, colorLabel.frame.size.height+30, self.view.frame.size.width/10*8, 30))
        colorPickerPresentationBtn.setTitle("", forState: UIControlState.Normal)
        colorPickerPresentationBtn.tintColor = usColorPickerCtrl.colorPicker.lastColor
        colorPickerPresentationBtn.backgroundColor = usColorPickerCtrl.colorPicker.lastColor
        
        colorPickerPresentationBtn.tintColor = previousColorPickerColor
        colorPickerPresentationBtn.backgroundColor = previousColorPickerColor
        colorPickerPresentationBtn.addTarget(self, action: "listen2ColorPickerPresentationBtn:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.view.addSubview(colorLabel)
        self.view.addSubview(colorPickerPresentationBtn)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func listen2ColorPickerPresentationBtn(sender: UIButton!) {
        self.presentViewController(usColorPickerCtrl, animated: true, completion: {
            print("Choose color...")
        })
    }
    
    /*
     * pragma mark - USColorPickerControllerDelegate methods
     */
    
    func dismissColorChanging(controller: USColorPickerController) {
    
        // change back to what we had before
        self.usColorPickerCtrl.colorPicker.lastPosition = self.previousColorPickerPosition
        self.usColorPickerCtrl.colorPicker.lastColor = self.previousColorPickerColor
        self.usColorPickerCtrl.colorPicker.applyPosition(self.previousColorPickerPosition, color: self.previousColorPickerColor)
    }
    
    func useColorChanging(controller: USColorPickerController) {
    
        // saving new values
        self.previousColorPickerPosition = usColorPickerCtrl.colorPicker.lastPosition
        self.previousColorPickerColor = usColorPickerCtrl.colorPicker.lastColor
        usColorPickerCtrl.colorPicker.applyPositionAndColor()
        
        // applying chosen color to the button
        colorPickerPresentationBtn.tintColor = usColorPickerCtrl.colorPicker.lastColor // set button's color
        colorPickerPresentationBtn.backgroundColor = usColorPickerCtrl.colorPicker.lastColor
        self.dismissViewControllerAnimated(true, completion: {
            print("Using selected color picker color")
        })
    }
}