//
//  GMGridViewCell.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 01.04.21.
//  Copyright © 2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "GMGridViewCell.h"


@interface GMGridViewCell ()
@end


@implementation GMGridViewCell

static UIFont *titleFont;
static CGFloat titleHeight;
static UIImage *videoIcon;
static UIColor *titleColor;
static UIImage *checkedIcon;
static UIColor *selectedColor;
static UIColor *disabledColor;

+ (void)initialize
{
    titleFont = [Font regular12];
    titleHeight = 20.0f;
    videoIcon = [UIImage imageNamed:@"GMImagePickerVideo"];
    titleColor = [Color officialWhiteColor];
    checkedIcon = [UIImage imageNamed:@"CTAssetsPickerChecked"];
    selectedColor = [UIColor colorWithWhite:1 alpha:0.3];
    disabledColor = [UIColor colorWithWhite:1 alpha:0.9];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.contentView.translatesAutoresizingMaskIntoConstraints = YES;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.opaque                 = NO;
        self.enabled                = YES;
        
        CGFloat cellSize = self.contentView.bounds.size.width;
        
        _imageView = [UIImageView new];
        _imageView.frame = CGRectMake(0, 0, cellSize, cellSize);
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_imageView];
        
        
        float x_offset = 4.0f;
        UIColor *topGradient = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:0.0];
        UIColor *botGradient = [UIColor colorWithRed:0.00 green:0.00 blue:0.00 alpha:0.8];
        _gradientView = [[UIView alloc] initWithFrame: CGRectMake(0.0f, self.bounds.size.height-titleHeight, self.bounds.size.width, titleHeight)];
        _gradient = [CAGradientLayer layer];
        _gradient.frame = _gradientView.bounds;
        _gradient.colors = [NSArray arrayWithObjects:(id)[topGradient CGColor], (id)[botGradient CGColor], nil];
        [_gradientView.layer insertSublayer:_gradient atIndex:0];
        _gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _gradientView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_gradientView];
        _gradientView.hidden = YES;
        
        _videoIcon = [UIImageView new];
        _videoIcon.frame = CGRectMake(x_offset, self.bounds.size.height-titleHeight, self.bounds.size.width-2*x_offset, titleHeight);
        _videoIcon.contentMode = UIViewContentModeLeft;
        _videoIcon.image = [UIImage imageNamed:@"GMVideoIcon" inBundle:[NSBundle bundleForClass:GMGridViewCell.class] compatibleWithTraitCollection:nil];
        _videoIcon.translatesAutoresizingMaskIntoConstraints = NO;
        _videoIcon.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_videoIcon];
        _videoIcon.hidden = YES;
        
        _videoDuration = [UILabel new];
        _videoDuration.font = titleFont;
        _videoDuration.textColor = titleColor;
        _videoDuration.textAlignment = NSTextAlignmentRight;
        _videoDuration.frame = CGRectMake(x_offset, self.bounds.size.height-titleHeight, self.bounds.size.width-2*x_offset, titleHeight);
        _videoDuration.contentMode = UIViewContentModeRight;
        _videoDuration.translatesAutoresizingMaskIntoConstraints = NO;
        _videoDuration.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_videoDuration];
        _videoDuration.hidden = YES;
        
        _coverView = [[UIView alloc] initWithFrame:self.bounds];
        _coverView.translatesAutoresizingMaskIntoConstraints = NO;
        _coverView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _coverView.backgroundColor = [UIColor colorWithRed:0.24 green:0.47 blue:0.85 alpha:0.6];
        [self addSubview:_coverView];
        _coverView.hidden = YES;
        
        _selectedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectedButton.frame = CGRectMake(2*self.bounds.size.width/3, 0*self.bounds.size.width/3, self.bounds.size.width/3, self.bounds.size.width/3);
        _selectedButton.contentMode = UIViewContentModeTopRight;
        _selectedButton.adjustsImageWhenHighlighted = NO;
        [_selectedButton setImage:nil forState:UIControlStateNormal];
        _selectedButton.translatesAutoresizingMaskIntoConstraints = NO;
        _selectedButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_selectedButton setImage:[UIImage imageNamed:@"GMSelected" inBundle:[NSBundle bundleForClass:GMGridViewCell.class] compatibleWithTraitCollection:nil] forState:UIControlStateSelected];
        _selectedButton.hidden = NO;
        _selectedButton.userInteractionEnabled = NO;
        [self addSubview:_selectedButton];
    }

    self.shouldShowSelection = YES;

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _gradient.frame = _gradientView.bounds;
}

- (void)bind:(PHAsset *)asset
{
    self.asset  = asset;
    
    if (self.asset.mediaType == PHAssetMediaTypeVideo) {
        _videoIcon.hidden = NO;
        _videoDuration.hidden = NO;
        _gradientView.hidden = NO;
        _videoDuration.text = [self getDurationWithFormat:self.asset.duration];
    } else {
        _videoIcon.hidden = YES;
        _videoDuration.hidden = YES;
        _gradientView.hidden = YES;
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (!self.shouldShowSelection) {
        return;
    }
    
    _coverView.hidden = !selected;
    _selectedButton.selected = selected;
}

- (NSString*)getDurationWithFormat:(NSTimeInterval)duration
{
    NSInteger ti = (NSInteger)duration;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    //NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
}

@end
