
@import Foundation;
#import "CGUtilities.h"

@class FractalConfiguration;

@protocol FractalConfigurationChangeDelegate <NSObject>
- (void)fractalConfigurationDidChange:(FractalConfiguration *)fractalConfiguration;
@end

@interface FractalConfiguration : NSObject

@property (nonatomic) CGFloat scale;
@property (nonatomic) CGPoint offset;
@property (nonatomic) NSInteger maximumIterations;
@property (nonatomic) CGFloatComplex complex;

@property (nonatomic, weak) id<FractalConfigurationChangeDelegate> delegate;

- (CGPoint)actualOffset;

@end

