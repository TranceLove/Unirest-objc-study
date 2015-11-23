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
    // Put setup code here. This method is called before the invocation of each test method in the class
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (NSString *) createUrl:(NSString *)suffix{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *serverAddress = [bundle objectForInfoDictionaryKey:@"server.ip"];
    int serverPort = (int)[[bundle objectForInfoDictionaryKey:@"server.port"] integerValue];
    NSString *retval = [NSString stringWithFormat:@"http://%@:%d%@", serverAddress, serverPort, suffix];
    NSLog(@"%@", retval);
    return retval;
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

- (void)testSlowCallTimeout {
    [UNIRest timeout:1];
    
    NSError *error = nil;
    
    UNIHTTPStringResponse *response = [[UNIRest get:^(UNISimpleRequest *request){
        [request setUrl:[self createUrl:@"/slow-calls"]];
    }]asString:&error];
    
    XCTAssertNotNil(error);
    XCTAssertNil(response);
}


- (void)testSlowCallWait {
    [UNIRest timeout:60];
    
    NSError *error = nil;
    
    UNIHTTPStringResponse *response = [[UNIRest get:^(UNISimpleRequest *request){
        [request setUrl:[self createUrl:@"/slow-calls"]];
    }]asString:&error];
    
    XCTAssertNil(error);
    XCTAssertNotNil(response);
    XCTAssertEqual(response.code, 200);
    XCTAssertEqualObjects(response.body, @"Slow calls worth the wait");
}

- (void)testCancelCall {
    __block BOOL hasCalledback = NO;
    
    UNIUrlConnection *connection = [[UNIRest get:^(UNISimpleRequest *request){
        [request setUrl:[self createUrl:@"/cancel-or-fail"]];
    }]asStringAsync:^(UNIHTTPStringResponse *response, NSError *error){
        hasCalledback = YES;
    }];
    
    [connection cancel];
    
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:5];
    while (hasCalledback == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:loopUntil];
    }
    
    XCTAssertFalse(hasCalledback);
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
