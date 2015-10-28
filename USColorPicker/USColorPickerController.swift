//
//  USColorPickerController.swift
//  USColorPickerSwiftProject
//
//  Created by USER STUDIO on 26/10/2015.
//  Copyright © 2015 User Studio. All rights reserved.
//

import Foundation
import UIKit

protocol USColorPickerControllerDelegate {
    func dismissColorChanging(controller: USColorPickerController)
    func useColorChanging(controller: USColorPickerController)
}

class USColorPickerController: UIViewController, USColorPickerViewDelegate {

    var delegate: USColorPickerControllerDelegate?
    
    var paletteImgView:UIImageView = UIImageView()
    var btnsView:UIView = UIView()
    var selectChosenColorBtn:UIButton = UIButton()
    var cancelBtn:UIButton = UIButton()
    var colorPicker:USColorPickerView = USColorPickerView()

    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.

        // init values
        let bounds = UIScreen.mainScreen().bounds
        let h:CGFloat = bounds.size.height
        let w:CGFloat = bounds.size.width
        let m:CGFloat = 0.06875 * CGFloat(w) // = 22;
        
        // self view
        self.view.frame = CGRectMake(0, 0, w, h);

        // creating the color picker (UIView)
        self.colorPicker.frame = self.view.frame
        self.colorPicker.delegate = self
        self.view.addSubview(self.colorPicker)
        self.view.bringSubviewToFront(self.colorPicker)
        
        // colors
        let c:UIColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        self.colorPicker.lastColor = c
        self.colorPicker.lastPosition = CGPointMake(w/2, 0)
        
        // create palette img view
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(w, h), false, 1.0); // force scale of 1
        let image = UIImage(named: "uscolorpicker-palette")
        UIGraphicsEndImageContext()
        paletteImgView = UIImageView(frame:self.view.frame)
        paletteImgView.image = image
        paletteImgView.contentMode = UIViewContentMode.ScaleToFill
        self.view.addSubview(paletteImgView)
        self.view.sendSubviewToBack(paletteImgView)
        
        // set color picker's palette ref + frame
        self.colorPicker.colorPickerPalette = paletteImgView
        self.colorPicker.frame = self.view.frame
        
        // create cursor and add as subview of colorPicker
        self.colorPicker.colorPickerCursor = UIImageView(frame: CGRectMake(self.colorPicker.lastPosition.x, self.colorPicker.lastPosition.y, 75, 75))
        self.colorPicker.colorPickerCursor.image = UIImage(named: "uscolorpicker-cursor")
        self.colorPicker.addSubview(self.colorPicker.colorPickerCursor)
        self.colorPicker.bringSubviewToFront(self.colorPicker.colorPickerCursor)
        
        // apply values
        self.colorPicker.applyPositionAndColor()
        
        // btns view
        btnsView = UIView(frame: CGRectMake(0, self.view.frame.size.height - m*3, w, m*3))
        btnsView.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(btnsView)
        self.view.bringSubviewToFront(btnsView)
        
        // Adds a shadow to btns view
        let layer1:CALayer = btnsView.layer
        layer1.shadowOffset = CGSizeMake(1, 1)
        layer1.shadowColor = UIColor.blackColor().CGColor
        layer1.shadowRadius = 22
        layer1.shadowOpacity = 0.33334
        layer1.shadowPath = UIBezierPath(rect:layer1.bounds).CGPath
        
        // set select button action & props
        self.selectChosenColorBtn = UIButton(type: UIButtonType.RoundedRect)
        self.selectChosenColorBtn.frame = CGRectMake(w*0.5 - m*1.5, 0, m*3, m*3)
        self.selectChosenColorBtn.addTarget(self, action: "dismissColorPickerAndUseSelectedColor", forControlEvents: .TouchUpInside)
        self.selectChosenColorBtn.backgroundColor = UIColor.clearColor()
        self.selectChosenColorBtn.setTitle("✔︎", forState: UIControlState.Normal)
        self.selectChosenColorBtn.titleLabel?.font = UIFont(name: "userstudio", size: 64)
        self.selectChosenColorBtn.setTitleColor(UIColor(white: 0.2392, alpha: 1.0), forState: UIControlState.Normal)
        self.selectChosenColorBtn.setTitleColor(UIColor(white: 0.6667, alpha: 1.0), forState: UIControlState.Highlighted)
        btnsView.addSubview(self.selectChosenColorBtn)
        
        // set cancel button action & props
        self.cancelBtn = UIButton(type: UIButtonType.RoundedRect)
        self.cancelBtn.frame = CGRectMake(0, 0, m*3, m*3)
        self.cancelBtn.addTarget(self, action: "dismissColorPicker", forControlEvents: .TouchUpInside)
        self.cancelBtn.backgroundColor = UIColor.clearColor()
        self.cancelBtn.setTitle("✘", forState: UIControlState.Normal)
        self.cancelBtn.titleLabel?.font = UIFont(name: "userstudio", size: 42)
        self.cancelBtn.setTitleColor(UIColor(white: 0.2392, alpha: 1.0), forState: UIControlState.Normal)
        self.cancelBtn.setTitleColor(UIColor(white: 0.6667, alpha: 1.0), forState: UIControlState.Highlighted)
        btnsView.addSubview(self.cancelBtn)
       
        // hiding status bar
        if self.respondsToSelector(Selector(setNeedsStatusBarAppearanceUpdate())) {
            // iOS 7
            self.prefersStatusBarHidden()
            self.performSelector(Selector(setNeedsStatusBarAppearanceUpdate()))
        } else {
            // iOS 6
            self.prefersStatusBarHidden()
            UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func viewDidAppear() {
        
        // cursor init
        self.colorPicker.applyPositionAndColor()
        
        // start with showing the UI
        self.showUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /* 
     * pragma mark - USColorPickerImageViewDelegate methods
     */
    
    func hideUI() {
        UIView.animateWithDuration(0.25, delay: 0.0, options: .CurveEaseOut, animations: {
            self.btnsView.frame = CGRectMake(0, self.view.frame.size.height, self.btnsView.frame.size.width, self.btnsView.frame.size.height)
            }, completion: { finished in
        })
    }
    
    func showUI() {
        UIView.animateWithDuration(0.25, delay: 0.15, options: .CurveEaseOut, animations: {
            self.btnsView.frame = CGRectMake(0, self.view.frame.size.height - self.btnsView.frame.size.height, self.btnsView.frame.size.width, self.btnsView.frame.size.height)
            }, completion: { finished in
        })
    }
    
    /*
    * pragma mark - USColorPickerControllerDelegate methods
    */

    func dismissColorPicker() {

        self.delegate?.dismissColorChanging(self)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dismissColorPickerAndUseSelectedColor() {

        self.delegate?.useColorChanging(self)
    }
}


