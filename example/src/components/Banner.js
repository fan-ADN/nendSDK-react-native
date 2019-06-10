// @flow

'use strict'

import * as React from 'react';
import {
  StyleSheet,
  Platform,
  Text,
  View
} from 'react-native';
import {AdView} from 'react-native-nend-bridger';

export default class Banner extends React.Component<{}, {}> {
    static navigationOptions = {
        title: 'Banner',
    };
    render() {
        let spotId: string;
        let apiKey: string;
        if (Platform.OS === 'ios') {
            spotId = '3172';
            apiKey = 'a6eca9dd074372c898dd1df549301f277c53f2b9';
        } else {
            spotId = '3174';
            apiKey = 'c5cb8bc474345961c6e7a9778c947957ed8e1e4f';
        }
        return (
          <View style={styles.container}>
            <AdView
                spotId={spotId}
                apiKey={apiKey}
                adjustSize={true} // 広告のサイズを画面の横幅に合わせて調節 (省略した場合はfalse)
                onAdLoaded={() => console.log('loading of ad is completed.')}
                onAdFailedToLoad={(event) => console.log(`loading of ad is failed: ${event.nativeEvent.code}, ${event.nativeEvent.message}`)}
                onAdClicked={() => console.log('ad clicked.')}
                onInformationClicked={() => console.log('information button clicked.')}
            />
            <Text style={styles.text}>320x50</Text>
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
  text: {
      marginTop: 8,
      fontWeight: 'bold'
  }
});
