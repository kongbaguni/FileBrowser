//
//  utill.swift
//  FileBrowser
//
//  Created by 서창열 on 2017. 7. 21..
//  Copyright © 2017년 서창열. All rights reserved.
//

import Foundation
import UIKit

extension UIImage
{
    func crop(_ frame:CGRect) -> UIImage
    {
        if let ref:CGImage = self.cgImage?.cropping(to: frame)
        {
            // print("cropImage : \(frame) imageSize : \(self.size)")
            return UIImage(cgImage: ref)
        }
        return self
    }
    
    func scaleToSize(_ size:CGSize) -> UIImage? {
        
        var newSize = size
        let widthFactor = self.size.width / newSize.width
        let heightFactor = self.size.height / newSize.height
        
        var resizeFactor = widthFactor
        if self.size.height > self.size.width {
            resizeFactor = heightFactor
        }
        newSize.width = self.size.width / resizeFactor
        newSize.height = self.size.height / resizeFactor
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        if let context:CGContext = UIGraphicsGetCurrentContext() {
            context.translateBy(x: 0.0, y: newSize.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.draw(self.cgImage!, in: CGRect(x: 0.0, y: 0.0, width: newSize.width, height: newSize.height))
            let scaledImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            return scaledImage
        }
        return nil
    }
    func scaleTo2(_ scaleX:CGFloat,scaleY:CGFloat) ->UIImage?
    {
        let newSize:CGSize = CGSize(width: self.size.width * scaleX, height: self.size.height * scaleY)
        return scaleToSize(newSize)
    }
    func scaleTo(_ scaleTo:CGFloat) -> UIImage?
    {
        return scaleTo2(scaleTo, scaleY: scaleTo)
    }
    func writeToPNGfile(_ fileName:String) -> String?
    {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        if let destinationPath = URL(string: documentsPath)?.appendingPathComponent("\(fileName).png").path
        {
            try? UIImagePNGRepresentation(self)?.write(to: URL(fileURLWithPath: destinationPath), options: [.atomic])
            return destinationPath
        }
        return nil
    }
    
    func resizeImage(_ targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        var newSize: CGSize
        if(widthRatio < heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        let scale = 1.0//UIScreen.main.scale
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, CGFloat(scale))
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    static func imageWidhColor(_ color:UIColor, rectValue: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1), alphaValue: CGFloat = 1.0) -> UIImage {
        let rect = rectValue//CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setAlpha(alphaValue)
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    //    static func loadImageAsset(_ asset: PHAsset) ->UIImage? {
    //        var retImage: UIImage? = nil
    //        let options = PHImageRequestOptions()
    //        options.version = .current
    //        options.resizeMode = .exact
    //        options.isSynchronous = true
    //
    //        PHCachingImageManager.default().requestImage(for: asset , targetSize: UIScreen.main.bounds.size, contentMode: PHImageContentMode.aspectFit, options: options) { (image, info) -> Void in
    //            retImage = image
    //        }
    //        if retImage != nil {
    //            return retImage
    //        }
    //        return nil
    //    }
    //
    //    static func loadImageAssetForFileURL(_ path: String) ->UIImage? {
    //        var retImage: UIImage? = nil
    //        let options = PHImageRequestOptions()
    //        options.version = .current
    //        options.resizeMode = .exact
    //        options.isSynchronous = true
    //
    //        let fetchResult = PHAsset.fetchAssets(with: nil)
    //        fetchResult.enumerateObjects({ (asset, index, _) in
    //            PHCachingImageManager.default().requestImageData(for: asset, options: options, resultHandler: { (data, dataUTI, orientation, info) in
    //                if let urlkey = info?["PHImageFileURLKey"] as? NSURL {
    //
    //                    // print("absoluteString : \(urlkey.absoluteString), path : \(path)")
    //
    //                    if urlkey.absoluteString! == path {
    //                        // print("@@@### absoluteString : \(urlkey.absoluteString), path : \(path)")
    //                        PHCachingImageManager.default().requestImage(for: asset , targetSize: UIScreen.main.bounds.size, contentMode: PHImageContentMode.aspectFit, options: options) { (image, info) -> Void in
    //                            retImage = image
    //                        }
    //                    }
    //                }
    //            })
    //        })
    //
    //        if retImage != nil {
    //            return retImage
    //        }
    //        return nil
    //    }
    
    func fixedOrientation()-> UIImage {
        if imageOrientation == UIImageOrientation.up {
            return self
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case UIImageOrientation.down, UIImageOrientation.downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
            break
        case UIImageOrientation.left, UIImageOrientation.leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
            break
        case UIImageOrientation.right, UIImageOrientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat(-M_PI_2))
            break
        case UIImageOrientation.up, UIImageOrientation.upMirrored:
            break
        }
        
        switch imageOrientation {
        case UIImageOrientation.upMirrored, UIImageOrientation.downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case UIImageOrientation.leftMirrored, UIImageOrientation.rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImageOrientation.up, UIImageOrientation.down, UIImageOrientation.left, UIImageOrientation.right:
            break
        }
        
        let ctx: CGContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0, space: self.cgImage!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case UIImageOrientation.left, UIImageOrientation.leftMirrored, UIImageOrientation.right, UIImageOrientation.rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(origin: CGPoint.zero, size: size))
        default:
            ctx.draw(self.cgImage!, in: CGRect(origin: CGPoint.zero, size: size))
            break
        }
        
        let cgImage: CGImage = ctx.makeImage()!
        
        return UIImage(cgImage: cgImage)
    }
}
