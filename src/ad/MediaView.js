// @flow

'use strict'

import * as React from 'react';
import type {ViewProps} from 'ViewPropTypes';
import {
    requireNativeComponent,
    findNodeHandle,
    UIManager,
} from 'react-native';
import type {VideoNativeAd} from './VideoNativeAd';

const RCTNendMediaView = requireNativeComponent('RCTNendMediaView');

type Props = {
    ...ViewProps,
    onPlaybackStarted?: ?Function,
    onPlaybackStopped?: ?Function,
    onPlaybackCompleted?: ?Function,
    onPlaybackError?: ?Function,
    onFullScreenOpened?: ?Function,
    onFullScreenClosed?: ?Function,
};

type State = {
    videoId: number
}

export default class MediaView extends React.Component<Props, State> {
    constructor() {
        super();
        this.state = { videoId: 0 };
    }

    componentDidUpdate(prevProps: Props, prevState: State) {
        if (this.state.videoId > 0 && this.state.videoId != prevState.videoId) {
            UIManager.dispatchViewManagerCommand(
                findNodeHandle(this),
                UIManager.RCTNendMediaView.Commands.setMedia,
                [this.state.videoId]);
        }
    }

    render() {
        return (
          <RCTNendMediaView {...this.props} />
        )
    }
}
