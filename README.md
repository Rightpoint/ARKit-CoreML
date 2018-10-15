# Using CoreML to enhance ARKit

ARKit is good at tracking images, but is pretty lenient. Enough to consider the Queen of Diamonds and the Queen of Clubs to be the same tracking image.

![Xcode Reference Too Similar](Documentation%20Support/Xcode_Reference_Too_Similar.png)

Queen of Clubs | Queen of Diamonds
:-------------:|:-------------------------:
![Queen of Clubs](Documentation%20Support/Queen_Clubs.jpg)  |  ![Queen of Diamonds](Documentation%20Support/Queen_Diamond.jpg)

This makes sense; It needs to be robust across lighting conditions, orientation, minor physical deformities, or other irregularties 
