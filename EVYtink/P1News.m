//
//  P1News.m
//  EVYtink
//
//  Created by roomlinksaas_dev on 5/20/2559 BE.
//  Copyright © 2559 roomlinksaas_dev. All rights reserved.
//

#import "P1News.h"
#import "ViewWeb.h"
#import "FBSDKCoreKit.framework/Headers/FBSDKCoreKit.h"
#import "FBSDKLoginKit.framework/Headers/FBSDKLoginKit.h"
#import "FBSDKShareKit.framework/Headers/FBSDKShareKit.h"
#import "LoginFacebook.h"
#import "CommentViewController.h"
#import <UIImageView+AFNetworking.h>
#import "SlideOutMenuFiles/SWRevealViewController.h"


@interface P1News (){
    NSUserDefaults *defaults;
}

@end

@implementation P1News
@synthesize arrNews,arrShowNews,leftButton;


- (void)viewDidLoad {
    [super viewDidLoad];
    leftButton.target = self.revealViewController;
    leftButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    UIImage* logoImage = [UIImage imageNamed:@"TopCenterlogoevytink.png"];
    UIImageView *uiimagelogoImage = [[UIImageView alloc] initWithImage:logoImage];
    uiimagelogoImage.frame = CGRectMake(75, 0, 100, 44);
    [uiimagelogoImage setContentMode:UIViewContentModeScaleAspectFit];
    self.navigationItem.titleView = uiimagelogoImage;
    
    //self.tabBarController.tabBarItem.image = [UIImage imageNamed:@"icon_facebook.png"];
    [[self.tabBarController.tabBar.items objectAtIndex:0] setImage:[[UIImage imageNamed:@"TabNewsicon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [[self.tabBarController.tabBar.items objectAtIndex:1] setImage:[[UIImage imageNamed:@"TabEventicon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [[self.tabBarController.tabBar.items objectAtIndex:2] setImage:[[UIImage imageNamed:@"TabPromoicon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [[self.tabBarController.tabBar.items objectAtIndex:3] setImage:[[UIImage imageNamed:@"TabFavicon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [[self.tabBarController.tabBar.items objectAtIndex:4] setImage:[[UIImage imageNamed:@"TabMoreManu.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];

    [self.tabBarController.tabBar.items objectAtIndex:0].imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    [self.tabBarController.tabBar.items objectAtIndex:1].imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    [self.tabBarController.tabBar.items objectAtIndex:2].imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    [self.tabBarController.tabBar.items objectAtIndex:3].imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    [self.tabBarController.tabBar.items objectAtIndex:4].imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
    
    static NSString *CellIdentifier1 = @"idenCell1";
    static NSString *CellIdentifier2 = @"idenCell2";
    static NSString *CellIdentifier3 = @"idenCell3";
    UINib *nib = [UINib nibWithNibName:@"CustomCell1" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellIdentifier1];
    
    nib = [UINib nibWithNibName:@"CustomCell2" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellIdentifier2];
    
    nib = [UINib nibWithNibName:@"CustomCell3" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellIdentifier3];
    
    [self.tableView reloadData];
    
    
    arrNews = [[NSMutableArray alloc] init];
    arrShowNews = [[NSMutableArray alloc] init];
    [self setArrNews:arrNews];
    if ([arrNews count]<5) {
        [self startArrShowNews:arrNews startAt:0 endAt:([arrNews count] - 1)];
    }else{
        [self startArrShowNews:arrNews startAt:0 endAt:4];
    }
}

-(void)startArrShowNews:(NSMutableArray *)arrS startAt:(int)start endAt:(int)end{
    for (int count = start; count <= end; count++) {
        [arrShowNews addObject:[arrNews objectAtIndex:count]];
        if ([[[arrShowNews objectAtIndex:count] objectForKey:@"imageurl"]isEqualToString:@"no"]){
            NSLog(@"Pic - ไม่มีรูป");
        }else if ([[[arrShowNews objectAtIndex:count] objectForKey:@"imageurl2"]isEqualToString:@"no"]){
            NSLog(@"%d Pic - มีรูปที่ 1",count);
        }else{
            NSLog(@"Pic - มีรูป 2 รูป");
        }
    }
    [self.tableView reloadData];
}

-(UIImage *)loadImageFormUrl:(NSString *)strURL{
    //NSString *dataUrl = @"http://koratstartup.com/wp-content/uploads/2016/04/NjpUs24nCQKx5e1EaLRzVmhEaudlUAKrWs0nDIVOAVQ.jpg";
    NSURL *url = [NSURL URLWithString:strURL];
    UIImage *imgReturn;
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        UIImage *imgChange = [UIImage imageWithData:data];
        float oldWidth = imgChange.size.width;
        float scaleFactor = self.view.frame.size.width / oldWidth;
        float newHeight = imgChange.size.height * scaleFactor;
        float newWidth = oldWidth * scaleFactor;
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
        [imgChange drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSLog(@"newImage : %@",newImage);
    }];
    [downloadTask resume];
    return imgReturn;
}

-(void)setArrNews:(NSMutableArray *)arrNews{
    NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://evbt.azurewebsites.net/docs/page/theme/betajsonnews.aspx"]];
    id jsonObjects = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"JSON DATA - %@,\nJSON OBJECT - %@",jsonData,jsonObjects);
    NSLog(@"COunt json - %@",jsonObjects);
     for (int i=0; i<[jsonObjects count]; i++) {
        [arrNews addObject:[jsonObjects objectAtIndex:i]];
         NSLog(@"รอบที่ - %d",i);
     }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"COUNTTTTT - %lu",[arrShowNews count]);
    return [arrShowNews count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier1 = @"idenCell1";
    static NSString *CellIdentifier2 = @"idenCell2";
    static NSString *CellIdentifier3 = @"idenCell3";
    
    if ((indexPath.row == ([arrShowNews count])-1)&&([arrNews count]!=[arrShowNews count])) {
        if (([arrShowNews count] + 5) <= [arrNews count]) {
            [self startArrShowNews:arrNews startAt:(indexPath.row + 1) endAt:(indexPath.row + 5)];
            NSLog(@"บวกเพิ่ม 5");
        }else{
            [self startArrShowNews:arrNews startAt:(indexPath.row + 1) endAt:([arrNews count] - 1)];
            NSLog(@"บวกเพิ่ม %lu",[arrNews count]);
        }
    }
    
    if ([[[arrShowNews objectAtIndex:indexPath.row] objectForKey:@"imageurl"]isEqualToString:@"no"]) {
        P1CellCustom1 *cell = (P1CellCustom1 *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        cell.delegate = self;
        if (![cell.txtDetail.text isEqualToString:[[arrNews objectAtIndex:indexPath.row] objectForKey:@"title"]]) {
            NSString *string = [NSString stringWithFormat:@"%@",[[[arrShowNews objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"imgprofile"]];
            NSArray *subString = [string componentsSeparatedByString:@"?"];
            NSString *urlimg = subString[0];
            NSURL *urlUser = [NSURL URLWithString:[NSString stringWithFormat:@"%@?",urlimg]];
            NSData *datUrlUser = [[NSData alloc] initWithContentsOfURL:urlUser];
            
            NSURLRequest *requestImageUser = [NSURLRequest requestWithURL:[NSURL URLWithString:string]];
            [cell.img setImageWithURLRequest:requestImageUser placeholderImage:NULL success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull imageShowHere) {
                cell.img.image = imageShowHere;
                
            } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                NSLog(@"Errorrrrrrrr");
            }];
            
            
            cell.indexAction = indexPath;
            cell.strObjId = [[arrShowNews objectAtIndex:indexPath.row] objectForKey:@"newsevyid"];
            cell.txtName.text = [[[arrShowNews objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"publishtitle"];
            cell.txtDate.text = [[arrShowNews objectAtIndex:indexPath.row] objectForKey:@"evydatetime"];
            cell.txtDetail.text = [[arrShowNews objectAtIndex:indexPath.row] objectForKey:@"title"];
            cell.urlToShow = [NSString stringWithFormat:@"%@",[[arrNews objectAtIndex:indexPath.row] objectForKey:@"url"]];
        }
        return cell;
    }else if ([[[arrShowNews objectAtIndex:indexPath.row] objectForKey:@"imageurl2"]isEqualToString:@"no"]){
        P1CellCustom2 *cell = (P1CellCustom2 *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
        cell.delegate = self;
        if (![cell.txtDetail.text isEqualToString:[[arrNews objectAtIndex:indexPath.row] objectForKey:@"title"]]) {
            NSString *string = [NSString stringWithFormat:@"%@",[[[arrShowNews objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"imgprofile"]];
            NSArray *subString = [string componentsSeparatedByString:@"?"];
            NSString *urlimg = subString[0];
            NSURL *urlUser = [NSURL URLWithString:[NSString stringWithFormat:@"%@?",urlimg]];
            NSData *datUrlUser = [[NSData alloc] initWithContentsOfURL:urlUser];
            
            NSURLRequest *requestImageUser = [NSURLRequest requestWithURL:[NSURL URLWithString:string]];
            [cell.img setImageWithURLRequest:requestImageUser placeholderImage:NULL success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull imageShowHere) {
                cell.img.image = imageShowHere;
                
            } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                NSLog(@"Errorrrrrrrr");
            }];
            
            
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[[arrNews objectAtIndex:indexPath.row] objectForKey:@"imageurl"]]];
            NSURLRequest *urlrequest = [NSURLRequest requestWithURL:url];
            [cell.imgPic1 setImageWithURLRequest:urlrequest placeholderImage:NULL success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull imageShowHere) {
                cell.imgPic1.image = imageShowHere;
                
            } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                NSLog(@"Errorrrrrrrr");
            }];
            
            cell.indexAction = indexPath;
            cell.strObjId = [[arrShowNews objectAtIndex:indexPath.row] objectForKey:@"newsevyid"];
            cell.txtName.text = [[[arrShowNews objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"publishtitle"];
            cell.txtDate.text = [[arrShowNews objectAtIndex:indexPath.row] objectForKey:@"evydatetime"];
            cell.txtDetail.text = [[arrShowNews objectAtIndex:indexPath.row] objectForKey:@"title"];
            cell.urlToShow = [NSString stringWithFormat:@"%@",[[arrNews objectAtIndex:indexPath.row] objectForKey:@"url"]];
        }
        return cell;
    }else{
        P1CellCustom3 *cell = (P1CellCustom3 *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
        cell.delegate = self;
        if (![cell.txtDetail.text isEqualToString:[[arrNews objectAtIndex:indexPath.row] objectForKey:@"title"]]) {
            NSString *string = [NSString stringWithFormat:@"%@",[[[arrShowNews objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"imgprofile"]];
            NSArray *subString = [string componentsSeparatedByString:@"?"];
            NSString *urlimg = subString[0];
            NSURL *urlUser = [NSURL URLWithString:[NSString stringWithFormat:@"%@?",urlimg]];
            NSData *datUrlUser = [[NSData alloc] initWithContentsOfURL:urlUser];
            
            NSURLRequest *requestImageUser = [NSURLRequest requestWithURL:[NSURL URLWithString:string]];
            [cell.img setImageWithURLRequest:requestImageUser placeholderImage:NULL success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull imageShowHere) {
                cell.img.image = imageShowHere;
                
            } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                NSLog(@"Errorrrrrrrr");
            }];
            
            NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[[arrNews objectAtIndex:indexPath.row] objectForKey:@"imageurl"]]];
            NSURLRequest *urlrequest = [NSURLRequest requestWithURL:url];
            
            [cell.imgPic1 setImageWithURLRequest:urlrequest placeholderImage:NULL success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull imageShowHere) {
                cell.imgPic1.image = imageShowHere;
                
            } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                NSLog(@"Errorrrrrrrr");
            }];
            
            NSURL *url2 = [NSURL URLWithString:[NSString stringWithFormat:@"%@",[[arrNews objectAtIndex:indexPath.row] objectForKey:@"imageurl2"]]];
            NSURLRequest *urlrequest2 = [NSURLRequest requestWithURL:url2];
            
            [cell.imgPic2 setImageWithURLRequest:urlrequest2 placeholderImage:NULL success:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, UIImage * _Nonnull imageShowHere) {
                cell.imgPic2.image = imageShowHere;
            } failure:^(NSURLRequest * _Nonnull request, NSHTTPURLResponse * _Nullable response, NSError * _Nonnull error) {
                NSLog(@"Errorrrrrrrr");
            }];
            
            
            
            cell.indexAction = indexPath;
            cell.strObjId = [[arrShowNews objectAtIndex:indexPath.row] objectForKey:@"newsevyid"];
            cell.txtName.text = [[[arrShowNews objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"publishtitle"];
            cell.txtDate.text = [[arrShowNews objectAtIndex:indexPath.row] objectForKey:@"evydatetime"];
            cell.txtDetail.text = [[arrShowNews objectAtIndex:indexPath.row] objectForKey:@"title"];
            cell.urlToShow = [NSString stringWithFormat:@"%@",[[arrNews objectAtIndex:indexPath.row] objectForKey:@"url"]];
        }
        return cell;
    }

}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[[arrShowNews objectAtIndex:indexPath.row] objectForKey:@"imageurl"]isEqualToString:@"no"]) {
        return 168;
    }else if ([[[arrShowNews objectAtIndex:indexPath.row] objectForKey:@"imageurl2"]isEqualToString:@"no"]){
        return 400;
    }else{
        return 291;
    }
}

-(void)getImageFormUrlForCell:(NSString *)urlString forIndex:(NSIndexPath *)indexPath{
    NSString *dataUrl = @"http://koratstartup.com/wp-content/uploads/2016/04/NjpUs24nCQKx5e1EaLRzVmhEaudlUAKrWs0nDIVOAVQ.jpg";
    NSURL *url = [NSURL URLWithString:dataUrl];
    
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        UIImage *imgChange = [UIImage imageWithData:data];
        float oldWidth = imgChange.size.width;
        float scaleFactor = self.view.frame.size.width / oldWidth;
        float newHeight = imgChange.size.height * scaleFactor;
        float newWidth = oldWidth * scaleFactor;
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
        [imgChange drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //StickersCoordinate *sendUnlock = [arrStickerSore objectAtIndex:indexPath.row];
    ViewWeb *sendWebView = [self.storyboard instantiateViewControllerWithIdentifier:@"openWebView"];
    
    sendWebView.url = [NSURL URLWithString:[[arrShowNews objectAtIndex:indexPath.row] objectForKey:@"url"]];
    [self presentViewController:sendWebView animated:YES completion:NULL];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)testShowCell{
    NSLog(@"Show Cell");
}

-(BOOL)ChkFacebookLoginStatus{
    if ([FBSDKAccessToken currentAccessToken]) {
        return TRUE;
    }else{
        LoginFacebook *LoginFacebookView = [self.storyboard instantiateViewControllerWithIdentifier:@"LogInF"];
        [self presentViewController:LoginFacebookView animated:YES completion:nil];
        return FALSE;
    }
}

-(void)shareToFacebook:(NSString *)urlToShare{
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:urlToShare];
    content.placeID = @"556530234511791";
    [FBSDKShareDialog showFromViewController:self withContent:content delegate:nil];
}

- (IBAction)BtLogout:(id)sender {
    LoginFacebook *LoginFacebookView = [self.storyboard instantiateViewControllerWithIdentifier:@"LogInF"];
    [self presentViewController:LoginFacebookView animated:YES completion:nil];
}

-(void)commentTo:(NSIndexPath *)indexPath{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    CommentViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"storyComment"];
    viewController.userId = [self checkUserId];
    viewController.newsId = [[arrShowNews objectAtIndex:indexPath.row] objectForKey:@"newsevyid"];
    [self.navigationController pushViewController:viewController animated:YES];
}

-(NSString *)checkUserId{
    NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://evbt.azurewebsites.net/docs/page/theme/evycheckfbloginjson.aspx?evarfid=%@",[[FBSDKAccessToken currentAccessToken] userID]]]];
    id jsonObjects = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    return [[jsonObjects objectAtIndex:0] objectForKey:@"evyaccountid"];
}
@end
