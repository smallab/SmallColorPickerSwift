//
//  USImageColorPicking.swift
//  USColorPickerSwiftProject
//
//  Created by USER STUDIO on 26/10/2015.
//  Copyright © 2015 User Studio. All rights reserved.
//

import Foundation
import UIKit


class USImageColorPicking: NSObject {

    static func getPixelColorAtLocation(point: CGPoint, imgRef:CGImageRef) -> UIColor {
        
        //Make sure point is within the image
        let color: UIColor
        
        // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpha, Red, Green, Blue
        let cgctx:CGContextRef = createARGBBitmapContextFromImage(imgRef)
        
        let pixelsWide:size_t = CGImageGetWidth(imgRef)
        let pixelsHigh:size_t = CGImageGetHeight(imgRef)

        let rect = CGRect(x: 0, y: 0, width: pixelsWide, height: pixelsHigh)

        // Draw the image to the bitmap context. Once we draw, the memory
        // allocated for the context for rendering will then contain the
        // raw image data in the specified color space.
        CGContextDrawImage(cgctx, rect, imgRef);

        // Now we can get a pointer to the image data associated with the bitmap
        // context.
        let data = CGBitmapContextGetData(cgctx)
        let dataType = UnsafeMutablePointer<UInt8>(data)

        //offset locates the pixel in the data from x,y.
        //4 for 4 bytes of data per pixel, w is width of one row of data.
        let offset = 4*((pixelsWide * Int(round(point.y))) + Int(round(point.x)))
        let alpha = dataType[offset]
        
        let red = dataType[offset+1]
        let green = dataType[offset+2]
        let blue = dataType[offset+3]

        color = UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha)/255.0 )
        
        return color
    }
    
    
    static func getPixelColorAtLocation(point:CGPoint, data:UnsafeMutablePointer<UInt8>, cgctx:CGContextRef, w:size_t) -> UIColor {
        
        //offset locates the pixel in the data from x,y.
        //4 for 4 bytes of data per pixel, w is width of one row of data.
        let offset = 4*((w * Int(round(point.y))) + Int(round(point.x)))
        let alpha = data[offset]
        
        let red = data[offset+1]
        let green = data[offset+2]
        let blue = data[offset+3]
        
        return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha)/255.0 )
    }
    
    
    // Create a UIColor from a Hex string.
    static func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        // Remove # from hex
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        // String should be 6 or 8 characters
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        // Separate into r, g, b substrings
        let rString = (cString as NSString).substringToIndex(2)
        let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        // Scan values
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    

    static func createARGBBitmapContextFromImage(imgRef:CGImageRef) -> CGContextRef {
        
        // Get image width, height
        let pixelsWide = CGImageGetWidth(imgRef)
        let pixelsHigh = CGImageGetHeight(imgRef)
        
        // Declare the number of bytes per row. Each pixel in the bitmap in this
        // example is represented by 4 bytes; 8 bits each of red, green, blue, and
        // alpha.
        let bitmapBytesPerRow = pixelsWide * 4
        let bitmapByteCount = bitmapBytesPerRow * Int(pixelsHigh)
        
        // Use the generic RGB color space.
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Allocate memory for image data. This is the destination in memory
        // where any drawing to the bitmap context will be rendered.
        let bitmapData = malloc(bitmapByteCount)
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        
        // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
        // per component. Regardless of what the source image format is
        // (CMYK, Grayscale, and so on) it will be converted over to the format
        // specified here by CGBitmapContextCreate.
        let context = CGBitmapContextCreate(bitmapData, pixelsWide, pixelsHigh, 8,
            bitmapBytesPerRow, colorSpace, bitmapInfo.rawValue)
        
        // draw the image onto the context
        let rect = CGRect(x: 0, y: 0, width: pixelsWide, height: pixelsHigh)
        CGContextDrawImage(context, rect, imgRef)
        
        return context!
    }
    
    
    static func colorsAreTheSame(color1:UIColor, color2:UIColor, tolerance:CGFloat) -> Bool {

        let color1Array = CGColorGetComponents(color1.CGColor)
        
        let r1 = color1Array[0]
        let g1 = color1Array[1]
        let b1 = color1Array[2]
        let a1 = CGColorGetAlpha(color1.CGColor)
        
        let color2Array = CGColorGetComponents(color2.CGColor)
        
        let r2 = color2Array[0]
        let g2 = color2Array[1]
        let b2 = color2Array[2]
        let a2 = CGColorGetAlpha(color2.CGColor)
        
        return
            fabs(CGFloat(r1 - r2)) <= tolerance &&
            fabs(CGFloat(g1 - g2)) <= tolerance &&
            fabs(CGFloat(b1 - b2)) <= tolerance &&
            fabs(CGFloat(a1 - a2)) <= tolerance
    }
    

    static func getPositionForColor(colorHex:NSString, image:UIImage) -> CGPoint {
        
        var position:CGPoint
        var xPos:CGFloat = 0.0;
        var yPos:CGFloat = 0.0;
        
        let currentColor:UIColor = colorWithHexString(colorHex as String)
        
        var breakable:Bool = false
        
        let imgRef:CGImageRef = image.CGImage!
        var itColor:UIColor;
        
        // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpha, Red, Green, Blue
        let cgctx:CGContextRef = createARGBBitmapContextFromImage(imgRef)
        
        let pixelsWide = CGImageGetWidth(imgRef)
        let pixelsHigh = CGImageGetHeight(imgRef)
        _ = CGRect(x: 0, y: 0, width: pixelsWide, height: pixelsHigh)
        
        let data = CGBitmapContextGetData(cgctx)
        let dataType = UnsafeMutablePointer<UInt8>(data)
        
        // Now we can get a pointer to the image data associated with the bitmap
        // context.
        for var i = 0; i < Int(image.size.height); i+=7 {
            for var j = 0; j < Int(image.size.width); j++ {
                
                itColor = getPixelColorAtLocation(CGPointMake(CGFloat(j), CGFloat(i)), data:dataType, cgctx:cgctx, w: size_t(pixelsWide))
                
                if (colorsAreTheSame(itColor, color2: currentColor, tolerance:0.05) == true) {
                    yPos = CGFloat(i)
                    xPos = CGFloat(j)
                    breakable = true
                    break
                }
            }
            if breakable {
                break
            }
        }
        position = CGPointMake(xPos, yPos);
        return position
    }
}

extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {
        
        let pixelData = CGDataProviderCopyData(CGImageGetDataProvider(self.CGImage))
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }  
}