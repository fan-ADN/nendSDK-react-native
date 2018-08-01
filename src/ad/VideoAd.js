// @flow

'use strict'
 
import {
    NativeModules,
    NativeEventEmitter,
} from 'react-native';

import type EmitterSubscription from 'EmitterSubscription';
import UserFeature from './UserFeature';

const NendRewardedVideoAd = NativeModules.NendRewardedVideoAd;
const NendInterstitialVideoAd = NativeModules.NendInterstitialVideoAd;

type VideoAdEvent = 
  | 'onVideoPlaybackError'
  | 'onVideoShown'
  | 'onVideoClosed'
  | 'onVideoPlaybackStarted'
  | 'onVideoPlaybackStopped'
  | 'onVideoPlaybackCompleted'
  | 'onVideoAdClicked'
  | 'onVideoAdInformationClicked'
  | 'onRewarded';

type VideoAdEventArgs = {
    spotId: string,
    eventType: VideoAdEvent,
    rewardName?: ?string,
    rewardAmount?: ?number
};

export type RewardItem = {
    name: string,
    amount: number
};

type VideoAdCallback = (void) => void;
type RewardCallback = (RewardItem) => void;

class VideoAd {
    +spotId: string;
    _subscription: EmitterSubscription;
    onVideoShown: ?VideoAdCallback;
    onVideoClosed: ?VideoAdCallback;
    onVideoPlaybackError: ?VideoAdCallback;
    onVideoPlaybackStarted: ?VideoAdCallback;
    onVideoPlaybackStopped: ?VideoAdCallback;
    onVideoPlaybackCompleted: ?VideoAdCallback;
    onVideoAdClicked: ?VideoAdCallback;
    onVideoAdInformationClicked: ?VideoAdCallback;

    constructor(spotId: string) {
        this.spotId = spotId;
    }

    handleVideoAdEvent(args: VideoAdEventArgs) {
        if (args.spotId !== this.spotId) {
            return;
        }
        switch (args.eventType) {
            case 'onVideoPlaybackError':
                if (this.onVideoPlaybackError) {
                    this.onVideoPlaybackError();
                }
                break;
            case 'onVideoShown':
                if (this.onVideoShown) {
                    this.onVideoShown();
                }
                break;
            case 'onVideoClosed':
                if (this.onVideoClosed) {
                    this.onVideoClosed();
                }
                break;
            case 'onVideoPlaybackStarted':
                if (this.onVideoPlaybackStarted) {
                    this.onVideoPlaybackStarted();
                }
                break;
            case 'onVideoPlaybackStopped':
                if (this.onVideoPlaybackStopped) {
                    this.onVideoPlaybackStopped();
                }
                break;
            case 'onVideoPlaybackCompleted':
                if (this.onVideoPlaybackCompleted) {
                    this.onVideoPlaybackCompleted();
                }
                break;
            case 'onVideoAdClicked':
                if (this.onVideoAdClicked) {
                    this.onVideoAdClicked();
                }
                break;
            case 'onVideoAdInformationClicked':
                if (this.onVideoAdInformationClicked) {
                    this.onVideoAdInformationClicked();
                }
                break;
        }
    }

    destroy() {
        this._subscription.remove();
    }
}

export class RewardedVideoAd extends VideoAd {
    onRewarded: ?RewardCallback;
    _rewardedVideoAdEmitter: NativeEventEmitter;

    constructor(spotId: string, apiKey: string) {
        super(spotId);
        this._rewardedVideoAdEmitter = new NativeEventEmitter(NendRewardedVideoAd);
        super._subscription = this._rewardedVideoAdEmitter.addListener('RewardedVideoAdEventListener', (args: VideoAdEventArgs) => {
            if (args.spotId === this.spotId && args.eventType === 'onRewarded') {
                if (this.onRewarded && args.rewardName && args.rewardAmount) {
                    this.onRewarded({ name: args.rewardName, amount: args.rewardAmount });
                }
            } else {
                super.handleVideoAdEvent(args);
            }
        });
        NendRewardedVideoAd.initialize(spotId, apiKey);
    }

    loadAd(): Promise<void> {
        return NendRewardedVideoAd.loadAd(this.spotId);
    }

    isLoaded(): Promise<boolean> {
        return NendRewardedVideoAd.isLoaded(this.spotId);
    }

    show() {
        NendRewardedVideoAd.show(this.spotId);
    }

    setUserId(userId: string) {
        NendRewardedVideoAd.setUserId(this.spotId, userId);
    }

    setUserFeature(userFeature: UserFeature) {
        NendRewardedVideoAd.setUserFeature(this.spotId, userFeature.getReferenceId());
    }

    destroy() {
        super.destroy();
        NendRewardedVideoAd.destroy(this.spotId);
    }
}

 export class InterstitialVideoAd extends VideoAd {
    _interstitialVideoAdEmitter: NativeEventEmitter;

    constructor(spotId: string, apiKey: string) {
        super(spotId);
        this._interstitialVideoAdEmitter = new NativeEventEmitter(NendInterstitialVideoAd);
        super._subscription = this._interstitialVideoAdEmitter.addListener('InterstitialVideoAdEventListener', (args: VideoAdEventArgs) => {
            super.handleVideoAdEvent(args);
        });
        NendInterstitialVideoAd.initialize(spotId, apiKey);
    }

    loadAd(): Promise<void> {
        return NendInterstitialVideoAd.loadAd(this.spotId);
    }

    isLoaded(): Promise<boolean> {
        return NendInterstitialVideoAd.isLoaded(this.spotId);
    }

    show() {
        NendInterstitialVideoAd.show(this.spotId);
    }

    setUserId(userId: string) {
        NendInterstitialVideoAd.setUserId(this.spotId, userId);
    }

    setUserFeature(userFeature: UserFeature) {
        NendInterstitialVideoAd.setUserFeature(this.spotId, userFeature.getReferenceId());
    }

    addFallbackFullBoard(fullBoardSpotId: string, fullBoardApiKey: string) {
        NendInterstitialVideoAd.addFallbackFullBoard(this.spotId, fullBoardSpotId, fullBoardApiKey);
    }

    destroy() {
        super.destroy();
        NendInterstitialVideoAd.destroy(this.spotId);
    }
}
