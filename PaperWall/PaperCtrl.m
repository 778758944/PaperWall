//
//  PaperCtrl.m
//  PaperWall
//
//  Created by Tom Xing on 12/9/18.
//  Copyright © 2018 Tom Xing. All rights reserved.
//

#import "PaperCtrl.h"
#import "ColorQuantizer.h"
#import "UIImage+getRgbData.h"

@interface PaperCtrl ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property(nonatomic, strong) UIButton * btn;
@property(nonatomic, strong) UIImageView * imageView;
@property(nonatomic, strong) UIImage * selectImage;
@property(nonatomic, strong) NSMutableArray<UIButton *> * paltes;
@property(nonatomic, strong) UIStackView * stackView;
@property(nonatomic, strong) UIImageView * qImageView;
@property(nonatomic, strong) NSFileManager * fileManager;
@end

@implementation PaperCtrl

#pragma make btn
-(UIButton *) btn
{
    if (!_btn) {
        _btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btn setTitle:@"Select an Image" forState:(UIControlStateNormal)];
        [_btn setBackgroundColor:[UIColor redColor]];
        [_btn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
        [_btn addTarget:self action:@selector(chooseImage) forControlEvents:(UIControlEventTouchDown)];
        _btn.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _btn;
}

#pragma make fileManager
-(NSFileManager *) fileManager
{
    if (!_fileManager) {
        _fileManager = [NSFileManager defaultManager];
    }
    
    return _fileManager;
}

#pragma make qImageView
-(UIImageView *) qImageView
{
    if (!_qImageView) {
        _qImageView = [[UIImageView alloc] init];
        _qImageView.contentMode = UIViewContentModeScaleAspectFit;
        _qImageView.clipsToBounds = YES;
        _qImageView.layer.cornerRadius = 10;
        _qImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return _qImageView;
}

#pragma make imageView
-(UIImageView *) imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.clipsToBounds = YES;
        _imageView.layer.cornerRadius = 10;
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return _imageView;
}

#pragma make selectImage
-(void) setSelectImage:(UIImage *)selectImage
{
    NSData * png_data = UIImagePNGRepresentation(selectImage);
    NSData * jpg_data = UIImageJPEGRepresentation(selectImage, 0.75);
    NSLog(@"original png size: %lu, origin jpg size: %lu", png_data.length, jpg_data.length);
    _selectImage = selectImage;
    self.imageView.image = _selectImage;
//    self.qImageView.image = _selectImage;
    [self testRgb];
//    [self getPixel];
}

-(void) testRgb
{
    unsigned char * p = [_selectImage getRgbData];
    CGFloat width = _selectImage.size.width;
    CGFloat height = _selectImage.size.height;
    
    uint8_t * q_data = getQuantizerRgbData(p, width * height * 4, 256);
    /*
    for (int i = 0; i < width * height * 4; i += 4) {
        NSLog(@"R = %u, G = %u, B = %u, A = %u", p[i], p[i + 1], p[i + 2], p[i+3]);
    }
     */
    
    UIImage * image = [UIImage imageWithRgbData:q_data width:width height:(height)];
    
    self.qImageView.image = image;
    NSData * png_data = UIImagePNGRepresentation(image);
    NSData * jpg_data = UIImageJPEGRepresentation(image, 0.75);
    NSLog(@"compress size: %lu, jpg_data size: %lu", png_data.length, jpg_data.length);
    
    NSURL * url = [[self.fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL * jpg_url = [url URLByAppendingPathComponent:@"a.jpg"];
    
    if ([jpg_data writeToURL:url atomically:YES]) {
        NSLog(@"success: %@", jpg_url);
    }
    
    NSData * rgbData = [NSData dataWithBytes:q_data length:width * height * 4];
    
    NSURL * bitmapUrl = [url URLByAppendingPathComponent:@"a.bitmap"];
    
    if ([rgbData writeToURL:bitmapUrl atomically:YES]) {
        NSLog(@"success: %@", bitmapUrl);
    }
    
    
    
    
    
    
    free(p);
}

#pragma make paltes
-(NSMutableArray<UIButton *> *) paltes
{
    if (!_paltes) {
        _paltes = [[NSMutableArray alloc] initWithCapacity:8];
    }
    
    return _paltes;
}

#pragma make style
-(void) style
{
    // btn
    [self.btn.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20].active = YES;
    [self.btn.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20].active = YES;
    [self.btn.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:20].active = YES;
    [self.btn.heightAnchor constraintEqualToConstant:44].active = YES;
    
    // imageView
    [self.imageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-10].active = YES;
    [self.imageView.heightAnchor constraintEqualToConstant:300].active = YES;
    [self.imageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10].active = YES;
    [self.imageView.topAnchor constraintEqualToAnchor:self.btn.bottomAnchor constant:20].active = YES;
    
    // qImageView
    [self.qImageView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-10].active = YES;
    [self.qImageView.heightAnchor constraintEqualToConstant:300].active = YES;
    [self.qImageView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:10].active = YES;
    [self.qImageView.topAnchor constraintEqualToAnchor:self.imageView.bottomAnchor constant:25].active = YES;
}

-(void) styleStackView
{
    [self.stackView.topAnchor constraintEqualToAnchor:self.imageView.bottomAnchor constant:30].active = YES;
    [self.stackView.leadingAnchor constraintEqualToAnchor:self.imageView.leadingAnchor].active = YES;
    [self.stackView.trailingAnchor constraintEqualToAnchor:self.imageView.trailingAnchor].active = YES;
    [self.stackView.heightAnchor constraintEqualToConstant:100].active = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview: self.btn];
    [self.view addSubview: self.imageView];
    [self.view addSubview: self.qImageView];
    [self style];
}

#pragma make chooseImage
-(void) chooseImage
{
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma make pickerDelegate
-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSData * imageData = [NSData dataWithContentsOfURL: info[@"UIImagePickerControllerImageURL"]];
    self.selectImage = [[UIImage alloc] initWithData:imageData scale:1.0];
}

#pragma make getPixel
-(void) getPixel
{
    CGSize size = self.selectImage.size;
    CGFloat width = 100;
    CGFloat height = size.height * (100/size.width);
    unsigned char * p = (unsigned char *) calloc(width * height * 4, sizeof(unsigned char));
    
    CGImageRef imageRef = self.selectImage.CGImage;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(p, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    [self colorPalte: p withSize: width * height * 4];
    free(p);
}

#pragma make getFullPixel
-(void) getFullPixel
{
    
}

#pragma make colorQuantize
-(void) colorPalte: (unsigned char *) data withSize: (NSUInteger) size
{
    QuantizedColor * p = getQuantizedColor(data, size, 256);
    NSLog(@"color count: %d", p->count);
    [self.paltes removeAllObjects];
    for (int i = 0; i < p->count; i++) {
        ColorRGB * c = p->colors[i];
        UIButton * v = [UIButton buttonWithType:UIButtonTypeCustom];
        [v addTarget:self action:@selector(changeBackColor:) forControlEvents:(UIControlEventTouchDown)];
        v.backgroundColor = [UIColor colorWithRed:c->r/255.0 green:c->g/255.0 blue:c->b/255.0 alpha:1];
        [self.paltes addObject:v];
        if (i == 0) {
            [self changeBackColor:v];
        }
        
        if (self.stackView) {
            [self.stackView removeFromSuperview];
        }
        
        self.stackView = [[UIStackView alloc] initWithArrangedSubviews:self.paltes];
        [self.view addSubview: self.stackView];
        self.stackView.translatesAutoresizingMaskIntoConstraints = NO;
        self.stackView.backgroundColor = [UIColor redColor];
        self.stackView.axis = UILayoutConstraintAxisHorizontal;
        self.stackView.alignment = UIStackViewAlignmentFill;
        self.stackView.spacing = 10;
        self.stackView.distribution = UIStackViewDistributionFillEqually;
        [self styleStackView];
        NSLog(@"r=%d, g=%d, b=%d, count=%llu", c->r, c->g, c->b, c->pixelCount);
    }
    freeQuantizedColor(p);
}

#pragma make changeBackColor
-(void) changeBackColor: (UIButton *) btn
{
    const CGFloat * c = CGColorGetComponents(btn.backgroundColor.CGColor);
    [UIView animateWithDuration:2 animations:^{
        self.view.backgroundColor = [UIColor colorWithRed:c[0] green:c[1] blue:c[2] alpha:1.0];
    }];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
