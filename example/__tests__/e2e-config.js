var devices = {
    'ios-simulator': {
        platformName: 'iOS',
        platformVersion: '12.4',
        deviceName: 'iPhone Simulator', // or if you choose target like -> "iPhone X"
        app: process.cwd() + '/ios/build/example/Build/Products/Debug-iphonesimulator/example.app',
    },
    'android-emulator': {
        platformName: "Android",
        deviceName: "Android Emulator",
        app: process.cwd() + '/android/app/build/outputs/apk/debug/app-debug.apk'
    }
}

if (!process.env.E2E_DEVICE) {
    throw new Error('E2E_DEVICE environment variable is not defined');
}

if (!devices[process.env.E2E_DEVICE]) {
    throw new Error(`No e2e device configuration found in package.json for E2E_DEVICE environment ${process.env.E2E_DEVICE}`);
}

export default devices[process.env.E2E_DEVICE];
