//
//  RCTNendAdViewManager.swift
//  AwesomeProject
//

import UIKit
import NendAd

@objc(RCTNendAdViewManager)
class RCTNendAdViewManager: RCTViewManager {
  static override func requiresMainQueueSetup() -> Bool {
    return false
  }
  
  override var methodQueue: DispatchQueue! {
    return DispatchQueue.main
  }
  
  override func view() -> UIView! {
    return RCTNADView()
  }
  
  @objc(loadAd:)
  func loadAd(reactTag: NSNumber) {
    bridge.uiManager.addUIBlock { (manager, viewRegistry) in
      if let view = viewRegistry?[reactTag] as? RCTNADView {
        view.loadAd()
      }
    }
  }

  @objc(resume:)
  func resume(reactTag: NSNumber) {
    bridge.uiManager.addUIBlock { (manager, viewRegistry) in
      if let view = viewRegistry?[reactTag] as? RCTNADView, let adView = view.adView {
        adView.resume()
      }
    }
  }

  @objc(pause:)
  func pause(reactTag: NSNumber) {
    bridge.uiManager.addUIBlock { (manager, viewRegistry) in
      if let view = viewRegistry?[reactTag] as? RCTNADView, let adView = view.adView {
        adView.pause()
      }
    }
  }
}

class RCTNADView: RCTView {
  @objc var spotId: String?
  @objc var apiKey: String?
  @objc var adjustSize = false
  @objc var onAdLoaded: RCTBubblingEventBlock?
  @objc var onAdFailedToLoad: RCTBubblingEventBlock?
  @objc var onAdClicked: RCTBubblingEventBlock?
  @objc var onInformationClicked: RCTBubblingEventBlock?
  
  fileprivate var adView: NADView?
  
  fileprivate func loadAd() {
    guard let spotId = self.spotId, let apiKey = self.apiKey, adView == nil else { return }
    adView = NADView(isAdjustAdSize: adjustSize)
    addSubview(adView!)
    adView!.delegate = self
    adView!.setNendID(apiKey, spotID: spotId)
    adView!.load()
  }
}

extension RCTNADView: NADViewDelegate {
  func nadViewDidReceiveAd(_ adView: NADView!) {
    if let callback = onAdLoaded {
      callback(["width": adView.bounds.size.width, "height": adView.bounds.size.height])
    }
  }
  
  func nadViewDidFail(toReceiveAd adView: NADView!) {
    if let callback = onAdFailedToLoad {
      let error = adView.error as NSError
      let body: [String: Any] = ["code": error.code, "message": error.domain]
      callback(body)
    }
  }
  
  func nadViewDidClickAd(_ adView: NADView!) {
    if let callback = onAdClicked {
      callback(nil)
    }
  }
  
  func nadViewDidClickInformation(_ adView: NADView!) {
    if let callback = onInformationClicked {
      callback(nil)
    }
  }
}
