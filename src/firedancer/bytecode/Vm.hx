package firedancer.bytecode;

import haxe.Int32;
import banker.binary.ByteStackData;
import banker.vector.WritableVector as Vec;
import sneaker.print.Printer.println;
import firedancer.assembly.Opcode;
import firedancer.bytecode.internal.Constants.*;

/**
	(WIP)

	Virtual machine for executing bytecode.
**/
class Vm {
	static extern inline final infiniteLoopCheckThreshold = 4096;

	public static function run(
		code: BytecodeData,
		codeLength: UInt,
		codePosVec: Vec<UInt>,
		stack: ByteStackData,
		stackSizeVec: Vec<UInt>,
		xVec: Vec<Float>,
		yVec: Vec<Float>,
		vxVec: Vec<Float>,
		vyVec: Vec<Float>,
		vecIndex: UInt
	): Void {
		var codePos = codePosVec[vecIndex];
		if (codeLength <= codePos) return;

		var stackSize = stackSizeVec[vecIndex];

		var volX: Float = 0.0;
		var volY: Float = 0.0;

		inline function readOp(): Int32 {
			final opcode = code.getI32(codePos);
			println('${Opcode.from(opcode).toString()} (pos: $codePos)');
			codePos += LEN32;
			return opcode;
		}

		inline function readCodeI32(): Int32 {
			final v = code.getI32(codePos);
			codePos += LEN32;
			println('  read_int ... $v');
			return v;
		}

		inline function readCodeF64(): Float {
			final v = code.getF64(codePos);
			codePos += LEN64;
			println('  read_float ... $v');
			return v;
		}

		inline function pushInt(v: Int32): Void {
			stackSize = stack.pushI32(stackSize, v);
			println('  push_int -> ${stack.toHex(stackSize, true)}');
		}

		inline function pushFloat(v: Float): Void {
			stackSize = stack.pushF64(stackSize, v);
			println('  push_float -> ${stack.toHex(stackSize, true)}');
		}

		inline function pushVec(x: Float, y: Float): Void {
			stackSize = stack.pushF64(stackSize, x);
			stackSize = stack.pushF64(stackSize, y);
			println('  push_vec -> ${stack.toHex(stackSize, true)}');
		}

		inline function popInt(): Int32 {
			final ret = stack.popI32(stackSize);
			stackSize = ret.size;
			// print('\n  pop_int ... $intValue');
			return ret.value;
		}

		inline function popFloat(): Float {
			final ret = stack.popF64(stackSize);
			stackSize = ret.size;
			// print('\n  pop_float ... $floatValue');
			return ret.value;
		}

		inline function peekInt(): Int32 {
			final v = stack.peekI32(stackSize);
			// print('\n  peek_int ... $v');
			return v;
		}

		inline function peekFloat(): Float {
			final v = stack.peekF64(stackSize);
			// print('\n  peek_float ... $v');
			return v;
		}

		inline function peekVec(bytesToSkip: Int)
			return stack.peekVec2D64(stackSize - bytesToSkip);

		inline function dropInt(): Void {
			stackSize = stack.drop(stackSize, Bit32);
			println('  drop_int -> ${stack.toHex(stackSize, true)}');
		}

		inline function dropFloat(): Void {
			stackSize = stack.drop(stackSize, Bit64);
			println('  drop_int -> ${stack.toHex(stackSize, true)}');
		}

		inline function dropVec(): Void {
			stackSize = stack.drop2D(stackSize, Bit64);
			println('  drop_int -> ${stack.toHex(stackSize, true)}');
		}

		inline function decrement(): Void {
			stack.decrement32(stackSize);
			println('  decrement ... ${stack.toHex(stackSize, true)}');
		}

		#if debug
		var cnt = 0;
		#end

		do {
			#if debug
			if (infiniteLoopCheckThreshold < ++cnt) throw "Detected infinite loop.";
			#end

			switch readOp() {
				case PushInt:
					pushInt(readCodeI32());
				case PeekVec:
					final vec = peekVec(readCodeI32());
					volX = vec.x;
					volY = vec.y;
				case DropVec:
					dropVec();
				case CountDownBreak:
					if (0 != peekInt()) {
						decrement();
						codePos -= LEN32;
						break;
					} else {
						dropInt();
					}
				case Break:
					break;
				case Jump:
					final jumpLength = readCodeI32();
					codePos += jumpLength;
				case CountDownJump:
					if (0 != peekInt()) {
						decrement();
						codePos += LEN32; // skip the operand
					} else {
						dropInt();
						final jumpLength = readCodeI32();
						codePos += jumpLength;
					}
				case Decrement:
					decrement();
				case SetPositionC:
					xVec[vecIndex] = readCodeF64();
					yVec[vecIndex] = readCodeF64();
				case AddPositionC:
					xVec[vecIndex] += readCodeF64();
					yVec[vecIndex] += readCodeF64();
				case SetVelocityC:
					vxVec[vecIndex] = readCodeF64();
					vyVec[vecIndex] = readCodeF64();
				case AddVelocityC:
					vxVec[vecIndex] += readCodeF64();
					vyVec[vecIndex] += readCodeF64();
				case SetPositionS:
					final vec = peekVec(0);
					xVec[vecIndex] = vec.x;
					yVec[vecIndex] = vec.y;
				case AddPositionS:
					final vec = peekVec(0);
					xVec[vecIndex] += vec.x;
					yVec[vecIndex] += vec.y;
				case SetVelocityS:
					final vec = peekVec(0);
					vxVec[vecIndex] = vec.x;
					vyVec[vecIndex] = vec.y;
				case AddVelocityS:
					final vec = peekVec(0);
					vxVec[vecIndex] += vec.x;
					vyVec[vecIndex] += vec.y;
				case SetPositionV:
					xVec[vecIndex] = volX;
					yVec[vecIndex] = volY;
				case AddPositionV:
					xVec[vecIndex] += volX;
					yVec[vecIndex] += volY;
				case SetVelocityV:
					vxVec[vecIndex] = volX;
					vyVec[vecIndex] = volY;
				case AddVelocityV:
					vxVec[vecIndex] += volX;
					vyVec[vecIndex] += volY;
				case CalcRelativePositionCV:
					volX = readCodeF64() - xVec[vecIndex];
					volY = readCodeF64() - yVec[vecIndex];
				case CalcRelativeVelocityCV:
					volX = readCodeF64() - vxVec[vecIndex];
					volY = readCodeF64() - vyVec[vecIndex];
				case MultVecVCS:
					final multiplier = readCodeF64();
					pushVec(volX * multiplier, volY * multiplier);
				case other:
					#if debug
					throw 'Unknown opcode: $other';
					#end
			}
		} while (codePos < codeLength);

		codePosVec[vecIndex] = codePos;
		stackSizeVec[vecIndex] = stackSize;

		println("");
	}

	public static function dryRun(bytecode: Bytecode): Void {
		final code = bytecode.data;
		final codeLength = bytecode.length;
		final codePosVec = Vec.fromArrayCopy([UInt.zero]);
		final stack = ByteStackData.alloc(256);
		final stackSizeVec = Vec.fromArrayCopy([UInt.zero]);
		final xVec = Vec.fromArrayCopy([0.0]);
		final yVec = Vec.fromArrayCopy([0.0]);
		final vxVec = Vec.fromArrayCopy([0.0]);
		final vyVec = Vec.fromArrayCopy([0.0]);
		final vecIndex = UInt.zero;
		var frame = UInt.zero;

		while (codePosVec[UInt.zero] < bytecode.length) {
			if (infiniteLoopCheckThreshold < frame)
				throw 'Exceeded $infiniteLoopCheckThreshold frames.';

			println('[frame $frame]');
			Vm.run(
				code,
				codeLength,
				codePosVec,
				stack,
				stackSizeVec,
				xVec,
				yVec,
				vxVec,
				vyVec,
				vecIndex
			);
			++frame;
		}
	}
}
