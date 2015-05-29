//
//  Movies.m
//  RottenMangoes
//
//  Created by Alain  on 2015-05-28.
//  Copyright (c) 2015 Alain . All rights reserved.
//

#import "Movies.h"

@implementation Movies

-(instancetype)initWithMovie:(NSString*)movieTitle andYear:(int)year andRunTime:(int)runTime andRating:(NSString*)rating andThumbnail:thumbnailURL
{
    self = [super init];
    if (self) {
        _movieTitle = movieTitle;
        _year = year;
        _runTime = runTime;
        _rating = rating;
        _thumbnailURL = thumbnailURL;
    }
    return self;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"Movie title[%@], Year[%d], RunTime[%d], Rating[%@], Thumbnail[%@]", self.movieTitle, self.year, self.runTime, self.rating, self.thumbnailURL];
}

@end
