(function() {
	const log = console.log;
	const startTime = performance.now();
	log('starting gamepad spoof');

	class NostlanGamepad {
		constructor(p, type) {
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
			this.index = p;
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
				start: 7,
				leftStickBtn: 8,
				rightStickBtn: 9,
				up: 10,
				down: 11,
				left: 12,
				right: 13
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
				dpad: 6 // firefox only
			};

			// safari maps the dpad to buttons 10-13
			// firefox maps axis 6 to these dpad values
			// ios safari doesn't use this
			// but I'll include this method anyway
			// to acheive better compatibility with sites
			// that might use this method
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
			this.gamepads[p] = new NostlanGamepad(p, type);
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
			let pressed = {
				pressed: true,
				touched: true,
				value: 1
			};
			let released = {
				pressed: false,
				touched: false,
				value: 0
			};
			if (/up/i.test(direction)) {
				nostlan.gamepads[p].buttons[10] = pressed;
			} else if (/down/i.test(direction)) {
				nostlan.gamepads[p].buttons[11] = pressed;
			} else {
				nostlan.gamepads[p].buttons[10] = released;
				nostlan.gamepads[p].buttons[11] = released;
			}
			if (/left/i.test(direction)) {
				nostlan.gamepads[p].buttons[12] = pressed;
			} else if (/right/i.test(direction)) {
				nostlan.gamepads[p].buttons[13] = pressed;
			} else {
				nostlan.gamepads[p].buttons[12] = released;
				nostlan.gamepads[p].buttons[13] = released;
			}
			// firefox specific :( whoops
			// nostlan.gamepads[p].axes[6] = this.dpadVals[direction];

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

		trigger(p, name, val) {
			log(`p${p} ${name} val:${val.toFixed(2)}}`);
			let trigger = this.axes[name];
			nostlan.gamepads[p].axes[trigger] = val;
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

	window.addEventListener('DOMContentLoaded', (event) => {
		log('DOM fully loaded and parsed');

		// https://jsnes.org/
		let elems = document.getElementsByClassName('mb-3');
		if (elems) {
			elems[0].innerHTML = 'JSNES+Nostlan';
		}

	});

})();
