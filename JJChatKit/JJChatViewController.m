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

// Issue one:
// Sometimes losing the items when the device rotates.

// Issue two:
// There is a visible jar when the text view returns on the second line, probably to do with the scroll to rect method

// Issue three:
// When can the initial scroll to the bottom view take place?, viewWillAppear seems to be too early?

// Issue four:
// Need to fix where the colours are being set



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

// Is this all to be binned?
//@property (nonatomic, strong) UITapGestureRecognizer *resetKeyboardGesture;
//@property (nonatomic, weak) IBOutlet UIButton *sendMessageButton;
//@property (nonatomic, weak) IBOutlet UIBarButtonItem *sendButton;
//@property (nonatomic, weak) IBOutlet UIView *textViewContainer;
//@property (nonatomic, weak) IBOutlet UIView *postView;
//@property (nonatomic, weak) IBOutlet UITextView *messageTextView;

@end

@implementation JJChatViewController


#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    // Create the view for text input
    self.textToolBar = (JJTextToolbar *)[[[NSBundle bundleForClass:[JJTextToolbar class]] loadNibNamed:@"TextToolbar" owner:self options:nil] lastObject];
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


#pragma mark - Attribute Housekeeping

- (void)dismissKeyboard
{
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
    
    cell.message = message;
    
    return cell;
}


#pragma mark - Keyboard handling

- (void)keyboardDidShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    self.kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect frame = self.collectionView.frame;
    frame.size.height = self.view.bounds.size.height - self.kbSize.height;
    self.collectionView.frame = frame;
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
    
    // Sort out the magick numbers !
    
    [self.textToolBar setHeight:MIN(textView.contentSize.height + 9, 160)];
    [self scrollToCaretInTextView:textView animated:NO];
    
    // TODO: Add a listener to move the scroll view up with the text input..?
    [self scrollToBottomAnimated:YES];
}

// http://stackoverflow.com/questions/22315755/ios-7-1-uitextview-still-not-scrolling-to-cursor-caret-after-new-line
- (void)scrollToCaretInTextView:(UITextView *)textView animated:(BOOL)animated {
    
#warning this still scrolls if there is a newline character..?
    CGRect rect = [textView caretRectForPosition:textView.selectedTextRange.end];
    rect.size.height += textView.textContainerInset.bottom;
    [textView scrollRectToVisible:rect animated:animated];
}


//// Sets the enabled status of the send button, according to the content of the text view
//- (void)toggleSendButton
//{
//    if ([self.messageTextView.text isEqualToString:@""] || [self.messageTextView.text isEqualToString:[self placeholderText]]) {
//        [self.sendButton setEnabled:NO];
//    } else {
//        [self.sendButton setEnabled:YES];
//    }
//}
//
//- (NSString *)placeholderText
//{
//    return [NSString stringWithFormat:@"Message"];
//}
//
//// Put the placeholder back if there is no text
//-(void)textViewDidEndEditing:(UITextView *)textView
//{
//    if ([textView.text isEqualToString:@""]) {
//        textView.text = [self placeholderText];
//        [self.messageTextView setTextColor:[UIColor separatorColor]];
//    }
//    [self toggleSendButton];
//}
//



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

@end