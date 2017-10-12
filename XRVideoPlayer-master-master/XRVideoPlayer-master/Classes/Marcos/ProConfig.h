//
//  ProConfig.h
//  XRVideoPlayer-master
//
//  Created by xuran on 16/4/22.
//  Copyright © 2016年 黯丶野火. All rights reserved.
//
//  配置文件

#ifndef ProConfig_h
#define ProConfig_h

// baseURL
#define RequestBaseURL  @"http://c.3g.163.com"

// 网络视频URL
#define CODE_VIDEOLIST  @"/nc/video/list/VAP4BFR16/y/0-10.html"

#define CustomErrorDomain  @"CustomErrorDomain"

// 添加下载任务到列表的通知
#define NNKEY_DOWNLOAD_ADD_TO_LIST "NNKEY_DOWNLOAD_ADD_TO_LIST"

// 自定义错误码
typedef enum {
    
    CustomErrorTypeDataNIL    = 80001, // 数据为空
    CustomErrorCodeTypeUNJSON = 80003, // 不是JSON格式
    CustomErrorTypeParamNIL   = 80004  // 参数为空
    
}CustomErrorType;

#endif /* ProConfig_h */
