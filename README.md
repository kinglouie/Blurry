# Blurry
**Note:** this is in early development, expect some changes to happen.


![Example](https://thumbs.gfycat.com/BrownDigitalAdder-size_restricted.gif)

## Usage
### Create a Bar at the top identical to the menubar
	$ ./Blurry --height 22 --top 0 --left 0 --right 0 --material 9

## Development

### Generate XCode Project
    $ swift package generate-xcodeproj --xcconfig-overrides ./buildsettings.xcconfig

### Build a release

	$ swift build -c release -Xswiftc -static-stdlib

### Build and run for testing purposes

	$ swift run Blurry --height 22 --top 0 --left 0 --right 0 --material 9