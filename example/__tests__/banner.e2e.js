import wd from 'wd';
import config from './e2e-config';

const port = 4723;
const driver = wd.promiseChainRemote('localhost', port);
jasmine.DEFAULT_TIMEOUT_INTERVAL = 60000;

describe('Simple Integration Test via Appium', () => {
    beforeAll(async () => {
        await driver.init(config);
        await driver.sleep(5000);
    });
    // beforeAll(async () => await driver.init(config));
    afterAll(async () => await driver.quit());

    test('show Banner', async () => {
        await driver.elementByAccessibilityId('Go to banner ad example').click();
        await driver.sleep(5000);
        expect(await driver.hasElementByAccessibilityId('NendBannerAdView')).toBe(true);
        await driver.elementByAccessibilityId('NendBannerAdView').click();
        await driver.sleep(3000);
        expect(await driver.hasElementByAccessibilityId('NendBannerAdView')).toBe(false);
    });
});
