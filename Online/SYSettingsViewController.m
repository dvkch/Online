//
//  SYSettingsViewController.m
//  Online
//
//  Created by Stan Chevallier on 04/11/2015.
//  Copyright © 2015 Syan. All rights reserved.
//

#import "SYSettingsViewController.h"
#import "SYStorage.h"
#import "SYColorView.h"

@interface SYSettingsViewController ()
@property (nonatomic, weak) IBOutlet SYColorView *pickerSuccess;
@property (nonatomic, weak) IBOutlet SYColorView *pickerTimeout;
@property (nonatomic, weak) IBOutlet SYColorView *pickerFailure;
@end

@implementation SYSettingsViewController

+ (SYSettingsViewController *)viewController
{
    NSNib *nib = [[NSNib alloc] initWithNibNamed:[[self class] description] bundle:nil];
    NSArray *items;
    [nib instantiateWithOwner:nil topLevelObjects:&items];
    SYSettingsViewController *viewController;
    for (NSObject *item in items)
    {
        if ([item isKindOfClass:[self class]])
            viewController = (SYSettingsViewController *)item;
    }

    return viewController;
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    [self.pickerSuccess setColor:[[SYStorage shared] colorSuccess]];
    [self.pickerTimeout setColor:[[SYStorage shared] colorTimeout]];
    [self.pickerFailure setColor:[[SYStorage shared] colorFailure]];
}

- (void)viewWillDisappear
{
    [super viewWillDisappear];
    [self save];
}

- (void)save
{
    [[SYStorage shared] setColorSuccess:self.pickerSuccess.color];
    [[SYStorage shared] setColorTimeout:self.pickerTimeout.color];
    [[SYStorage shared] setColorFailure:self.pickerFailure.color];
}

#pragma mark - Actions

- (IBAction)pickerDidChangeColor:(SYColorView *)sender
{
    if (sender == self.pickerSuccess)
        [[SYStorage shared] setColorSuccess:self.pickerSuccess.color];
    
    if (sender == self.pickerTimeout)
        [[SYStorage shared] setColorTimeout:self.pickerTimeout.color];
    
    if (sender == self.pickerFailure)
        [[SYStorage shared] setColorFailure:self.pickerFailure.color];
}

- (IBAction)buttonDefaultsTap:(id)sender
{
    [self.pickerSuccess setColor:[[SYStorage shared] defaultColorSuccess]];
    [self.pickerTimeout setColor:[[SYStorage shared] defaultColorTimeout]];
    [self.pickerFailure setColor:[[SYStorage shared] defaultColorFailure]];
    [self save];
}

- (IBAction)buttonCloseTap:(id)sender
{
    [self.view.window close];
}

@end
