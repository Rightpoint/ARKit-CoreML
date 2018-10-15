# Enhancing ARKit image detection with CoreML

ARKit is good at tracking images, but is pretty lenient. Enough to consider the Queen of Clubs and the Queen of Diamonds to be too similar to track separately.

![Xcode Reference Too Similar](Documentation%20Support/Xcode_Reference_Too_Similar.png)

<img src="https://github.com/Raizlabs/ARKit-CoreML/blob/blog/Documentation%20Support/Queen_Clubs.jpg" height="350"> <img src="https://github.com/Raizlabs/ARKit-CoreML/blob/blog/Documentation%20Support/Queen_Diamond.jpg" height="350">

This lenience is understandable. Image detection needs to be robust across lighting conditions, orientation, and other printing/reproduction irregularities. ARKit is prioritizing a stronger, uninterrupted tracking experience over fine disambiguation of tracking images.

By inspection however, these two images _should_ be easy for a machine to differentiate. Their colors and compositions are plenty different. 

Consider an application where a different AR experience is triggered off of each playing card. Perhaps we learn the bask story of the different Queens and their path to royalty. The AR tracking is important to identify the trigger and to physically anchor the experience. But we _need_ to be able to confidently tell which card we're tracking. Enter CoreML.

CoreML can be employed to help disambiguate the playing cards using a simple image classifier. In the grand scheme its vast capabilities, differentiating a few static compositions is a trivial task for machine learning. Using [CreateML](https://developer.apple.com/documentation/createml), [Custom Vision](https://www.customvision.ai/), [Watson](https://developer.ibm.com/patterns/deploy-a-core-ml-model-with-watson-visual-recognition/), or any other drag-and-drop service capable of generating a `.mlmodel` file, you can have a robust image classifier with as few as 5 training images per classification.

## Putting it all together

The general workflow for employing `CoreML` alongside `ARKit` is simple: 
- `ARKit` informs you that it has detected a reference image
- grab a screenshot of this real-world object
- feed it into your machine learning classifier
- Use the results to show the correct content

While the high-level approach isn't complicated, the low-level execution is more difficult. This project serves as an example and a host for utility methods to make incorporating `CoreML` into your `ARKit` applications easier.
