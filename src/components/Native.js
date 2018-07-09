// @flow

'use strict'

import * as React from 'react';
import type {ViewProps} from 'ViewPropTypes';
import {
    findNodeHandle,
    StyleSheet,
    Text,
    Image,
    View,
    Platform,
    TouchableHighlight
} from 'react-native';
import {
    NativeAd,
    NativeAdLoader
} from "../ad/NativeAd";
import type {AdExplicitly} from "../ad/NativeAd";

type State = {
    adImageUrl: string,
    logoImageUrl: string,
    title: string,
    content: string,
    promotionName: string,
    promotionUrl: string,
    callToAction: string,
    adExplicitly: string
};

export default class Native extends React.Component<{}, State> {
    _rootView: ?View;
    _prText: ?Text;
    _adLoader: NativeAdLoader;
    _ad: ?NativeAd;

    static navigationOptions = {
        title: 'Native',
    };

    constructor() {
        super();
        this.state = {
            adImageUrl: '',
            logoImageUrl: '',
            title: '',
            content: '',
            promotionName: '',
            promotionUrl: '',
            callToAction: '',
            adExplicitly: ''
        };
        if (Platform.OS === 'ios') {
            this._adLoader = new NativeAdLoader('485504', '30fda4b3386e793a14b27bedb4dcd29f03d638e5');
        } else {
            this._adLoader = new NativeAdLoader('485520', 'a88c0bcaa2646c4ef8b2b656fd38d6785762f2ff');
        }
    }

    async componentDidMount() {
        try {
            const ad: NativeAd = await this._adLoader.loadAd('PR')
            this.setState({
                adImageUrl: ad.adImageUrl,
                logoImageUrl: ad.logoImageUrl,
                title: ad.title,
                content: ad.content,
                promotionName: ad.promotionName,
                promotionUrl: ad.promotionUrl,
                callToAction: ad.callToAction,
                adExplicitly: ad.adExplicitly
            });
            // クリックイベントの登録とインプレッションの計測を開始
            ad.activateWith(findNodeHandle(this._rootView), findNodeHandle(this._prText));
            this._ad = ad;
        } catch (error) {
            console.log(error);
        }
    }

    componentWillUnmount() {
      this._adLoader.destroy();
      if (this._ad) {
          this._ad.destroy();
      }
    }

    render() {
        return (
          <View style={styles.container}>
            <TouchableHighlight 
              onPress={() => {if (this._ad) this._ad.performClick()}} // Android の場合のみ呼び出し必須
              underlayColor="white">
              <View
                style={styles.adRoot}
                ref={component => this._rootView = component}>
                <View style={styles.logoContainer}>
                  {(() => {
                    if (this.state.logoImageUrl !== '') {
                      return <Image style={styles.logoImage} source={{uri: this.state.logoImageUrl}}></Image>;
                    }
                  })()}
                  <View style={styles.titleContainer}>
                    <Text style={styles.title} ellipsizeMode={'tail'} numberOfLines={1}>{this.state.title}</Text>
                    <View style={styles.prContainer}>
                      <Text style={styles.promotionName}>{this.state.promotionName}</Text>
                      <Text style={styles.pr} ref={component => this._prText = component}>{this.state.adExplicitly}</Text>
                    </View>
                  </View>
                </View>
                {(() => {
                  if (this.state.adImageUrl !== '') {
                    return <Image style={styles.adImage} source={{uri: this.state.adImageUrl}}></Image>;
                  }
                })()}
                <Text style={styles.promotionUrl}>{this.state.promotionUrl}</Text>
                <Text style={styles.content}>{this.state.content}</Text>
                <Text style={styles.cta}>{this.state.callToAction}</Text>
              </View>
            </TouchableHighlight>
          </View>
        );
    }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  adRoot: {
    width: 302,
    borderColor: 'black',
    borderWidth: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: 'white'
  },
  logoContainer: {
    width: 294,
    margin: 4,
    flexDirection: 'row'
  },
  titleContainer: {
    margin: 4,
    alignItems: 'flex-start'
  },
  prContainer: {
    width: 246,
    flexDirection: 'row',
    justifyContent: 'space-between'
  },
  adImage: {
    width: 300,
    height: 180,
    backgroundColor: 'gray',
  },
  logoImage: {
    width: 40,
    height: 40,
    backgroundColor: 'gray',
  },
  title: {
    color: 'black',
    fontWeight: 'bold'
  },
  pr: {
    padding: 1,
    backgroundColor: 'gray',
    fontWeight: 'bold',
    color: 'white'
  },
  promotionName: {
    marginTop: 4,
  },
  promotionUrl: {
    alignSelf: 'flex-start',
    margin: 4,
  },
  content: {
    margin: 4
  },
  cta: {
    width: 200,
    padding: 8,
    marginVertical: 8,
    fontWeight: 'bold',
    textAlign: 'center',
    textAlignVertical: 'center',
    backgroundColor: 'steelblue',
    color: 'white'
  }
});
