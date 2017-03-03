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

#import "ORKFileImportStep.h"
#import "ORKFileImportStepViewController.h"

#import "ORKHelpers_Internal.h"

#define ORKThrowInvalidArgumentExceptionUnsupported(argument, unsupported)  if (argument == unsupported) { @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@#argument" has unsupported value "@#unsupported userInfo:nil]; }

@interface ORKFileImportStep ()

@property (nonatomic, readwrite, copy) NSArray<NSString *> *documentTypes;
@property (nonatomic, readwrite) UIDocumentPickerMode mode;

@end

@implementation ORKFileImportStep

+ (instancetype)makePDFImportStepWithIdentifier:(NSString *)identifier {
    return [[self alloc] initWithIdentifier:identifier documentTypes:@[@"public.pdf", @"com.adobe.pdf"]];
}

+ (Class)stepViewControllerClass {
    return [ORKFileImportStepViewController class];
}

- (Class)stepViewControllerClass {
    return [[self class] stepViewControllerClass];
}

- (instancetype)initWithIdentifier:(NSString *)identifier
                     documentTypes:(NSArray<NSString *> *)allowedUTIs{
    self = [super initWithIdentifier:identifier];

    if (self) {
        ORKThrowInvalidArgumentExceptionIfNil(allowedUTIs);

        _documentTypes = [allowedUTIs copy];
        _mode = UIDocumentPickerModeImport;

        self.selectButtonTitle = @"Select a File";
        self.reselectButtonTitle = @"Select a Different File";
        self.text = @"Select a PDF by tapping the button below.";
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder: aDecoder];
    if (self) {
        ORK_DECODE_OBJ_CLASS(aDecoder, documentTypes, NSArray);
        ORK_DECODE_ENUM(aDecoder, mode);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    ORK_ENCODE_OBJ(aCoder, documentTypes);
    ORK_ENCODE_ENUM(aCoder, mode);
    [super encodeWithCoder:aCoder];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@\n\tDocumentTypes: %@", super.description, self.documentTypes];
}

@end
