//
//  CollectionViewCell.h
//  RottenMangoes
//
//  Created by Alain  on 2015-05-29.
//  Copyright (c) 2015 Alain . All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *movieTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;

@end