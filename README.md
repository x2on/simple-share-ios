# Simple-Share for iOS

## Overview
Simple-Share is an easy drop-in library for sharing on iOS.

### Supported Shares
- Facebook (facebook-ios-sdk 3.1.1)
- Twitter
- Mail
- Safari

## Instructions
First checkout the submodules:
```bash
git submodule init
git submodule update
```

Then build the facebook sdk:
```bash
cd submodules/facebook-ios-sdk/scripts
./build_framework.sh
```

Then run ```./build.sh``` and drop the libsimple-share.a file into your Xcode project.
Copy the include folder also to your project and set the "Header Search Path" to this folder.

you can share an URL to Facebook with this single line:

```objective-c
[facebookShare shareUrl:[NSURL URLWithString:@"http://www.felixschulze.de"]];
```

Twitter:
```objective-c
[simpleTwitterShare shareText:@"Some text to share"];
```

Mail:
```objective-c
[simpleMailShare shareText:@"Some text" subject:@"Some subject" isHTML:NO];
```

## Compatibility
Lowest supported iOS is 5.0

## Sample App
The project also includes a sample iOS App

## License
Apache License, Version 2.0 - See LICENSE