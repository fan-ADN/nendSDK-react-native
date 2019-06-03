rm react-native-nend-bridger-[0-9].[0-9].[0-9].tgz
npm pack

rm -rf example/

react-native init example

git checkout example/App.js
git checkout example/src/components

cd example

# react navigation
npm install --save react-navigation
npm install --save react-native-gesture-handler
react-native link react-native-gesture-handler
# Check -> https://reactnavigation.org/docs/en/getting-started.html

# nend bridger
npm i ../react-native-nend-bridger-[0-9].[0-9].[0-9].tgz
react-native link react-native-nend-bridger

cd -
git checkout example/android/app/src/main/java/com/example/MainApplication.java
git checkout example/ios/Podfile
cd -

cd ios
pod install
