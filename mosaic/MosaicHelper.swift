//
//  MosaicHelper.swift
//  mosaic
//
//  Created by Divine Grace on 18/10/16.
//  Copyright © 2016 Divine Grace. All rights reserved.
//

import UIKit
import CoreGraphics
import CoreImage


class MosaicHelper {
    
    //get the average color of the specific area of an image
    static func getAverageColorInRectOfImage(context:CIContext, image: CGImage, rect: CGRect) -> UIColor?
    {
        
        //Fill a one-pixel sized bitmap (with alpha) based on the CIImage
        var bitmap = [UInt8](repeating: 0, count: 4)
            if (image).cropping(to: rect) != nil {
            let rawImage = CIImage(cgImage: (image).cropping(to: rect)!)
            let extent = rawImage.extent
            let inputExtent = CIVector(x: extent.origin.x, y: extent.origin.y, z: extent.size.width, w: extent.size.height)
            
            //Creating a 1 pixel CIImage with the average of the given area.
            let filter = CIFilter(name: "CIAreaAverage", withInputParameters: [kCIInputImageKey: rawImage, kCIInputExtentKey: inputExtent])!
            let outputImage = filter.outputImage!
            let outputExtent = outputImage.extent
            assert(outputExtent.size.width == 1 && outputExtent.size.height == 1)
            
            // Render to bitmap.
            context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: kCIFormatRGBA8, colorSpace: CGColorSpaceCreateDeviceRGB())
            
            // Compute result.
            let result = UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
            return result
        }
        return nil
    }
    

}



