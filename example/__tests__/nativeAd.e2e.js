import wd from 'wd';
import config from './e2e-config';
import commonUtils from './e2e-commonUtils';

const port = 4723;
const driver = wd.promiseChainRemote('localhost', port);
jasmine.DEFAULT_TIMEOUT_INTERVAL = 60000;

describe('Native ad Test via Appium', () => {
    beforeAll(async () => {
        await driver.init(config);
        await driver.sleep(5000);
    });
    afterAll(async () => await driver.quit());

    test('Click ad', async () => {
        await driver.elementByAccessibilityId('Go to native ad example').click();
        await driver.sleep(5000);
        expect(await driver.hasElementByAccessibilityId('AdClickPerformer')).toBe(true);
        await driver.elementByAccessibilityId('AdClickPerformer').click();
        await driver.sleep(3000);
        expect(await driver.hasElementByAccessibilityId('AdClickPerformer')).toBe(false);

        await commonUtils.backFromBroser(driver);
        await commonUtils.pressBackButton(driver);
    });

    //Note : cannot find accessibilityLabel...
    // test('Click information', async () => {
    //     await driver.elementByAccessibilityId('Go to native ad example').click();
    //     await driver.sleep(5000);
    //     expect(await driver.hasElementByAccessibilityId('InformationClickPerformer')).toBe(true);
    //     await driver.elementByAccessibilityId('InformationClickPerformer').click();
    //     await driver.sleep(3000);
    //     expect(await driver.hasElementByAccessibilityId('InformationClickPerformer')).toBe(false);
    // });
});
