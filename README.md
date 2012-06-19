# Simple-Share for iOS

## Overview
Simple-Share is an easy drop-in library for sharing on iOS.

### Supported Shares
- Facebook
- Twitter (iOS 5 only)
- Mail
- Safari

## Instructions
Clone the repository recursively
`git clone --recursive git://github.com/x2on/simple-share-ios.git`

or alternatively clone and checkout the submodules separately:
```bash
git clone git://github.com/x2on/simple-share-ios.git
cd simple-share-ios
git submodule init
git submodule update
```
Then run ```./build.sh``` and drop the libsimple-share.a file into your Xcode project.
Copy the include folder also to your project and set the "Header Search Path" to this folder.

you can share an URL to Facebook with this single line:

```objective-c
[facebookShare shareUrl:[NSURL URLWithString:@"http://www.felixschulze.de"]];
```

## Sample App
The project also includes a sample iOS App

## License
Apache License, Version 2.0 - See LICENSE