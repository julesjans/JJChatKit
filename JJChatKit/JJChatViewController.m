//
//  JJChatViewController.m
//  JJChatKit
//
//  Created by Julian Jans on 22/07/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

#import "JJChatViewController.h"
#import "NSString+JJChatkit.h"
#import "UIColor+JJChatkit.h"
#import "JJCollectionViewCell.h"
#import "JJFlowLayout.h"
#import "JJBubble.h"
#import "JJTextToolbar.h"


#warning Losing items on rotation
#warning Handing down the view controller is a bad design pattern


@interface JJChatViewController ()  <UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate>

// Collection View implementation
@property (nonatomic, strong) JJFlowLayout *flowLayout;
@property (nonatomic, strong) UICollectionView *collectionView;

/// Handling of the text input view embedded in the inputAccessoryView
@property (nonatomic, strong) UIView *inputAccessoryView;
@property (nonatomic, strong) JJTextToolbar *textToolBar;
@property (nonatomic, weak) UITextView *textView;

/// Placeholders for sizing the view according to the keyboard
@property (nonatomic) CGSize kbSize;

@end

@implementation JJChatViewController


#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    // Create the view for text input
    self.textToolBar = (JJTextToolbar *)[[[NSBundle bundleForClass:[JJTextToolbar class]] loadNibNamed:@"JJTextToolbar" owner:self options:nil] lastObject];
    self.textToolBar.delegate = self;
    [self.textToolBar setFont:self.messageFont];
    self.inputAccessoryView = self.textToolBar;
    self.textView = self.textToolBar.textView;
    self.textView.delegate = self;
    
    // Create the collection view with the custom layout
    self.flowLayout = [[JJFlowLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    [self.collectionView registerNib:[UINib nibWithNibName:@"JJCollectionViewCell" bundle: [NSBundle bundleForClass:[JJChatViewController class]]] forCellWithReuseIdentifier:@"JJChatCell"];
    self.collectionView.frame = self.view.bounds;
    [self.view addSubview:self.collectionView];

    // Gestures to handle the keyboard dismiss
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    // Set up the placeholder
    [self togglePlaceholder:self.textView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self scrollToBottomAnimated:NO];
    [super viewDidAppear:animated];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    #warning Is this expensive?
    // Seems to be the only way to get the transitions to work?
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        [self.flowLayout invalidateLayout];
        
        CGRect frame = self.view.bounds;
        self.collectionView.frame = frame;
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        [self.flowLayout invalidateLayout];
        
        CGRect frame = self.view.bounds;
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
    // Optimise the rendering here by caching the sizes of the of the rendered views in a static variable
    static NSMutableDictionary *sizes;
    if (!sizes) {
        sizes = [NSMutableDictionary dictionary];
    }
    
    id<JJMessage> message = [self.messages objectAtIndex:indexPath.row];
    
    // Get the content of the message
    NSString *text = message.content;
    
    // If we have already rendered this then return the size
    NSValue *renderedSize = [sizes objectForKey:[text keyForOrientation]];
    if (renderedSize) {
         return [renderedSize CGSizeValue];
    }
    
    // Get the full width of the view
    CGFloat cellWidth = self.collectionView.bounds.size.width;
    // Get the prefered available width of text, and max height
    CGSize textSize = CGSizeMake(((cellWidth - ((BUBBLE_PADDING * 2) + BUBBLE_FACTOR)) * 0.75), CGFLOAT_MAX);
    // Calculate the rect that will contain the text content
    CGRect textRect = [text boundingRectWithSize:textSize options:NSStringDrawingUsesLineFragmentOrigin attributes: @{NSFontAttributeName: self.messageFont} context:nil];
    // Calculate the size of the final cell
    CGSize cellSize = CGSizeMake(cellWidth, ceilf(textRect.size.height) + (BUBBLE_PADDING * 2));
    // Put the size in the dictionary for caching
    [sizes setObject:[NSValue valueWithCGSize:cellSize] forKey:[text keyForOrientation]];
    
    return cellSize;
}

- (JJCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JJCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JJChatCell" forIndexPath:indexPath];
    
    id<JJMessage> message = [self.messages objectAtIndex:indexPath.row];
    cell.controller = self;
    cell.message = message;
    
    return cell;
}


#pragma mark - Keyboard handling

- (void)KeyboardDidShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    self.kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect frame = self.collectionView.frame;
    frame.size.height = self.view.bounds.size.height - self.kbSize.height;
    self.collectionView.frame = frame;
    
    [self scrollToBottomAnimated:YES];
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{

    NSDictionary* info = [aNotification userInfo];
    self.kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect frame = self.collectionView.frame;
    frame.size.height = (self.view.bounds.size.height - self.textToolBar.frame.size.height);
    self.collectionView.frame = frame;
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
        textView.text = [self placeholderText];
        [textView setTextColor:[UIColor lightGrayColor]];
    } else if ([textView.text isEqualToString:self.placeholderText]) {
        textView.text = @"";
        [textView setTextColor:[UIColor blackColor]];
    }
    [self togglePostButton];
}

- (void)togglePostButton
{
    if (![self.textView.text validString] || [self.textView.text isEqualToString:[self placeholderText]]) {
        [self.textToolBar.postButton setEnabled:NO];
    } else {
        [self.textToolBar.postButton setEnabled:YES];
    }
}


#pragma mark - UIScrollViewDelegate & Actions

- (void)scrollToBottomAnimated:(BOOL)animated
{
    CGPoint bottomOffset = CGPointMake(0, self.collectionView.contentSize.height - self.collectionView.bounds.size.height);
    if ( bottomOffset.y > 0 ) {
        [self.collectionView setContentOffset:bottomOffset animated:animated];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self.collectionView]) {
        [self.textView resignFirstResponder];
    }
}


#pragma mark - Custom Action Delegate

- (void)didPostMessage:(NSString *)message
{
    [self.textView setText:@""];
    [self.textToolBar setOptimisedHeight];
    [self.textView resignFirstResponder];
}


#pragma mark - View Attributes

- (UIFont *)messageFont {
    if (!_messageFont) {
        return [UIFont fontWithName:@"AvenirNext-Medium" size:16.0];
    }
    return _messageFont;
}

- (NSString *)placeholderText {
    if (!_placeholderText) {
        return @"Message";
    }
    return _placeholderText;
}


#warning this is not the best way to set the colours for the view..?

- (UIColor *)fromBackgroundColour {
    if (!_fromBackgroundColour) {
        return [UIColor fromBackgroundColour];
    }
    return _fromBackgroundColour;
}

- (UIColor *)fromTextColour {
    if (!_fromTextColour) {
        return [UIColor fromTextColour];
    }
    return _fromTextColour;
}

- (UIColor *)toBackgroundColour {
    if (!_toBackgroundColour) {
        return [UIColor toBackgroundColour];
    }
    return _toBackgroundColour;
}

- (UIColor *)toTextColour {
    if (!_toTextColour) {
        return [UIColor toTextColour];
    }
    return _toTextColour;
}

- (UIColor *)inputViewColor {
    if (!_inputViewColor) {
        return [UIColor inputViewColor];
    }
    return _inputViewColor;
}

- (UIColor *)inputViewBorderColor {
    if (!_inputViewBorderColor) {
        return [UIColor inputViewBorderColor];
    }
    return _inputViewBorderColor;
}

@end