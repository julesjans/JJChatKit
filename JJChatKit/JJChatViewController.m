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


#import "TextToolbar.h"

@interface JJChatViewController ()  <UICollectionViewDataSource, UICollectionViewDelegate, UITextViewDelegate>

// Collection View implementation
@property (nonatomic, strong) JJFlowLayout *flowLayout;
@property (nonatomic, strong) UICollectionView *collectionView;

#warning need to clear this controller up to include the text input view...

@property (nonatomic, readwrite, retain) UIView *inputAccessoryView;


@property (nonatomic, strong) TextToolbar *textToolBar;
@property (nonatomic, strong) UITextView *textView;


//// Handling the view that is used to handle the keyboard...?
@property (nonatomic) CGSize kbSize;
@property (nonatomic) CGSize cvSize;
//@property (nonatomic, strong) UITapGestureRecognizer *resetKeyboardGesture;
//
//// All this handles the text input view - Need to do this in code..?
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

    self.flowLayout = [[JJFlowLayout alloc] init];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    // TODO: Switch the cell view back to code from the nib?
    // [self.collectionView registerClass:[JJCollectionViewCell class]  forCellWithReuseIdentifier:@"cell"];
    UINib *nib = [UINib nibWithNibName:@"JJCollectionViewCell" bundle: [NSBundle bundleForClass:[JJChatViewController class]]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"JJChatCell"];
    
    self.view = self.collectionView;
    
    // Configure the input selection view..?
    
    
    
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
   
    
    self.textToolBar = (TextToolbar *)[[[NSBundle bundleForClass:[TextToolbar class]] loadNibNamed:@"TextToolbar" owner:self options:nil] lastObject];
    
    self.inputAccessoryView = self.textToolBar;
    
    self.textView = self.textToolBar.textView;
    self.textView.delegate = self;
    
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self scrollToBottomAnimated:YES];
    
    self.cvSize = self.collectionView.bounds.size;
}



- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self.collectionView.collectionViewLayout invalidateLayout];
    [self.collectionView reloadData];
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.collectionView performBatchUpdates:nil completion:nil];
}

- (JJCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JJCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JJChatCell" forIndexPath:indexPath];
    
    id<JJMessage> message = [self.messages objectAtIndex:indexPath.row];
    
    cell.message = message;
    
    return cell;
}
















- (void)dismissKeyboard
{
    [self.textView resignFirstResponder];
}










- (BOOL)canBecomeFirstResponder {
    return YES;
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
////// Clear out the placeholder when editing the text
//-(void)textViewDidBeginEditing:(UITextView *)textView
//{
//
//    
//    
//    
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



- (void)keyboardDidShow:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    self.kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect frame = self.collectionView.frame;
    frame.size.height = self.cvSize.height - self.kbSize.height;
    self.collectionView.frame = frame;
    
    [self scrollToBottomAnimated:YES];
}

- (void)keyboardWillHide:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    self.kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGRect frame = self.collectionView.frame;
    frame.size.height = (self.cvSize.height - self.textToolBar.frame.size.height);
    self.collectionView.frame = frame;

//    [self scrollToBottomAnimated:YES];
}








//
// Will resize the text view to span multiple lines





- (void)textViewDidChange:(UITextView *)textView
{
//    CGFloat fixedWidth = textView.frame.size.width;
//    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
//  

    
    [self.textToolBar setHeight:textView.contentSize.height + 32];
    
    
    

}





- (void)scrollToBottomAnimated:(BOOL)animated
{
    CGPoint bottomOffset = CGPointMake(0, self.collectionView.contentSize.height - self.collectionView.bounds.size.height);
    if ( bottomOffset.y > 0 ) {
        [self.collectionView setContentOffset:bottomOffset animated:animated];
    }
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.textView resignFirstResponder];
}





#warning need to do all the delegate methods for handling the text input





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