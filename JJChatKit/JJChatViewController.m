//
//  JJChatViewController.m
//  JJChatKit
//
//  Created by Julian Jans on 22/07/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

#import "JJChatViewController.h"
#import "NSString+JJChatkit.h"
#import "JJCollectionViewCell.h"
#import "JJFlowLayout.h"
#import "JJBubble.h"
#import "JJTextToolbar.h"
#import "JJChatAppearance.h"
#import "JJCollectionView.h"


// TODO: Are there any issues with items on the rotation?

@interface JJChatViewController ()  <UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

// Collection View implementation
@property (nonatomic, strong) JJFlowLayout *flowLayout;

/// Handling of the text input view embedded in the inputAccessoryView
@property (nonatomic, strong) UIView *inputAccessoryView;
@property (nonatomic, strong) JJTextToolbar *textToolBar;
@property (nonatomic, weak) UITextView *textView;

/// Placeholders for sizing the view according to the keyboard
@property (nonatomic) CGSize kbSize;

// Handle the side swipe for the times..?
@property (nonatomic, strong) UIPanGestureRecognizer *sideSwipeRecogniser;

@end


@implementation JJChatViewController


#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // Create the view for text input
    self.textToolBar = (JJTextToolbar *)[[[NSBundle bundleForClass:[JJTextToolbar class]] loadNibNamed:@"JJTextToolbar" owner:self options:nil] lastObject];
    self.textToolBar.delegate = self;
    self.inputAccessoryView = self.textToolBar;
    self.textView = self.textToolBar.textView;
    self.textView.delegate = self;
    
    // Create the collection view with the custom layout
    self.flowLayout = [[JJFlowLayout alloc] init];
    
    // Make the frame larger than the view for the side time labels
    CGRect frame = self.view.bounds;
    frame.size.width += SIDE_PADDING;
    
    self.collectionView = [[JJCollectionView alloc] initWithFrame:frame collectionViewLayout:self.flowLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView registerNib:[UINib nibWithNibName:@"JJCollectionViewCell" bundle: [NSBundle bundleForClass:[JJChatViewController class]]] forCellWithReuseIdentifier:@"JJChatCell"];
    [self.view addSubview:self.collectionView];

    // Gestures to handle the keyboard dismiss
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    // Swipe to move the messages.
     self.sideSwipeRecogniser = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipeForTime:)];
     [self.view addGestureRecognizer:self.sideSwipeRecogniser];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Set up the placeholder
    [self togglePlaceholder:self.textView];
    
    self.textToolBar.delegate = self;
    
    [self.textToolBar setFont:[[JJChatAppearance sharedApearance] messageFont]];
    
    self.kbSize = CGSizeMake(0, 49.0f);

    [self.collectionView layoutIfNeeded];
    [self scrollToBottomAnimated:NO];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    // TODO: Is this expensive?
    // Seems to be the only way to get the transitions to work?
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        [self.flowLayout invalidateLayout];
        
        CGRect frame = self.view.bounds;
        frame.size.width += SIDE_PADDING;
        self.collectionView.frame = frame;
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        [self.flowLayout invalidateLayout];
        
        CGRect frame = self.view.bounds;
        frame.size.width += SIDE_PADDING;
        self.collectionView.frame = frame;
    }];
}


#pragma mark - Controller Housekeeping

- (void)dismissKeyboard {
    [self.textView resignFirstResponder];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}


#pragma mark - Collection View Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(JJFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Cache the sizes of the cells, so that we don't have to recalculate them
    static NSCache *sizes;
    if (!sizes) {
        sizes = [NSCache new];
    }
    
    id<JJMessage> message = [self.messages objectAtIndex:indexPath.row];
    
    // Get the content of the message
    NSString *text = message.content;
    
    // If we have already rendered this then return the size
    NSValue *renderedSize = [sizes objectForKey:[text keyForOrientation]];
    if (renderedSize) {
         //return [renderedSize CGSizeValue];
    }
    
    // Get the full width of the view
    CGFloat cellWidth = self.collectionView.bounds.size.width;
    // Get the prefered available width of text, and max height
    
    CGSize textSize = CGSizeMake((cellWidth * 0.55) - ((BUBBLE_PADDING * 2) + BUBBLE_FACTOR), CGFLOAT_MAX);
    // Calculate the rect that will contain the text content
    CGRect textRect = [text boundingRectWithSize:textSize options:NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName: [[JJChatAppearance sharedApearance] messageFont]} context:nil];
    // Calculate the size of the final cell
    CGSize cellSize = CGSizeMake(self.collectionView.bounds.size.width, ceilf((textRect.size.height) + (BUBBLE_PADDING * 2)));
    // Put the size in the dictionary for caching
    [sizes setObject:[NSValue valueWithCGSize:cellSize] forKey:[text keyForOrientation]];
    
    //    // Get the full width of the view
    //    CGFloat cellWidth = self.collectionView.bounds.size.width;
    //    // Get the prefered available width of text, and max height
    //    CGSize textSize = CGSizeMake(((cellWidth * 0.55) - ((BUBBLE_PADDING * 2) + BUBBLE_FACTOR)), CGFLOAT_MAX);
    //    // Calculate the rect that will contain the text content
    //    CGRect textRect = [text boundingRectWithSize:textSize options:NSLineBreakByWordWrapping|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes: @{NSFontAttributeName: self.messageFont} context:nil];
    //    // Calculate the size of the final cell
    //    CGSize cellSize = CGSizeMake(cellWidth, ceil(textRect.size.height) + (BUBBLE_PADDING * 2));
    //    // Put the size in the dictionary for caching
    //    [sizes setObject:[NSValue valueWithCGSize:cellSize] forKey:[text keyForOrientation]];
    
    return cellSize;
}

- (JJCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JJCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JJChatCell" forIndexPath:indexPath];
    
    id<JJMessage> message = [self.messages objectAtIndex:indexPath.row];

    cell.message = message;
    
    return cell;
}


#pragma mark - Keyboard handling
- (void)setInsets
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.collectionView setContentInset: UIEdgeInsetsMake(self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height, 0, self.kbSize.height, 0)];
    }];
}

- (void)KeyboardDidShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    self.kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    [self setInsets];
    
    
    if ([self.textView isFirstResponder]) {
        [self scrollToBottomAnimated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    self.kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [self setInsets];
}


#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    [self.textToolBar setOptimisedHeight];
    [self scrollToCaretInTextView:textView animated:NO];
    [self togglePostButton];
}

// http://stackoverflow.com/questions/22315755/ios-7-1-uitextview-still-not-scrolling-to-cursor-caret-after-new-line
- (void)scrollToCaretInTextView:(UITextView *)textView animated:(BOOL)animated
{
    CGRect rect = [textView caretRectForPosition:textView.selectedTextRange.end];
    rect.size.height += textView.textContainerInset.bottom;
    [textView scrollRectToVisible:rect animated:animated];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self togglePlaceholder:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self togglePlaceholder:textView];
}

- (void)togglePlaceholder:(UITextView *)textView
{
    if (![textView.text validString] || [textView.text isEqualToString:@"Placeholder text"]) {
        textView.text = [[JJChatAppearance sharedApearance] placeholderText];
        [textView setTextColor:[UIColor lightGrayColor]];
    } else if ([textView.text isEqualToString:[[JJChatAppearance sharedApearance] placeholderText]]) {
        textView.text = @"";
        [textView setTextColor:[UIColor blackColor]];
    }
    [self togglePostButton];
}

- (void)togglePostButton
{
    if (![self.textView.text validString] || [self.textView.text isEqualToString:[[JJChatAppearance sharedApearance] placeholderText]]) {
        [self.textToolBar.postButton setEnabled:NO];
    } else {
        [self.textToolBar.postButton setEnabled:YES];
    }
}


#pragma mark - UIScrollViewDelegate & Actions

- (void)scrollToBottomAnimated:(BOOL)animated
{
    [self.collectionView layoutIfNeeded];
    
    CGPoint bottomOffset = CGPointMake(0, (self.collectionView.contentSize.height - self.collectionView.bounds.size.height) + self.kbSize.height);

    if ( bottomOffset.y > 0 ) {
    
        if (!animated) self.flowLayout.skipAnimations = YES;
        
        [self.collectionView setContentOffset:bottomOffset animated:animated];
        
        if (!animated) self.flowLayout.skipAnimations = NO;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.collectionView]) {
        [self.textView resignFirstResponder];
    }
}


#pragma mark - Custom Action Delegate

- (void)didSendMessage:(NSString *)message
{
    [self.textView setText:@""];
    [self.textToolBar setOptimisedHeight];
    [self.textView resignFirstResponder];
}


#pragma mark - Handle the Swipe

- (void)pauseLayoutChanges:(BOOL)pause
{
    JJCollectionView *collectionView = (JJCollectionView *)self.collectionView;
    collectionView.isAnimating = pause;
    
    JJFlowLayout *flowLayout = self.flowLayout;
    flowLayout.skipAnimations = pause;
}

- (void)swipeForTime:(UIPanGestureRecognizer *)sender
{
    static BOOL isAnimating;

    if (isAnimating) return;
    
    static CGPoint startLocation, currentLocation;
    
    static NSArray *cells;
    if (!cells) cells = [self.collectionView.visibleCells copy];
    
    static NSMutableArray *cellFrames;
    if (!cellFrames) cellFrames = [NSMutableArray array];
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            
            [self pauseLayoutChanges:YES];

            for (JJCollectionViewCell *cell in cells) {
                [cellFrames addObject:[NSValue valueWithCGPoint:cell.center]];
            }
            startLocation = [sender locationInView:self.view];
        }

        case UIGestureRecognizerStateChanged:
            currentLocation = [sender locationInView:self.view];
            
            for (JJCollectionViewCell *cell in cells) {
                
                if (cells.count != cellFrames.count) { break; }
                
                CGPoint frameLocation = [[cellFrames objectAtIndex:[cells indexOfObject:cell]] CGPointValue];
                
                CGPoint newCenter = CGPointMake(frameLocation.x + (MIN(0, MAX(-SIDE_PADDING, currentLocation.x - startLocation.x))), frameLocation.y);
                
                if (!cell.recipient) {
                    cell.center = newCenter;
                } else {
                    cell.sidePadding.constant = MIN((SIDE_PADDING + 12), -(currentLocation.x - startLocation.x) + 12);
                }
            }

            break;
            
        case UIGestureRecognizerStateEnded: {
            
                isAnimating = YES;
            
                [UIView animateWithDuration:0.3 animations:^{
                    
                    for (JJCollectionViewCell *cell in cells) {
                        
                        if (cells.count != cellFrames.count) { break; }
                        
                        cell.sidePadding.constant = 14;
                        [cell setNeedsUpdateConstraints];
                    
                        if (!cell.recipient) {
                            CGPoint frameLocation = [[cellFrames objectAtIndex:[cells indexOfObject:cell]] CGPointValue];
                            cell.center = frameLocation;
                        } else {
                            [cell layoutIfNeeded];
                        }
                    }

                } completion:^(BOOL finished) {
                    cells = nil;
                    cellFrames = nil;
                    isAnimating = NO;
                    [self pauseLayoutChanges:NO];
                }];
        }
        default:
            break;
    }
}

@end