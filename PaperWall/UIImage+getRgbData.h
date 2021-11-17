//
//  UIImage+getRgbData.h
//  PaperWall
//
//  Created by Tom Xing on 12/22/18.
//  Copyright © 2018 Tom Xing. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (getRgbData)
+(UIImage *) imageWithRgbData: (unsigned char *) rawData width: (CGFloat) w height: (CGFloat) h;
-(unsigned char *) getRgbData;
-(unsigned char *) getRgbDataWithSize: (CGSize) size;
@end

NS_ASSUME_NONNULL_END
