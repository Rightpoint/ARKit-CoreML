# Using CoreML to enhance ARKit

ARKit is good at tracking images, but is pretty lenient. Enough to consider the Queen of Clubs and the Queen of Diamonds to be too similar to track separately.

![Xcode Reference Too Similar](Documentation%20Support/Xcode_Reference_Too_Similar.png)

<img src="https://github.com/Raizlabs/ARKit-CoreML/blob/blog/Documentation%20Support/Queen_Clubs.jpg" height="350"> <img src="https://github.com/Raizlabs/ARKit-CoreML/blob/blog/Documentation%20Support/Queen_Diamond.jpg" height="350">

This lenience is understandable. Image detection needs to be robust across lighting conditions, orientation, minor physical deformities, or other printing/reproduction irregularties. ARKit is prioritizing a stronger, uninterrupted tracking experience over fine disambiguation of tracking images.

By inspection however, these two images _should_ be easy for a machine to differentiate. Their colors and compositions are plenty different. Consider an application where a different AR experience is triggered off of each playing card. Perhaps we learn the baskstory of the different Queens and their path to royalty. The AR tracking is important to identify the trigger and to physically anchor the experience. But we _need_ to be able to confidently tell which card we're tracking. Enter CoreML.

CoreML can be employed to help disambiguate which card the user scanned. By training a simple image classifier, 
