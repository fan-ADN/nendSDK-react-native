//
//  RCTNendUserFeature.swift
//  AwesomeProject
//

import UIKit
import NendAd

@objc(RCTNendUserFeature)
class RCTNendUserFeature: NSObject, RCTBridgeModule {
  private var userFeatures = [Int: NADUserFeature]()
  private var referenceId = 0
  
  static func requiresMainQueueSetup() -> Bool {
    return false
  }
  
  var methodQueue: DispatchQueue! {
    return DispatchQueue.main
  }
  
  static func moduleName() -> String! {
    return "NendUserFeature"
  }
  
  func constantsToExport() -> [AnyHashable : Any]! {
    return ["Male": 1, "Female": 2]
  }
  
  @objc(create)
  func create() -> NSNumber {
    let userFeature = NADUserFeature()
    referenceId += 1
    userFeatures[referenceId] = userFeature
    return NSNumber(integerLiteral: referenceId)
  }
  
  @objc(setGender:gender:)
  func setGender(refId: Int, gender: Int) {
    if let userFeature = userFeatures[refId], let gender = NADGender(rawValue: gender) {
      userFeature.gender = gender
    }
  }
  
  @objc(setAge:age:)
  func setAge(refId: Int, age: Int) {
    if let userFeature = userFeatures[refId] {
      userFeature.age = age
    }
  }
  
  @objc(setBirthday:year:month:day:)
  func setBirthday(refId: Int, year: Int, month: Int, day: Int) {
    if let userFeature = userFeatures[refId] {
      userFeature.setBirthdayWithYear(year, month: month, day: day)
    }
  }
  
  @objc(addCustomStringValue:key:value:)
  func addCustomStringValue(refId: Int, key: String, value: String) {
    if let userFeature = userFeatures[refId] {
      userFeature.addCustomStringValue(value, forKey: key)
    }
  }

  @objc(addCustomBooleanValue:key:value:)
  func addCustomBooleanValue(refId: Int, key: String, value: Bool) {
    if let userFeature = userFeatures[refId] {
      userFeature.addCustomBoolValue(value, forKey: key)
    }
  }

  @objc(addCustomIntegerValue:key:value:)
  func addCustomIntegerValue(refId: Int, key: String, value: Int) {
    if let userFeature = userFeatures[refId] {
      userFeature.addCustomIntegerValue(value, forKey: key)
    }
  }

  @objc(addCustomDoubleValue:key:value:)
  func addCustomDoubleValue(refId: Int, key: String, value: Double) {
    if let userFeature = userFeatures[refId] {
      userFeature.addCustomDoubleValue(value, forKey: key)
    }
  }

  @objc(destroy:)
  func destroy(refId: Int) {
    userFeatures.removeValue(forKey: refId)
  }
  
  func getUserFeature(refId: Int) -> NADUserFeature? {
    return userFeatures[refId]
  }
}
