//
//  ChangeLog.h
//  CooperNative
//
//  Created by sunleepy on 12-9-14.
//  Copyright (c) 2012年 codesharp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ChangeLog : NSManagedObject

@property (nonatomic, retain) NSString * accountId;
@property (nonatomic, retain) NSNumber * changeType;
@property (nonatomic, retain) NSString * dataid;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSNumber * isSend;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * tasklistId;
@property (nonatomic, retain) NSString * value;

@end
