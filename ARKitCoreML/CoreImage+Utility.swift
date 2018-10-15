//
//  CoreImage+Utility.swift
//  ARKitCoreML
//
//  Created by Jason Clark on 10/11/18.
//  Copyright © 2018 Raizlabs. All rights reserved.
//

import CoreImage

extension CIImage {

    func perspectiveCorrected(topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage {
        return self.applyingFilter("CIPerspectiveCorrection", parameters: [
            "inputTopLeft": CIVector(cgPoint: topLeft),
            "inputTopRight": CIVector(cgPoint: topRight),
            "inputBottomLeft": CIVector(cgPoint: bottomLeft),
            "inputBottomRight": CIVector(cgPoint: bottomRight),
        ])
    }

}
