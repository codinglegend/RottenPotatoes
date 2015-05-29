//
//  Movies.h
//  RottenMangoes
//
//  Created by Alain  on 2015-05-28.
//  Copyright (c) 2015 Alain . All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Movies : NSObject
@property (nonatomic) NSString* movieTitle;
@property (nonatomic) int year;
@property (nonatomic) int runTime;
@property (nonatomic) NSString* rating;

//-(instancetype)initWithDictionary:(NSDictionary*)dictionary;

-(instancetype)initWithMovie:(NSString*)movieTitle andYear:(int)year andRunTime:(int)runTime andRating:(NSString*)rating;






@end
