package com.perfume.utils.bvh{	use namespace prfmbvh;	internal class BvhParser{		private var _lines:Vector.<BvhLine>		private var _currentLine:uint;		private var _currentBone:BvhBone;				public function BvhParser(_bvh:Bvh, _str:String) {			var line_arr:Array = _str.split("\n");						_lines = new Vector.<BvhLine>();					for each (var _line_str:String in line_arr) {				_lines.push(new BvhLine(_line_str));			}				_currentLine = 1;			_bvh.rootBone = parseBone(_bvh.bones);						var currentLine:uint;			for (currentLine = 0; currentLine < _lines.length; currentLine++) {				if (_lines[currentLine].lineType == "MOTION") break;			}						currentLine++;			var _numFrames:Number = _lines[currentLine].numFrames;			_bvh.numFramesInternal = _numFrames;			currentLine++;			_bvh.frameTimeInternal = _lines[currentLine].frameTime;			currentLine++;						var _frames:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>();			var i:int;			var l:int = _lines.length;			for (i = currentLine; i < l; i++) {				_frames.push(_lines[i].frames);			}			_bvh.frames = _frames;						_numFrames = _bvh.numFramesInternal = _frames.length;		}				private function parseBone(_bones:Vector.<BvhBone>):BvhBone {			var bone:BvhBone = new BvhBone( _currentBone );						_bones.push(bone);						bone.name = _lines[_currentLine].boneName;						_currentLine++;			_currentLine++;			bone.offsetX = _lines[_currentLine].offsetX;			bone.offsetY = _lines[_currentLine].offsetY;			bone.offsetZ = _lines[_currentLine].offsetZ;							_currentLine++;			bone.numChannels = _lines[_currentLine].numChannels;			bone.channels = _lines[_currentLine].channelsProps;							_currentLine++;						while (_currentLine < _lines.length){				switch (_lines[_currentLine].lineType){					case "ROOT":					case "JOINT":						var child : BvhBone = parseBone(_bones);						child.parent = bone;						bone.children.push(child);						break;					case "End":						_currentLine++;						_currentLine++;						bone.isEnd = true;						bone.endOffsetX = _lines[_currentLine].offsetX;						bone.endOffsetY = _lines[_currentLine].offsetY;						bone.endOffsetZ = _lines[_currentLine].offsetZ;						_currentLine++;						_currentLine++;						return bone;						break;					case "}":						return bone;						break;				}				_currentLine++;			}			return bone;		}			}}internal class BvhLine{	private var _lineType:String;	private var _boneType:String;		private var _boneName:String;	private var _offsetX:Number;	private var _offsetY:Number;	private var _offsetZ:Number;	private var _numChannels:uint;	private var _channelsProps:Vector.<String>;	private var _numFrames:uint;	private var _frameTime:Number;	private var _frames:Vector.<Number>;		public function BvhLine(_str : String) {		parse(_str);	}		private function parse(_str:String):void {		var _lineStr:String = _str;		_lineStr = trim(_lineStr);				var words : Array = _lineStr.split(" ");		if (String(words[0]).indexOf("Frames:") != -1) {			words[0] = "Frames:";			words.push( _lineStr.split(":")[1] );		}		if (words[0] == "Frame" && words.length == 2) {			words[1] = "Time:";			words[2] = _lineStr.split(":")[1];		}		if (!isNaN(Number(words[0]))){			_lineType = "FRAME";		} else {			_lineType = words[0];		}		switch (_lineType){			case "HIERARCHY":				break;			case "ROOT":			case "JOINT":				_boneType = (words[0] == "ROOT") ? "ROOT" : "JOINT";				_boneName = words[1];				break;			case "OFFSET":				_offsetX = Number(words[1]);				_offsetY = Number(words[2]);				_offsetZ = Number(words[3]);				break;			case "CHANNELS":				_numChannels = Number(words[1]);				_channelsProps = new Vector.<String>();				for (var i:int = 0; i < _numChannels; i++) _channelsProps.push( words[i+2] );				break;			case "Frames:":				_numFrames = Number(words[1]);				break;			case "Frame":				_frameTime = Number(words[2]);				break;			case "End":			case "{":			case "}":			case "MOTION":				break;			case "FRAME":				_frames = new Vector.<Number>();				for each (var word : String in words) _frames.push( Number(word) );				break;		}	}			    private function trim(str:String):String {        var startIndex:int = 0;        while (isWhitespace(str.charAt(startIndex)))            ++startIndex;        var endIndex:int = str.length - 1;        while (isWhitespace(str.charAt(endIndex)))            --endIndex;        if (endIndex >= startIndex)            return str.slice(startIndex, endIndex + 1);        else            return "";    }    private function isWhitespace(character:String):Boolean{        switch (character){            case " ":            case "\t":            case "\r":            case "\n":            case "\f":                return true;            default:                return false;        }    }		public function get frames():Vector.<Number> { return _frames; }	public function get frameTime():Number { return _frameTime; }	public function get numFrames():uint { return _numFrames; }	public function get channelsProps():Vector.<String> { return _channelsProps; }	public function get numChannels():uint { return _numChannels; }	public function get offsetZ():Number { return _offsetZ; }	public function get offsetY():Number { return _offsetY; }	public function get offsetX():Number { return _offsetX; }	public function get boneName():String { return _boneName; }	public function get boneType():String { return _boneType; }	public function get lineType():String { return _lineType; }}