# Using CoreML to enhance ARKit

ARKit is good at tracking images, but is pretty lenient. Enough to consider the Queen of Clubs and the Queen of Diamonds to be the same tracking image.

![Xcode Reference Too Similar](Documentation%20Support/Xcode_Reference_Too_Similar.png)

<img src="https://github.com/Raizlabs/ARKit-CoreML/blob/blog/Documentation%20Support/Queen_Clubs.jpg" height="350"> <img src="https://github.com/Raizlabs/ARKit-CoreML/blob/blog/Documentation%20Support/Queen_Diamond.jpg" height="350">

This makes sense; It needs to be robust across lighting conditions, orientation, minor physical deformities, or other irregularties 
