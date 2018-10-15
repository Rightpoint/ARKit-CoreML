//
//  ARSceneViewController.swift
//  ARKitCoreML
//
//  Created by Jason Clark on 10/11/18.
//  Copyright © 2018 Raizlabs. All rights reserved.
//

import ARKit
import SceneKit
import UIKit

final class ARSceneViewController: UIViewController {

    lazy var recognizer = MLRecognizer(
        model: Queens().model,
        sceneView: sceneView
    )

    let detectionImages = ARReferenceImage.referenceImages(
        inGroupNamed: "AR Resources",
        bundle: nil
    )

    lazy var sceneView: ARSCNView = {
        let sceneView = ARSCNView()
        sceneView.delegate = self
        return sceneView
    }()

    lazy var refreshButton = UIBarButtonItem(
        barButtonSystemItem: .refresh,
        target: self, action: #selector(refreshButtonPressed)
    )

}

extension ARSceneViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = refreshButton

        view.addSubview(sceneView)
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        view.subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        resetTracking()
    }

    func resetTracking() {
        let config = ARWorldTrackingConfiguration()
        config.detectionImages = detectionImages
        config.maximumNumberOfTrackedImages = 1
        config.isLightEstimationEnabled = true
        config.isAutoFocusEnabled = true
        sceneView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        title = nil
    }

}

extension ARSceneViewController: ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }

        addIndicatorPlane(to: imageAnchor)

        recognizer.classify(imageAnchor: imageAnchor) { [weak self] in
            if case .success(let value) = $0 {
                self?.title = value
            }
        }
    }

    func addIndicatorPlane(to imageAnchor: ARImageAnchor) {
        let node = sceneView.node(for: imageAnchor)
        let size = imageAnchor.referenceImage.physicalSize
        let plane = SCNNode(geometry: SCNPlane(width: size.width, height: size.height))
        plane.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        plane.geometry?.firstMaterial?.fillMode = .lines
        plane.eulerAngles.x = -.pi / 2
        node?.addChildNode(plane)
    }

}

extension ARSceneViewController {

    @objc func refreshButtonPressed() {
        resetTracking()
    }

}
