package firedancer.bytecode;

import haxe.Int32;
import banker.vector.WritableVector as Vec;
import sneaker.print.Printer;
import firedancer.assembly.Opcode;
import firedancer.types.Emitter;
import firedancer.bytecode.internal.Constants.*;
import firedancer.common.MathStatics.*;
import firedancer.common.Vec2DStatics.*;

/**
	Virtual machine for executing bytecode.
**/
class Vm {
	static extern inline final infiniteLoopCheckThreshold = 4096;

	public static function run(
		thread: Thread,
		xVec: Vec<Float>,
		yVec: Vec<Float>,
		vxVec: Vec<Float>,
		vyVec: Vec<Float>,
		vecIndex: UInt,
		emitter: Emitter
	): Void {
		final maybeCode = thread.code;
		if (maybeCode.isNone()) return;
		final code = maybeCode.unwrap();
		final codeLength = thread.codeLength;

		var codePos = thread.codePos;
		final stack = thread.stack;
		var stackSize = thread.stackSize;

		var volFloat: Float = 0.0;
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

		inline function peekInt(): Int32
			return stack.peekI32(stackSize);

		inline function peekFloat(): Float
			return stack.peekF64(stackSize);

		inline function peekFloatSkipped(bytesToSkip: Int): Float
			return stack.peekF64(stackSize - bytesToSkip);

		inline function peekVecSkipped(bytesToSkip: Int)
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
			println('  drop_vec -> ${stack.toHex(stackSize, true)}');
		}

		inline function decrement(): Void {
			stack.decrement32(stackSize);
			println('  decrement ... ${stack.toHex(stackSize, true)}');
		}

		inline function getX(): Float
			return xVec[vecIndex];

		inline function getY(): Float
			return yVec[vecIndex];

		inline function getVx(): Float
			return vxVec[vecIndex];

		inline function getVy(): Float
			return vyVec[vecIndex];

		inline function setX(x: Float): Void
			xVec[vecIndex] = x;

		inline function setY(y: Float): Void
			yVec[vecIndex] = y;

		inline function setVx(vx: Float): Void
			vxVec[vecIndex] = vx;

		inline function setVy(vy: Float): Void
			vyVec[vecIndex] = vy;

		inline function addX(x: Float): Void
			xVec[vecIndex] += x;

		inline function addY(y: Float): Void
			yVec[vecIndex] += y;

		inline function addVx(vx: Float): Void
			vxVec[vecIndex] += vx;

		inline function addVy(vy: Float): Void
			vyVec[vecIndex] += vy;

		inline function setPosition(x: Float, y: Float): Void {
			setX(x);
			setY(y);
		}

		inline function addPosition(x: Float, y: Float): Void {
			addX(x);
			addY(y);
		}

		inline function setVelocity(vx: Float, vy: Float): Void {
			setVx(vx);
			setVy(vy);
		}

		inline function addVelocity(vx: Float, vy: Float): Void {
			addVx(vx);
			addVy(vy);
		}

		inline function getDistance(): Float
			return hypot(getX(), getY());

		inline function getBearing(): Float
			return atan2(getY(), getX());

		inline function getSpeed(): Float
			return hypot(getVx(), getVy());

		inline function getDirection(): Float
			return atan2(getVy(), getVx());

		inline function setDistance(value: Float): Void {
			final newPosition = setLength(getX(), getY(), value);
			setPosition(newPosition.x, newPosition.y);
		}

		inline function addDistance(value: Float): Void {
			final newPosition = addLength(getX(), getY(), value);
			setPosition(newPosition.x, newPosition.y);
		}

		inline function setBearing(value: Float): Void {
			final newPosition = setAngle(getX(), getY(), value);
			setPosition(newPosition.x, newPosition.y);
		}

		inline function addBearing(value: Float): Void {
			final newPosition = addAngle(getX(), getY(), value);
			setPosition(newPosition.x, newPosition.y);
		}

		inline function setSpeed(value: Float): Void {
			final newVelocity = setLength(getVx(), getVy(), value);
			setVelocity(newVelocity.x, newVelocity.y);
		}

		inline function addSpeed(value: Float): Void {
			final newVelocity = addLength(getVx(), getVy(), value);
			setVelocity(newVelocity.x, newVelocity.y);
		}

		inline function setDirection(value: Float): Void {
			final newVelocity = setAngle(getVx(), getVy(), value);
			setVelocity(newVelocity.x, newVelocity.y);
		}

		inline function addDirection(value: Float): Void {
			final newVelocity = addAngle(getVx(), getVy(), value);
			setVelocity(newVelocity.x, newVelocity.y);
		}

		#if debug
		var cnt = 0;
		#end

		while (true) {
			#if debug
			if (infiniteLoopCheckThreshold < ++cnt) throw "Detected infinite loop.";
			#end

			switch readOp() {
				case PushInt:
					pushInt(readCodeI32());
				case PeekFloat:
					volFloat = peekFloatSkipped(readCodeI32());
				case DropFloat:
					dropFloat();
				case PeekVec:
					final vec = peekVecSkipped(readCodeI32());
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
				case MultFloatVCS:
					final multiplier = readCodeF64();
					pushFloat(volFloat * multiplier);
				case MultVecVCS:
					final multiplier = readCodeF64();
					pushVec(volX * multiplier, volY * multiplier);
				case SetPositionC:
					setPosition(readCodeF64(), readCodeF64());
				case AddPositionC:
					addPosition(readCodeF64(), readCodeF64());
				case SetVelocityC:
					setVelocity(readCodeF64(), readCodeF64());
				case AddVelocityC:
					addVelocity(readCodeF64(), readCodeF64());
				case SetPositionS:
					final vec = peekVecSkipped(0);
					setPosition(vec.x, vec.y);
				case AddPositionS:
					final vec = peekVecSkipped(0);
					addPosition(vec.x, vec.y);
				case SetVelocityS:
					final vec = peekVecSkipped(0);
					setPosition(vec.x, vec.y);
				case AddVelocityS:
					final vec = peekVecSkipped(0);
					addPosition(vec.x, vec.y);
				case SetPositionV:
					setPosition(volX, volY);
				case AddPositionV:
					addPosition(volX, volY);
				case SetVelocityV:
					setVelocity(volX, volY);
				case AddVelocityV:
					addVelocity(volX, volY);
				case CalcRelativePositionCV:
					volX = readCodeF64() - getX();
					volY = readCodeF64() - getY();
				case CalcRelativeVelocityCV:
					volX = readCodeF64() - getVx();
					volY = readCodeF64() - getVy();
				case SetDistanceC:
					setDistance(readCodeF64());
				case AddDistanceC:
					addDistance(readCodeF64());
				case SetBearingC:
					setBearing(readCodeF64());
				case AddBearingC:
					addBearing(readCodeF64());
				case SetSpeedC:
					setSpeed(readCodeF64());
				case AddSpeedC:
					addSpeed(readCodeF64());
				case SetDirectionC:
					setDirection(readCodeF64());
				case AddDirectionC:
					addDirection(readCodeF64());
				case SetDistanceS:
					setDistance(peekFloat());
				case AddDistanceS:
					addDistance(peekFloat());
				case SetBearingS:
					setBearing(peekFloat());
				case AddBearingS:
					addBearing(peekFloat());
				case SetSpeedS:
					setSpeed(peekFloat());
				case AddSpeedS:
					addSpeed(peekFloat());
				case SetDirectionS:
					setDirection(peekFloat());
				case AddDirectionS:
					addDirection(peekFloat());
				case SetDistanceV:
					setDistance(volFloat);
				case AddDistanceV:
					addDistance(volFloat);
				case SetBearingV:
					setBearing(volFloat);
				case AddBearingV:
					addBearing(volFloat);
				case SetSpeedV:
					setSpeed(volFloat);
				case AddSpeedV:
					addSpeed(volFloat);
				case SetDirectionV:
					setDirection(volFloat);
				case AddDirectionV:
					addDirection(volFloat);
				case CalcRelativeDistanceCV:
					volFloat = readCodeF64() - getDistance();
				case CalcRelativeBearingCV:
					volFloat = readCodeF64() - normalizeAngle(getBearing());
				case CalcRelativeSpeedCV:
					volFloat = readCodeF64() - getSpeed();
				case CalcRelativeDirectionCV:
					volFloat = readCodeF64() - normalizeAngle(getDirection());
				case SetShotPositionC:
					thread.setShotPosition(readCodeF64(), readCodeF64());
				case AddShotPositionC:
					thread.addShotPosition(readCodeF64(), readCodeF64());
				case SetShotVelocityC:
					thread.setShotVelocity(readCodeF64(), readCodeF64());
				case AddShotVelocityC:
					thread.addShotVelocity(readCodeF64(), readCodeF64());
				case SetShotPositionS:
					final vec = peekVecSkipped(0);
					thread.setShotPosition(vec.x, vec.y);
				case AddShotPositionS:
					final vec = peekVecSkipped(0);
					thread.addShotPosition(vec.x, vec.y);
				case SetShotVelocityS:
					final vec = peekVecSkipped(0);
					thread.setShotVelocity(vec.x, vec.y);
				case AddShotVelocityS:
					final vec = peekVecSkipped(0);
					thread.addShotVelocity(vec.x, vec.y);
				case SetShotPositionV:
					thread.setShotPosition(volX, volY);
				case AddShotPositionV:
					thread.addShotPosition(volX, volY);
				case SetShotVelocityV:
					thread.setShotVelocity(volX, volY);
				case AddShotVelocityV:
					thread.addShotVelocity(volX, volY);
				case CalcRelativeShotPositionCV:
					volX = readCodeF64() - thread.shotX;
					volY = readCodeF64() - thread.shotY;
				case CalcRelativeShotVelocityCV:
					volX = readCodeF64() - thread.shotVx;
					volY = readCodeF64() - thread.shotVy;
				case SetShotDistanceC:
					thread.setShotDistance(readCodeF64());
				case AddShotDistanceC:
					thread.addShotDistance(readCodeF64());
				case SetShotBearingC:
					thread.setShotBearing(readCodeF64());
				case AddShotBearingC:
					thread.addShotBearing(readCodeF64());
				case SetShotSpeedC:
					thread.setShotSpeed(readCodeF64());
				case AddShotSpeedC:
					thread.addShotSpeed(readCodeF64());
				case SetShotDirectionC:
					thread.setShotDirection(readCodeF64());
				case AddShotDirectionC:
					thread.addShotDirection(readCodeF64());
				case SetShotDistanceS:
					thread.setShotDistance(peekFloat());
				case AddShotDistanceS:
					thread.addShotDistance(peekFloat());
				case SetShotBearingS:
					thread.setShotBearing(peekFloat());
				case AddShotBearingS:
					thread.addShotBearing(peekFloat());
				case SetShotSpeedS:
					thread.setShotSpeed(peekFloat());
				case AddShotSpeedS:
					thread.addShotSpeed(peekFloat());
				case SetShotDirectionS:
					thread.setShotDirection(peekFloat());
				case AddShotDirectionS:
					thread.addShotDirection(peekFloat());
				case SetShotDistanceV:
					thread.setShotDistance(volFloat);
				case AddShotDistanceV:
					thread.addShotDistance(volFloat);
				case SetShotBearingV:
					thread.setShotBearing(volFloat);
				case AddShotBearingV:
					thread.addShotBearing(volFloat);
				case SetShotSpeedV:
					thread.setShotSpeed(volFloat);
				case AddShotSpeedV:
					thread.addShotSpeed(volFloat);
				case SetShotDirectionV:
					thread.setShotDirection(volFloat);
				case AddShotDirectionV:
					thread.addShotDirection(volFloat);
				case CalcRelativeShotDistanceCV:
					volFloat = readCodeF64() - thread.getShotDistance();
				case CalcRelativeShotBearingCV:
					volFloat = readCodeF64() - normalizeAngle(thread.getShotBearing());
				case CalcRelativeShotSpeedCV:
					volFloat = readCodeF64() - thread.getShotSpeed();
				case CalcRelativeShotDirectionCV:
					volFloat = readCodeF64() - normalizeAngle(thread.getShotDirection());
				case Fire:
					final bytecodeId = readCodeI32();
					final bytecode = if (bytecodeId < 0) Maybe.none() else
						Maybe.none(); // TODO: see table or some kind of that
					emitter.emit(
						xVec[vecIndex] + thread.shotX,
						yVec[vecIndex] + thread.shotY,
						thread.shotVx,
						thread.shotVy,
						bytecode
					);
				case other:
					#if debug
					throw 'Unknown opcode: $other';
					#end
			}

			if (codeLength <= codePos) {
				thread.code = Maybe.none();
				return;
			}
		}

		thread.update(codePos, stackSize);

		println("");
	}

	public static function dryRun(bytecode: Bytecode): Void {
		final thread = new Thread(64);
		thread.set(bytecode, 0, 0, 0, 0);
		final xVec = Vec.fromArrayCopy([0.0]);
		final yVec = Vec.fromArrayCopy([0.0]);
		final vxVec = Vec.fromArrayCopy([0.0]);
		final vyVec = Vec.fromArrayCopy([0.0]);
		final vecIndex = UInt.zero;
		final emitter = new NullEmitter();

		var frame = UInt.zero;

		while (thread.code.isSome()) {
			if (infiniteLoopCheckThreshold < frame)
				throw 'Exceeded $infiniteLoopCheckThreshold frames.';

			println('[frame $frame]');
			Vm.run(thread, xVec, yVec, vxVec, vyVec, vecIndex, emitter);
			++frame;
		}
	}

	static function println(s: String): Void {
		#if firedancer_verbose
		Printer.println(s);
		#end
	}
}

private class NullEmitter implements Emitter {
	public function new() {}

	public function emit(
		x: Float,
		y: Float,
		vx: Float,
		vy: Float,
		code: Maybe<Bytecode>
	): Void {}
}
