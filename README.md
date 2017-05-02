PortalView
==========

[![Swift](https://img.shields.io/badge/swift-3-orange.svg?style=flat)](#)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/badge/platform-iOS-lightgrey.svg?style=flat)](#)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://opensource.org/licenses/MIT)

A (potentially) cross-platform, declarative and immutable Swift library for building user interfaces.

**WARNING!: This is still a work-in-progress, although the minimum features are available to create real world applications the API is still under design and some key optimizations are still missing. Use at your own risk.**

## TL; DR;

 * Declarative API inspired by [Elm](http://elm-lang.org/) and [React](https://facebook.github.io/react/).
 * 100% in Swift and decoupled from UIKit which makes it (potentially) cross-platform.
 * Uses facebook's [Yoga](http://github.com/facebook/yoga). A cross-platform layout engine that implements [Flexbox](https://www.w3schools.com/CSS/css3_flexbox.asp) which is used by [ReactNative](https://github.com/facebook/react-native).
 * Leverage the Swift compiler in order to have a strongly type-safe API.

Here is a sneak peak of the API but you can also check [this examples](https://github.com/guidomb/PortalView#example) or read the library [overview](./Documentation/Overview.md) to learn more about the main concepts.

```swift
enum Message {

  case like
  case goToDetailScreen

}

let component: Component<Message> = container(
  children: [
    label(
      text: "Hello PortalView!",
      style: labelStyleSheet() { base, label in
          base.backgroundColor = .white
          label.textColor = .red
          label.textSize = 12
      },
      layout: layout() {
          $0.flex = flex() {
              $0.grow = .one
          }
          $0.justifyContent = .flexEnd
      }
    )
    button(
      properties: properties() {
          $0.text = "Tap to like!"
          $0.onTap = .like
      }
    )
    button(
      properties: properties() {
          $0.text = "Tap to got to detail screen"
          $0.onTap = .goToDetailScreen
      }
    )
  ]
)
```

## Installation

### Carthage

Install [Carthage](https://github.com/Carthage/Carthage) first by either using the [official .pkg installer](https://github.com/Carthage/Carthage/releases) for the latest release or If you use [Homebrew](http://brew.sh) execute the following commands:

```
brew update
brew install carthage
```

Once Carthage is installed add the following entry to your `Cartfile`

```
github "guidomb/PortalView" "master"
```

### Manual

TODO

## Example

For some examples on how the API looks like and how to use this library check

 * The [examples](./Examples.xcodeproj) project in this repository.
 * [This](https://github.com/guidomb/SyrmoPortalExample) example project
 * The following video

[![PortalView live reload example](https://img.youtube.com/vi/Xaj6vdNLC5k/0.jpg)](https://www.youtube.com/watch?v=Xaj6vdNLC5k)

## Documentation

PortalView is still a work-in-progress. Documentation will be added as the library matures inside the [Documentation](./Documentation) directory.
You can read the library [overview](./Documentation/Overview.md) to learn more about the main concepts.

## Contribute

### Setup

Install [Carthage](https://github.com/Carthage/Carthage) first, then run

```
git clone git@github.com:guidomb/PortalView.git
cd PortalView
script/bootstrap
open PortalView.xcworkspace
```
