//
//  ContentView.swift
//  Nostlan
//
//  Created by Quinton Ashley on 3/18/20.
//  Copyright © 2020 Quinton Ashley. All rights reserved.
//

import SwiftUI
import WebKit
import GameController

// Small class to hold variables that we'll use in the View body
class observable: ObservableObject {
	@Published var observation:NSKeyValueObservation?;
	@Published var loggedIn = false;
	@Published var webView:WKWebView!;
}

struct ContentView: UIViewRepresentable {
	var pageURL:String; // Page to load
	@ObservedObject var g = observable();
	
	func makeUIView(context: Context) -> WKWebView {
		return WKWebView(); // Just make a new WKWebView, we don't need to do anything else here.
	}
	
	func updateUIView(_ uiView: WKWebView, context: Context) {
		g.webView = uiView;
		
		var nostlanJS:String = "";
		do {
			let path = Bundle.main.path(forResource: "nostlan-ios", ofType: "js");
			nostlanJS = try String(contentsOfFile: path!);
		} catch {
			print("nostlan-ios.js could not be loaded");
		}
		
		// Set up our key-value observer - we're checking for WKWebView.title changes here
		// which indicates a new page has loaded.
		g.observation = g.webView.observe(\WKWebView.title, options: .new) {
			view, change in
			let title:String = view.title!;
			if title != "" {
				self.g.loggedIn = true; // We loaded the page
				print("Page loaded: \(title)");
				self.g.webView.evaluateJavaScript("console.log('page loaded: \(title)');" + nostlanJS, completionHandler: nil);
			}
		}
		g.webView.load(pageURL); // Send the command to WKWebView to load our page
		
		
		NotificationCenter.default.addObserver(self, selector: Selector(("connectControllers")), name: NSNotification.Name.GCControllerDidConnect, object: nil);
		NotificationCenter.default.addObserver(self, selector: Selector(("disconnectControllers")), name: NSNotification.Name.GCControllerDidDisconnect, object: nil);
		
		connectControllers();
	}
	
	// This Function is called when a controller is connected
	func connectControllers() {
		// Used to register the Nimbus Controllers to a specific Player Number
		var indexNumber = 0;
		// Run through each controller currently connected to the system
		for controller in GCController.controllers() {
			print("controller connected!");
			//Check to see whether it is an extended Game Controller (Such as a Nimbus)
			if controller.extendedGamepad != nil {
				controller.playerIndex = GCControllerPlayerIndex.init(rawValue: indexNumber)!;
				indexNumber += 1;
				setupControllerControls(controller: controller);
			}
		}
	}
	
	// Function called when a controller is disconnected
	func disconnectControllers() {
	}
	
	func setupControllerControls(controller: GCController) {
		// Function that check the controller when anything is moved or pressed on it
		controller.extendedGamepad?.valueChangedHandler = {
			(gamepad: GCExtendedGamepad, element: GCControllerElement) in
			// Add movement in here for sprites of the controllers
			self.controllerInputDetected(gamepad: gamepad, element: element, index: controller.playerIndex.rawValue);
		}
	}
	
	func controllerInputDetected(gamepad: GCExtendedGamepad, element: GCControllerElement, index: Int) {
		if (gamepad.leftThumbstick == element) {
			if (gamepad.leftThumbstick.xAxis.value != 0) {
				print("Controller: \(index), LeftThumbstickXAxis: \(gamepad.leftThumbstick.xAxis)");
			} else if (gamepad.leftThumbstick.xAxis.value == 0) {
				// YOU CAN PUT CODE HERE TO STOP YOUR PLAYER FROM MOVING
				
			}
		} else if (gamepad.rightThumbstick == element) {
			if (gamepad.rightThumbstick.xAxis.value != 0) {
				print("Controller: \(index), rightThumbstickXAxis: \(gamepad.rightThumbstick.xAxis)");
			}
		} else if (gamepad.dpad == element) {
			if (gamepad.dpad.xAxis.value != 0) {
				print("Controller: \(index), D-PadXAxis: \(gamepad.rightThumbstick.xAxis)");
				
			} else if (gamepad.dpad.xAxis.value == 0){
				// YOU CAN PUT CODE HERE TO STOP YOUR PLAYER FROM MOVING
			}
		} else if (element == gamepad.buttonA) {
			print("a button pressed: \(gamepad.buttonA.value)");
			g.webView.evaluateJavaScript("nostlan.button('a', \(gamepad.buttonB.value));", completionHandler: nil);
		} else if (element == gamepad.buttonB) {
			print("b button pressed: \(gamepad.buttonB.value)");
			g.webView.evaluateJavaScript("nostlan.button('b', \(gamepad.buttonB.value));", completionHandler: nil);
		} else if (element == gamepad.buttonX) {
			g.webView.evaluateJavaScript("nostlan.button('x', \(gamepad.buttonX.value));", completionHandler: nil);
		} else if (element == gamepad.buttonY) {
			g.webView.evaluateJavaScript("nostlan.button('y', \(gamepad.buttonY.value));", completionHandler: nil);
		} else if (element == gamepad.buttonMenu) {
			g.webView.evaluateJavaScript("nostlan.button('start', \(gamepad.buttonMenu.value));", completionHandler: nil);
		} else if (element == gamepad.buttonOptions) {
			g.webView.evaluateJavaScript("nostlan.button('select', \(String(describing: gamepad.buttonOptions?.value)));", completionHandler: nil);
		}
	}
}

// Extension for WKWebView so we can just pass a URL string to .load() instead of all the boilerplate
extension WKWebView {
	func load(_ urlString: String) {
		if let url = URL(string: urlString) {
			let request = URLRequest(url: url)
			load(request)
		}
	}
}
