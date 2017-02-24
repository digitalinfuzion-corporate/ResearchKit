//
//  ORKFileImportView.h
//  ResearchKit
//
//  Created by Stephen Furlani on 2/23/17.
//  Copyright © 2017 Digital Infuzion, Inc. All rights reserved.
//

#import "ORKVerticalContainerView.h"
#import "ORKStepHeaderView.h"
#import "ORKVerticalContainerView.h"
#import "ORKNavigationContainerView.h"
#import "ORKTintedImageView.h"

@class ORKFileImportStep;

@interface ORKFileImportStepView : ORKVerticalContainerView

- (void) setPDFURL: (NSURL *)url;
- (void) setFileImportStep:(ORKFileImportStep *)step target:(id)target;

@end
