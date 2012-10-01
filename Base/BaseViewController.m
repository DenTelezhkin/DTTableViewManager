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
@end
