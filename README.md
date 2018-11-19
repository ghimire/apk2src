## apk2src.sh  
#### Decompile or reverse-engineer Android APK Packages 

License: GNU GPL v3.0  

This script is for educational purpose only. It is aimed at security 
professionals in reverse engineering APK packages for the sole purpose 
of identifying malicious behaviours.

**Usage**  
>$ chmod u+x apk2src.sh  
>$ ./apk2src.sh /path/to/apkfile.apk  

A bzip2 tarball is created in the current path with fully decompiled java sources and project assets. After extraction, the 
folder can be imported to Eclipse as Android project.

**Testing**  
To test the script on APKs installed on your device, use the commands below to download APKs and decompile them using the apk2src.sh script.  
>$ adb shell ls /data/app/ | sed 's/[[:space:]]//g' | while read line; do adb pull /data/app/${line} .; done  
>$ for i in *.apk; do ./apk2src.sh ${i}; done  

**Thanks to**  
* [dex2jar project](http://code.google.com/p/dex2jar/) 
* [jd-core-java project](https://github.com/nviennot/jd-core-java) 
