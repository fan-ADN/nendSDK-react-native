// @flow

'use strict'

import * as React from 'react';
import type {ViewProps} from 'ViewPropTypes';
import {
    requireNativeComponent,
    findNodeHandle,
    UIManager,
    AppState
} from 'react-native';

const RCTNendAdView = requireNativeComponent('RCTNendAdView');

type Event = Object;

type Props = {
    ...ViewProps,
    spotId: string,
    apiKey: string,
    adjustSize: boolean,
    onAdLoaded?: ?Function,
    onAdFailedToLoad?: ?Function,
    onAdClicked?: ?Function,
    onInformationClicked?: ?Function
};

type State = {
    style: {    
        width: number,
        height: number
    }
};

export default class AdView extends React.Component<Props, State> {
    static defaultProps = {
        adjustSize: false
    };

    constructor() {
        super();
        this.state = {
            style: {
                width: 0,
                height: 0
            }
        };
    }

    componentDidMount() {
        this.loadAd();
        AppState.addEventListener('change', this._handleAppStateChange);
    }

    componentWillUnmount() {
        AppState.removeEventListener('change', this._handleAppStateChange);
    }

    loadAd() {
        UIManager.dispatchViewManagerCommand(
            findNodeHandle(this),
            UIManager.RCTNendAdView.Commands.loadAd,
            null
        );
    }

    resume() {
        UIManager.dispatchViewManagerCommand(
            findNodeHandle(this),
            UIManager.RCTNendAdView.Commands.resume,
            null
        );
    }

    pause() {
        UIManager.dispatchViewManagerCommand(
            findNodeHandle(this),
            UIManager.RCTNendAdView.Commands.pause,
            null
        );
    }

    _handleAppStateChange = (nextAppState: string) => {
        if (nextAppState === 'active') {
            this.resume();
        } else {
            this.pause();
        }
    }

    _onAdLoaded = (e: Event) => {
        const width: number = e.nativeEvent.width;
        const height: number = e.nativeEvent.height;
        this.setState({ style: { width, height } });
        if (this.props.onAdLoaded) {
            this.props.onAdLoaded(e);
        }
    }

    _onAdFailedToLoad = (e: Event) => {
        if (this.props.onAdFailedToLoad) {
            this.props.onAdFailedToLoad(e);
        }
    }

    _onAdClicked = (e: Event) => {
        if (this.props.onAdClicked) {
            this.props.onAdClicked(e);
        }
    }

    _onInformationClicked = (e: Event) => {
        if (this.props.onInformationClicked) {
            this.props.onInformationClicked(e);
        }
    }

    render() {
        return (
            <RCTNendAdView 
                {...this.props}
                style={[this.props.style, this.state.style]}
                onAdLoaded={this._onAdLoaded}
                onAdFailedToLoad={this._onAdFailedToLoad}
                onAdClicked={this._onAdClicked}
                onInformationClicked={this._onInformationClicked}
            />
        );
    }
}
