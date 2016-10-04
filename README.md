# G3 Mod Packaging Made Easy
Brought to you by Mike1072 and CamDawg


## Introduction

This utility is designed to simplify the creation of mod packages for different operating systems.  Once everything has been set up, you will be able to create a Windows, OS X, and Linux package for your mod with one double-click.

This was created in conjunction with [Real Mod](https://GitHub.com/Gibberlings3/RealMod), a fully-functioning mod that exists to showcase how to use this packaging utility and demonstrate the current best practices for audio conversion, character set handling, and tileset decompression.  When packaging your mod for the first time, you will need to copy and modify some of the files included in Real Mod.


## Instructions


### Set Up Your Folders

1. Place the contents of this repository in a folder named **ModPackaging**.
2. In the directory that contains **ModPackaging**, create a folder for your mod.  Place the files and folders for your mod that would normally be extracted to the IE game directory there.  You do not need to include WeiDU.
3. In the directory that contains **ModPackaging**, create a folder named **RealMod** and place the contents of [Real Mod](mike1072/RealMod) there.

When that's done, you should have one directory containing 3 folders: **ModPackaging**, **RealMod**, and **YourModNameHere**.


### Copy Over Some Files

1. The G3 icons were officially updated in 2015, so make sure to grab the latest .bmp and .ico files from the **RealMod\real_mod\style** directory. The banner file format had to be changed, so your mod needs the new files for packaging to succeed.
2. Modern versions of OS X cannot run the old sox and tisunpack programs that are included in many mods.  If your mod has audio, grab the latest sox from the **RealMod\real_mod\audio** directory.  If it has tilesets, grab the latest tisunpack from the **RealMod\real_mod\tiz\osx** directory.
3. Create a copy of **RealMod\package_mod.bat** and place it in the folder for your mod.


### Package a New Version

1. Use a text editor to open **package_mod.bat** in the folder for your mod.  Follow the included instructions to modify the file so that it reflects the properties of your mod.
2. Run **package_mod.bat** in the folder for your mod to create mod packages for all appropriate operating systems.

For future updates to the mod, you only need to update the version number in **package_mod.bat** and then run it.


## Contact Information

Comments about the packaging utility can be directed to [this forum thread](http://gibberlings3.net/forums/index.php?showtopic=26717).  If the thread is inaccessible, you can contact [Mike1072](http://gibberlings3.net/forums/index.php?showuser=1412) on the Gibberlings 3 forums.


## Version History

Version 7 - October 3, 2016

- Updated to WeiDU v240


Version 6 - September 13, 2016

- Updated to WeiDU v239


Version 5 - December 29, 2015

- Rewrote .bat files so they will function when called from a separate folder


Version 4 - March 7, 2015

- Updated to WeiDU v238
- Added option to prevent lowercasing filenames
- Fixed archive creation when .tp2 is outside of mod folder


Version 3 - February 15, 2015

- Replaced fnr with sed to improve compatibility under Wine, thanks to AstroBryGuy


Version 2 - January 6, 2015

- Updated to WeiDU v237
- Replaced OS X version of tisunpack with a more compatible one provided by StefanO


Version 1 - October 3, 2014

- Initial release packaged with WeiDU v236
