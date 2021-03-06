//
//  PackageCreator_Tests.m
//  CocosBuilder
//
//  Created by Nicky Weber on 16.06.14.
//
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "ProjectSettings.h"
#import "SBErrors.h"
#import "NSString+Packages.h"
#import "MiscConstants.h"
#import "PackageCreator.h"
#import "FileSystemTestCase.h"
#import "SBAssserts.h"

@interface PackageCreator_Tests : FileSystemTestCase

@property (nonatomic, strong) PackageCreator *packageCreator;
@property (nonatomic, strong) ProjectSettings *projectSettings;
@property (nonatomic, strong) id fileManagerMock;

@end

@implementation PackageCreator_Tests

- (void)setUp
{
    [super setUp];

    self.projectSettings = [[ProjectSettings alloc] init];
    self.projectSettings.projectPath = [self fullPathForFile:@"foo.ccbuilder/packagestests.ccbproj"];

    self.packageCreator = [[PackageCreator alloc] init];
    _packageCreator.projectSettings = _projectSettings;

    [self createFolders:@[@"foo.ccbuilder/Packages"]];
}

- (void)testCreatePackageWithName
{
    NSError *error;
    SBAssertStringsEqual([_packageCreator createPackageWithName:@"NewPackage" error:&error], [self fullPathForFile:@"foo.ccbuilder/Packages/NewPackage.ccbpack"]);
    XCTAssertNil(error, @"Error object should nil");

    [self assertFileExists:@"foo.ccbuilder/Packages/NewPackage.ccbpack"];
    [self assertFileExists:@"foo.ccbuilder/Packages/NewPackage.ccbpack/Package.plist"];

    XCTAssertTrue([_projectSettings isResourcePathInProject:[self fullPathForFile:@"foo.ccbuilder/Packages/NewPackage.ccbpack"]]);
}

- (void)testCreatePackageFailsWithPackageAlreadyInProject
{
    NSString *fullPackagePath = [self fullPathForFile:@"foo.ccbuilder/Packages/NewPackage.ccbpack"];

    [_projectSettings addResourcePath:fullPackagePath error:nil];

    NSError *error;
    XCTAssertNil([_packageCreator createPackageWithName:@"NewPackage" error:&error], @"Creation of package should return NO.");
    XCTAssertNotNil(error, @"Error object should be set");
    XCTAssertEqual(error.code, SBDuplicateResourcePathError, @"Error code should equal constant SBDuplicateResourcePathError");
}

- (void)testCreatePackageFailsWithExistingPackageButNotInProject
{
    _fileManagerMock = [OCMockObject niceMockForClass:[NSFileManager class]];
    _packageCreator.fileManager = _fileManagerMock;

    NSString *fullPackagePath = [self fullPathForFile:@"foo.ccbuilder/Packages/NewPackage.ccbpack"];

    NSError *underlyingFileError = [NSError errorWithDomain:SBErrorDomain code:NSFileWriteFileExistsError userInfo:nil];
    [[[_fileManagerMock expect] andReturnValue:@(NO)] createDirectoryAtPath:fullPackagePath
                                                 withIntermediateDirectories:YES
                                                                  attributes:nil
                                                                       error:[OCMArg setTo:underlyingFileError]];

    NSError *error;
    XCTAssertNil([_packageCreator createPackageWithName:@"NewPackage" error:&error], @"Creation of package should return NO.");
    XCTAssertNotNil(error, @"Error object should be set");
    XCTAssertEqual(error.code, SBResourcePathExistsButNotInProjectError, @"Error code should equal constant SBResourcePathExistsButNotInProjectError");

    [_fileManagerMock verify];
}

- (void)testCreatePackageFailsBecauseOfOtherDiskErrorThanFileExists
{
    _fileManagerMock = [OCMockObject niceMockForClass:[NSFileManager class]];
    _packageCreator.fileManager = _fileManagerMock;

    NSString *fullPackagePath = [self fullPathForFile:@"foo.ccbuilder/Packages/NewPackage.ccbpack"];

    NSError *underlyingFileError = [NSError errorWithDomain:SBErrorDomain code:NSFileWriteNoPermissionError userInfo:nil];
    [[[_fileManagerMock expect] andReturnValue:@(NO)] createDirectoryAtPath:fullPackagePath
                                                 withIntermediateDirectories:YES
                                                                  attributes:nil
                                                                       error:[OCMArg setTo:underlyingFileError]];

    NSError *error;
    XCTAssertNil([_packageCreator createPackageWithName:@"NewPackage" error:&error], @"Creation of package should return NO.");
    XCTAssertNotNil(error, @"Error object should be set");
    XCTAssertEqual((int)error.code, NSFileWriteNoPermissionError, @"Error code should equal constant NSFileWriteNoPermissionError");

    [_fileManagerMock verify];
}

- (void)testCreatablePackageNameWithBaseName
{
    [_projectSettings addResourcePath:[self fullPathForFile:@"foo.ccbuilder/Packages/NewPackage.ccbpack"] error:nil];
    [_projectSettings addResourcePath:[self fullPathForFile:@"foo.ccbuilder/Packages/NewPackage 1.ccbpack"] error:nil];
    [self createFolders:@[@"foo.ccbuilder/Packages/NewPackage 2.ccbpack"]];

    SBAssertStringsEqual(@"NewPackage 3", [_packageCreator creatablePackageNameWithBaseName:@"NewPackage"]);
}

@end
