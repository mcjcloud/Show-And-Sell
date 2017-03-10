#Show & Sell
Central High School
Keller, TX

###Quick Reference
* [Overview] (#overview)
* [Instructions for Installation] (#instructions-for-installation)
* [Troubleshooting] (#troubleshooting)

###Overview
When we began this project, we began with the following specifications in mind:
>Create a mobile application that would allow a platform for a digital yard sale to raise funds to attend NLC. The app should allow for the donation of items, including picture, suggested price, and a rating for the condition of the item. The app should allow for interaction/comments on the items. Code should be error free.

We believe that with Show & Sell, we have gone above and beyond these guidelines. Our application strives to be the most powerful, easiest-to-use platform for hosting digital yard sales, thanks to its inclusion of the following features:

* Item Donation, including a picture, suggested price, item condition, and more details about the item
* Commenting threads on items
* Bookmarking items for quick future reference
* Full support for online purchasing using the Braintree Payments API
* Creation of multiple yard sales/groups
* Group management, including deleting, editing, and approving items in your group
* Anti-abuse protections
* Finding nearby groups based on the user's location
* Searching for items and groups
* Help section
* Account creation and login with email or Google OAuth
* Sharing items via Twitter
* Deep links into the app from Twitter
* Both Apple and Android versions of the app, each with a user-friendly UI that fits well with native design patterns

With Show & Sell, we empower FBLA chapters and other organizations to mobilize their members and the community to harness the power of mobile technology to raise funds from the sale of donated items.

###Instructions for Installation

Make sure you fulfill the following requirements before continuing:

* Have a computer running OS X 10.11.5 or later
* Have [Xcode 8] (https://developer.apple.com/xcode/downloads/) or later installed
* Have the latest version of [CocoaPods] (https://cocoapods.org/) installed.
* Have an iOS device or emulator running iOS 10 or later

After completing the requirements, perform the following to install:

1. Clone the project by either
  * Downloading the project zipped, and unpackaging it into the desired directory *OR*
  * If you have [git] (https://git-scm.com) installed, navigating to the desired directory in Terminal and executing the following command: `$ git clone https://github.com/mcjcloud/Show-And-Sell.git`
2. Navigate to the project directory (which includes a file named "Podfile") and execute the following command: `$ pod install` 
3. Open the project by double clicking on the file named "Show And Sell.xcworkspace" in the project directory
4. Wait for Xcode to finish indexing (as can be seen at the top of the Xcode window).
5. Click on root file in the Project Navigator (located on the left) named "Show And Sell" to open the project settings.
6. Navigate to the "General" tab and change the Bundle identifier (currently "com.insertcoolnamehere.Show-And-Sell") to a new, unique identifier (i.e. "com.randomidentifier.fblaapp")
7. Once complete, run the app by clicking the play button located at the top left of the Xcode window.
8. If you're running on a real device, you must approve the developer profile before the app can run. Go to Settings > General > Device Management and verify the Provisioning Profile.

Once installed, the app will run for three days before the codesigning expires, and the app must be installed again.


###Troubleshooting

> 1. I created a brand new Bundle identifier, but the app still won't run.
>   * A: Follow [this] (https://developer.apple.com/library/content/documentation/IDEs/Conceptual/AppStoreDistributionTutorial/CreatingYourTeamProvisioningProfile/CreatingYourTeamProvisioningProfile.html) link to create a Code Signing Identity (provisioning profile)
