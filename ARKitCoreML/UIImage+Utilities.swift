//
//  UIImage+Utilities.swift
//  ARKitCoreML
//
//  Created by Jason Clark on 10/11/18.
//  Copyright © 2018 Raizlabs. All rights reserved.
//

import UIKit
import VideoToolbox

extension UIImage {

    public convenience init?(pixelBuffer: CVPixelBuffer) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        guard let image = cgImage else { return nil }
        self.init(cgImage: image)
    }

    public func crop(rect: CGRect) -> UIImage? {
        var rect = rect
        rect.origin.x *= scale
        rect.origin.y *= scale
        rect.size.width *= scale
        rect.size.height *= scale

        if let imageRef = cgImage?.cropping(to: rect) {
            return UIImage(cgImage: imageRef, scale: scale, orientation: imageOrientation)
        }
        return nil
    }

    public func rotate(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size

        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, true, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }

        // Move origin to middle
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))

        self.draw(in: CGRect(
            x: -size.width / 2,
            y: -size.height / 2,
            width: size.width, height: size.height
        ))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    public func getOrCreateCGImage() -> CGImage? {
        return cgImage ?? ciImage.flatMap {
                let context = CIContext()
                return context.createCGImage($0, from: $0.extent)
        }
    }

    /**
     Scales the image to the given height while preserving its aspect ratio.
     */
    public func resize(toHeight newHeight: CGFloat) -> UIImage? {
        guard self.size.height != newHeight else { return self }
        let ratio = newHeight / size.height
        let newSize = CGSize(width: size.width * ratio, height: newHeight)
        return resize(to: newSize)
    }

    /**
     Scales the image to the given width while preserving its aspect ratio.
     */
    public func resize(toWidth newWidth: CGFloat) -> UIImage? {
        guard self.size.width != newWidth else { return self }
        let ratio = newWidth / size.width
        let newSize = CGSize(width: newWidth, height: size.height * ratio)
        return resize(to: newSize)
    }

    private func resize(to newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let scaledImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }

}
