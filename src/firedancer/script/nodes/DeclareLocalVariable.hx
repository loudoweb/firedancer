package firedancer.script.nodes;

import firedancer.assembly.Instruction;
import firedancer.script.expression.AngleExpression;
import firedancer.script.expression.FloatExpression;
import firedancer.script.expression.IntExpression;
import firedancer.assembly.ValueType;
import firedancer.script.expression.GenericExpression;

/**
	Declares a local variable.
**/
class DeclareLocalVariable extends AstNode {
	public static function fromInt(name: String, ?initialValue: IntExpression): DeclareLocalVariable {
		if (initialValue == null) {
			initialValue = 0;
		}
		return new DeclareLocalVariable(name, initialValue);
	}

	public static function fromFloat(name: String, ?initialValue: FloatExpression): DeclareLocalVariable {
		if (initialValue == null) {
			initialValue = 0.0;
		}
		return new DeclareLocalVariable(name, initialValue);
	}

	public static function fromAngle(name: String, ?initialValue: AngleExpression): DeclareLocalVariable {
		if (initialValue == null) {
			initialValue = 0.0;
		}
		return new DeclareLocalVariable(name, initialValue);
	}

	final name: String;
	final initialValue: GenericExpression;

	public function new(name: String, initialValue: GenericExpression) {
		this.name = name;
		this.initialValue = initialValue;
	}

	override public inline function containsWait(): Bool
		return false;

	override public function toAssembly(context: CompileContext): AssemblyCode {
		inline function getAddress(valueType: ValueType): UInt
			return context.localVariables.push(this.name, valueType);

		final storeRL: Instruction = switch initialValue.toEnum() {
			case IntExpr(_):
				Store(Int(Reg), getAddress(Int));
			case FloatExpr(_) | AngleExpr(_):
				Store(Float(Reg), getAddress(Float));
			case VecExpr(_):
				throw "Local variable of vector type is not supported.";
		}

		return {
			[
				initialValue.loadToVolatile(context),
				[storeRL]
			].flatten();
		}
	}
}
