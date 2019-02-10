//
// Copyright (c) 2018 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "ProfileView.h"
#import "PictureView.h"
#import "CallAudioView.h"
#import "CallVideoView.h"
#import "AllMediaView.h"
#import "ChatPrivateView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ProfileView()
{
	NSTimer *timer;
	DBUser *dbuser;
	NSString *userId;

	BOOL isBlocker;
	BOOL isChatEnabled;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UIImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelInitials;
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelDetails;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellStatus;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellCountry;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellLocation;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellPhone;
@property (strong, nonatomic) IBOutlet UIButton *buttonCallPhone;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellMedia;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellChat;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellFriend;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellBlock;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ProfileView

@synthesize viewHeader, imageUser, labelInitials, labelName, labelDetails;
@synthesize cellStatus, cellCountry, cellLocation, cellPhone, buttonCallPhone;
@synthesize cellMedia, cellChat;
@synthesize cellFriend, cellBlock;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(NSString *)userId_ Chat:(BOOL)chat_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	userId = userId_;
	isChatEnabled = chat_;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	isBlocker = [Blocker isBlocker:userId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.title = @"Profile";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
	[self.navigationItem setBackBarButtonItem:backButton];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableHeaderView = viewHeader;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imageUser.layer.cornerRadius = imageUser.frame.size.width/2;
	imageUser.layer.masksToBounds = YES;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadUser];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadUser) userInfo:nil repeats:YES];
	[[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillDisappear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[timer invalidate]; timer = nil;
}

#pragma mark - Realm methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", userId];
	dbuser = [[DBUser objectsWithPredicate:predicate] firstObject];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelInitials.text = [dbuser initials];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[DownloadManager image:dbuser.picture completion:^(NSString *path, NSError *error, BOOL network)
	{
		if (error == nil)
		{
			imageUser.image = [[UIImage alloc] initWithContentsOfFile:path];
			labelInitials.text = nil;
		}
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	labelName.text = dbuser.fullname;
	labelDetails.text = UserLastActive(dbuser);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	cellStatus.detailTextLabel.text = dbuser.status;
	cellCountry.detailTextLabel.text = dbuser.country;
	cellLocation.detailTextLabel.text = dbuser.location;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[buttonCallPhone setTitle:dbuser.phone forState:UIControlStateNormal];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	cellFriend.textLabel.text = [Friend isFriend:userId] ? @"Remove Friend" : @"Add Friend";
	cellBlock.textLabel.text = [Blocked isBlocked:userId] ? @"Unblock User" : @"Block User";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView reloadData];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionPhoto:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (dbuser.picture != nil)
	{
		PictureView *pictureView = [[PictureView alloc] initWith:imageUser.image];
		[self presentViewController:pictureView animated:YES completion:nil];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionCallPhone:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *number1 = [NSString stringWithFormat:@"tel://%@", dbuser.phone];
	NSString *number2 = [number1 stringByReplacingOccurrencesOfString:@" " withString:@""];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:number2] options:@{} completionHandler:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionCallAudio:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	AdvertPremium(self);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionCallVideo:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	AdvertPremium(self);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionMedia
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *recipientId = dbuser.objectId;
	NSString *chatId = [Chat chatIdPrivate:recipientId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	AllMediaView *allMediaView = [[AllMediaView alloc] initWith:chatId];
	[self.navigationController pushViewController:allMediaView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionChatPrivate
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	ChatPrivateView *chatPrivateView = [[ChatPrivateView alloc] initWith:dbuser.objectId];
	[self.navigationController pushViewController:chatPrivateView animated:YES];
}

#pragma mark - User actions (Friend/Unfriend)

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionFriendOrUnfriend
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[Friend isFriend:userId] ? [self actionUnfriend] : [self actionFriend];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionFriend
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[alert addAction:[UIAlertAction actionWithTitle:@"Add Friend" style:UIAlertActionStyleDefault
											handler:^(UIAlertAction *action) { [self actionFriendUser]; }]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self presentViewController:alert animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionFriendUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[Friend createItem:userId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	cellFriend.textLabel.text = @"Remove Friend";
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionUnfriend
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[alert addAction:[UIAlertAction actionWithTitle:@"Remove Friend" style:UIAlertActionStyleDefault
											handler:^(UIAlertAction *action) { [self actionUnfriendUser]; }]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self presentViewController:alert animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionUnfriendUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[Friend deleteItem:userId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	cellFriend.textLabel.text = @"Add Friend";
}

#pragma mark - User actions (Block/Unblock)

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionBlockOrUnblock
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[Blocked isBlocked:userId] ? [self actionUnblock] : [self actionBlock];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionBlock
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[alert addAction:[UIAlertAction actionWithTitle:@"Block User" style:UIAlertActionStyleDestructive
											handler:^(UIAlertAction *action) { [self actionBlockUser]; }]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self presentViewController:alert animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionBlockUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	AdvertPremium(self);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionUnblock
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[alert addAction:[UIAlertAction actionWithTitle:@"Unblock User" style:UIAlertActionStyleDestructive
											handler:^(UIAlertAction *action) { [self actionUnblockUser]; }]];
	[alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self presentViewController:alert animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionUnblockUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	AdvertPremium(self);
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 3;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (section == 0) return isBlocker ? 3 : 4;
	if (section == 1) return isChatEnabled ? 2 : 1;
	if (section == 2) return 2;
	return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ((indexPath.section == 0) && (indexPath.row == 0)) return cellStatus;
	if ((indexPath.section == 0) && (indexPath.row == 1)) return cellCountry;
	if ((indexPath.section == 0) && (indexPath.row == 2)) return cellLocation;
	if ((indexPath.section == 0) && (indexPath.row == 3)) return cellPhone;
	if ((indexPath.section == 1) && (indexPath.row == 0)) return cellMedia;
	if ((indexPath.section == 1) && (indexPath.row == 1)) return cellChat;
	if ((indexPath.section == 2) && (indexPath.row == 0)) return cellFriend;
	if ((indexPath.section == 2) && (indexPath.row == 1)) return cellBlock;
	return nil;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((indexPath.section == 1) && (indexPath.row == 0)) [self actionMedia];
	if ((indexPath.section == 1) && (indexPath.row == 1)) [self actionChatPrivate];
	if ((indexPath.section == 2) && (indexPath.row == 0)) [self actionFriendOrUnfriend];
	if ((indexPath.section == 2) && (indexPath.row == 1)) [self actionBlockOrUnblock];
}

@end
