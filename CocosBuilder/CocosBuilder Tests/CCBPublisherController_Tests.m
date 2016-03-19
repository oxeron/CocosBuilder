//
//  CCBPublisherController_Tests.m
//  CocosBuilder
//
//  Created by Nicky Weber on 21.07.14.
//
//

#import <XCTest/XCTest.h>
#import "FileSystemTestCase.h"
#import "CCBPublisherController.h"
#import "SBPackageSettings.h"
#import "ProjectSettings.h"
#import "RMPackage.h"
#import "FileSystemTestCase+Images.h"
#import "PublishOSSettings.h"
#import "MiscConstants.h"

@interface CCBPublisherController_Tests : FileSystemTestCase

@property (nonatomic, strong) CCBPublisherController *publisherController;
@property (nonatomic, strong) ProjectSettings *projectSettings;
@property (nonatomic, strong) SBPackageSettings *packageSettings;
@property (nonatomic, strong) RMPackage *package;

@end


@implementation CCBPublisherController_Tests

- (void)setUp
{
    [super setUp];

    self.projectSettings = [[ProjectSettings alloc] init];
    _projectSettings.projectPath = [self fullPathForFile:@"baa.cocosbuilder/publishtest.ccbproj"];
    _projectSettings.publishDirectory = @"../Published-iOS";

    self.publisherController = [[CCBPublisherController alloc] init];
    _publisherController.projectSettings = _projectSettings;
}

- (void)tearDown
{
    self.projectSettings = nil;
    self.package = nil;
    self.packageSettings = nil;
    self.publisherController = nil;

    [super tearDown];
}

- (void)configureSinglePackagePublishSettingCase
{
    [_projectSettings addResourcePath:[self fullPathForFile:@"baa.cocosbuilder/Packages/foo.sbpack"] error:nil];

    self.package = [[RMPackage alloc] init];
    _package.dirPath = [self fullPathForFile:@"baa.cocosbuilder/Packages/foo.sbpack"];

    self.packageSettings = [[SBPackageSettings alloc] initWithPackage:_package];
    _packageSettings.publishToCustomOutputDirectory = NO;
    _packageSettings.publishToMainProject = NO;
    _packageSettings.publishToZip = YES;

    PublishOSSettings *iosSettings = [_packageSettings settingsForOsType:kCCBPublisherOSTypeIOS];
    iosSettings.resolution_tablethd = YES;
    iosSettings.resolution_phone = YES;

    [self createFolders:@[@"baa.cocosbuilder/Packages/foo.sbpack"]];

    _publisherController.packageSettings = @[_packageSettings];
}

- (void)testPackageExportToDefaultDirectory
{
    [self configureSinglePackagePublishSettingCase];

    [self createPNGAtPath:@"baa.cocosbuilder/Packages/foo.sbpack/resources-auto/plane.png" width:10 height:2];

    [_publisherController startAsync:NO];

    [self assertFileDoesNotExist:@"Published-Packages/foo-iOS-tablethd"];
    [self assertFileDoesNotExist:@"Published-Packages/foo-iOS-phone"];

    [self assertFilesExistRelativeToDirectory:[@"baa.cocosbuilder" stringByAppendingPathComponent:DEFAULT_OUTPUTDIR_PUBLISHED_PACKAGES] filesPaths:@[
            @"foo-iOS-tablethd.zip",
            @"foo-iOS-phone.zip"
    ]];
}

- (void)testMainProjectPublishWithOldResourcePath
{
    [self configureSinglePackagePublishSettingCase];

    _projectSettings.publishEnabledIOS = NO;

    _packageSettings.publishToZip = NO;
    _packageSettings.publishToMainProject = YES;

    [self createPNGAtPath:@"baa.cocosbuilder/OldResourcePath/resources-auto/sun.png" width:4 height:4];
    [_projectSettings addResourcePath:[self fullPathForFile:@"baa.cocosbuilder/OldResourcePath"] error:nil];

    RMDirectory *oldResourcePath = [[RMDirectory alloc] init];
    oldResourcePath.dirPath = [self fullPathForFile:@"baa.cocosbuilder/OldResourcePath"];
    _publisherController.oldResourcePaths = @[oldResourcePath];

    [self createPNGAtPath:@"baa.cocosbuilder/Packages/foo.sbpack/resources-auto/plane.png" width:10 height:2];


    [_publisherController startAsync:NO];
}

- (void)testPackageExportToCustomDirectory
{
    [self configureSinglePackagePublishSettingCase];

    [self createPNGAtPath:@"baa.cocosbuilder/Packages/foo.sbpack/resources-auto/plane.png" width:10 height:2];

    _packageSettings.publishToCustomOutputDirectory = YES;
    _packageSettings.customOutputDirectory = @"../custom";

    PublishOSSettings *iosSettings = [_packageSettings settingsForOsType:kCCBPublisherOSTypeIOS];
    iosSettings.resolutions = @[];

    [_publisherController startAsync:NO];
    /*
    [self assertFilesExistRelativeToDirectory:@"custom" filesPaths:@[
          @"foo-Android-phone.zip"
    ]];
     */
}

- (void)testPublishMainProjectWithSomePackagesNotIncluded
{
    [self createPNGAtPath:@"baa.cocosbuilder/Packages/Menus.sbpack/resources-auto/button.png" width:4 height:4];
    [self createPNGAtPath:@"baa.cocosbuilder/Packages/Characters.sbpack/resources-auto/hero.png" width:4 height:4];
    [self createPNGAtPath:@"baa.cocosbuilder/Packages/Backgrounds.sbpack/resources-auto/desert.png" width:4 height:4];

    [_projectSettings addResourcePath:[self fullPathForFile:@"baa.cocosbuilder/Packages/Menus.sbpack"] error:nil];
    [_projectSettings addResourcePath:[self fullPathForFile:@"baa.cocosbuilder/Packages/Characters.sbpack"] error:nil];
    [_projectSettings addResourcePath:[self fullPathForFile:@"baa.cocosbuilder/Packages/Backgrounds.sbpack"] error:nil];
    _projectSettings.publishEnabledIOS = YES;

    SBPackageSettings *packageSettingsMenus = [self createSettingsWithPath:@"baa.cocosbuilder/Packages/Menus.sbpack"];
    packageSettingsMenus.publishToMainProject = NO;
    packageSettingsMenus.publishToZip = NO;

    SBPackageSettings *packageSettingsCharacters = [self createSettingsWithPath:@"baa.cocosbuilder/Packages/Characters.sbpack"];
    packageSettingsCharacters.publishToMainProject = YES;
    packageSettingsCharacters.publishToZip = NO;

    SBPackageSettings *packageSettingsBackgrounds = [self createSettingsWithPath:@"baa.cocosbuilder/Packages/Backgrounds.sbpack"];
    packageSettingsBackgrounds.publishToMainProject = YES;
    packageSettingsBackgrounds.publishToZip = NO;

    _publisherController.packageSettings = @[packageSettingsMenus, packageSettingsCharacters, packageSettingsBackgrounds];

    [_publisherController startAsync:NO];

    NSArray *resolutions = @[RESOLUTION_TABLET, RESOLUTION_TABLET_HD, RESOLUTION_PHONE, RESOLUTION_PHONE_HD];
    NSArray *osSuffixes = @[@"iOS"];

    for (NSString *osSuffix in osSuffixes)
    {
        for (NSString *resolution in resolutions)
        {
            NSString *outputFolder = [NSString stringWithFormat:@"Published-%@", osSuffix];
            [self assertFilesExistRelativeToDirectory:outputFolder filesPaths:@[
                    [NSString stringWithFormat:@"resources-%@/hero.png", resolution],
                    [NSString stringWithFormat:@"resources-%@/desert.png", resolution]
            ]];

            [self assertFilesDoNotExistRelativeToDirectory:outputFolder filesPaths:@[
                    [NSString stringWithFormat:@"resources-%@/button.png", resolution]
            ]];
        }
    }

    for (NSString *osSuffix in osSuffixes)
    {
        for (NSString *resolution in resolutions)
        {
            [self assertFilesDoNotExistRelativeToDirectory:packageSettingsMenus.effectiveOutputDirectory filesPaths:@[
                    [NSString stringWithFormat:@"Menus-%@-%@.zip", osSuffix, resolution]
            ]];
            [self assertFilesDoNotExistRelativeToDirectory:packageSettingsCharacters.effectiveOutputDirectory filesPaths:@[
                    [NSString stringWithFormat:@"Characters-%@-%@.zip", osSuffix, resolution]
            ]];
            [self assertFilesDoNotExistRelativeToDirectory:packageSettingsBackgrounds.effectiveOutputDirectory filesPaths:@[
                    [NSString stringWithFormat:@"Backgrounds-%@-%@.zip", osSuffix, resolution]
            ]];
        }
    }
}

- (void)testNothingToPublish
{
    [self configureSinglePackagePublishSettingCase];

    _packageSettings.publishToZip = NO;
    _packageSettings.publishToMainProject = NO;
    _packageSettings.publishToCustomOutputDirectory = NO;

    [_publisherController startAsync:NO];

    [self assertFileDoesNotExist:@"Published-iOS"];
    [self assertFileDoesNotExist:DEFAULT_OUTPUTDIR_PUBLISHED_PACKAGES];
}


#pragma mark - helpers

- (SBPackageSettings *)createSettingsWithPath:(NSString *)path
{
    RMPackage *package = [[RMPackage alloc] init];
    package.dirPath = [self fullPathForFile:path];

    return [[SBPackageSettings alloc] initWithPackage:package];
}

@end