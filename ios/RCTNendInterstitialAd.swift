//
//  RCTNendInterstitialAd.swift
//  AwesomeProject
//

import UIKit
import Foundation
import NendAd

@objc(RCTNendInterstitialAd)
class RCTNendInterstitialAd: RCTEventEmitter {
  typealias Promise = (resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock)

  fileprivate let kRCTNendInterstitialAdEventClosed = "onInterstitialAdClosed"

  fileprivate var loadPromises = [String: [Promise]]()
  fileprivate var hasListeners = false
  
  override var methodQueue: DispatchQueue! {
    return DispatchQueue.main
  }
  
  override static func requiresMainQueueSetup() -> Bool {
    return false
  }
  
  override func startObserving() {
    hasListeners = true
  }
  
  override func stopObserving() {
    hasListeners = false
  }
  
  override func supportedEvents() -> [String]! {
    return [kRCTNendInterstitialAdEventClosed]
  }
  
  @objc(loadAd:apiKey:resolver:rejecter:)
  func loadAd(spotId: String, apiKey: String, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
    let promise = (resolve: resolver, reject: rejecter)
    if var promises = loadPromises.removeValue(forKey: spotId) {
      promises.append(promise)
      loadPromises[spotId] = promises
      return
    }
    loadPromises[spotId] = [promise]
    NADInterstitial.sharedInstance().loadAd(withApiKey: apiKey, spotId: spotId)
  }
  
  @objc(show:resolver:rejecter:)
  func show(spotId: String, resolver: RCTPromiseResolveBlock, rejecter: RCTPromiseRejectBlock) {
    guard let vc = UIApplication.shared.keyWindow?.rootViewController else { return }
    let result = NADInterstitial.sharedInstance().showAd(from: vc, spotId: spotId)
    if result == .AD_SHOW_SUCCESS {
      resolver(nil)
    } else {
      rejecter("", result.name, nil)
    }
  }
  
  @objc(setAutoReloadEnabled:)
  func setAutoReloadEnabled(enabled: Bool) {
    NADInterstitial.sharedInstance().enableAutoReload = enabled
  }
  
  override init() {
    super.init()
    NADInterstitial.sharedInstance().delegate = self
  }
}

extension RCTNendInterstitialAd: NADInterstitialDelegate {
  func didFinishLoadInterstitialAd(withStatus status: NADInterstitialStatusCode, spotId: String!) {
    loadPromises.removeValue(forKey: spotId)?.forEach {
      if status == .SUCCESS {
        $0.resolve(nil)
      } else {
        $0.reject("", status.name, nil)
      }
    }
  }
  
  func didClick(with type: NADInterstitialClickType, spotId: String!) {
    if !hasListeners { return }
    let body = ["spotId": spotId, "clickType": type.name]
    sendEvent(withName: kRCTNendInterstitialAdEventClosed, body: body)
  }
}

extension NADInterstitialStatusCode {
  var name: String {
    switch self {
    case .FAILED_AD_REQUEST:
      return "FAILED_AD_REQUEST"
    case .FAILED_AD_DOWNLOAD:
      return "FAILED_AD_DOWNLOAD"
    case .INVALID_RESPONSE_TYPE:
      return "INVALID_RESPONSE_TYPE"
    default:
      return ""
    }
  }
}

extension NADInterstitialClickType {
  var name: String {
    switch self {
    case .DOWNLOAD:
      return "DOWNLOAD"
    case .CLOSE:
      return "CLOSE"
    case .INFORMATION:
      return "INFORMATION"
    }
  }
}

extension NADInterstitialShowResult {
  var name: String {
    switch self {
    case .AD_SHOW_SUCCESS:
      return "AD_SHOW_SUCCESS"
    case .AD_SHOW_ALREADY:
      return "AD_SHOW_ALREADY"
    case .AD_FREQUENCY_NOT_REACHABLE:
      return "AD_FREQUENCY_NOT_REACHABLE"
    case .AD_CANNOT_DISPLAY:
      return "AD_CANNOT_DISPLAY"
    case .AD_LOAD_INCOMPLETE:
      return "AD_LOAD_INCOMPLETE"
    case .AD_REQUEST_INCOMPLETE:
      return "AD_REQUEST_INCOMPLETE"
    case .AD_DOWNLOAD_INCOMPLETE:
      return "AD_DOWNLOAD_INCOMPLETE"
    }
  }
}
