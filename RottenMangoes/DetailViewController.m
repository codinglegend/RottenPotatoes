//
//  DetailViewController.m
//  RottenMangoes
//
//  Created by Alain  on 2015-05-27.
//  Copyright (c) 2015 Alain . All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor darkGrayColor];
    
//for the label it's easy:
    self.detailDescriptionLabel.text = self.detailItem.movieTitle;

//but since the image has the issue of being a URL I have to worry about those conversions first:
    
//this won't work this thumbnailURL is a string, and self.detailImageView.image is a UIImage  self.detailImageView.image = self.detailItem.thumbnailURL;
    
    // detailItem the object we pass through...

    NSURL *movieThumbnailURL = [NSURL URLWithString:self.detailItem.thumbnailURL];
    NSData *movieThumbnailData = [NSData dataWithContentsOfURL:movieThumbnailURL];
    UIImage *movieThumbnail = [UIImage imageWithData:movieThumbnailData];
    
    self.detailImageView.image = movieThumbnail;
    
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end