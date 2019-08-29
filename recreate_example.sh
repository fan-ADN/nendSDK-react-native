rm -rf example/

rm react-native-nend-bridger-[0-9].[0-9].[0-9].tgz
npm pack

react-native init example --version 0.59.8
# --package=net.nend.reactnativeexample

git checkout example/App.js
git checkout example/src/components
git checkout example/__tests__

cd example

# react navigation
npm install --save react-navigation
npm install --save react-native-gesture-handler
react-native link react-native-gesture-handler
# Check -> https://reactnavigation.org/docs/en/getting-started.html

# appium
npm i --save-dev wd
npm i --save-dev appium
npm i --save-dev appium-doctor

# CI
npm i --save-dev jest-jenkins-reporter

# nend bridger
npm i ../react-native-nend-bridger-[0-9].[0-9].[0-9].tgz
react-native link react-native-nend-bridger

cd -
git checkout example/android/app/src/main/java/net/nend/reactnativeexample/MainApplication.java
git checkout example/ios/Podfile
cd -

cd ios
pod install
