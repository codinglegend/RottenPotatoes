//
//  MasterViewController.m
//  RottenMangoes
//
//  Created by Alain  on 2015-05-27.
//  Copyright (c) 2015 Alain . All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "Movies.h"
#import "CollectionViewCell.h"

// Tom says start with initialization methods, then your overriding methods, then predefined? custom?

@interface MasterViewController ()

@property (nonatomic) NSMutableArray* moviesFound; //an object property always starts out as nil (until you put something in it via alloc init)


@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}


//        NSJSONSerialization +dataWithJSONObject:options:error  +JSONObjectWithData:options:error
// NSURLSessionDownloadTask to download from the internet (or your computer), saves to disk, then gets it and brings it back (large files, stuff you want to write on to disk) --> gives you NSURL
// NSURLSessionTask also to download from the internet (or your computer), saves to memory, gets you NSData from JSON?

-(void)fetchData { // never return for void, but always return for objects (when the return type is CustomObject, UICollectionView, ANYTHING but void) or (instancetype) as return type (usually returns self)
    
    NSURL *moviesApiUrl = [NSURL URLWithString:@"http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?apikey=sr9tdu3checdyayjz85mff8j&page_limit=20"]; //this is a convenience method, does the same thing as alloc init
    
    NSMutableURLRequest *moviesRequest = [NSMutableURLRequest requestWithURL:moviesApiUrl];
    [moviesRequest setHTTPMethod: @"GET"]; // only works if it's an NSMutableURLRequest
    
    
    NSURLSessionTask *getMovies = [[NSURLSession sharedSession] dataTaskWithRequest:moviesRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        // getting the actual contents of the URL (but a bad way to do it, just a long string):
        //        NSString *text = [[NSString alloc ] initWithContentsOfURL:moviesApiUrl encoding:NSUTF8StringEncoding error:nil];
        //        NSLog(@"JSON Response: %@", text);
        
        //step: Use a JSON Parser to convert/deserialize the JSON string into an NSDictionary
        NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        //        NSLog(@"Dictionary: %@", parsedData);
        
        NSArray *moviesArray = [parsedData objectForKey:@"movies"]; //is the same as the literal: parsedData[@"movies"];
        
        
        for (NSDictionary *movieDetails in moviesArray){ // this means get every object in this array and MAKE it an NSDictionary
            
            // below, year and runtime are being return from a dictionary/array which means they are objects...which means we need to access the intvalue
            
            Movies *movie = [[Movies alloc] initWithMovie:[movieDetails objectForKey:@"title"]
                                                  andYear:[[movieDetails objectForKey:@"year"] intValue]
                                               andRunTime:[[movieDetails objectForKey:@"runtime"] intValue]
                                                andRating:[movieDetails objectForKey:@"mpaa_rating"]
                                             andThumbnail:[[movieDetails objectForKey:@"posters"] objectForKey:@"thumbnail"]];
            
            NSLog(@"Movie objects: %@", movie); //when you NSLog an object, you call on a predefined method called description, which we defined in movies.m
            
            [self.moviesFound addObject:movie];
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData]; // without this block, it would not load.
        });
        
    }];
    
    [getMovies resume]; // tasks are always returned in a suspended state. you must call resume to get them started.
}

-(void)viewDidLoad{
    
    [super viewDidLoad];
    
    self.moviesFound = [[NSMutableArray alloc] init]; // you ask yourself, what kind of object is self.moviesFound? it's an NSMutableArray (as defined in the properties), therefore that is what you alloc init with.
    
    [self fetchData]; //calling a method in viewDidLoad
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Segues

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([[segue identifier] isEqualToString:@"showDetail"]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
//        [[segue destinationViewController] setDetailItem:object];
//    }
//}

#pragma mark - Collection View

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.moviesFound.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CollectionViewCell *customCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"customCellIdentifier" forIndexPath:indexPath];
    
    //    Movies *movie = self.moviesFound[indexPath.item]; // you could create an instance as you've done here to access movie.movieTitle below in this way: customCell.movieTitleLabel.text = movie.movieTitle...or you could do it the way I did
    
    customCell.backgroundColor = [UIColor lightGrayColor];
    collectionView.backgroundColor = [UIColor darkGrayColor];
    customCell.movieTitleLabel.text = [self.moviesFound[indexPath.item] movieTitle]; // assigning the property (movieTitle) we want to the relevant IBOutlet (movieTitleLabel)
    
    // my thumbnailURL is a string, need to turn it into a UIImage:
    
    Movies *movie = self.moviesFound[indexPath.item];
    NSURL *movieThumbnailURL = [NSURL URLWithString:movie.thumbnailURL]; //because NSData below only takes an NSURL
    NSData *movieThumbnailData = [NSData dataWithContentsOfURL:movieThumbnailURL];
    UIImage *movieThumbnail = [UIImage imageWithData:movieThumbnailData];
    
    customCell.thumbnailImageView.image = movieThumbnail;
    
    return customCell;
}


//could use (a collectionView method) didSelectItemAtItemPath


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{

        if ([segue.identifier isEqualToString:@"detailIdentifier"]){
            NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
            
            Movies *myMovie = self.moviesFound[selectedIndexPath.item];
            
            DetailViewController *detailViewController = [segue destinationViewController];
            detailViewController.detailItem = myMovie; //detailItem here is the property I defined in DetailViewController.h of type Movies....you then pass in this WHOLE object, allowing you access itss individual properties as I do in the viewDidLoad of the detailViewController.m. the individual properties I access are the picture (as I defined as a property in Movies) and the movie title (as defined in Movies). Final note: should have named Movies just "Movie" since it is a "Movie" object
            
            
        }
    
}


@end

/* // nixed these from under the for in loop, I don't prefer this style at all
 //            NSString* newTitle = [movieDetails objectForKey:@"title"];
 //            NSString* rating = [movieDetails objectForKey:@"mpaa_rating"];
 //            NSNumber* yearAsObject  = [movieDetails objectForKey:@"year"];
 //            NSNumber* runTimeAsObject = [movieDetails objectForKey:@"runtime"];
 //            NSString* thumbnailURL = [[movieDetails objectForKey:@"posters"] objectForKey:@"thumbnail"];
 //
 //            Movies *movie = [[Movies alloc] initWithMovie:newTitle andYear:yearAsObject.intValue andRunTime:runTimeAsObject.intValue andRating:rating andThumbnail:thumbnailURL]; */
