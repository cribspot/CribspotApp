//
//  MapView.m
//  cribspot
//
//  Created by Patrick Wilson on 10/24/13.
//  Copyright (c) 2013 Patrick Wilson. All rights reserved.
//

#import "MapView.h"
#import "SearchView.h"
#import "houseDetail.h"
#import "CollegeCell.h"
#include <GoogleMaps/GoogleMaps.h>

@interface MapView ()
@end

@implementation MapView
{
    NSDictionary *houseData;
    UIView *test;
}
@synthesize collegeData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IBAction)searchClick:(id)sender{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
    SearchView *sv = [storyboard instantiateViewControllerWithIdentifier:@"searchView"];
    [self.navigationController pushViewController:sv animated:YES];
}

-(BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker{
    UILabel *label1 = (UILabel*)[test viewWithTag:69];
    UILabel *label2 = (UILabel*)[test viewWithTag:68];
    UILabel *label3 = (UILabel*)[test viewWithTag:67];
    
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:test
                                            action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:singleFingerTap];
    
    
    if (test.hidden==TRUE) {
        CGRect curFrame = test.frame;
        test.frame = CGRectMake(0, 20, 320, 0);
        test.hidden=FALSE;
        [label1 setHidden:TRUE];
        [label2 setHidden:TRUE];
        [label3 setHidden:TRUE];
        [UIView animateWithDuration:0.5
                         animations:^{
                             test.frame = curFrame;
                             
                         }
                         completion:^(BOOL finished) {
                             [label1 setHidden:FALSE];
                             [label2 setHidden:FALSE];
                             [label3 setHidden:FALSE];
                         }];
        
    }
    

    
    int markerid = marker.zIndex;
    
    NSString *markerURL = [NSString stringWithFormat:@"https://www.cribspot.com/Listings/APIGetListingsByMarkerId/%d?token=jg836djHjTk95Pxk69J6X4",markerid];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:markerURL]];
    NSError *error;
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    NSError *jsonParsingError = nil;
    if (!error) {
        NSArray * markerInfo=[NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:&jsonParsingError];
        for (NSDictionary *boom in markerInfo){
            NSDictionary *Marker = [boom objectForKey:@"Marker"];
            NSDictionary *Rental = [boom objectForKey:@"Rental"];
            NSString *address = [Marker objectForKey:@"street_address"];
            NSString *rent = [Rental objectForKey:@"rent"];
            NSString *baths = [Rental objectForKey:@"baths"];
            NSString *beds = [Rental objectForKey:@"beds"];
            
            UILabel *addressLabel = (UILabel*)[test viewWithTag:69];
            [addressLabel setText:address];
            
            UILabel *bbLabel = (UILabel*)[test viewWithTag:68];
            NSString *bbstring = [NSString stringWithFormat:@"%@ Beds and %@ Baths",beds,baths];
            [bbLabel setText:bbstring];
            
            UILabel *rentLabel = (UILabel*)[test viewWithTag:67];
            NSString *rentstring = [NSString stringWithFormat:@"$%@/m",rent];
            [rentLabel setText:rentstring];
            
            break;
 
        }
    }
    
    
    
    
        return false;
}

-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate{
    
    if (test.hidden==FALSE) {
        UILabel *label1 = (UILabel*)[test viewWithTag:69];
        UILabel *label2 = (UILabel*)[test viewWithTag:68];
        UILabel *label3 = (UILabel*)[test viewWithTag:67];
        [label1 setHidden:TRUE];
        [label2 setHidden:TRUE];
        [label3 setHidden:TRUE];
        [UIView animateWithDuration:0.5
                         animations:^{
                             test.frame = CGRectMake(0, 20, 320, 0);
                             
                         }
                         completion:^(BOOL finished){
                             if (finished) {
                                 test.hidden=TRUE;
                                 test.frame=CGRectMake(0, self.navigationController.navigationBar.frame.size.height+20, self.view.frame.size.width, 78);
                                 
                             }
                         }];
    }
}


-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
    houseDetail *det = [storyboard instantiateViewControllerWithIdentifier:@"houseDetail"];
    NSUInteger tag = marker.zIndex -1;
    
    det.houseData = [[NSMutableArray alloc] initWithObjects:
                     [[houseData objectForKey:@"address"] objectAtIndex:tag],
                     [[houseData objectForKey:@"pictures"] objectAtIndex:tag],
                     [[houseData objectForKey:@"desc"] objectAtIndex:tag],
                     nil];
    [self.navigationController pushViewController:det animated:YES];
}


- (void)viewDidLoad
{
    CLLocationDegrees longitude = [[collegeData objectAtIndex:1] doubleValue];
    CLLocationDegrees latitude = [[collegeData objectAtIndex:2] doubleValue];
    int newid = [[collegeData objectAtIndex:3] integerValue];
    
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latitude
                                                            longitude:longitude
                                                                 zoom:13];
    GMSMapView *mapView_ = [GMSMapView mapWithFrame:[[UIScreen mainScreen] applicationFrame] camera:camera];
    mapView_.myLocationEnabled = YES;
    mapView_.settings.myLocationButton = YES;
    mapView_.settings.compassButton = YES;
    UIEdgeInsets mapInsets = UIEdgeInsetsMake(45.0, 10.0, 49.0, 0.0);
    mapView_.padding = mapInsets;
    
    
    test = [[UIView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height+20, self.view.frame.size.width, 78)];
    
    test.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.85f];;
    
    test.hidden =YES;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 310, 24)];
    label.tag = 69;
    [label setFont:[UIFont boldSystemFontOfSize:20]];
    [label setTextAlignment:NSTextAlignmentRight];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, 310, 20)];
    label2.tag = 68;
    [label2 setTextAlignment:NSTextAlignmentRight];
    
    UILabel *label3 =[[UILabel alloc] initWithFrame:CGRectMake(15, 30, 200, 20)];
    label3.tag = 67;
    [label3 setFont:[UIFont boldSystemFontOfSize:15]];
    [label3 setTextColor:[UIColor redColor]];
    [label3 setTextAlignment:NSTextAlignmentLeft];
    
    
    [test addSubview:label];
    [test addSubview:label2];
    [test addSubview:label3];
    
    
    
    NSString *collegeURL = [NSString stringWithFormat:@"https://www.cribspot.com/Map/APIGetBasicData/0/%d?token=jg836djHjTk95Pxk69J6X4",newid];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:collegeURL]];
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSError *jsonParsingError = nil;
    NSArray * collegeInfo=[NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:&jsonParsingError];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat: @"https://s3-us-west-2.amazonaws.com/cribspot-img/dots/dot_available.png"]];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *availimage = [UIImage imageWithData:data];

    NSURL *url2 = [NSURL URLWithString:[NSString stringWithFormat: @"https://s3-us-west-2.amazonaws.com/cribspot-img/dots/dot_leased.png"]];
    NSData *data2 = [NSData dataWithContentsOfURL:url2];
    UIImage *leasedimage = [UIImage imageWithData:data2];
    
    NSURL *url3 = [NSURL URLWithString:[NSString stringWithFormat: @"https://s3-us-west-2.amazonaws.com/cribspot-img/dots/dot_unknown.png"]];
    NSData *data3 = [NSData dataWithContentsOfURL:url3];
    UIImage *unknownimage = [UIImage imageWithData:data3];
    
    mapView_.delegate=self;
    
    //add university ids
    int count =0;
    for (NSDictionary *test1 in collegeInfo) {
        NSDictionary *Marker = [test1 objectForKey:@"Marker"];
        NSDictionary *Listing = [test1 objectForKey:@"Listing"];
        NSDictionary *Sublet = [test1 objectForKey:@"Rental"];
        NSNumber *testlong =[Marker objectForKey:@"longitude"];
        NSNumber *testlat =[Marker objectForKey:@"latitude"];
        id available = [Listing objectForKey:@"available"];
        int markerid = [[Marker objectForKey:@"marker_id"] integerValue];

        
        
        
        GMSMarker *markerTest =[[GMSMarker alloc] init];
        markerTest.position = CLLocationCoordinate2DMake((CLLocationDegrees)[testlat doubleValue], (CLLocationDegrees)[testlong doubleValue]);
        markerTest.icon= availimage;
        markerTest.zIndex = markerid;
        if (available==[NSNull null]) {
            markerTest.icon= unknownimage;
        }
        else if ([available boolValue]) {
            markerTest.icon= availimage;
        }
        else{
            markerTest.icon = leasedimage;
        }
        

        
        markerTest.map =mapView_;
        
        if (count++>200) {
            break;
        }
        
    }
    
    
    
    
    
    
    
    
    
    
    
    UIBarButtonItem *CSLogo = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"search.png"] style:UIBarButtonItemStylePlain target:self action:@selector(searchClick:)
                                                    ];
    self.navigationItem.rightBarButtonItem=CSLogo;
    
    self.navigationItem.title = @"Cribspot";
    
    
   
    

    
    [self.view addSubview:mapView_];
    [self.view bringSubviewToFront:self.testToolbar];
    [self.view addSubview:test];
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Back" style: UIBarButtonItemStyleBordered target: nil action: nil];
    [[self navigationItem] setBackBarButtonItem: newBackButton];
    
   
    
    
    //The event handling method

    
    
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:[recognizer.view superview]];

    //PUSH TO DETAIL VIEW
}

-(void)viewDidAppear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)favoriteButton:(id)sender {
    if (self.favoriteButton.tintColor == [UIColor redColor]) {
        self.favoriteButton.tintColor = nil;
        
    }
    else{
        self.favoriteButton.tintColor = [UIColor redColor];
        
    }
}
- (IBAction)loginButton:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle: nil];
    UIViewController *login = [storyboard instantiateViewControllerWithIdentifier:@"login"];
    [self.navigationController pushViewController:login animated:YES];
}
@end
