//
//  JJChatViewController.m
//  JJChatKit
//
//  Created by Julian Jans on 22/07/2015.
//  Copyright (c) 2015 Julian Jans. All rights reserved.
//

#import "JJChatCollectionViewController.h"
#import "JJCollectionViewCell.h"
#import "JJMessage.h"
#import "JJFlowLayout.h"




@interface JJChatCollectionViewController ()  <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) JJFlowLayout *flowLayout;




@property (nonatomic, strong) UICollectionView *collectionView;



// Handling the view that is used to handle the keyboard...?
@property (nonatomic) CGSize kbSize;
@property (nonatomic) CGSize tbSize;
@property (nonatomic, strong) UITapGestureRecognizer *resetKeyboardGesture;

// All this handles the text input view - Need to do this in code..?
@property (nonatomic, weak) IBOutlet UIButton *sendMessageButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *sendButton;
@property (nonatomic, weak) IBOutlet UIView *textViewContainer;
@property (nonatomic, weak) IBOutlet UIView *postView;
@property (nonatomic, weak) IBOutlet UITextView *messageTextView;

// Handles the profile image in the navigation item...?
@property (nonatomic, strong) UIImageView *profileImage;
@property (nonatomic, strong) UILabel *profileLabel;


@end

@implementation JJChatCollectionViewController



#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.flowLayout = [[JJFlowLayout alloc] init];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    //    [self.collectionView registerClass:[JJCollectionViewCell class]  forCellWithReuseIdentifier:@"cell"];
    UINib *nib = [UINib nibWithNibName:@"JJCollectionViewCell" bundle: [NSBundle bundleForClass:[self class]]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"cell"];
    
    
    
    
    self.view = self.collectionView;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView reloadData];
}



#pragma mark - Messages

-(NSString *) randomStringWithLength: (int) len {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)[letters length])]];
    }
    
    return randomString;
}

- (NSArray *)messages
{
    if (!_messages) {
        NSMutableArray *array = [[NSMutableArray alloc]init];
        int x=0;
        while (x < 2000) {
            [array addObject:@{@"content": [self randomStringWithLength:arc4random_uniform(180)], @"read": @(0), @"recipient": @((arc4random() % 2 ? 1 : 0))}];
            x++;
        }
        _messages = array;
    }

    return _messages;
}




#pragma mark - Collection View Delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.messages.count;
}

#define MESSAGE_PADDING 8.0f
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(JJFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Optimise the rendering here by caching the sizes of the of the rendered views
    static NSMutableDictionary *sizes;
    if (!sizes) {
        sizes = [NSMutableDictionary dictionary];
    }
    
    // Get the text
    NSString *text = (NSString*)[[self.messages objectAtIndex:indexPath.row] objectForKey:@"content"];
    
    // If we have already rendered this then return the size
    NSValue *renderedSize = [sizes objectForKey:[self stringForTextLength:text]];
    if (renderedSize) {
         return [renderedSize CGSizeValue];
    }
    
    // Otherwise we need to render a view and calculate the size of it!
    CGFloat cellWidth = self.collectionView.bounds.size.width;
    CGRect rect = [text boundingRectWithSize:CGSizeMake(((cellWidth - (MESSAGE_PADDING * 2)) * 0.75), CGFLOAT_MAX)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes: @{NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Medium" size:16.0]}
                                              context:nil];

    CGSize computedSize = CGSizeMake(cellWidth, ceilf(rect.size.height) + (MESSAGE_PADDING * 2));
    
    // Add the size to the dictionary
    [sizes setObject:[NSValue valueWithCGSize:computedSize] forKey:[self stringForTextLength:text]];
    
    return computedSize;
}

- (NSString *)stringForTextLength:(NSString *)text
{
    return [NSString stringWithFormat:@"%ld-%@", (long)[[UIApplication sharedApplication] statusBarOrientation], @([text length])];
}






- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.collectionView performBatchUpdates:nil completion:nil];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout *)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0;
}

-(JJCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JJCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}



- (void)configureCell:(JJCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary<JJMessage> *message = [self.messages objectAtIndex:indexPath.row];
    
    JJCollectionViewCell *bubbleCell = (JJCollectionViewCell *)cell;
    bubbleCell.message = message;
}















































#pragma mark - Message send box
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
//// Clear out the placeholder when editing the text
//-(void)textViewDidBeginEditing:(UITextView *)textView
//{
//    if ([textView.text isEqualToString:[self placeholderText]] || [textView.text isEqualToString:@""]) {
//        textView.text = @"";
//        [self.messageTextView setTextColor:[UIColor blackColor]];
//    }
//    [self toggleSendButton];
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
//- (void)keyboardDidShow:(NSNotification*)aNotification
//{
//    // Get the height of the keyboard
//    NSDictionary* info = [aNotification userInfo];
//    self.kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
//    
//    // Get the new position to move the text entry field.
//    CGRect frame = self.postView.frame;
//    frame.origin.y = (self.view.bounds.size.height - self.kbSize.height) - frame.size.height;
//    self.postView.frame = frame;
//    
//    // Now resize the table view to take into account the view
//    frame = self.tableView.frame;
//    frame.size.height = (self.tbSize.height - self.postView.frame.size.height) - self.kbSize.height;
//    self.tableView.frame = frame;
//    
//    [self scrollToBottomAnimated:YES];
//}
//
//- (void)keyboardWillHide:(NSNotification*)aNotification
//{
//    self.kbSize = CGSizeMake(0, 0);
//    
//    CGRect frame = self.postView.frame;
//    frame.origin.y = (self.view.bounds.size.height) - frame.size.height;
//    self.postView.frame = frame;
//    
//    frame = self.tableView.frame;
//    frame.size.height = (self.tbSize.height - self.postView.frame.size.height);
//    self.tableView.frame = frame;
//    
//    [self scrollToBottomAnimated:YES];
//}
//
//// Will resize the text view to span multiple lines
//- (void)textViewDidChange:(UITextView *)textView
//{
//    [self toggleSendButton];
//    
//    textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//    
//    float height = textView.contentSize.height - 44;
//    
//    if (height < 0) {
//        [self resetMessageContent];
//        return;
//    }
//    
//    // Make the text entry view and the table view meet in the middle
//    if (height > 0 && height < self.tableView.frame.size.height) {
//        
//        // This is the textview
//        CGRect textFrame = textView.frame;
//        textFrame.size.height = textView.contentSize.height;
//        textView.frame = textFrame;
//        
//        // The frame of the container
//        CGRect textContainerFrame = self.textViewContainer.frame;
//        textContainerFrame.size.height = self.messageTextView.bounds.size.height - (self.textViewContainer.layer.borderWidth *2);
//        self.textViewContainer.frame = textContainerFrame;
//        
//        // This is enlarging the entire view
//        CGRect frame = self.postView.frame;
//        frame.size.height = 54 + height;
//        frame.origin.y = (self.postView.superview.frame.size.height - self.kbSize.height) - frame.size.height;
//        self.postView.frame = frame;
//        
//        CGRect tableFrame;
//        tableFrame = self.tableView.frame;
//        tableFrame.size.height = (self.tableView.superview.frame.size.height - self.kbSize.height) - frame.size.height;
//        self.tableView.frame = tableFrame;
//        
//        [self scrollToBottomAnimated:YES];
//        [textView scrollRangeToVisible:NSMakeRange([textView.text length], 0)];
//    } else {
//        [self scrollToBottomAnimated:YES];
//        [textView scrollRangeToVisible:NSMakeRange([textView.text length], 0)];
//    }
//}
//
//// Reset the text box views to their normal size
//- (void)resetMessageContent
//{
//    CGRect textFrame = self.textViewContainer.frame;
//    textFrame.size.height = 36;
//    self.textViewContainer.frame = textFrame;
//    
//    self.messageTextView.frame = self.textViewContainer.bounds;
//    
//    CGRect frame = self.postView.frame;
//    frame.size.height = 44;
//    frame.origin.y = (self.postView.superview.frame.size.height - self.kbSize.height) - frame.size.height;
//    self.postView.frame = frame;
//    
//    CGRect tableFrame;
//    tableFrame = self.tableView.frame;
//    tableFrame.size.height = (self.tableView.superview.frame.size.height - self.kbSize.height) - frame.size.height;
//    self.tableView.frame = tableFrame;
//}
//
//- (IBAction)dismissKeyboard:(id)sender
//{
//    [self.messageTextView resignFirstResponder];
//    [self updateTable];
//}
//
//// Gesture to be placed in the view to handle the tap screen to dismiss keyboard
//- (UITapGestureRecognizer *)resetKeyboardGesture
//{
//    if (!_resetKeyboardGesture) {
//        _resetKeyboardGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard:)];
//        _resetKeyboardGesture.delegate = self;
//    }
//    return _resetKeyboardGesture;
//}
//
//// Mask the tap screen gesture over the play button
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    if ([touch.view isEqual:self.playButton]) {
//        return NO;
//    } else {
//        return YES;
//    }
//}






@end