//
//  NSMutableArray+Convenience.m
//  Guess
//
//  Created by qichunren on 9/5/14.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

@implementation NSMutableArray (Convenience)

- (void)moveObjectAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    id object = [self objectAtIndex:fromIndex];
    [self removeObjectAtIndex:fromIndex];
    [self insertObject:object atIndex:toIndex];
}

@end
