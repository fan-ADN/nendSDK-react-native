//
//  RCTNendVideoAd.swift
//  AwesomeProject
//

import UIKit
import Foundation
import NendAd

class VideoAdDelegate<V: NADVideo>: NSObject {
  typealias Promise = (resolve: RCTPromiseResolveBlock, reject: RCTPromiseRejectBlock)

  private var videoAdCache = [String: V]()
  private let videoAdToSpotId = NSMapTable<V, NSString>(keyOptions: .weakMemory, valueOptions: .strongMemory)
  private var loadPromises = [String: [Promise]]()
  fileprivate let eventName: String
  fileprivate var hasListeners = false
  
  init(_ eventName: String) {
    self.eventName = eventName
    super.init()
  }
  
  fileprivate func initialize(spotId: String, apiKey: String) {
    if self[adSpot: spotId] == nil {
      let videoAd = V(spotId: spotId, apiKey: apiKey)
      self[adSpot: spotId] = videoAd
      videoAdToSpotId.setObject(NSString(string: spotId), forKey: videoAd)
    }
  }
  
  fileprivate func loadAd(spotId: String, promise: Promise) {
    guard let videoAd = self[adSpot: spotId] else { return }
    if var promises = loadPromises.removeValue(forKey: spotId) {
      promises.append(promise)
      loadPromises[spotId] = promises
      return
    }
    loadPromises[spotId] = [promise]
    videoAd.loadAd()
  }
  
  fileprivate func isLoaded(spotId: String, promise: Promise) {
    if let videoAd = self[adSpot: spotId], videoAd.isReady {
      promise.resolve(NSNumber(booleanLiteral: true))
    } else {
      promise.resolve(NSNumber(booleanLiteral: false))
    }
  }
  
  fileprivate func show(spotId: String) {
    if let videoAd = self[adSpot: spotId], let vc = UIApplication.shared.keyWindow?.rootViewController {
      videoAd.showAd(from: vc)
    }
  }
  
  fileprivate func destroy(spotId: String) {
    if let videoAd = self[adSpot: spotId] {
      videoAd.releaseAd()
      videoAdCache.removeValue(forKey: spotId)
    }
    loadPromises.removeValue(forKey: spotId)
  }
  
  fileprivate func setUserId(spotId: String, userId: String) {
    if let videoAd = self[adSpot: spotId] {
      videoAd.userId = userId
    }
  }
  
  fileprivate func setUserFeature(bridge: RCTBridge, spotId: String, refId: Int) {
    if let module = bridge.module(for: RCTNendUserFeature.self) as? RCTNendUserFeature,
      let videoAd = self[adSpot: spotId],
      let feature = module.getUserFeature(refId: refId) {
      videoAd.userFeature = feature
    }
  }

  fileprivate func dispatchLoadResult(videoAd: V, error: Error? = nil) {
    guard let spotId = videoAdToSpotId.object(forKey: videoAd),
      let promises = loadPromises.removeValue(forKey: String(spotId)) else { return }
    promises.forEach {
      if let e = error {
        $0.reject("\(e._code)", e.localizedDescription, e)
      } else {
        $0.resolve(nil)
      }
    }
  }
  
  fileprivate func sendEvent(emitter: RCTEventEmitter, videoAd: V, eventType: String, args: [String: Any] = [String: Any]()) {
    guard let spotId = videoAdToSpotId.object(forKey: videoAd), hasListeners else { return }
    var body = args
    body["spotId"] = spotId
    body["eventType"] = eventType
    emitter.sendEvent(withName: eventName, body: body)
  }
  
  fileprivate subscript(adSpot spotId: String) -> V? {
    get {
      return videoAdCache[spotId]
    }
    set {
      videoAdCache[spotId] = newValue
    }
  }
}

@objc(RCTNendRewardedVideoAd)
class RCTNendRewardedVideoAd: RCTEventEmitter {
  fileprivate let delegate = VideoAdDelegate<NADRewardedVideo>("RewardedVideoAdEventListener")
  
  override static func requiresMainQueueSetup() -> Bool {
    return false
  }
  
  override var methodQueue: DispatchQueue! {
    return DispatchQueue.main
  }
  
  override func supportedEvents() -> [String]! {
    return [delegate.eventName]
  }
  
  override func startObserving() {
    delegate.hasListeners = true
  }
  
  override func stopObserving() {
    delegate.hasListeners = false
  }
  
  @objc(initialize:apiKey:)
  func initialize(spotId: String, apiKey: String) {
    delegate.initialize(spotId: spotId, apiKey: apiKey)
    delegate[adSpot: spotId]!.delegate = self
  }
  
  @objc(loadAd:resolver:rejecter:)
  func loadAd(spotId: String, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
    delegate.loadAd(spotId: spotId, promise: (resolve: resolver, reject: rejecter))
  }

  @objc(isLoaded:resolver:rejecter:)
  func isLoaded(spotId: String, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
    delegate.isLoaded(spotId: spotId, promise: (resolve: resolver, reject: rejecter))
  }
  
  @objc(show:)
  func show(spotId: String) {
    delegate.show(spotId: spotId)
  }
  
  @objc(setUserId:userId:)
  func setUserId(spotId: String, userId: String) {
    delegate.setUserId(spotId: spotId, userId: userId)
  }
  
  @objc(setUserFeature:refId:)
  func setUserFeature(spotId: String, refId: Int) {
    delegate.setUserFeature(bridge: bridge, spotId: spotId, refId: refId)
  }
  
  @objc(destroy:)
  func destroy(spotId: String) {
    delegate.destroy(spotId: spotId)
  }
}

extension RCTNendRewardedVideoAd: NADRewardedVideoDelegate {
  func nadRewardVideoAd(_ nadRewardedVideoAd: NADRewardedVideo!, didReward reward: NADReward!) {
    delegate.sendEvent(emitter: self, videoAd: nadRewardedVideoAd, eventType: "onRewarded",
                       args: ["rewardName": reward.name, "rewardAmount": reward.amount])
  }
  
  func nadRewardVideoAdDidReceiveAd(_ nadRewardedVideoAd: NADRewardedVideo!) {
    delegate.dispatchLoadResult(videoAd: nadRewardedVideoAd)
  }
  
  func nadRewardVideoAd(_ nadRewardedVideoAd: NADRewardedVideo!, didFailToLoadWithError error: Error!) {
    delegate.dispatchLoadResult(videoAd: nadRewardedVideoAd, error: error)
  }
  
  func nadRewardVideoAdDidOpen(_ nadRewardedVideoAd: NADRewardedVideo!) {
    delegate.sendEvent(emitter: self, videoAd: nadRewardedVideoAd, eventType: "onVideoShown")
  }
  
  func nadRewardVideoAdDidClose(_ nadRewardedVideoAd: NADRewardedVideo!) {
    delegate.sendEvent(emitter: self, videoAd: nadRewardedVideoAd, eventType: "onVideoClosed")
  }
  
  func nadRewardVideoAdDidClickAd(_ nadRewardedVideoAd: NADRewardedVideo!) {
    delegate.sendEvent(emitter: self, videoAd: nadRewardedVideoAd, eventType: "onVideoAdClicked")
  }
  
  func nadRewardVideoAdDidFailed(toPlay nadRewardedVideoAd: NADRewardedVideo!) {
    delegate.sendEvent(emitter: self, videoAd: nadRewardedVideoAd, eventType: "onVideoPlaybackError")
  }
  
  func nadRewardVideoAdDidStopPlaying(_ nadRewardedVideoAd: NADRewardedVideo!) {
    delegate.sendEvent(emitter: self, videoAd: nadRewardedVideoAd, eventType: "onVideoPlaybackStopped")
  }
  
  func nadRewardVideoAdDidStartPlaying(_ nadRewardedVideoAd: NADRewardedVideo!) {
    delegate.sendEvent(emitter: self, videoAd: nadRewardedVideoAd, eventType: "onVideoPlaybackStarted")
  }
  
  func nadRewardVideoAdDidCompletePlaying(_ nadRewardedVideoAd: NADRewardedVideo!) {
    delegate.sendEvent(emitter: self, videoAd: nadRewardedVideoAd, eventType: "onVideoPlaybackCompleted")
  }
  
  func nadRewardVideoAdDidClickInformation(_ nadRewardedVideoAd: NADRewardedVideo!) {
    delegate.sendEvent(emitter: self, videoAd: nadRewardedVideoAd, eventType: "onVideoAdInformationClicked")
  }
}

@objc(RCTNendInterstitialVideoAd)
class RCTNendInterstitialVideoAd: RCTEventEmitter {
  fileprivate let delegate = VideoAdDelegate<NADInterstitialVideo>("InterstitialVideoAdEventListener")
  
  override static func requiresMainQueueSetup() -> Bool {
    return false
  }
  
  override var methodQueue: DispatchQueue! {
    return DispatchQueue.main
  }
  
  override func supportedEvents() -> [String]! {
    return [delegate.eventName]
  }
  
  override func startObserving() {
    delegate.hasListeners = true
  }
  
  override func stopObserving() {
    delegate.hasListeners = false
  }

  @objc(initialize:apiKey:)
  func initialize(spotId: String, apiKey: String) {
    delegate.initialize(spotId: spotId, apiKey: apiKey)
    delegate[adSpot: spotId]!.delegate = self
  }
  
  @objc(loadAd:resolver:rejecter:)
  func loadAd(spotId: String, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
    delegate.loadAd(spotId: spotId, promise: (resolve: resolver, reject: rejecter))
  }
  
  @objc(isLoaded:resolver:rejecter:)
  func isLoaded(spotId: String, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
    delegate.isLoaded(spotId: spotId, promise: (resolve: resolver, reject: rejecter))
  }
  
  @objc(show:)
  func show(spotId: String) {
    delegate.show(spotId: spotId)
  }
  
  @objc(setUserId:userId:)
  func setUserId(spotId: String, userId: String) {
    delegate.setUserId(spotId: spotId, userId: userId)
  }
  
  @objc(setUserFeature:refId:)
  func setUserFeature(spotId: String, refId: Int) {
    delegate.setUserFeature(bridge: bridge, spotId: spotId, refId: refId)
  }
  
  @objc(destroy:)
  func destroy(spotId: String) {
    delegate.destroy(spotId: spotId)
  }
  
  @objc(addFallbackFullBoard:fullboardSpotId:fullBoardApiKey:)
  func addFallbackFullBoard(spotId: String, fullboardSpotId: String, fullBoardApiKey: String) {
    if let videoAd = delegate[adSpot: spotId] {
      videoAd.addFallbackFullboard(withSpotId: fullboardSpotId, apiKey: fullBoardApiKey)
    }
  }
}

extension RCTNendInterstitialVideoAd: NADInterstitialVideoDelegate {
  func nadInterstitialVideoAdDidReceiveAd(_ nadInterstitialVideoAd: NADInterstitialVideo!) {
    delegate.dispatchLoadResult(videoAd: nadInterstitialVideoAd)
  }
  
  func nadInterstitialVideoAd(_ nadInterstitialVideoAd: NADInterstitialVideo!, didFailToLoadWithError error: Error!) {
    delegate.dispatchLoadResult(videoAd: nadInterstitialVideoAd, error: error)
  }
  
  func nadInterstitialVideoAdDidOpen(_ nadInterstitialVideoAd: NADInterstitialVideo!) {
    delegate.sendEvent(emitter: self, videoAd: nadInterstitialVideoAd, eventType: "onVideoShown")
  }
  
  func nadInterstitialVideoAdDidClose(_ nadInterstitialVideoAd: NADInterstitialVideo!) {
    delegate.sendEvent(emitter: self, videoAd: nadInterstitialVideoAd, eventType: "onVideoClosed")
  }
  
  func nadInterstitialVideoAdDidClickAd(_ nadInterstitialVideoAd: NADInterstitialVideo!) {
    delegate.sendEvent(emitter: self, videoAd: nadInterstitialVideoAd, eventType: "onVideoAdClicked")
  }
  
  func nadInterstitialVideoAdDidFailed(toPlay nadInterstitialVideoAd: NADInterstitialVideo!) {
    delegate.sendEvent(emitter: self, videoAd: nadInterstitialVideoAd, eventType: "onVideoPlaybackError")
  }
  
  func nadInterstitialVideoAdDidStopPlaying(_ nadInterstitialVideoAd: NADInterstitialVideo!) {
    delegate.sendEvent(emitter: self, videoAd: nadInterstitialVideoAd, eventType: "onVideoPlaybackStopped")
  }
  
  func nadInterstitialVideoAdDidStartPlaying(_ nadInterstitialVideoAd: NADInterstitialVideo!) {
    delegate.sendEvent(emitter: self, videoAd: nadInterstitialVideoAd, eventType: "onVideoPlaybackStarted")
  }
  
  func nadInterstitialVideoAdDidCompletePlaying(_ nadInterstitialVideoAd: NADInterstitialVideo!) {
    delegate.sendEvent(emitter: self, videoAd: nadInterstitialVideoAd, eventType: "onVideoPlaybackCompleted")
  }
  
  func nadInterstitialVideoAdDidClickInformation(_ nadInterstitialVideoAd: NADInterstitialVideo!) {
    delegate.sendEvent(emitter: self, videoAd: nadInterstitialVideoAd, eventType: "onVideoAdInformationClicked")
  }
}
