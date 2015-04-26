//
//  DeviceModel.h
//  Car Racing Challenge
//
//  Created by Alex Ongarato on 25/04/15.
//  Copyright (c) 2015 Alex Ongarato. All rights reserved.
//

#ifndef Car_Racing_Challenge_DeviceModel_h
#define Car_Racing_Challenge_DeviceModel_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class DeviceModel;

@interface DeviceModel : NSObject

- (NSString *) platform;
- (NSString *)platformString;

@end

#endif
