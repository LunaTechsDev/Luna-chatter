//=============================================================================
// Luna_MessageSounds.js
//=============================================================================
//=============================================================================
// Build Date: 2020-09-04 21:51:29
//=============================================================================
//=============================================================================
// Made with LunaTea -- Haxe
//=============================================================================


// Generated by Haxe 4.1.3
/*:
@author LunaTechs - Kino
@plugindesc This plugin allows you to add sounds to your text in the message window
at character, word, sentence, and just message intervals. 
menu <LunaMsgSounds>.

@target MV MZ



@help
This plugin allows you to have a press start button before the title screen information.

MIT License
Copyright (c) 2020 LunaTechsDev
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE
*/
(function ($hx_exports, $global) { "use strict"
class EReg {
	constructor(r,opt) {
		this.r = new RegExp(r,opt.split("u").join(""))
	}
	match(s) {
		if(this.r.global) {
			this.r.lastIndex = 0
		}
		this.r.m = this.r.exec(s)
		this.r.s = s
		return this.r.m != null;
	}
}
class LunaMessageSounds {
	static main() {
		let _this = $plugins
		let _g = []
		let _g1 = 0
		while(_g1 < _this.length) {
			let v = _this[_g1]
			++_g1
			if(new EReg("<LunaMsgSounds>","ig").match(v.description)) {
				_g.push(v)
			}
		}
		
//=============================================================================
// Window_Message
//=============================================================================
      
	}
}
class haxe_iterators_ArrayIterator {
	constructor(array) {
		this.current = 0
		this.array = array
	}
	hasNext() {
		return this.current < this.array.length;
	}
	next() {
		return this.array[this.current++];
	}
}
class _$LTGlobals_$ {
}
class utils_Fn {
	static proto(obj) {
		return obj.prototype;
	}
}
LunaMessageSounds.main()
})(typeof exports != "undefined" ? exports : typeof window != "undefined" ? window : typeof self != "undefined" ? self : this, {})
