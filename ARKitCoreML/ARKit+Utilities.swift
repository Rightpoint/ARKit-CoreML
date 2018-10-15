//
//  ARKit+Utilities.swift
//  ARKitCoreML
//
//  Created by Jason Clark on 10/11/18.
//  Copyright © 2018 Raizlabs. All rights reserved.
//

import ARKit

extension ARSCNView {

    /**
     Functionally equivalent to `SCNView`'s `snapshot()`, except only including the raw camera image, not any virtual geometry that may be in the scene.
     */
    public func capturedImage() -> UIImage? {
        guard let frame = session.currentFrame else { return nil }
        return frame.getCapturedImage(inSceneView: self)
    }

    /**
     Returns a cropped and deskewed image of the raw camera image of a given `ARImageAnchor`, not including any virtual geometry that may be in the scene.
     */
    public func capturedImage(from anchor: ARImageAnchor) -> UIImage? {
        guard
            let frame = session.currentFrame,
            let node = node(for: anchor),
            let pov = pointOfView,
            isNode(node, insideFrustumOf: pov),
            let snapshot = frame.getCapturedImage(inSceneView: self),
            let coreImage = CIImage(image: snapshot),
            let featureCorners = projectCorners(of: anchor)
        else {
            return nil
        }
        // CoreImage uses cartesian coordinates
        func cartesianForPoint(point: CGPoint, extent: CGRect) -> CGPoint {
            return CGPoint(x: point.x, y: extent.height - point.y)
        }
        let deskewed = coreImage.perspectiveCorrected(
            topLeft: cartesianForPoint(point: featureCorners.topLeft, extent: coreImage.extent),
            topRight: cartesianForPoint(point: featureCorners.topRight, extent: coreImage.extent),
            bottomLeft: cartesianForPoint(point: featureCorners.bottomLeft, extent: coreImage.extent),
            bottomRight: cartesianForPoint(point: featureCorners.bottomRight, extent: coreImage.extent)
        )
        return UIImage(ciImage: deskewed)
    }

}

extension ARFrame {
    /**
     Gives the camera data in the given frame after scaling and cropping it
     in the same way Apple does it for constructing the backing image you
     can retrieve via `sceneView.snapshot()`.
     */
    func getCapturedImage(inSceneView sceneView: ARSCNView) -> UIImage? {
        let rawImage = getOrientationCorrectedCameraImage(forOrientation: UIApplication.shared.statusBarOrientation)
        let viewportSize = sceneView.frame.size

        switch UIApplication.shared.statusBarOrientation {

        case .portrait, .portraitUpsideDown:
            guard let resized = rawImage?.resize(toHeight: viewportSize.height) else {
                return nil
            }
            return resized.crop(rect: CGRect(
                x: (resized.size.width - viewportSize.width) / 2,
                y: 0,
                width: viewportSize.width,
                height: viewportSize.height)
            )

        case .landscapeLeft, .landscapeRight:
            guard let resized = rawImage?.resize(toWidth: viewportSize.width) else {
                return nil
            }
            return resized.crop(rect: CGRect(
                x: 0,
                y: (resized.size.height - viewportSize.height) / 2,
                width: viewportSize.width,
                height: viewportSize.height)
            )

        case .unknown:
            return nil
        }
    }

}

private extension ARSCNView {

    private func projectCorners(of imageAnchor: ARImageAnchor) -> (topRight: CGPoint, bottomRight: CGPoint, bottomLeft: CGPoint, topLeft: CGPoint)? {
        guard
            let camera = session.currentFrame?.camera,
            let corners = CornerTrackingNode.tracking(anchor: imageAnchor, inScene: self)
            else { return nil }

        defer {
            corners.removeFromParentNode()
        }

        let pointsWorldSpace = [
            corners.topRight.simdWorldPosition,
            corners.bottomRight.simdWorldPosition,
            corners.bottomLeft.simdWorldPosition,
            corners.topLeft.simdWorldPosition,
            ]

        let pointsImageSpace: [CGPoint] = pointsWorldSpace.map {
            var point = camera.projectPoint($0,
                                            orientation: UIApplication.shared.statusBarOrientation,
                                            viewportSize: bounds.size)
            point.x *= UIScreen.main.scale
            point.y *= UIScreen.main.scale
            return point
        }

        return (
            topRight: pointsImageSpace[0],
            bottomRight: pointsImageSpace[1],
            bottomLeft: pointsImageSpace[2],
            topLeft: pointsImageSpace[3]
        )
    }

}

private extension ARFrame {
    /**
     Rotates the image from the camera to match the orientation of the device.
     */
    private func getOrientationCorrectedCameraImage(forOrientation orientation: UIInterfaceOrientation) -> UIImage? {
        var rotationRadians: Float = 0
        switch orientation {
        case .portrait:
            rotationRadians = .pi / 2
        case .portraitUpsideDown:
            rotationRadians = -.pi / 2
        case .landscapeLeft:
            rotationRadians = .pi
        case .landscapeRight:
            break
        case .unknown:
            return nil
        }
        return UIImage(pixelBuffer: capturedImage)?.rotate(radians: rotationRadians)
    }

}


private class CornerTrackingNode: SCNNode {

    let topLeft = SCNNode()
    let topRight = SCNNode()
    let bottomLeft = SCNNode()
    let bottomRight = SCNNode()

    init(anchor: ARImageAnchor) {
        super.init()

        let physicalSize = anchor.referenceImage.physicalSize
        let halfWidth = Float(physicalSize.width / 2)
        let halfHeight = Float(physicalSize.height / 2)

        addChildNode(topLeft)
        topLeft.position = position
        topLeft.localTranslate(by: SCNVector3(-halfWidth, 0, halfHeight))

        addChildNode(topRight)
        topRight.position = position
        topRight.localTranslate(by: SCNVector3(halfWidth, 0, halfHeight))

        addChildNode(bottomLeft)
        bottomLeft.position = position
        bottomLeft.localTranslate(by: SCNVector3(-halfWidth, 0, -halfHeight))

        addChildNode(bottomRight)
        bottomRight.position = position
        bottomRight.localTranslate(by: SCNVector3(halfWidth, 0, -halfHeight))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    static func tracking(anchor: ARImageAnchor, inScene scene: ARSCNView) -> CornerTrackingNode? {
        guard let node = scene.node(for: anchor) else { return nil }
        let tracker = CornerTrackingNode(anchor: anchor)
        node.addChildNode(tracker)
        return tracker
    }

}
