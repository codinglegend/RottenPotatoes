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

@interface MasterViewController ()

@property (nonatomic) NSMutableArray* moviesFound; //an object property always starts out as nil (until you put something in it via alloc init)

@property (nonatomic) NSMutableArray* stuff;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
}


//        NSJSONSerialization +dataWithJSONObject:options:error  +JSONObjectWithData:options:error
// NSURLSessionDownloadTask to download from the internet (or your computer), saves to disk, then gets it and brings it back (large files, stuff you want to write on to disk) --> gives you NSURL
// NSURLSessionTask also to download from the internet (or your computer), saves to memory, gets you NSData from JSON?

-(void)fetchData {
    
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
            
            NSString* newTitle = [movieDetails objectForKey:@"title"];
            NSString* rating = [movieDetails objectForKey:@"mpaa_rating"];
            NSNumber* yearAsObject  = [movieDetails objectForKey:@"year"];
            NSNumber* runTimeAsObject = [movieDetails objectForKey:@"runtime"];
            NSString* thumbnailURL = [[movieDetails objectForKey:@"posters"] objectForKey:@"thumbnail"];
        
            Movies *movie = [[Movies alloc] initWithMovie:newTitle andYear:yearAsObject.intValue andRunTime:runTimeAsObject.intValue andRating:rating andThumbnail:thumbnailURL];
    
// the perhaps less clean way to do it (although it makes more sense to me):
//  Movies *movie = [[Movies alloc] initWithMovie:[movieDetails objectForKey:@"title"] andYear:[movieDetails objectForKey:@"year"] andRunTime:[movieDetails objectForKey:@"runtime"] andRating:[movieDetails objectForKey:@"mpaa_rating"]];
            
            NSLog(@"Movie objects: %@", movie); //NSLog + objects, calls on a predefined method called description, which we defined in movies.m
            
            [self.moviesFound addObject:movie];
                             
                             }
        
                             }];
    
    [getMovies resume]; // tasks are always returned in a suspended state. you must call resume to get them started.
}

-(void)viewDidLoad{
    
    self.moviesFound = [[NSMutableArray alloc] init];
    
    [self fetchData]; //calling a method in viewDidLoad
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
        
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        [[segue destinationViewController] setDetailItem:object];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"timeStamp"] description];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

@end
