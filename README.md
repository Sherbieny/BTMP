# BTMP

This is a Swift project for iOS.

BTMP gives you the facility to listen to what you like before you go to bed on the app of your choice, the app then checks on you from time to time to see if you slept or not. It pauses what's playing and wait for you to tell it to resume if you are still awake. If you make any sound loud enough to be detected by the app, it will resume what was playing and then check again after a while. If no sound is detected, the app will automatically stop what's being played and close.

- Information and youtube video about the app: https://sites.google.com/view/btmp/home

- The app was on the App Store for a while but was removed due to lack of time to maintain it, it is now open source and free to use

## Project Structure

- `AppDelegate.swift`: The main application delegate.
- `Audio/`: Directory containing audio-related code.
- `BTMP.entitlements`: The entitlements for the app.
- `Button/`: Contains custom button implementations, such as `StartToggleButton.swift`.
- `Controller/`: Contains various view controllers, such as `OnBoardingView.swift`, `SettingsViewController.swift`, and `SubscriptionViewController.swift`.
- `License/`: Directory containing license-related files.
- `Model/`: Contains model classes for the app.
- `Storyboard/`: Contains storyboard files for the app.
- `Supporting Files/`: Contains various supporting files for the app.
- `BTMP.xcodeproj/`: The Xcode project file.
- `BTMP.xcworkspace/`: The Xcode workspace file.
- `Pods/`: Contains the CocoaPods dependencies for the project.

## Installation

1. Clone the repository.
2. Open `BTMP.xcworkspace` in Xcode.
3. Install the necessary CocoaPods dependencies with `pod install`.
4. Build and run the project in Xcode.

## Features

1. You will not lose track of what you were listening after you go to sleep, this is especially beneficial if you like to listen to audiobooks or podcasts and don't want to miss any of it and forget where you stopped the night before

2. The app will stop whatever is playing when you go to sleep and then close, saving battery and making sure there is no more sound playing while you are asleep

- Note 1: The app needs to stay on foreground while it is working, locking the phone or moving to another app will stop the process

- Note 2: While the app is open the screen will not lock, but once you are asleep, the app closes automatically and the phone will lock normally after.

## Contributing

Contributions are welcome. Please open a pull request with your changes.

## License

This project is licensed under the MIT License - see the [LICENSE.txt](BTMP/License/LICENSE.txt) file for details.
