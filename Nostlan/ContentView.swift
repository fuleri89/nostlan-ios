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
	@Published var pageLoaded = false;
	@Published var gotControllers = false;
	@Published var webView:WKWebView!;
}

struct ContentView: UIViewRepresentable {
	
	var pageURL:String; // Page to load
	@ObservedObject var g = observable();
	
	func makeUIView(context: Context) -> WKWebView {
		g.webView = WKWebView();
		
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
				self.g.pageLoaded = true; // We loaded the page
				print("Page loaded: \(title)");
				self.g.webView.evaluateJavaScript("console.log('page loaded: \(title)');" + nostlanJS, completionHandler: nil);
			}
		}
		g.webView.load(pageURL); // Send the command to WKWebView to load our page
		
		
		NotificationCenter.default.addObserver(self, selector: Selector(("connectControllers")), name: NSNotification.Name.GCControllerDidConnect, object: nil);
		NotificationCenter.default.addObserver(self, selector: Selector(("disconnectControllers")), name: NSNotification.Name.GCControllerDidDisconnect, object: nil);
		
		return g.webView; // Just make a new WKWebView, we don't need to do anything else here.
	}
	
	func updateUIView(_ uiView: WKWebView, context: Context) {
		if (g.pageLoaded && g.gotControllers != true) {
			connectControllers();
			g.gotControllers = true;
		}
	}
	
	// This Function is called when a controller is connected
	func connectControllers() {
		// Used to register the Nimbus Controllers to a specific Player Number
		var indexNumber = 0;
		// Run through each controller currently connected to the system
		for controller in GCController.controllers() {
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
		//  controller.productCategory xbox or ps
		print("controller playerIndex: \(controller.playerIndex)");
		print("controller type: \(controller.productCategory)");
		// Function that check the controller when anything is moved or pressed on it
		controller.extendedGamepad?.valueChangedHandler = {
			(gamepad: GCExtendedGamepad, element: GCControllerElement) in
			// Add movement in here for sprites of the controllers
			self.controllerInputDetected(gamepad: gamepad, element: element, p: controller.playerIndex.rawValue);
		}
	}
	
	func controllerInputDetected(gamepad: GCExtendedGamepad, element: GCControllerElement, p: Int) {
		if (gamepad.leftThumbstick == element) {
			print("p\(p) leftStick x:\(gamepad.leftThumbstick.xAxis.value) y:\(gamepad.leftThumbstick.yAxis.value)");
			g.webView.evaluateJavaScript("nostlan.stick(\(p), 'leftStick', \(gamepad.leftThumbstick.xAxis.value), \(gamepad.leftThumbstick.yAxis.value));", completionHandler: nil);
		} else if (gamepad.rightThumbstick == element) {
			print("p\(p) rightStick x:\(gamepad.rightThumbstick.xAxis.value) y:\(gamepad.rightThumbstick.yAxis.value)");
			g.webView.evaluateJavaScript("nostlan.stick(\(p), 'rightStick', \(gamepad.rightThumbstick.xAxis.value), \(gamepad.rightThumbstick.yAxis.value));", completionHandler: nil);
		} else if (gamepad.dpad == element) {
			print("p\(p), dpad x:\(gamepad.dpad.xAxis.value) y:\(gamepad.dpad.yAxis.value)");
			var direction:String = "";
			if (gamepad.dpad.yAxis.value == 1) {
				direction = "up";
				if (gamepad.dpad.xAxis.value == -1) {
					direction += "Left";
				} else if (gamepad.dpad.xAxis.value == 1) {
					direction += "Right";
				}
			} else if (gamepad.dpad.yAxis.value == -1) {
				direction = "down";
				if (gamepad.dpad.xAxis.value == -1) {
					direction += "Left";
				} else if (gamepad.dpad.xAxis.value == 1) {
					direction += "Right";
				}
			} else if (gamepad.dpad.xAxis.value == -1) {
				direction = "left";
			} else if (gamepad.dpad.xAxis.value == 1) {
				direction = "right";
			} else {
				direction = "nuetral";
			}
			print("p\(p), dpad direction: \(direction)");
			g.webView.evaluateJavaScript("nostlan.dpad(\(p), '\(direction)');", completionHandler: nil);
		} else if (element == gamepad.buttonA) {
			print("p\(p) a button pressed: \(gamepad.buttonA.value)");
			g.webView.evaluateJavaScript("nostlan.button(\(p), 'a', \(gamepad.buttonB.value));", completionHandler: nil);
		} else if (element == gamepad.buttonB) {
			print("p\(p) b button pressed: \(gamepad.buttonB.value)");
			g.webView.evaluateJavaScript("nostlan.button(\(p), 'b', \(gamepad.buttonB.value));", completionHandler: nil);
		} else if (element == gamepad.buttonX) {
			print("p\(p) x button pressed: \(gamepad.buttonX.value)");
			g.webView.evaluateJavaScript("nostlan.button(\(p), 'x', \(gamepad.buttonX.value));", completionHandler: nil);
		} else if (element == gamepad.buttonY) {
			print("p\(p) y button pressed: \(gamepad.buttonY.value)");
			g.webView.evaluateJavaScript("nostlan.button(\(p), 'y', \(gamepad.buttonY.value));", completionHandler: nil);
		} else if (element == gamepad.leftShoulder) {
			print("p\(p) l button pressed: \(gamepad.leftShoulder.isPressed)");
			g.webView.evaluateJavaScript("nostlan.button(\(p), 'l', \(gamepad.leftShoulder.isPressed ? 1:0));", completionHandler: nil);
		} else if (element == gamepad.rightShoulder) {
			print("p\(p) r button pressed: \(gamepad.rightShoulder.isPressed)");
			g.webView.evaluateJavaScript("nostlan.button(\(p), 'r', \(gamepad.rightShoulder.isPressed ? 1:0));", completionHandler: nil);
		} else if (element == gamepad.buttonMenu) {
			print("p\(p) start button pressed: \(gamepad.buttonMenu.value)");
			g.webView.evaluateJavaScript("nostlan.button(\(p), 'start', \(gamepad.buttonMenu.value));", completionHandler: nil);
		} else if (element == gamepad.buttonOptions) {
			print("p\(p) select button pressed: \(gamepad.buttonOptions!.value)");
			g.webView.evaluateJavaScript("nostlan.button(\(p), 'select', \(gamepad.buttonOptions!.value));", completionHandler: nil);
		}
	}
}

// Extension for WKWebView so we can just pass a URL string to .load() instead of all the boilerplate
extension WKWebView {
	func load(_ urlString: String) {
		if let url = URL(string: urlString) {
			let request = URLRequest(url: url)
			load(request)
		} else {
			print("failed to load " + urlString);
		}
	}
}
