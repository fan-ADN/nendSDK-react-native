// @flow

'use strict'

import {
    NativeModules,
    NativeEventEmitter
} from 'react-native';
import type EmitterSubscription from 'EmitterSubscription';

export type ClickType = 
  | 'DOWNLOAD' 
  | 'CLOSE' 
  | 'INFORMATION';

export type ShowError = 
  | 'AD_CANNOT_DISPLAY' 
  | 'AD_SHOW_ALREADY' 
  | 'AD_FREQUENCY_NOT_REACHABLE' 
  | 'AD_LOAD_INCOMPLETE' 
  | 'AD_REQUEST_INCOMPLETE' 
  | 'AD_DOWNLOAD_INCOMPLETE';

type CloseEventArgs = {
    spotId: string,
    clickType: ClickType
};

const NendInterstitialAd = NativeModules.NendInterstitialAd;
const eventEmitter = new NativeEventEmitter(NendInterstitialAd);
const subscription: EmitterSubscription = eventEmitter.addListener('onInterstitialAdClosed', (args: CloseEventArgs) => {
    if (InterstitialAd.onInterstitialAdClosed) {
        InterstitialAd.onInterstitialAdClosed(args.spotId, args.clickType);
    }
}); 

export default class InterstitialAd {
    static onInterstitialAdClosed: ?((spotId: string, type: ClickType) => void);

    static loadAd(spotId: string, apiKey: string): Promise<void> {
        return NendInterstitialAd.loadAd(spotId, apiKey);
    }

    static show(spotId: string): Promise<void> {
        return NendInterstitialAd.show(spotId);
    }

    static setAutoReloadEnabled(enabled: boolean) {
        NendInterstitialAd.setAutoReloadEnabled(enabled);
    }

    static destroy() {
        subscription.remove();
    }
}
