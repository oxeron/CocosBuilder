/*
 * CocosBuilder: http://www.cocosbuilder.org
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "SpriteSheetSettingsWindow.h"
#import "FCFormatConverter.h"

@interface SpriteSheetSettingsWindow ()

@end

@implementation SpriteSheetSettingsWindow

@synthesize textureFileFormat;
@synthesize compress;
@synthesize dither;
@synthesize textureFileFormatHTML5;
@synthesize iOSEnabled;
@synthesize tvOSEnabled;
@synthesize HTML5Enabled;
@synthesize ditherHTML5;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (!self) return NULL;
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self updateIOSSettings:nil];
    [self updateHTML5Settings:nil];
}

- (IBAction)updateIOSSettings:(NSPopUpButton *)sender {
    BOOL compressEnabled = [self isCompressable:textureFileFormat] && iOSEnabled;
    [iosCompress setEnabled:compressEnabled];
    if(!compressEnabled){
        [iosCompress setState:NSOffState];
    }
    BOOL ditherEnabled = [self isDitherable:textureFileFormat] && iOSEnabled;
    [iosDither setEnabled:ditherEnabled];
    if(!ditherEnabled){
        [iosDither setState:NSOffState];
    }
}

- (IBAction)updateTVOSSettings:(NSPopUpButton *)sender {
    BOOL compressEnabled = [self isCompressable:textureFileFormat] && tvOSEnabled;
    [tvosCompress setEnabled:compressEnabled];
    if(!compressEnabled){
        [tvosCompress setState:NSOffState];
    }
    BOOL ditherEnabled = [self isDitherable:textureFileFormat] && tvOSEnabled;
    [tvosDither setEnabled:ditherEnabled];
    if(!ditherEnabled){
        [tvosDither setState:NSOffState];
    }
}

- (IBAction)updateHTML5Settings:(NSPopUpButton *)sender {
    BOOL ditherEnabled = [self isDitherable:textureFileFormatHTML5] && HTML5Enabled;
    [HTML5Dither setEnabled:ditherEnabled];
    if(!ditherEnabled){
        [HTML5Dither setState:NSOffState];
    }
}

- (BOOL)isCompressable:(int)textureFomat {
    return (textureFomat >= kFCImageFormatPVR_RGBA8888 && textureFomat <= kFCImageFormatPVRTC_2BPP);
}

- (BOOL)isDitherable:(int)textureFomat {
    return ((textureFomat == kFCImageFormatPVR_RGBA4444) || (textureFomat == kFCImageFormatPVR_RGB565) || (textureFomat == kFCImageFormatPNG_8BIT));
}
@end
