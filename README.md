# Enhancing ARKit Image Detection with Core ML
_ARKit is quite good at tracking images, but it struggles to disambiguate similar compositions. Core ML can help fill in the gaps._

#### ARKit
ARKit is a powerful tool that allows developers to create Augmented Reality apps. It comes loaded with [image detection and tracking](https://developer.apple.com/documentation/arkit/recognizing_images_in_an_ar_experience) functionality, which allows apps to "anchor" virtual content contextually on to real-world surfaces.

#### Tracking/Detection Trade-offs
For the best experience, image detection should be robust across lighting conditions, orientation, and other printing/reproduction irregularities. ARKit prioritizes this stronger, uninterrupted tracking experience over fine disambiguation between tracking images. Consequently, ARKit is fairly "lenient" when it comes to image detection.

### An Example
Consider an application where a different AR experience is triggered off of each playing card. (Perhaps we learn the story of the different Queens and their path to royalty.)

![Demo Gif](Documentation%20Support/Demo.gif)

AR tracking is essential for identifying the trigger and physically anchoring the experience. But we _need_ to be able to tell which card we're tracking confidently. Unfortunately, ARKit considers the Queen of Clubs and the Queen of Diamonds to be compositionally too similar to track separately. 

<img src="https://github.com/Raizlabs/ARKit-CoreML/blob/master/Documentation%20Support/Queen_Clubs.jpg" height="350"> <img src="https://github.com/Raizlabs/ARKit-CoreML/blob/master/Documentation%20Support/Queen_Diamond.jpg" height="350">
![Xcode Reference Too Similar](Documentation%20Support/Xcode_Reference_Too_Similar.png)

This ambiguity makes it impossible to build this experience using ARKit alone. (Both queens will be recognized in each card).
By inspection, however, these two images _should_ be easy for a machine to differentiate. Their colors and compositions are plenty different.

### How Core ML Can Help

Core ML can be employed to help disambiguate the playing cards using a simple image classifier. Compared to its vast capabilities, differentiating a few static compositions is a trivial task for machine learning. Using [Create ML](https://developer.apple.com/documentation/createml), [Custom Vision](https://www.customvision.ai/), [Watson](https://developer.ibm.com/patterns/deploy-a-core-ml-model-with-watson-visual-recognition/), or any other drag-and-drop service capable of generating a `.mlmodel` file, you can have a robust image classifier with as few as 5 training images per classification.

### How To Use Core ML With ARKit

The general workflow for employing Core ML alongside ARKit is simple: 
- ARKit informs you that it has detected a reference image coming in from the camera
- grab a snapshot of this real-world object
- feed it into your machine learning classifier
- Use the results to show the correct content

While the high-level approach isn't complicated, the low-level execution is more difficult.

# Usage
This project serves as an example and a host for utility methods to make it easier to incorporate Core ML into your ARKit applications.

### MLRecognizer
The tricky functionality is abstracted behind a simple [`MLRecognizer`](Library/MLRecognizer.swift) class. Instantiate it with a reference to your `MLModel` and your `ARSceneView`. 

```swift
lazy var recognizer = MLRecognizer(
    model: PlayingCards().model,
    sceneView: sceneView
)
```

Then, use the `classify` method to receive a classification for a given `ARImageAnchor`
```swift
func classify(imageAnchor: ARImageAnchor, completion: @escaping (Result<String>) -> Void)
```

Thats it! Go build something cool.

### Example
See [`ARSceneViewController`](Example/ARSceneViewController.swift) for an example implementation. 

In the `ARSCNViewDelegate` `renderer(_:didAdd:for:)` callback, we forward the image anchor to the `MLRecognizer` to be snapshotted, cropped, deskewed, and classified.

```swift
func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    guard let imageAnchor = anchor as? ARImageAnchor else { return }

    // send off anchor to be snapshotted, cropped, deskewed, and classified
    recognizer.classify(imageAnchor: imageAnchor) { [weak self] result in
        if case .success(let classification) = result {

            // update app with classification
            self?.attachLabel(classification, to: node)
        }
    }
}
```

## Utilities
[`ARKit+Utilities`](Library/ARKit+Utilities.swift) contains a number of useful utilities for capturing and cropping images from ARKit scenes.

```swift
extension ARSCNView {
    /**
     Functionally equivalent to `SCNView`'s `snapshot()`,
     except only including the raw camera image, 
     not any virtual geometry that may be in the scene.
     */
    public func capturedImage() -> UIImage?

    /**
     Returns a cropped and deskewed image of the raw camera image of a given `ARImageAnchor`, 
     not including any virtual geometry that may be in the scene.
     */
    public func capturedImage(from anchor: ARImageAnchor) -> UIImage?
}
```

## Installation
Add the files located in the [Library](Library/) folder to your project!
