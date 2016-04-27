//
//  VideoListCell.swift
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/27.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//

import UIKit
import SnapKit

let screenSize = UIScreen.mainScreen().bounds.size

class VideoListCell: UITableViewCell {
    
    lazy var titleLabel: UILabel = UILabel()
    lazy var coverImageView: UIImageView = UIImageView()
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.font = UIFont.systemFontOfSize(15.0)
        titleLabel.textColor = UIColor.blackColor()
        titleLabel.textAlignment = .Left
        self.contentView.addSubview(titleLabel)
        titleLabel.snp_makeConstraints { (make) in
            make.top.equalTo(self.contentView.snp_top).offset(15.0)
            make.left.equalTo(self.contentView.snp_left).offset(15.0)
            make.width.greaterThanOrEqualTo(0.0)
            make.height.equalTo(30.0)
        }
        
        coverImageView.backgroundColor = UIColor.redColor()
        self.contentView.addSubview(coverImageView)
        coverImageView.snp_makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp_bottom).offset(15.0)
            make.left.equalTo(titleLabel.snp_left).offset(0.0)
            make.width.equalTo(self.contentView.snp_width).offset(-30.0)
            make.height.equalTo(100.0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
    }
    
    func configVideoCellWithModel(model: VideoModel?) -> Void {
        
        if let video = model {
            titleLabel.text = video.title
        }else {
            titleLabel.text = ""
        }
    }
    
    
    
}
