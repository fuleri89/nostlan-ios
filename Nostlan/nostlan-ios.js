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
	const startTime = performance.now();
	log('starting gamepad spoof');

	class NostlanGamepad {
		constructor(type) {
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
			this.gamepads = [new NostlanGamepad('xbox'), null, null, null];
			this.btns = {
				a: 0,
				b: 1,
				x: 2,
				y: 3,
				l: 4,
				r: 5,
				select: 6,
				start: 7
			};
			this.axes = {
				leftStick: {
					x: 0,
					y: 1
				},
				rightStick: {
					x: 2,
					y: 3
				},
				leftTrigger: 4,
				rightTrigger: 5,
				dpad: 6
			};

			this.dpadVals = {
				up: -1.0,
				upRight: -0.7142857142857143,
				right: -0.4285714285714286,
				downRight: -0.1428571428571429,
				down: 0.1428571428571428,
				downLeft: 0.4285714285714286,
				left: 0.7142857142857142,
				upLeft: 1.0,
				nuetral: -1.2857142857142856
			};
		}

		addGamepad(p, type) {
			// p for player
			// type can be xbox or ps (playstation)
			log(`adding gamepad idx: ${p} type: ${type}`);
			this.gamepads[p] = new NostlanGamepad(type);
		}

		removeGamepad(p) {
			log(`removed gamepad idx: ${p}`);
			this.gamepads[p] = null;
		}

		updateTimestamp(p) {
			nostlan.gamepads[p].timestamp = performance.now() - startTime;
		}

		button(p, name, val) {
			val = (val) ? true : false; // convert to boolean
			log(`p${p} ${name} btn ${(val)?'pressed':'released'}`);
			let btn = this.btns[name];
			nostlan.gamepads[p].buttons[btn] = {
				pressed: val,
				touched: val,
				value: (val) ? 1 : 0
			};
			this.updateTimestamp(p);
		}

		dpad(p, direction) {
			log(`p${p} dpad ${direction}`);
			nostlan.gamepads[p].axes[6] = this.dpadVals[direction];
			this.updateTimestamp(p);
		}

		stick(p, name, x, y) {
			log(`p${p} ${name} x:${x.toFixed(2)} y:${y.toFixed(2)}`);
			let xAxis = this.axes[name].x;
			let yAxis = this.axes[name].y;
			nostlan.gamepads[p].axes[xAxis] = x;
			nostlan.gamepads[p].axes[yAxis] = y;
			this.updateTimestamp(p);
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
