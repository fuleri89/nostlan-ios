// ==UserScript==
// @name         HTML Gamepad Spoof
// @namespace    http://tampermonkey.net/
// @version      0.1
// @description  HTML Gamepad Spoof
// @author       qashto
// @match        *://*/*
// @grant        none
// ==/UserScript==

(function() {
	const log = console.log;
	let startTime = performance.now();
	log('starting gamepad spoof');

	class NostlanGamepad {
		constructor() {
			this.axes = [0, 0, 0, 0, 0, 0, 0];
			this.buttons = [{
				pressed: false,
				touched: false,
				value: 0
			}, {
				pressed: false,
				touched: false,
				value: 0
			}, {
				pressed: false,
				touched: false,
				value: 0
			}, {
				pressed: false,
				touched: false,
				value: 0
			}, {
				pressed: false,
				touched: false,
				value: 0
			}, {
				pressed: false,
				touched: false,
				value: 0
			}, {
				pressed: false,
				touched: false,
				value: 0
			}, {
				pressed: false,
				touched: false,
				value: 0
			}, {
				pressed: false,
				touched: false,
				value: 0
			}, {
				pressed: false,
				touched: false,
				value: 0
			}];
			this.connected = true;
			this.displayId = 0;
			this.hand = '';
			this.hapticActuators = [];
			this.id = '45e-2e0-Xbox Wireless Controller';
			this.index = 0;
			this.mapping = 'standard';
			this.pose = {
				angularAcceleration: null,
				angularVelocity: null,
				hasOrientation: false,
				hasPosition: false,
				linearAcceleration: null,
				linearVelocity: null,
				orientation: null,
				position: null
			};
			this.timestamp = 1;
		}
	};

	class Nostlan {
		constructor() {
			this.gamepads = [new NostlanGamepad(), null, null, null];
			this.btns = {
				a: 0,
				b: 1,
				x: 2,
				y: 3,
				l: 4,
				r: 5,
				select: 8,
				start: 9
			};
		}

		button(btn, val) {
			log(`${btn} btn ${(val)?'pressed':'released'}: ${val}`);
			btn = this.btns[btn];
			let isPressed = (val) ? true : false;
			nostlan.gamepads[0].buttons[btn] = {
				pressed: isPressed,
				touched: isPressed,
				value: val
			};
			nostlan.gamepads[0].timestamp = performance.now() - startTime;
		}
	}

	window.nostlan = new Nostlan();
	navigator.getGamepads = function() {
		return nostlan.gamepads;
	};

	let gamepadConnected = document.createEvent('Event');
	gamepadConnected.initEvent('gamepadconnected', true, false);
	gamepadConnected.gamepad = nostlan.gamepads[0];
	window.dispatchEvent(gamepadConnected);

})();
