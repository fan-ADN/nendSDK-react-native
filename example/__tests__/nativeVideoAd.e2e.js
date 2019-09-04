import wd from 'wd';
import config from './e2e-config';
import commonUtils from './e2e-commonUtils';

const port = 4723;
const driver = wd.promiseChainRemote('localhost', port);
jasmine.DEFAULT_TIMEOUT_INTERVAL = 60000;

describe('Native Video ad Test via Appium', () => {
    beforeAll(async () => {
        await driver.init(config);
        await driver.sleep(5000);
    });
    afterAll(async () => await driver.quit());

    test('Check playing', async () => {
        await driver.elementByAccessibilityId('Go to video native ad example').click();
        await driver.sleep(5000);

        expect(await driver.hasElementByAccessibilityId("onPlaybackStarted")).toBe(true);
        await driver.sleep(5000);
        expect(await driver.hasElementByAccessibilityId("onPlaybackCompleted")).toBe(true);

        //Note : can find executing on Android
        // await driver.elementByAccessibilityId("play").click();
        // await driver.sleep(3000);

        //Note : can find "NendAdNativeMediaView" on Appium inspector, but not found on execute time...
        // await driver.elementsByAccessibilityId("NendAdNativeMediaView").click();
        // expect(await driver.hasElementByAccessibilityId("onFullScreenOpened")).toBe(true);
        // await driver.sleep(5000);
        // await driver.elementByAccessibilityId("closeVideo").click();
        // await driver.sleep(1000);
        // expect(await driver.hasElementByAccessibilityId("onFullScreenClosed")).toBe(true);

        await commonUtils.pressBackButton(driver);
    });

    test('Register clickable', async () => {
        await driver.elementByAccessibilityId('Go to video native ad example').click();
        await driver.sleep(5000);

        var cta = "詳細を見る";// Not found via 'AdClickPerformer'
        expect(await driver.hasElementByAccessibilityId(cta)).toBe(true);
        await driver.elementByAccessibilityId(cta).click();
        await driver.sleep(3000);
        expect(await driver.hasElementByAccessibilityId(cta)).toBe(false);

        await commonUtils.backFromBroser(driver);
        await commonUtils.pressBackButton(driver);
    });
});
