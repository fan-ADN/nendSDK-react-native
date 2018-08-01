// @flow
 
'use strict'

import {NativeModules} from 'react-native';

const userFeature = NativeModules.NendUserFeature;

export type Gender = 'Male' | 'Female'

export default class UserFeature {
    _referenceId: number

    constructor() {
        this._referenceId = userFeature.create();
    }

    setGender(gender: Gender) {
        userFeature.setGender(this._referenceId, gender === 'Male' ? userFeature.Male : userFeature.Female);
    }

    setAge(age: number) {
        userFeature.setAge(this._referenceId, age);
    }

    setBirthday(year: number, month: number, day: number) {
        userFeature.setBirthday(this._referenceId, year, month, day);
    }

    addCustomValue(key: string, value: string | boolean | number) {
        if (typeof value === 'string') {
            userFeature.addCustomStringValue(this._referenceId, key, value);
        } else if (typeof value === 'boolean') {
            userFeature.addCustomBooleanValue(this._referenceId, key, value);
        } else {
            if (Number.isInteger(value)) {
                userFeature.addCustomIntegerValue(this._referenceId, key, value);
            } else {
                userFeature.addCustomDoubleValue(this._referenceId, key, value);
            }
        }
    }

    destroy() {
        userFeature.destroy(this._referenceId);
    }

    getReferenceId(): number {
        return this._referenceId;
    }
}
