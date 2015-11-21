//
//  Unirest_studyTests.m
//  Unirest-studyTests
//
//  Created by Raymond Lai on 21/11/15.
//  Copyright (c) 2015 Raymond Lai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <Unirest.h>

@interface Unirest_studyTests : XCTestCase

@end

@implementation Unirest_studyTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (NSString *) createUrl:(NSString *)suffix{
    return [NSString stringWithFormat:@"http://10.0.2.15:9090%@", suffix];
}

- (void)testSimpleGet {
    UNIHTTPStringResponse *response = [[UNIRest get:^(UNISimpleRequest *request){
        [request setUrl:[self createUrl:@"/test"]];
    }]asString];
    XCTAssertEqual(response.code, 200);
    XCTAssertEqualObjects(response.body, @"GET /test OK");
    
}

- (void)testAsyncSimpleGet {
    
    XCTestExpectation *expect = [self expectationWithDescription:@"Async test expectations"];
    
    [[UNIRest get:^(UNISimpleRequest *request){
        [request setUrl:[self createUrl:@"/test"]];
    }]asStringAsync:^(UNIHTTPStringResponse *response, NSError *error) {
        XCTAssertEqual(response.code, 200);
        XCTAssertNotEqual(response.code, 515);
        XCTAssertEqualObjects(response.body, @"GET /test OK");
        [expect fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error){
        if(error)
            NSLog(@"Timed out with error: %@", error);
    }];
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
