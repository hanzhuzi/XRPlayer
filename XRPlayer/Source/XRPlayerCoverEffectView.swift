//
//  XRPlayerCoverEffectView.swift
//  QukeMechanic
//
//  Created by 徐冉 on 2019/8/23.
//  Copyright © 2019 QK. All rights reserved.
//

import UIKit
import SDWebImage

enum XRPlayerCoverPlaybackState: Int {
    case readyToPlay, playing, loadFaild
}

class XRPlayerCoverEffectView: UIView {
    
    var coverImageView: UIImageView = UIImageView(frame: CGRect.zero)
    private var coverEffectView: UIVisualEffectView = UIVisualEffectView(frame: CGRect.zero)
    private var playButton: UIButton = UIButton(type: UIButton.ButtonType.custom)
    
    var state: XRPlayerCoverPlaybackState = .readyToPlay {
        didSet {
            switch state {
            case .readyToPlay:
                let normalImg = xrplayer_imageForBundleResource(imageName: "icon_player_cover_play", bundleClass: self.classForCoder)
                playButton.configButtonForNormal(title: nil, textColor: UIColor.white, font: UIFont.systemFont(ofSize: 13), normalImage: normalImg, selectedImage: normalImg, backgroundColor: nil)
                playButton.isUserInteractionEnabled = true
                break
            case .playing:
                let normalImg = xrplayer_imageForBundleResource(imageName: "icon_player_cover_playing", bundleClass: self.classForCoder)
                playButton.configButtonForNormal(title: nil, textColor: UIColor.white, font: UIFont.systemFont(ofSize: 13), normalImage: normalImg, selectedImage: normalImg, backgroundColor: nil)
                playButton.isUserInteractionEnabled = false
                break
            case .loadFaild:
                let normalImg = xrplayer_imageForBundleResource(imageName: "icon_player_cover_faild", bundleClass: self.classForCoder)
                playButton.configButtonForNormal(title: "重新加载", textColor: UIColor.white, font: UIFont.systemFont(ofSize: 13), normalImage: normalImg, selectedImage: normalImg, backgroundColor: nil)
                playButton.isUserInteractionEnabled = true
                break
            }
        }
    }
    
    var playButtonTapClosure: ((_ state: XRPlayerCoverPlaybackState) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setup() {
        
        self.addSubview(self.coverImageView)
        coverImageView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        coverImageView.isUserInteractionEnabled = true
        
        // effect
        coverEffectView.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        coverImageView.addSubview(coverEffectView)
        coverEffectView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        self.addSubview(playButton)
        playButton.snp.makeConstraints { (make) in
            make.width.equalTo(70)
            make.height.equalTo(60)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        playButton.setImage(xrplayer_imageForBundleResource(imageName: "icon_player_cover_play", bundleClass: self.classForCoder), for: UIControl.State.normal)
        
        playButton.addTarget(self, action: #selector(self.playButtonAction), for: UIControl.Event.touchUpInside)
    }
    
    @objc func playButtonAction() {
        
        switch state {
        case .playing:
            break
        case .readyToPlay, .loadFaild:
            if playButtonTapClosure != nil {
                playButtonTapClosure!(state)
            }
            break
        }
    }
    
    func setCoverImageWithURL(url: String?, targetSize: CGSize) {
        
        
    }
    
}
