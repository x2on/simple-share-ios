# Simple-Share for iOS

## Overview
Simple-Share is an easy drop-in library for sharing on iOS.

## Instructions
Run ./build.sh and drop the libsimple-share.a file into your Xcode project.
Copy the include folder also to your project and set the "Header Search Path" to this folder.

you can share an URL to Facebook with this single line:

```objective-c
[facebookShare shareUrl:[NSURL URLWithString:@"http://www.felixschulze.de"]];
```

## Sample App
The project also includes a sample iOS App