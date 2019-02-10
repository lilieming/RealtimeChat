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

#import "WelcomeView.h"
#import "LoginPhoneView.h"
#import "LoginGoogleView.h"
#import "LoginEmailView.h"
#import "RegisterEmailView.h"
#import "NavigationController.h"

@implementation WelcomeView

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
}

#pragma mark - Phone login methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionLoginPhone:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	AdvertPremium(self);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didLoginPhone
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
}

#pragma mark - Google login methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionLoginGoogle:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	AdvertPremium(self);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didLoginGoogle
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
}

#pragma mark - Facebook login methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionLoginFacebook:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	AdvertPremium(self);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)signInWithFacebook:(void (^)(FUser *user, NSError *error))completion
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
}

#pragma mark - Email login methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionLoginEmail:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	LoginEmailView *loginEmailView = [[LoginEmailView alloc] init];
	loginEmailView.delegate = self;
	[self presentViewController:loginEmailView animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didLoginEmail
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissViewControllerAnimated:YES completion:^{
		UserLoggedIn(LOGIN_EMAIL);
	}];
}

#pragma mark - Email register methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionRegisterEmail:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RegisterEmailView *registerEmailView = [[RegisterEmailView alloc] init];
	registerEmailView.delegate = self;
	[self presentViewController:registerEmailView animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didRegisterUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissViewControllerAnimated:YES completion:^{
		UserLoggedIn(LOGIN_EMAIL);
	}];
}

@end
