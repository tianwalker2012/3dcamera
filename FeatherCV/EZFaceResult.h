//
//  EZFaceResult.h
//  FeatherCV
//
//  Created by xietian on 13-11-25.
//  Copyright (c) 2013年 tiange. All rights reserved.
//

#ifndef __FeatherCV__EZFaceResult__
#define __FeatherCV__EZFaceResult__

#include <iostream>
class EZFaceResult{

public:
    EZFaceResult();
    ~EZFaceResult();
    //cv::Rect_<float> orgRect;
    //cv::Rect_<float> destRect;
    //cv::Mat* face;
    float smileDegree;
    //For test purpose
    //cv::Mat* resizedImage;
    
};
#endif /* defined(__FeatherCV__EZFaceResult__) */
