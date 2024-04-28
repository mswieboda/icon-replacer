# icon-replacer

macOS command line app to replace Application icons with custom icons

## Installation

`make test` or `make release`

builds a command line app in a created `build` dir

## Usage

````
❯ ./build/icon-replacer -h
Icon Replacer (0.1.0)
Replaces macOS system icons with user specified ones
Usage: icon-replacer [args]
    -s FILE, --settings=FILE         Specifies settings file to load
    -v, --version                    Show version
    -h, --help                       Show help
````


## Example prompts

Note: the native macOS file chooser, and file name chooser are used for choosing files and saving the settings file.

````
./build/icon-replacer
Load settings from a file?
type Y to load, anything else means N
n
Which app file icon do you want to replace?
/Applications/Brave Browser.app/
Which icon do you want to use?
/Users/matt/Pictures/icons/chrome-dark.png
add another?
type Y to continue, anything else means N
n
save replacement settings?
type Y to continue, anything else means N
n
/Applications/Brave Browser.app/ icon replaced
````
