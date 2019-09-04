
exports.backFromBroser = async function(driver){
    if (process.env.E2E_DEVICE.includes('ios')) {
        await driver.elementByAccessibilityId("breadcrumb").click();
    } else {
        await driver.back();
    }
};

exports.pressBackButton = async function(driver){
    if (process.env.E2E_DEVICE.includes('ios')) {
        await driver.elementByAccessibilityId("header-back").click();
    } else {
        await driver.back();
    }
};
