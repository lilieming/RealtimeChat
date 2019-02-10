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

@implementation LinkedId

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)createItem
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *currentId = [FUser currentId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	FIRDatabaseReference *firebase = [[[FIRDatabase database] referenceWithPath:FLINKEDID_PATH] child:currentId];
	[firebase updateChildValues:@{currentId:@YES}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)createItem:(NSString *)userId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *currentId = [FUser currentId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	FIRDatabaseReference *firebase1 = [[[FIRDatabase database] referenceWithPath:FLINKEDID_PATH] child:currentId];
	[firebase1 updateChildValues:@{userId:@YES}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	FIRDatabaseReference *firebase2 = [[[FIRDatabase database] referenceWithPath:FLINKEDID_PATH] child:userId];
	[firebase2 updateChildValues:@{currentId:@YES}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)createItem:(NSString *)userId1 userId2:(NSString *)userId2
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FIRDatabaseReference *firebase1 = [[[FIRDatabase database] referenceWithPath:FLINKEDID_PATH] child:userId1];
	[firebase1 updateChildValues:@{userId2:@YES}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	FIRDatabaseReference *firebase2 = [[[FIRDatabase database] referenceWithPath:FLINKEDID_PATH] child:userId2];
	[firebase2 updateChildValues:@{userId1:@YES}];
}

@end
