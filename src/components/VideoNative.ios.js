// @flow

'use strict'

import * as React from 'react';
import {
  StyleSheet,
  Platform,
  Alert,
  View,
  Image,
  Text,
  findNodeHandle
} from 'react-native';
import {VideoNativeAdLoader} from '../ad/VideoNativeAd';
import type {VideoNativeAd} from '../ad/VideoNativeAd';
import MediaView from '../ad/MediaView';
import UserFeature from '../ad/UserFeature';
import Button from './Button';

type State = {
    title: string,
    description: string,
    advertiser: string,
    callToAction: string,
    userRating: number,
    userRatingCount: number,
    logoImageUrl: string
};

export default class VideoNative extends React.Component<{}, State> {
    _adLoader: VideoNativeAdLoader;
    _videoAd: ?VideoNativeAd;
    _mediaView: ?MediaView;
    _cta: ?Button;

    static navigationOptions = {
        title: 'VideoNative',
    };

    constructor() {
        super();
        this._adLoader = new VideoNativeAdLoader('887595', 'e7c1e68e7c16e94270bf39719b60534596b1e70d');

        // https://github.com/fan-ADN/nendSDK-iOS/wiki/%E5%8B%95%E7%94%BB%E3%83%8D%E3%82%A4%E3%83%86%E3%82%A3%E3%83%96%E5%BA%83%E5%91%8A%E5%AE%9F%E8%A3%85%E6%89%8B%E9%A0%86#%E3%83%A6%E3%83%BC%E3%82%B6%E3%83%BC%E5%B1%9E%E6%80%A7%E3%81%AE%E8%A8%AD%E5%AE%9A
        const feature = new UserFeature();
        feature.setGender('Female');
        feature.setAge(20);
        feature.setBirthday(2000, 1, 1);
        feature.addCustomValue('customStringValue', 'stringValue');
        feature.addCustomValue('customBooleanValue', true);
        feature.addCustomValue('customIntegerValue', 12345);
        feature.addCustomValue('customDoubleValue', 123.45);
        this._adLoader.setUserFeature(feature);
        feature.destroy();
        
        this.state = {
            title: '',
            description: '',
            advertiser: '',
            callToAction: '',
            userRating: -1,
            userRatingCount: -1,
            logoImageUrl: ''
        };
    }

    async componentDidMount() {
        try {
            const videoAd: VideoNativeAd = await this._adLoader.loadAd();
            if (this._mediaView) {
                this._mediaView.setState({videoId: videoAd.videoId});
            }
            this.setState({
                logoImageUrl: videoAd.logoImageUrl,
                title: videoAd.title,
                description: videoAd.description,
                callToAction: videoAd.callToAction,
                advertiser: videoAd.advertiserName,
                userRating: videoAd.userRating,
                userRatingCount: videoAd.userRatingCount
            });
            if (this._cta) {
                const tag: ?number = findNodeHandle(this._cta);
                if (tag) {
                    // コールトゥアクションボタンのクリックで広告ページに遷移できるようにする
                    videoAd.registerClickableViews([tag]);
                }
            }
            videoAd.onImpression = () => {console.log('onImpression')};
            videoAd.onClickAd = () => {console.log('onClickAd')};
            videoAd.onClickInformation = () => {console.log('onClickInformation')};
            this._videoAd = videoAd;
        } catch (error) {
            Alert.alert(error.message);
        }
    }

    componentWillUnmount() {
        this._adLoader.destroy();
        if (this._videoAd) {
            this._videoAd.destroy();
        }
    }

    render() {
        return (
            <View style={styles.container}>
              {(() => {
                if (this.state.logoImageUrl !== '') {
                    return <Image style={styles.logoImage} source={{uri: this.state.logoImageUrl}}></Image>;
                }
              })()}
              <Text style={styles.title} ellipsizeMode={'tail'} numberOfLines={1}>{this.state.title}</Text>
              <Text>{this.state.advertiser}</Text>
              <MediaView 
                style={styles.media} 
                ref={component => {this._mediaView = component}}
                onPlaybackStarted={() => console.log('onPlaybackStarted')}
                onPlaybackStopped={() => console.log('onPlaybackStopped')}
                onPlaybackCompleted={() => console.log('onPlaybackCompleted')}
                onPlaybackError={() => console.log('onPlaybackError')}
                onFullScreenOpened={() => console.log('onFullScreenOpened')}
                onFullScreenClosed={() => console.log('onFullScreenClosed')}
              />
              <Text ellipsizeMode={'tail'} numberOfLines={3}>{this.state.description}</Text>
              <Text>{this.state.userRating}, {this.state.userRatingCount}</Text>
              <Button ref={component => this._cta = component} title={this.state.callToAction} onPress={() => {}} />
              <Text>PR</Text>              
            </View>
        );
    }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  logoImage: {
    width: 60,
    height: 60,
    backgroundColor: 'gray',
  },
  media: {
      width: 320,
      height: 180,
      backgroundColor: 'black'
  },
  title: {
    fontSize: 18,
    color: 'black',
    fontWeight: 'bold'
  },
});