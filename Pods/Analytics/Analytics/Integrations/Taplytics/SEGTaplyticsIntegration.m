//
//  SEGTaplytics.m
//  Analytics
//
//  Created by Travis Jeffery on 6/4/14.
//  Copyright (c) 2014 Segment.io. All rights reserved.
//

#import "SEGTaplyticsIntegration.h"
#import "SEGAnalytics.h"
#import "SEGAnalyticsUtils.h"

#import <Taplytics/Taplytics.h>

@implementation SEGTaplyticsIntegration

+ (void)load {
  [SEGAnalytics registerIntegration:self withIdentifier:[self identifier]];
}

- (id)init {
  if (self = [super init]) {
    self.name = [self.class identifier];
    self.valid = NO;
    self.initialized = NO;
  }
  return self;
}

- (void)start {
  [Taplytics startTaplyticsAPIKey:[self apiKey]];
  
  SEGLog(@"TaplyticsIntegration initialized with api key %@", [self apiKey]);
}

- (void)validate {
  self.valid = ([self apiKey] != nil);
}

#pragma mark - Analytics API

- (void)identify:(NSString *)userId traits:(NSDictionary *)traits options:(NSDictionary *)options {
    // Map the traits to special mixpanel keywords.
    NSDictionary* map = @{
      @"lastName": @"lastName",
      @"firstName": @"firstName",
      @"gender": @"gender",
      @"age": @"age",
      @"name": @"name",
      @"email": @"email",
      @"avatarURl": @"avatar"
    };
    
    NSMutableDictionary *mappedTraits = [NSMutableDictionary dictionaryWithDictionary:[SEGAnalyticsIntegration map:traits withMap:map]];
    mappedTraits[@"user_id"] = userId;
    
    [Taplytics setUserAttributes:mappedTraits];
}

- (void)track:(NSString *)event properties:(NSDictionary *)properties options:(NSDictionary *)options {
    // If revenue is included, logRevenue to Taplytics.
    NSNumber *revenue = [SEGAnalyticsIntegration extractRevenue:properties];
    if (revenue) {
        [Taplytics logRevenue:event revenue:revenue metaData:properties];
    }
    else {
        [Taplytics logEvent:event value:nil metaData:properties];
    }
}

- (void)reset {
    [Taplytics resetUser:^{
        SEGLog(@"Reset Taplytics User");
    }];
}

#pragma mark - Private

- (NSString *)apiKey {
  return self.settings[@"apiKey"];
}


+ (NSString *)identifier {
  return @"Taplytics";
}

@end
