// @flow
 
'use strict'

import {NativeModules, Platform} from 'react-native';

const nativeAd = NativeModules.NendNativeAd;

export type AdExplicitly = 'PR' | 'Sponsored' | 'AD' | 'Promotion';

export class NativeAd {
    +_referenceId: number;
    +adImageUrl: string;
    +logoImageUrl: string;
    +title: string;
    +content: string;
    +promotionName: string;
    +promotionUrl: string;
    +callToAction: string;
    +adExplicitly: string;

    constructor(data: Object) {
        this._referenceId = data.referenceId;
        this.adImageUrl = data.adImageUrl;
        this.logoImageUrl = data.logoImageUrl;
        this.title = data.title;
        this.content = data.content;
        this.promotionName = data.promotionName;
        this.promotionUrl = data.promotionUrl;
        this.callToAction = data.callToAction;
        this.adExplicitly = data.adExplicitly;
    }

    activateWith(adViewTag: ?number, prViewTag: ?number) {
        if (adViewTag && prViewTag) {
            nativeAd.activate(this._referenceId, adViewTag, prViewTag);
        }
    }

    performClick() {
        if (Platform.OS === 'android') {
            nativeAd.performClick(this._referenceId);
        }
    }

    destroy() {
        nativeAd.destroyAd(this._referenceId);
    }
}

export class NativeAdLoader {
    +_spotId: string;
    +_apiKey: string;

    constructor(spotId: string, apiKey: string) {
        this._spotId = spotId;
        this._apiKey = apiKey;
    }

    loadAd(adExplicitly: AdExplicitly): Promise<NativeAd> {
        return nativeAd.loadAd(this._spotId, this._apiKey, adExplicitly)
                       .then((ad: Object) => Promise.resolve(new NativeAd(ad)))
                       .catch(error => Promise.reject(error));
    }

    destroy() {
        nativeAd.destroyLoader(this._spotId);
    }
}
