//
//  NSString+toNSArray.m
//  Axelrod's Tournament
//
//  Created by Elliot Adderton on 05/04/2014.
//  Copyright (c) 2014 Elliot Adderton. All rights reserved.
//

#import "NSString+toNSArray.h"

@implementation NSString (toNSArray)

- (NSArray *)toNSArray {
    NSMutableArray *letterArray = [NSMutableArray array];
    [self enumerateSubstringsInRange:NSMakeRange(0, self.length) options:(NSStringEnumerationByComposedCharacterSequences) usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        [letterArray addObject:substring];
    }];
    
    return letterArray;
}
@end
