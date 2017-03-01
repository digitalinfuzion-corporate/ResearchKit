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

#import "ORKFileImportStepView.h"

#import "ORKNavigationContainerView_Internal.h"

#import "ORKVerticalContainerView_Internal.h"

#import "ORKStepHeaderView_Internal.h"

#import "ORKFileImportStep.h"
#import "ORKHelpers_Internal.h"

@interface ORKPDFView : UIView

@property (nullable, nonatomic, copy) NSURL *url;

@end

@implementation ORKPDFView {

}

- (instancetype)initWithFrame:(CGRect)frame url:(nullable NSURL *)url
{
    self = [super initWithFrame:frame];
    if (self) {
        self.url = url;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    // PDF might be transparent, assume white paper
    [[UIColor lightGrayColor] set];
    CGContextFillRect(ctx, rect);

    if (!self.url) { return; }

    // Flip coordinates
    CGContextGetCTM(ctx);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -rect.size.height);

    // url is a file URL
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)self.url);
    CGPDFPageRef page1 = CGPDFDocumentGetPage(pdf, 1);

    // get the rectangle of the cropped inside
    CGRect mediaRect = CGPDFPageGetBoxRect(page1, kCGPDFCropBox);

    [[UIColor whiteColor] set];

    CGFloat border = 8;
    CGFloat w = rect.size.width - 2*border;
    CGFloat h = rect.size.height - 2*border;

    CGFloat scale = MIN(w / mediaRect.size.width, h / mediaRect.size.height);
    CGContextScaleCTM(ctx, scale, scale);
    CGFloat xOffset = -mediaRect.origin.x + (w/scale - mediaRect.size.width)/2 + border;
    CGFloat yOffset = -mediaRect.origin.y + border;
    CGContextTranslateCTM(ctx, xOffset, yOffset);

    CGContextFillRect(ctx, mediaRect);

    // draw it
    CGContextDrawPDFPage(ctx, page1);
    CGPDFDocumentRelease(pdf);
}

@end

@interface ORKFileImportStepView ()

@property (nonatomic, strong) ORKFileImportStep *step;

@end

@implementation ORKFileImportStepView {
    UIButton *_touch;
    id _target;

}

- (ORKPDFView *)pdfView {
    // TODO: fix magic numbers here
    return (ORKPDFView *)[[self.stepView subviews] objectAtIndex:0];
}

- (UILabel *)label {
    return (UILabel *)[[self.stepView subviews] objectAtIndex:1];
}

- (UIButton *)choose {
    return (UIButton *)[[self.stepView subviews] objectAtIndex:2];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void) setFileImportStep:(ORKFileImportStep *)step target:(id)target  {
    self.step = step;
    _target = target;

    ORKPDFView *pdf = [ORKPDFView new];

    ORKBorderedButton *choose = [ORKBorderedButton buttonWithType:UIButtonTypeCustom];
    [choose setTitle:self.step.selectButtonTitle forState:UIControlStateNormal];
    [choose addTarget:self action:@selector(openPicker:) forControlEvents:UIControlEventTouchUpInside];

    UILabel *label = [UILabel new];
    label.textAlignment = NSTextAlignmentCenter;

    UIView *container = [UIView new];
    [container addSubview:pdf];
    [container addSubview:label];
    [container addSubview:choose];
    self.stepView = container;

    ORKEnableAutoLayoutForViews(@[pdf, choose, container, label]);
    NSDictionary *views = NSDictionaryOfVariableBindings(pdf, choose, container, label);
    NSNumber *containerHeight = [NSNumber numberWithDouble: self.frame.size.height - 240];
    NSDictionary *metrics = NSDictionaryOfVariableBindings(containerHeight);

    NSMutableArray *constraints = [NSMutableArray new];

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[container(>=containerHeight)]"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:views]];

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-0-[pdf]-0-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=0)-[choose(200)]-(>=0)-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(>=0)-[label]-(>=0)-|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:views]];

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[choose(44)]-[pdf(>=320)]-[label(20)]-0-|"
                                                                             options:NSLayoutFormatAlignAllCenterX
                                                                             metrics:nil
                                                                               views:views]];

    [NSLayoutConstraint activateConstraints:constraints];

    self.headerView.instructionLabel.text = step.title;
}

- (IBAction)openPicker:(id)sender {
    if (!_target) { return; }
    if ([_target respondsToSelector:@selector(openPicker:)]) {
        [_target performSelector:@selector(openPicker:) withObject:self];
    }
}

- (void) setPDFURL: (NSURL *)url {

    self.pdfView.url = url;
    self.label.text = url ? url.lastPathComponent : @"";
    [self.choose setTitle: url ? self.step.reselectButtonTitle : self.step.selectButtonTitle
                 forState:UIControlStateNormal];

    [self tintColorDidChange];
    [self.pdfView setNeedsDisplay];
    [self setNeedsUpdateConstraints];

}

@end
