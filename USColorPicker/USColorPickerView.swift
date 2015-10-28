//
//  USColorPickerView.swift
//  USColorPickerSwiftProject
//
//  Created by USER STUDIO on 23/10/2015.
//  Copyright © 2015 User Studio. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import QuartzCore

protocol USColorPickerViewDelegate {
    func hideUI()
    func showUI()
}

class USColorPickerView: UIView {

    var delegate: USColorPickerViewDelegate?

    var lastPosition:CGPoint = CGPoint(x:0, y:0)
    var colorPickerCursor:UIImageView = UIImageView()
    var lastColor:UIColor = UIColor()
    var colorPickerPalette:UIImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /*
     * pragma mark - Handle the touch events
     */
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let _ = touches.first {
            self.delegate?.hideUI()
            self.touch(touches, withEvent: event)
        }
        super.touchesBegan(touches, withEvent:event)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let _ = touches.first {
            self.delegate?.showUI()
            self.touch(touches, withEvent: event)
        }
        super.touchesEnded(touches, withEvent:event)
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let _ = touches.first {
            self.touch(touches, withEvent: event)
        }
        super.touchesMoved(touches, withEvent:event)
    }
    
    func touch(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            var point:CGPoint = touch.locationInView(self)
            
            if Int(point.x) >= CGImageGetHeight(self.colorPickerPalette.image!.CGImage) {
                point = CGPointMake(point.x, point.y)
            }
            
            self.lastColor = USImageColorPicking.getPixelColorAtLocation(point, imgRef: (self.colorPickerPalette.image?.CGImage)!)
            self.lastPosition = point
            self.applyPositionAndColor()
        }
    }

    
    /*
     * pragma mark - Apply current or other values to view
     */
    
    func applyPositionAndColor() {
        self.colorPickerCursor.center = self.lastPosition
        self.backgroundColor = self.lastColor
    }
    
    func applyPosition(position:CGPoint, color:UIColor) {
        self.lastPosition = position
        self.colorPickerCursor.center = position
        self.lastColor = color
        self.backgroundColor = color
    }
    
    /*
    * pragma mark - Get position for color
    */

    func findPositionForColor(colorHex: NSString) {
        self.lastPosition = USImageColorPicking.getPositionForColor(colorHex, image: self.colorPickerPalette.image!)
        
    }
}

