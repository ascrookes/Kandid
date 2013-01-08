//
//  ImageSelectionViewController.m
//  Candid
//
//  Created by Amadou Crookes on 1/6/13.
//  Copyright (c) 2013 Amadou Crookes. All rights reserved.
//

#import "ImageSelectionViewController.h"

const int IMAGES_PER_ROW = 2;

@interface ImageSelectionViewController ()

@property (nonatomic,strong) NSMutableSet* imagesToSave;

@end

@implementation ImageSelectionViewController

@synthesize imageManager = _imageManager;
@synthesize imagesToSave = _imagesToSave;

+ (ImageSelectionViewController*)imageSelectionWithManager:(ImageManager *)manager
{
    ImageSelectionViewController* imageSelection = [[ImageSelectionViewController alloc] init];
    imageSelection.imageManager = manager;
    return imageSelection;
}

+ (void)presentModalImageSelectionWithManager:(ImageManager*)manager
{
    ImageSelectionViewController* isvc = [ImageSelectionViewController imageSelectionWithManager:manager];
    [isvc presentModalViewController:isvc animated:YES];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"VIEW DID Load");
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"VIEW APPEARED");
    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissModal:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveImages:(id)sender
{
    NSLog(@"save images");
    // sort images to save them in the order they were takenz
    for(NSNumber* index in self.imagesToSave) {
        [self.imageManager saveImageAtIndex:[index integerValue]];
    }
    [self dismissModalViewControllerAnimated:YES];
}


//*********************************************************
//*********************************************************
#pragma mark - UICollectionView Delegate/DataSource
//*********************************************************
//*********************************************************

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* reuseID = @"imageSelectionCollectionCell";
    ImageCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseID forIndexPath:indexPath];
    if(cell == nil) {
        // why is this function never called?
        cell = [ImageCollectionCell imageCellWithDelegate:self];
    }
    cell.delegate = self;
    NSInteger location = (indexPath.section * IMAGES_PER_ROW) + indexPath.row;
    [cell setupViewWithImage:[self.imageManager getImageAtIndex:location]];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    int numItems = IMAGES_PER_ROW;
    int numSections = ceil([self.imageManager count]/(double)IMAGES_PER_ROW);
    if(section == numSections - 1) {
        numItems = [self.imageManager count] % IMAGES_PER_ROW;
        if(numItems == 0)
            numItems = IMAGES_PER_ROW;
    }
    return numItems;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSLog(@"COLLECTION SIZE: %f", ceil([self.imageManager count]/(double)IMAGES_PER_ROW));
    return ceil([self.imageManager count]/(double)IMAGES_PER_ROW);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // maybe show full image with toolbar that has the options for selecting
    // pass in an array of the selected locations and loop through
    // that view must also have a delegate function to pass back the information
}


// probably do not need the save location
// everyone will just save the image and then upload it with other apps
// although people did send ig images to fb and twitter
- (void)didSelectCell:(ImageCollectionCell *)cell forLocation:(SaveLocation)saveLocation
{

    NSIndexPath* path = [self.collectionView indexPathForCell:cell];
    unsigned int index = (path.section * IMAGES_PER_ROW) + path.row;
    
    // add or remove the index for the image
    if([self.imagesToSave containsObject:@(index)]) {
        [self.imagesToSave removeObject:@(index)];
    } else {
        [self.imagesToSave addObject:@(index)];
    }
}


//*********************************************************
//*********************************************************
#pragma mark - Getters/Setters
//*********************************************************
//*********************************************************

- (ImageManager*)imageManager
{
    if(!_imageManager) {
        _imageManager = [[ImageManager alloc] init];
    }
    return _imageManager;
}

- (NSMutableSet*)imagesToSave
{
    if(!_imagesToSave) {
        _imagesToSave = [NSMutableSet set];
    }
    return _imagesToSave;
}


@end
