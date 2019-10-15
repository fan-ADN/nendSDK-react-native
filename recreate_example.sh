rm -rf example/

rm react-native-nend-bridger-[0-9].[0-9].[0-9].tgz
npm pack

react-native init example --version 0.61.1
# --package=net.nend.reactnativeexample

git checkout example/App.js
git checkout example/src/components
git checkout example/__tests__

cd example

# Check -> https://reactnavigation.org/docs/en/getting-started.html
# react navigation
npm install --save react-navigation
npm install --save react-native-gesture-handler
react-native link react-native-gesture-handler

# appium
npm i --save-dev wd
npm i --save-dev appium
npm i --save-dev appium-doctor

# CI
npm i --save-dev jest-jenkins-reporter

# nend bridger
npm i ../react-native-nend-bridger-[0-9].[0-9].[0-9].tgz

# Note : React Native CLI uses autolinking for native dependencies, but the following modules are linked manually...
# react-native link react-native-nend-bridger

cd -
git checkout example/android/app/src/main/java/net/nend/reactnativeexample/MainApplication.java
cd -

cd ios

# TODO...
# cp Podfile Podfile.txt
# cat Podfile.txt | sed -e '/^use_native_modules[iI]t$/a use_frameworks[iI]t'
# rm Podfile
# mv Podfile.txt Podfile

pod install
