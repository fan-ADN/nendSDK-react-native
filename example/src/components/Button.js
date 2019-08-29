// @flow

'use strict'

import * as React from 'react';
import {
  StyleSheet,
  TouchableHighlight,
  View,
  Text,
} from 'react-native';

type Props = {
    title: string,
    onPress: Function
}

export default class Button extends React.Component<Props> {
    render() {
        return (
          <TouchableHighlight onPress={this.props.onPress} underlayColor='white'>
            <View style={styles.button} accessibilityLabel={this.props.title} >
              <Text style={styles.buttonText}>{this.props.title}</Text>
            </View>
          </TouchableHighlight>
        );
    }
}

const styles = StyleSheet.create({
  button: {
    marginBottom: 30,
    width: 260,
    alignItems: 'center',
    backgroundColor: '#2196F3'
  },
  buttonText: {
    padding: 20,
    color: 'white'
  }
});
