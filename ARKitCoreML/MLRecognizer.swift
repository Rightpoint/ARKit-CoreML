//
//  MLRecognizer.swift
//  ARKitCoreML
//
//  Created by Jason Clark on 10/11/18.
//  Copyright © 2018 Raizlabs. All rights reserved.
//

import ARKit
import UIKit
import SceneKit
import Vision

class MLRecognizer: NSObject {

    private var model: MLModel
    private weak var sceneView: ARSCNView?
    private let visionQueue = DispatchQueue(label: "com.raizlabs.serialVisionQueue")

    init(model: MLModel, sceneView: ARSCNView) {
        self.model = model
        self.sceneView = sceneView
        super.init()
    }

    func classify(imageAnchor: ARImageAnchor, completion: @escaping (Result<String>) -> Void) {
        DispatchQueue.main.async { [weak self] in
            self?._classify(imageAnchor: imageAnchor, completion: { result in
                DispatchQueue.main.async {
                    completion(result)
                }
            })
        }
    }

}

private extension MLRecognizer {

    private func _classify(imageAnchor: ARImageAnchor, completion: @escaping (Result<String>) -> Void) {
        // 1. Crop image of the projection of the anchor
        guard
            let cropped = sceneView?.capturedImage(from: imageAnchor),
            let image = cropped.getOrCreateCGImage()
            else {
                completion(.failure(MLError.cropFailed))
                return
        }

        // 2. Prepare classification result handler
        let classificationResultHandler: VNRequestCompletionHandler = { request, error in
            guard let results = request.results as? [VNClassificationObservation] else { return }
            // classifications are ordered by confidence
            if let mostLikelyClassification = results.first {
                completion(.success(mostLikelyClassification.identifier))
            }
            else {
                completion(.failure(MLError.classificationFailed))
            }
        }

        // 3. Dispatch Vision request
        let requestHandler = VNImageRequestHandler(cgImage: image, options: [:])
        guard let vnModel = try? VNCoreMLModel(for: model)
        else {
            completion(.failure(MLError.loadModelFailed))
            return
        }

        let request = VNCoreMLRequest(
            model: vnModel,
            completionHandler: classificationResultHandler
        )
        request.imageCropAndScaleOption = .centerCrop
        request.usesCPUOnly = true
        visionQueue.async {
            do { try requestHandler.perform([request]) }
            catch { completion(.failure(error)) }
        }
    }

}

extension MLRecognizer {

    public enum Result<Value> {
        case success(Value)
        case failure(Error)
    }

    public enum MLError: Error {
        case cropFailed
        case loadModelFailed
        case classificationFailed
    }

}
