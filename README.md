# iCarsGoogleMap

To launch the project, use `iCarsGoogleMap.xcworkspace`
(not `iCarsGoogleMap.xcodeproj` because I am using Cocoapods)

Google API key is placed in a file called `API_KEYS.plist`

## Screenshots
![screenshot1](/screenshots/screen1.png "screenshot1")
![screenshot2](/screenshots/screen2.png "screenshot2")
![screenshot3](/screenshots/screen3.png "screenshot3")

## Implementation notes:

I used following dependencies:
- [SlideMenuControllerSwift](https://github.com/dekatotoro/SlideMenuControllerSwift) to add a “slide menu”
- Google Maps
- [Toast-Swift](https://github.com/scalessec/Toast-Swift) to add “activity indicator” to give a user feedback about “networking requests” in process
They are included in the commit to make sure you have the exact copy of them

As requested, I used .xib files instead of storyboards.

SlideMenuController is added at a “high level” in AppDelegate.swift where 2 controllers (`LeftMenuViewController` & `MapViewController`) have been added to it.

To extract values from this `.plist` file I added a “wrapper” method `valueForKey(named:)`  placed in a file `APIKeys.swift`.
If you would like to use your own API key, you should place it there.

In my Core Location methods, I am requesting permission for “Only while in use”. I have added appropriate explanation to `Privacy - Location When In Use Usage Description` in `Info.plist`

San Francisco and NY coordinates are hardcoded at the instantiation, but that’s what was required.

Global Tint color is system “blue”. It is inherited by location buttons, menu button and driving route polyline.

Do display Map Pins, I use method `mapView.animate(to: camera)` instead of  `mapView.camera = camera` that adds animation to displaying map changes. If that’s too hypnotic, it could be easily changed by using `mapView.camera = camera`

I put all my networking code into one simple struct called `NetworkManager`. It has a class method with completion handlers to make network calls. I use this “abstraction” pattern in my project to expose only specific methods to make networking calls and hide their implementation.
This is done to prevent scalability problems in the future: provider of the API may change or I may even completely change the data server. If that happens, I have to only refactor the implementation of my networking methods, but their exposed API will remain the same.

In my `static func getDrivingRoutePointsBetween(origin: String, destination: String, completionHandler: @escaping ((_ encodedPoints:String?,_ success: Bool) -> Void))`
I use `@escaping` keyword to allow the completionHandler fail gracefully, if the API of the data provider changes.
However, if there is a networking problem, completionHandler will be called with the result `nil` for the `encodedPoints` which will be handled as a “Networking error” by MapViewController with the appropriate UIAlertController message displayed to the user as a feedback.
Also "Google Directions API" method is called on the MAIN thread because of the Google requirement. I always make my API calls on the background, but not here because of the following exception: `Terminating app due to uncaught exception 'GMSThreadException', reason: 'The API method must be called from the main thread'`

Errors are handled and displayed for:
- Location sharing is denied by user in Settings
- Location sharing is restricted (like parental control)
- Networking error for google server (driving route)

I didn’t wipe out the commit history, you can see it all: I worked on the assignment last week “bit-by-bit” when I had slots of free time.

