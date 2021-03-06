package firedancer.assembly.types;

import firedancer.vm.FireArgument;
import firedancer.vm.Constants.*;

@:using(firedancer.assembly.types.FireType.FireTypeExtension)
enum FireType {
	Simple;
	Complex(fireArgument: FireArgument);
	SimpleWithCode(fireCode: Int);
	ComplexWithCode(fireArgument: FireArgument, fireCode: Int);
}

class FireTypeExtension {
	public static function toString(_this: FireType): String {
		return switch _this {
		case Simple: "fire";
		case Complex(fireArgument): 'fire ${fireArgument.toString()}';
		case SimpleWithCode(fireCode): 'fire code $fireCode';
		case ComplexWithCode(fireArgument, fireCode): 'fire ${fireArgument.toString()} code $fireCode';
		}
	}

	public static function bytecodeLength(_this: FireType): UInt {
		return switch _this {
		case Simple: UInt.zero;
		case Complex(_): IntSize;
		case SimpleWithCode(_): IntSize;
		case ComplexWithCode(_, _): IntSize + IntSize;
		}
	}
}
