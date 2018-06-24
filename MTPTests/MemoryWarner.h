// @copyright Trollwerks Inc.

@import UIKit;

@interface UIApplication (MemoryWarner)

- (void)_performMemoryWarning;

@end

@interface MemoryWarner : NSObject

- (void)performMemoryWarningEvery:(NSTimeInterval)seconds;

@end
