//
//  CEAdInvocation.m
//  Pods
//
//  Created by roylo on 2014/10/31.
//

#import "CEAdInvocation.h"
#import "CEStreamADHelper.h"

@implementation CEAdInvocation

+ (NSInvocation *)invocationForTarget:(id)target
                             selector:(SEL)selector
                            indexPath:(NSIndexPath *)indexPath
                   streamAdHelper:(CEStreamADHelper *)streamAdHelper
{
    if (![target respondsToSelector:selector]) {
        return nil;
    }

    // No invocations for ad rows.
    if ([streamAdHelper isAdAtIndexPath:indexPath]) {
        return nil;
    }

    // Create the invocation.
    NSMethodSignature *signature = [target methodSignatureForSelector:selector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:target];
    [invocation setSelector:selector];
    return invocation;
}

+ (NSInvocation *)invokeForTarget:(id)target
                 with2ArgSelector:(SEL)selector
                         firstArg:(id)arg1
                        secondArg:(NSIndexPath *)indexPath
                   streamAdHelper:(CEStreamADHelper *)streamAdHelper
{
    NSInvocation *invocation = [CEAdInvocation invocationForTarget:target
                                                                selector:selector
                                                               indexPath:indexPath
                                                    streamAdHelper:streamAdHelper];
    if (invocation) {
        NSIndexPath *origPath = [streamAdHelper originalIndexPathForAdjustedIndexPath:indexPath];
        [invocation setArgument:&(arg1) atIndex:2];
        [invocation setArgument:&(origPath) atIndex:3];
        [invocation invoke];
    }
    return invocation;
}

+ (NSInvocation *)invokeForTarget:(id)target
                 with3ArgSelector:(SEL)selector
                         firstArg:(id)arg1
                        secondArg:(id)arg2
                         thirdArg:(NSIndexPath *)indexPath
                   streamAdHelper:(CEStreamADHelper *)streamAdHelper
{
    NSInvocation *invocation = [CEAdInvocation invocationForTarget:target
                                                                selector:selector
                                                               indexPath:indexPath
                                                    streamAdHelper:streamAdHelper];
    if (invocation) {
        NSIndexPath *origPath = [streamAdHelper originalIndexPathForAdjustedIndexPath:indexPath];
        [invocation setArgument:&(arg1) atIndex:2];
        [invocation setArgument:&(arg2) atIndex:3];
        [invocation setArgument:&(origPath) atIndex:4];
        [invocation invoke];
    }
    return invocation;
}

+ (NSInvocation *)invokeForTarget:(id)target
              with3ArgIntSelector:(SEL)selector
                         firstArg:(id)arg1
                        secondArg:(NSInteger)arg2
                         thirdArg:(NSIndexPath *)indexPath
                   streamAdHelper:(CEStreamADHelper *)streamAdHelper
{
    NSInvocation *invocation = [CEAdInvocation invocationForTarget:target
                                                                selector:selector
                                                               indexPath:indexPath
                                                    streamAdHelper:streamAdHelper];
    if (invocation) {
        NSIndexPath *origPath = [streamAdHelper originalIndexPathForAdjustedIndexPath:indexPath];
        [invocation setArgument:&(arg1) atIndex:2];
        [invocation setArgument:&(arg2) atIndex:3];
        [invocation setArgument:&(origPath) atIndex:4];
        [invocation invoke];
    }
    return invocation;
}

+ (BOOL)boolResultForInvocation:(NSInvocation *)invocation defaultValue:(BOOL)defaultReturnValue
{
    if (!invocation) {
        return defaultReturnValue;
    }

    BOOL returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

+ (id)resultForInvocation:(NSInvocation *)invocation defaultValue:(id)defaultReturnValue
{
    if (!invocation) {
        return defaultReturnValue;
    }

    __unsafe_unretained id returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

+ (NSInteger)integerResultForInvocation:(NSInvocation *)invocation defaultValue:(NSInteger)defaultReturnValue
{
    if (!invocation) {
        return defaultReturnValue;
    }

    NSInteger returnValue;
    [invocation getReturnValue:&returnValue];
    return returnValue;
}

@end
