//
//  RCTNendVideoNativeAd.swift
//  AwesomeProject
//

import UIKit
import NendAd

@objc(RCTNendVideoNativeAd)
class RCTNendVideoNativeAd: RCTEventEmitter {
  private let kRCTNendVideoNativeAdEventName = "VideoNativeAdEventListener"
  private var loaderCache = [String: NADNativeVideoLoader]()
  private var videoAdCache = [Int: NADNativeVideo]()
  private let videoAdToReferenceId = NSMapTable<NADNativeVideo,  NSNumber>(keyOptions: .weakMemory, valueOptions: .strongMemory)
  private var referenceId = 0
  private var hasListeners = false
  
  override static func requiresMainQueueSetup() -> Bool {
    return false
  }
  
  override var methodQueue: DispatchQueue! {
    return DispatchQueue.main
  }
  
  override func constantsToExport() -> [AnyHashable : Any]! {
    return ["FullScreen": 1, "LP": 2]
  }
  
  override func supportedEvents() -> [String]! {
    return [kRCTNendVideoNativeAdEventName]
  }
  
  override func startObserving() {
    hasListeners = true
  }
  
  override func stopObserving() {
    hasListeners = false
  }
  
  @objc(initialize:apiKey:clickOption:)
  func initialize(spotId: String, apiKey: String, clickOption: Int) {
    if loaderCache[spotId] == nil, let option = NADNativeVideoClickAction(rawValue: clickOption) {
      let loader = NADNativeVideoLoader(spotId: spotId, apiKey: apiKey, clickAction: option)
      loaderCache[spotId] = loader
    }
  }
  
  @objc(loadAd:resolver:rejecter:)
  func loadAd(spotId: String, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
    guard let loader = loaderCache[spotId] else { return }
    loader.loadAd { [weak self] (ad, error) in
      guard let `self` = self else { return }
      if let videoAd = ad {
        videoAd.delegate = self
        self.referenceId += 1
        self.videoAdCache[self.referenceId] = videoAd
        self.videoAdToReferenceId.setObject(NSNumber(integerLiteral: self.referenceId), forKey: videoAd)
        resolver(videoAd.toJSON(refId: self.referenceId))
      } else if let e = error {
        rejecter("", "", e)
      }
    }
  }
  
  @objc(registerClickableViews:reactTags:)
  func registerClickableViews(refernceId: Int, reactTags: [NSNumber]) {
    if let videoAd = videoAdCache[refernceId] {
      videoAd.registerInteractionViews(reactTags.flatMap { bridge.uiManager.view(forReactTag: $0) })
    }
  }
  
  @objc(setUserId:userId:)
  func setUserId(spotId: String, userId: String) {
    if let loader = loaderCache[spotId] {
      loader.userId = userId
    }
  }

  @objc(setUserFeature:refId:)
  func setUserFeature(spotId: String, refId: Int) {
    if let module = bridge.module(for: RCTNendUserFeature.self) as? RCTNendUserFeature,
      let loader = loaderCache[spotId],
      let feature = module.getUserFeature(refId: refId) {
      loader.userFeature = feature
    }
  }
  
  @objc(destroyLoader:)
  func destroyLoader(spotId: String) {
    loaderCache.removeValue(forKey: spotId)
  }
  
  @objc(destroyAd:)
  func destroyAd(refernceId: Int) {
    videoAdCache.removeValue(forKey: refernceId)
  }
  
  fileprivate func sendEvent(videoAd: NADNativeVideo, eventType: String) {
    if let refId = videoAdToReferenceId.object(forKey: videoAd)?.intValue, hasListeners {
      sendEvent(withName: kRCTNendVideoNativeAdEventName, body: ["refId": refId, "eventType": eventType])
    }
  }
  
  func getVideoAd(refernceId: Int) -> NADNativeVideo? {
    return videoAdCache[refernceId]
  }
}

extension RCTNendVideoNativeAd: NADNativeVideoDelegate {
  func nadNativeVideoDidImpression(_ ad: NADNativeVideo) {
    sendEvent(videoAd: ad, eventType: "onImpression")
  }
  
  func nadNativeVideoDidClickAd(_ ad: NADNativeVideo) {
    sendEvent(videoAd: ad, eventType: "onClickAd")
  }
  
  func nadNativeVideoDidClickInformation(_ ad: NADNativeVideo) {
    sendEvent(videoAd: ad, eventType: "onClickInformation")
  }
}

extension NADNativeVideo {
  fileprivate func toJSON(refId: Int) -> [String: Any] {
    return ["logoImageUrl": logoImageUrl!,
            "title": title!,
            "description": explanation!,
            "advertiserName": advertiserName!,
            "userRating": userRating,
            "userRatingCount": userRatingCount,
            "callToAction": callToAction!,
            "referenceId": refId]
  }
}
