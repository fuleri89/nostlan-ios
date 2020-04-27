# nostlan-ios

Use Xbox One & PS4 controllers to play web based games on iOS 13.4+ without jailbreaking your iPhone/iPad!

### How does this work???

In iOS 13, released September 19, 2019, Apple added native support for Xbox One and PS4 controllers over bluetooth. However, Apple didn't add support for these controllers to Safari for iOS. I asked Apple Customer Service if/when they would support this and they didn't know. Instead of waiting I decided to do it myself!

Nostlan for iOS uses the new SwiftUI framework. When a web page is loaded I use Swift to JS eval bridging via WKWebview's evaluateJavaScript to inject nostlan-ios.js, which is a custom implementation of the [HTML5 Gamepad API](https://developer.mozilla.org/en-US/docs/Web/API/Gamepad_API/Using_the_Gamepad_API). This implementation achieves compatibility with web based games by overriding `navigator.getGamepads()` to make it return custom Gamepad objects via the class NostlanGamepad (I had to do this because [Gamepad](https://developer.mozilla.org/en-US/docs/Web/API/Gamepad) objects are read only). The custom gamepad objects are created, stored, and updated by `window.nostlan` of the class `Nostlan` which has methods for updating the buttons, dpad, sticks, and triggers. The Swift portion of Nostlan for iOS gets controller inputs from the [GCController Swift API](https://developer.apple.com/videos/play/wwdc2019/616/). On every input, webView.evaluateJavaScript is called with js that uses `window.nostlan` to update a gamepad.

### Confirmed Testing On

- [SUCCESS] iPhone 6S Plus running iOS 13.4 using an Xbox One Controller

### Possible Issues

Should support PS4 controllers and using multiple controllers at the same time but I haven't personally confirmed it.

### Know Issues

Doesn't work on sites (codepen for example) that only accept controller input in an iframe.
