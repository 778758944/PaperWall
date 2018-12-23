//
//  UIImage+getRgbData.m
//  PaperWall
//
//  Created by Tom Xing on 12/22/18.
//  Copyright © 2018 Tom Xing. All rights reserved.
//

#import "UIImage+getRgbData.h"
#import <stdlib.h>

@implementation UIImage (getRgbData)
-(unsigned char *) getRgbData
{
    CGSize imageSize = self.size;
    CGImageRef imageRef = self.CGImage;
    NSLog(@"image size: %@", [NSValue valueWithCGSize:imageSize]);
    CGFloat m_width = imageSize.width;
    CGFloat m_height = imageSize.height;
    // bitmap config
    NSUInteger bytesPerPixel = 4;
    NSUInteger bitsPerComponent = 8;
    NSUInteger bytesPerRow = bytesPerPixel * m_width;
    
    unsigned char * p = (unsigned char *) calloc(m_width * m_height * bytesPerPixel, sizeof(unsigned char));
    
    // create Color Space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create bitmap context
    CGContextRef bitmapRef = CGBitmapContextCreate(p, m_width, m_height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    
    // draw image
    CGContextDrawImage(bitmapRef, CGRectMake(0, 0, m_width, m_height), imageRef);
    
//    p = CGBitmapContextGetData(bitmapRef);
    
    //memory recycle
    CGContextRelease(bitmapRef);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return p;
}


+(UIImage *) imageWithRgbData: (unsigned char *) rawData width: (CGFloat) w height: (CGFloat) h
{
    // CGImage config
    size_t bitsPerComponent = 8;
    size_t bytesPerPixel = 4;
    size_t bytesPerRow = bytesPerPixel * w;
    
    size_t bufferLength = w * h * bytesPerPixel;
    // create date provider
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, rawData, bufferLength, NULL);
    
    // create Color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGImageRef iref = CGImageCreate(w, h, bitsPerComponent, bytesPerPixel * 8, bytesPerRow, colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big, provider, NULL, YES, kCGRenderingIntentDefault);
    
    unsigned char * pixels = (unsigned char *) calloc(bufferLength, sizeof(unsigned char));
    
    CGContextRef ctx = CGBitmapContextCreate(pixels, w, h, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(ctx, CGRectMake(0, 0, w, h), iref);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    
    UIImage * image = [UIImage imageWithCGImage: imageRef];
    
    // memory recycle
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(provider);
    CGContextRelease(ctx);
    CGImageRelease(iref);
    CGImageRelease(imageRef);
    free(pixels);
    
    return image;
    
    
}

@end
