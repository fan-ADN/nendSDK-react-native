//
//  RCTNendMediaViewManager.swift
//  AwesomeProject
//

import UIKit
import NendAd

@objc(RCTNendMediaViewManager)
class RCTNendMediaViewManager: RCTViewManager {
  static override func requiresMainQueueSetup() -> Bool {
    return false
  }
  
  override var methodQueue: DispatchQueue! {
    return DispatchQueue.main
  }

  override func view() -> UIView! {
    return RCTMediaView()
  }
  
  @objc(setMedia:refId:)
  func setMedia(reactTag: NSNumber, refId: Int) {
    bridge.uiManager.addUIBlock { (manager, viewRegistry) in
      if let view = viewRegistry?[reactTag] as? RCTMediaView,
        let module = self.bridge.module(for: RCTNendVideoNativeAd.self) as? RCTNendVideoNativeAd,
        let videoAd = module.getVideoAd(refernceId: refId) {
        view.videoView.videoAd = videoAd
      }
    }
  }
}

class RCTMediaView: RCTView {
  var onPlaybackStarted: RCTBubblingEventBlock?
  var onPlaybackStopped: RCTBubblingEventBlock?
  var onPlaybackCompleted: RCTBubblingEventBlock?
  var onPlaybackError: RCTBubblingEventBlock?
  var onFullScreenOpened: RCTBubblingEventBlock?
  var onFullScreenClosed: RCTBubblingEventBlock?
  
  fileprivate var videoView: NADNativeVideoView!
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    createVideoView(frame: frame)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    createVideoView()
  }
  
  private func createVideoView(frame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)) {
    videoView = NADNativeVideoView(frame: frame)
    videoView.translatesAutoresizingMaskIntoConstraints = false
    videoView.delegate = self
    self.addSubview(videoView)
    NSLayoutConstraint.activate([
      videoView.leftAnchor.constraint(equalTo: self.leftAnchor),
      videoView.topAnchor.constraint(equalTo: self.topAnchor),
      videoView.rightAnchor.constraint(equalTo: self.rightAnchor),
      videoView.bottomAnchor.constraint(equalTo: self.bottomAnchor)])
  }
}

extension RCTMediaView: NADNativeVideoViewDelegate {
  func nadNativeVideoViewDidStopPlay(_ videoView: NADNativeVideoView) {
    if let callback = onPlaybackStopped {
      callback(nil)
    }
  }
  
  func nadNativeVideoViewDidFail(toPlay videoView: NADNativeVideoView) {
    if let callback = onPlaybackError {
      callback(nil)
    }
  }
  
  func nadNativeVideoViewDidStartPlay(_ videoView: NADNativeVideoView) {
    if let callback = onPlaybackStarted {
      callback(nil)
    }
  }
  
  func nadNativeVideoViewDidCompletePlay(_ videoView: NADNativeVideoView) {
    if let callback = onPlaybackCompleted {
      callback(nil)
    }
  }
  
  func nadNativeVideoViewDidOpenFullScreen(_ videoView: NADNativeVideoView) {
    if let callback = onFullScreenOpened {
      callback(nil)
    }
  }
  
  func nadNativeVideoViewDidCloseFullScreen(_ videoView: NADNativeVideoView) {
    if let callback = onFullScreenClosed {
      callback(nil)
    }
  }
}
