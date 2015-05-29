//
//  Movies.m
//  RottenMangoes
//
//  Created by Alain  on 2015-05-28.
//  Copyright (c) 2015 Alain . All rights reserved.
//

#import "Movies.h"

@implementation Movies

-(instancetype)initWithMovie:(NSString*)movieTitle andYear:(int)year andRunTime:(int)runTime andRating:(NSString*)rating
{
    self = [super init];
    if (self) {
        _movieTitle = movieTitle;
        _year = year;
        _runTime = runTime;
        _rating = rating;
    }
    return self;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"Movie title[%@], Year[%d], RunTime[%d], Rating[%@]", self.movieTitle, self.year, self.runTime, self.rating ];
}

@end
