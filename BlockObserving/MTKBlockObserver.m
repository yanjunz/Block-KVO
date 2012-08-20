//
//  MTKBlockObserver.m
//  Block Key-Value Observing
//
//  Created by Martin Kiss on 14.7.12.
//  Copyright (c) 2012 iMartin Kiss. All rights reserved.
//

#import "MTKBlockObserver.h"









@implementation MTKBlockObserver


static NSUInteger _livingBlockObservers = 0;
+ (NSUInteger)livingBlockObservers {
    return _livingBlockObservers;
}

+ (MTKBlockObservationKind)kind {
    NSAssert(NO, @"Method is abstract");
    return NSIntegerMax;
}



@synthesize object = _object;
@synthesize keyPath = _keyPath;
@synthesize beforeBlock = _beforeBlock;
@synthesize afterBlock = _afterBlock;
@synthesize active = _active;



- (id)init {
    return [self initWithObject:nil keyPath:nil beforeBlock:nil afterBlock:nil];
}

- (id)initWithObject:(NSObject *)object
             keyPath:(NSString *)keyPath
         beforeBlock:(id)beforeBlock
          afterBlock:(id)afterBlock {
    self = [super init];
    if (self) {
        NSAssert( ! [self isMemberOfClass:[MTKBlockObserver class]],
                 @"Can not instantinate class MTKBlockObserver, use one of its subclasses");
        NSAssert(object, @"Observed object must not be NULL");
        NSAssert(keyPath, @"Observed key path must not be NULL");
        NSAssert(beforeBlock || afterBlock, @"At least one observing block must not be NULL");
        self->_object = object;
        self->_keyPath = keyPath;
        self->_beforeBlock = beforeBlock;
        self->_afterBlock = afterBlock;
        
        _livingBlockObservers ++;
    }
    return self;
}

- (void)dealloc {
    [self.object removeObserver:self forKeyPath:self.keyPath];
    
    _livingBlockObservers --;
    NSLog(@"DEALLOC: observer %@ %@", self->_object, self->_keyPath);
}



- (MTKBlockObservationKind)kind {
    return [[self class] kind];
}



- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (self.object == object && [self.keyPath isEqualToString:keyPath]) {
        if ([self shouldObserveChangeKind:[[change objectForKey:NSKeyValueChangeKindKey] intValue]]) {
            BOOL isPrior = [[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue];
            if (isPrior) {
                if (self.beforeBlock) {
                    [self observeBeforeChange:change];
                }
            }
            else {
                if (self.afterBlock) {
                    [self observeAfterChange:change];
                }
            }
        }
    }
}

- (void)observeBeforeChange:(NSDictionary *)change {
    NSAssert(NO, @"Method is abstract");
}

- (void)observeAfterChange:(NSDictionary *)change {
    NSAssert(NO, @"Method is abstract");
}


- (void)setActive:(BOOL)active {
    if (active != NO) {
        active = YES;
    }
    if (self->_active != active) {
        self->_active = active;
        if (active) {
            [self.object addObserver:self
                          forKeyPath:self.keyPath
                             options:
             NSKeyValueObservingOptionInitial |
             NSKeyValueObservingOptionOld |
             NSKeyValueObservingOptionNew |
             (self.beforeBlock? NSKeyValueObservingOptionPrior : 0)
                             context:nil];
        }
        else {
            [self.object removeObserver:self forKeyPath:self.keyPath];
        }
    }
}

- (void)activate {
    self.active = YES;
}

- (void)deactivate {
    self.active = NO;
}



@end

