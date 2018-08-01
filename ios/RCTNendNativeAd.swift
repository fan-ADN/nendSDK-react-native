//
//  RCTNendNativeAd.swift
//  AwesomeProject
//

import UIKit
import Foundation
import NendAd

@objc(RCTNendNativeAd)
class RCTNendNativeAd: NSObject, RCTBridgeModule {
  var bridge: RCTBridge!
  private var clientCache = [String: NADNativeClient]()
  private var nativeAdCache = [Int: NADNative]()
  private let adExplicitlyList = ["PR", "Sponsored", "AD", "Promotion"]
  private var referenceId = 0
  
  static func moduleName() -> String! {
    return "NendNativeAd"
  }
  
  static func requiresMainQueueSetup() -> Bool {
    return false
  }
  
  var methodQueue: DispatchQueue! {
    return DispatchQueue.main
  }
  
  @objc(loadAd:apiKey:adExplicitly:resolver:rejecter:)
  func loadAd(spotId: String, apiKey: String, adExplicitly: String, resolver: @escaping RCTPromiseResolveBlock, rejecter: @escaping RCTPromiseRejectBlock) {
    var client = clientCache[spotId]
    if client == nil {
      client = NADNativeClient(spotId: spotId, apiKey: apiKey)
      clientCache[spotId] = client
    }
    guard let explicitly = self.adExplicitlyList.index(of: adExplicitly) else { return }
    client!.load { [weak self] (ad, error) in
      guard let `self` = self else { return }
      if let nativeAd = ad {
        self.referenceId += 1
        self.nativeAdCache[self.referenceId] = nativeAd
        resolver(nativeAd.toJSON(refId: self.referenceId, adExplicitly: NADNativeAdvertisingExplicitly(rawValue: explicitly)!))
      } else if let e = error {
        rejecter(e._domain, e.localizedDescription, nil)
      }
    }
  }
  
  @objc(activate:rootViewTag:prViewTag:)
  func activate(refId: Int, rootViewTag: NSNumber, prViewTag: NSNumber) {
    if let nativeAd = nativeAdCache[refId],
      let rootView = bridge.uiManager.view(forReactTag: rootViewTag),
      let prView = bridge.uiManager.view(forReactTag: prViewTag) {
      let dummyLabel = UILabel()
      nativeAd.activateAdView(rootView, withPrLabel: dummyLabel)
      if let recognizer = dummyLabel.gestureRecognizers?[0] {
        // ReactのTextはUILabelを継承していないのでクリック処理だけモジュール側で登録する
        prView.addGestureRecognizer(recognizer)
      }
    }
  }
  
  @objc(destroyLoader:)
  func destroyLoader(spotId: String) {
    clientCache.removeValue(forKey: spotId)
  }
  
  @objc(destroyAd:)
  func destroyAd(referenceId: Int) {
    nativeAdCache.removeValue(forKey: referenceId)
  }
}

extension NADNative {
  func toJSON(refId: Int, adExplicitly: NADNativeAdvertisingExplicitly) -> [String: Any] {
    return ["adImageUrl": imageUrl,
            "logoImageUrl": logoUrl != nil ? logoUrl : "",
            "title": shortText,
            "content": longText,
            "promotionName": promotionName,
            "promotionUrl": promotionUrl,
            "callToAction": actionButtonText,
            "adExplicitly": prText(for: adExplicitly),
            "referenceId": refId];
  }
}
