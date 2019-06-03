rm react-native-nend-bridger-[0-9].[0-9].[0-9].tgz
npm pack

cd example
npm install

rm -rf node_modules/react-native-nend-bridger/
npm i ../react-native-nend-bridger-[0-9].[0-9].[0-9].tgz
react-native link react-native-nend-bridger

cd ios
pod install
