//
//  ProfileViewController.m
//  iamvegan
//
//  Created by Ian MacKinnon on 2016-01-23.
//  Copyright © 2016 Ian MacKinnon. All rights reserved.
//

#import "ProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <UIImage+Additions.h>
@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.nameLabel.text = self.vegan[PF_USER_NAME];
    self.bioText.text = @"Reducing our Carbon footprint one meal at a time. \n\n A man can live and be healthy without killing animals for food; therefore, if he eats meat, he participates in taking animal life merely for the sake of his appetite. And to act so is immoral. \n\n\n--Leo Tolstoy”";
    
    PFFile *pictureFile = [self.vegan objectForKey:PF_USER_PROFILE];
    
    if (pictureFile){
        [pictureFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
            if (!error){
                UIImage *profileImage = [UIImage imageWithData:data];
                profileImage = [self imageByCroppingImage:profileImage toSize:CGSizeMake(200, 200)];
                profileImage = [profileImage add_imageWithRoundedBounds];
                
                [self.profileView setImage:profileImage];
                
                self.profileView.layer.cornerRadius = self.profileView.frame.size.width / 2;
                self.profileView.clipsToBounds = YES;
                self.profileView.layer.borderWidth = 6.0;
                
                UIColor *color = [UIColor colorWithRed:51/250.0
                                                 green:85/255.0
                                                  blue:0
                                                 alpha:1.0];
                self.profileView.layer.borderColor = color.CGColor;
            }
        }];
    }
    
}

- (UIImage *)imageByCroppingImage:(UIImage *)image toSize:(CGSize)size
{
    // not equivalent to image.size (which depends on the imageOrientation)!
    double refWidth = CGImageGetWidth(image.CGImage);
    double refHeight = CGImageGetHeight(image.CGImage);
    
    double x = (refWidth - size.width) / 2.0;
    double y = (refHeight - size.height) / 2.0;
    
    CGRect cropRect = CGRectMake(x, y, size.height, size.width);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
    
    UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:0.0 orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    
    return cropped;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"background.png"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
