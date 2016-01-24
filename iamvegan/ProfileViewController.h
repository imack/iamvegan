//
//  ProfileViewController.h
//  iamvegan
//
//  Created by Ian MacKinnon on 2016-01-23.
//  Copyright © 2016 Ian MacKinnon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "VeganHelper.h"

@interface ProfileViewController : UIViewController

@property(nonatomic, strong) IBOutlet UIImageView *profileView;
@property(nonatomic, strong) IBOutlet UILabel *nameLabel;
@property(nonatomic, strong) IBOutlet UITextView *bioText;

@property(nonatomic, strong)  PFUser *vegan;

@end
