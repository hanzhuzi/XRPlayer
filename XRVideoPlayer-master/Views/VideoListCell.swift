//
//  VideoListCell.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/27.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

import UIKit
import SnapKit

public let screenSize = UIScreen.main.bounds.size

class VideoListCell: UITableViewCell {
    
    lazy var titleLabel: UILabel = UILabel()
    lazy var coverImageView: UIImageView = UIImageView()
    lazy var playBackgroundView: UIView = UIView()
    lazy var playButton: UIButton = UIButton()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.font = UIFont.systemFont(ofSize: 15.0)
        titleLabel.textColor = UIColor.black
        titleLabel.textAlignment = .left
        self.contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.contentView.snp.top).offset(15.0)
            make.left.equalTo(self.contentView.snp.left).offset(15.0)
            make.width.equalTo(self.contentView.snp.width).offset(-30.0)
            make.height.equalTo(30.0)
        }
        
        coverImageView.isUserInteractionEnabled = true
        coverImageView.backgroundColor = UIColor.lightGray
        self.contentView.addSubview(coverImageView)
        let coverHeight = 270.0 * (screenSize.width - 30.0) / 480.0
        coverImageView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10.0)
            make.left.equalTo(titleLabel.snp.left).offset(0.0)
            make.width.equalTo(self.contentView.snp.width).offset(-30.0)
            make.height.equalTo(coverHeight)
        }
        
        playBackgroundView.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
        self.contentView.addSubview(playBackgroundView)
        playBackgroundView.snp.makeConstraints { (make) in
            make.width.equalTo(self.coverImageView.snp.width)
            make.height.equalTo(self.coverImageView.snp.height)
            make.top.equalTo(self.coverImageView.snp.top)
            make.left.equalTo(self.coverImageView.snp.left)
        }
        
        playButton.setImage(UIImage(named: "black_play"), for: UIControlState())
        playBackgroundView.addSubview(playButton)
        playButton.snp.makeConstraints { (make) in
            make.width.equalTo(40.0)
            make.height.equalTo(40.0)
            make.center.equalTo(self.playBackgroundView.center)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func configVideoCellWithModel(_ model: VideoModel?) -> Void {
        
        if let video = model {
            titleLabel.text = video.title
            coverImageView.async_setImageWithURL(video.cover, placeHoldImage: nil)
        }else {
            titleLabel.text = ""
        }
    }
    
    static func cellHeight() -> CGFloat {
        
        var coverHeight = 270.0 * (screenSize.width - 30.0) / 480.0
        coverHeight += 70.0
        return coverHeight
    }
    
    
}
