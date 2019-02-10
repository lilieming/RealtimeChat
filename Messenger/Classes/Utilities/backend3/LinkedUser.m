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

#import "utilities.h"

@implementation LinkedUser

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)createItem:(FUser *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *userId = user[FUSER_OBJECTID];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *currentId = [FUser currentId];
	FUser *currentUser = [FUser currentUser];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	FIRDatabaseReference *firebase1 = [[[FIRDatabase database] referenceWithPath:FLINKEDUSER_PATH] child:currentId];
	[firebase1 updateChildValues:@{userId:user.dictionary}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	FIRDatabaseReference *firebase2 = [[[FIRDatabase database] referenceWithPath:FLINKEDUSER_PATH] child:userId];
	[firebase2 updateChildValues:@{currentId:currentUser.dictionary}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)createItem:(NSString *)userId1 userId2:(NSString *)userId2
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *user1 = [self user:userId1];
	NSDictionary *user2 = [self user:userId2];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	FIRDatabaseReference *firebase1 = [[[FIRDatabase database] referenceWithPath:FLINKEDUSER_PATH] child:userId1];
	[firebase1 updateChildValues:@{userId2:user2}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	FIRDatabaseReference *firebase2 = [[[FIRDatabase database] referenceWithPath:FLINKEDUSER_PATH] child:userId2];
	[firebase2 updateChildValues:@{userId1:user1}];
}

#pragma mark -

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)updateItems
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([UserDefaults objectForKey:LINKEDUSERIDS] != nil)
	{
		NSString *currentId = [FUser currentId];
		FUser *currentUser = [FUser currentUser];
		//-----------------------------------------------------------------------------------------------------------------------------------------
		NSMutableDictionary *multiple = [[NSMutableDictionary alloc] init];
		//-----------------------------------------------------------------------------------------------------------------------------------------
		for (NSString *userId in [UserDefaults objectForKey:LINKEDUSERIDS])
		{
			NSString *path = [NSString stringWithFormat:@"%@/%@", userId, currentId];
			multiple[path] = currentUser.dictionary;
		}
		//-----------------------------------------------------------------------------------------------------------------------------------------
		FIRDatabaseReference *reference = [[FIRDatabase database] referenceWithPath:FLINKEDUSER_PATH];
		[reference updateChildValues:multiple withCompletionBlock:^(NSError *error, FIRDatabaseReference *ref)
		{
			if (error != nil) [ProgressHUD showError:@"Network error."];
		}];
	}
}

#pragma mark -

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (NSDictionary *)user:(NSString *)userId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSMutableDictionary *user = [[NSMutableDictionary alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"objectId == %@", userId];
	DBUser *dbuser = [[DBUser objectsWithPredicate:predicate] firstObject];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (dbuser.objectId != nil)		user[FUSER_OBJECTID] = dbuser.objectId;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (dbuser.email != nil)		user[FUSER_EMAIL] = dbuser.email;
	if (dbuser.phone != nil)		user[FUSER_PHONE] = dbuser.phone;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (dbuser.firstname != nil)	user[FUSER_FIRSTNAME] = dbuser.firstname;
	if (dbuser.lastname != nil)		user[FUSER_LASTNAME] = dbuser.lastname;
	if (dbuser.fullname != nil)		user[FUSER_FULLNAME] = dbuser.fullname;
	if (dbuser.country != nil)		user[FUSER_COUNTRY] = dbuser.country;
	if (dbuser.location != nil)		user[FUSER_LOCATION] = dbuser.location;
	if (dbuser.status != nil)		user[FUSER_STATUS] = dbuser.status;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (dbuser.picture != nil)		user[FUSER_PICTURE] = dbuser.picture;
	if (dbuser.thumbnail != nil)	user[FUSER_THUMBNAIL] = dbuser.thumbnail;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	user[FUSER_KEEPMEDIA]			= @(dbuser.keepMedia);
	user[FUSER_NETWORKIMAGE]		= @(dbuser.networkImage);
	user[FUSER_NETWORKVIDEO]		= @(dbuser.networkVideo);
	user[FUSER_NETWORKAUDIO]		= @(dbuser.networkAudio);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (dbuser.wallpaper != nil)	user[FUSER_WALLPAPER] = dbuser.wallpaper;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (dbuser.loginMethod != nil)	user[FUSER_LOGINMETHOD] = dbuser.loginMethod;
	if (dbuser.oneSignalId != nil)	user[FUSER_ONESIGNALID] = dbuser.oneSignalId;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	user[FUSER_LASTACTIVE]			= @(dbuser.lastActive);
	user[FUSER_LASTTERMINATE]		= @(dbuser.lastTerminate);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	user[FUSER_CREATEDAT]			= @(dbuser.createdAt);
	user[FUSER_UPDATEDAT]			= @(dbuser.updatedAt);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return user;
}

@end
