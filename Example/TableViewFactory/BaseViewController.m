//
//  BaseViewController.m
//  ainifinity
//
//  Created by Alexey Belkevich on 5/24/12.
//  Copyright (c) 2012 MLSDev. All rights reserved.
//

#import "BaseViewController.h"


@implementation BaseViewController

#pragma mark -
#pragma mark main routine

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    
    if (iPad)
        return YES;
    else
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#define DEFAULT_VIEW_WIDTH_FOR_POPOVER  320
#define DEFAULT_VIEW_HEIGHT_FOR_POPOVER 400

-(CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(DEFAULT_VIEW_WIDTH_FOR_POPOVER, DEFAULT_VIEW_HEIGHT_FOR_POPOVER);
}

@end
