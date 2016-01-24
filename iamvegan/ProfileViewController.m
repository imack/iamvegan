//
//  ProfileViewController.m
//  iamvegan
//
//  Created by Ian MacKinnon on 2016-01-23.
//  Copyright © 2016 Ian MacKinnon. All rights reserved.
//

#import "ProfileViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:self.uuid];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (object){
            PFUser *user = (PFUser *)object;
            
            self.nameLabel.text = user[PF_USER_NAME];
            self.bioText.text = @"I just like animals, think we need to reduce our carbon footprint, and like feeling superior";
            
            PFFile *pictureFile = [user objectForKey:PF_USER_PROFILE];
            
            if (pictureFile){
                [pictureFile getDataInBackgroundWithBlock:^(NSData * _Nullable data, NSError * _Nullable error) {
                    if (!error){
                        UIImage *profileImage = [UIImage imageWithData:data];
                        [self.profileView setImage:profileImage];
                    }
                }];
            }
            
        }
    }];
    

    
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
