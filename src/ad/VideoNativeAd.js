// @flow

'use strict'
 
import {
    NativeModules,
    NativeEventEmitter,
} from 'react-native';

import type EmitterSubscription from 'EmitterSubscription';
import UserFeature from './UserFeature';

const videoNativeAd = NativeModules.NendVideoNativeAd;
const eventEmitter = new NativeEventEmitter(videoNativeAd);

export class VideoNativeAd {
    +videoId: number;
    +title: string;
    +description: string;
    +advertiserName: string;
    +userRating: number;
    +userRatingCount: number;
    +callToAction: string;
    +logoImageUrl: string;
    
    onImpression: ?Function; 
    onClickAd: ?Function; 
    onClickInformation: ?Function; 
    
    _subscription: EmitterSubscription;
    
    constructor(data: Object) {
        this.videoId = data.referenceId;
        this.title = data.title;
        this.description = data.description;
        this.advertiserName = data.advertiserName;
        this.userRating = data.userRating;
        this.userRatingCount = data.userRatingCount;
        this.callToAction = data.callToAction;
        this.logoImageUrl = data.logoImageUrl;

        this._subscription = eventEmitter.addListener('VideoNativeAdEventListener', (args: {refId: number, eventType: string}) => {
            if (args.refId === this.videoId) {
                switch (args.eventType) {
                    case 'onImpression':
                        if (this.onImpression) {
                            this.onImpression();
                        }
                        break;
                    case 'onClickAd':
                        if (this.onClickAd) {
                            this.onClickAd();
                        }
                        break;
                    case 'onClickInformation':
                        if (this.onClickInformation) {
                            this.onClickInformation();
                        }
                        break;                
                }
            }
        });
    }

    registerClickableViews(tags: [number]) {
        videoNativeAd.registerClickableViews(this.videoId, tags);        
    }

    destroy() {
        this._subscription.remove();
        videoNativeAd.destroyAd(this.videoId);
    }
}

export type VideoClickOption = 'FullScreen' | 'LP';

export class VideoNativeAdLoader {
    +_spotId: string;

    constructor(spotId: string, apiKey: string, clickOption: VideoClickOption = 'FullScreen') {
        this._spotId = spotId;
        const option: number = clickOption === 'FullScreen' ? videoNativeAd.FullScreen : videoNativeAd.LP;
        videoNativeAd.initialize(spotId, apiKey, option);
    }

    loadAd(): Promise<VideoNativeAd> {
        return videoNativeAd.loadAd(this._spotId).then((data: Object) => Promise.resolve(new VideoNativeAd(data)));
    }

    setUserId(userId: string) {
        videoNativeAd.setUserId(this._spotId, userId);
    }

    setUserFeature(userFeature: UserFeature) {
        videoNativeAd.setUserFeature(this._spotId, userFeature.getReferenceId());
    }

    destroy() {
        videoNativeAd.destroyLoader(this._spotId);
    }
}
