#!/bin/sh

PACKED=react-native-nend-bridger-[0-9].[0-9].[0-9].tgz
if [ -e ${PACKED} ]; then
    rm ${PACKED}
fi
npm pack

cd example
npm install

BRIDGER_DIR="node_modules/react-native-nend-bridger/"
if [ -d $BRIDGER_DIR ]; then
    rm -rf ${BRIDGER_DIR}
fi
npm i ../${PACKED}

# Note : React Native CLI uses autolinking for native dependencies, but the following modules are linked manually...
# react-native link react-native-nend-bridger

if [ "$(uname)" == "Darwin" ]; then
    #  Mac OS X platform
    cd ios
    pod install
# elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
#     # GNU/Linux platform
# elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
#     # 32 bits Windows NT platform
# elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]; then
#     # 64 bits Windows NT platform
fi
