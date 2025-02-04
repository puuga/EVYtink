//
//  PGetLocationViewController.h
//  EVYtink
//
//  Created by roomlinksaas_dev on 8/12/2559 BE.
//  Copyright © 2559 roomlinksaas_dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol PGetLocationViewControllerDelegate <NSObject>

-(void)setAddress:(NSString *)addressforSave;

@required

@end

@interface PGetLocationViewController : UIViewController<MKMapViewDelegate,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *MapV;
- (IBAction)BTsaveLocationAction:(id)sender;
- (IBAction)BtgotoCurrentLocationAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *BtgotoCurrentLocationProperties;

@property (assign, nonatomic) id<PGetLocationViewControllerDelegate> delegate;

@end
