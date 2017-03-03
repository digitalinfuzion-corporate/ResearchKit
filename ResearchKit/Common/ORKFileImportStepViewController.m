/*
 Copyright (c) 2017, Digital Infuzion, Inc. All rights reserved.

 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:

 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.

 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.

 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "ORKFileImportStepViewController.h"
#import "ORKFileImportStep.h"

#import "ORKHelpers_Internal.h"

#import "ORKStepViewController_Internal.h"
#import "ORKNavigationContainerView_Internal.h"

#import "ORKFileImportStepView.h"
#import "ORKResult.h"


@interface ORKFileImportStepViewController () <UIDocumentPickerDelegate>

@property (nonatomic, strong, nullable) ORKFileImportStepView *stepView;

@end

@implementation ORKFileImportStepViewController {
    NSURL *_fileURL;
}

- (ORKFileImportStep *)fileImportStep {
    return  (ORKFileImportStep *)self.step;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self stepDidChange];

}
- (ORKStepResult *)result {

    if (!_fileURL) { return [super result]; }
    ORKFileResult *result = [[ORKFileResult alloc] initWithIdentifier:self.step.identifier];
    result.fileURL = _fileURL;
    result.contentType = @"application/pdf"; // TODO: Fix This for appropriate types

    return [[ORKStepResult alloc] initWithStepIdentifier:self.step.identifier results:@[result]];
}

- (instancetype)initWithStep:(nullable ORKStep *)step {
    self = [super initWithStep:step];
    if (self) {

    }
    return self;
}

- (instancetype)initWithStep:(ORKStep *)step result:(nonnull ORKResult *)result {
    self = [self initWithStep:step];
    if (self) {
        ORKStepResult *stepResult = (ORKStepResult *)result;
        if (stepResult && [stepResult results].count > 0) {

            ORKFileResult *fileResult = ORKDynamicCast([stepResult results].firstObject, ORKFileResult);

            if (fileResult.fileURL) {
                _fileURL = [fileResult.fileURL copy];
            }
        }
    }
    return self;
}

- (void)stepDidChange {
    [super stepDidChange];

    [self.stepView removeFromSuperview];
    self.stepView = nil;

    if (self.step && [self isViewLoaded]) {

        self.stepView = [[ORKFileImportStepView alloc] initWithFrame:self.view.bounds ];
        self.stepView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.stepView];

        ORKNavigationContainerView *_continueSkip = self.stepView.continueSkipContainer;

        self.stepView.headerView.learnMoreButtonItem = self.learnMoreButtonItem;
        _continueSkip.hidden = self.isBeingReviewed;
        _continueSkip.skipEnabled = NO;

        self.continueButtonTitle = [self hasNextStep] ? @"Next" : @"Done";

        _continueSkip.continueButtonItem = self.continueButtonItem;
        _continueSkip.skipButtonItem = self.skipButtonItem;
        _continueSkip.optional = self.step.isOptional;

        [self.stepView setFileImportStep:self.fileImportStep target:self];

        [self renderPDF];
    }

}

- (void)renderPDF {
    self.stepView.continueSkipContainer.continueEnabled = (_fileURL != nil);
    [self.stepView setPDFURL: _fileURL];
}

- (IBAction)openPicker:(id)sender {
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:self.fileImportStep.documentTypes
                                                                                                    inMode:self.fileImportStep.mode];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - <UIDocumentPickerDelegate>

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    _fileURL = url;
    [self renderPDF];

}

// called if the user dismisses the document picker without selecting a document (using the Cancel button)
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
}

@end

