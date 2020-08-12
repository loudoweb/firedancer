package firedancer.script.expression;

import firedancer.assembly.Opcode.calc;
import firedancer.script.nodes.DeclareLocalVariable;
import firedancer.script.nodes.OperateLocalVariable;

@:access(firedancer.script.expression.FloatExpression)
abstract FloatLocalVariableExpression(String) {
	public extern inline function new(name: String)
		this = name;

	@:to function toFloatExpression(): FloatExpression {
		return FloatExpression.fromEnum(FloatLikeExpressionEnum.Runtime(Custom(context -> {
			final variable = context.localVariables.get(this);
			final code = variable.loadToVolatile();
			switch variable.type {
				case Int: code.pushStatement(calc(CastIntToFloatVV));
				case Float:
				case Vec: throw "Cannot cast vector to float.";
			}
			code;
		})));
	}

	@:op(-A)
	extern inline function unaryMinus(): FloatExpression
		return get().unaryMinus();

	@:op(A + B) @:commutative
	static extern inline function addOp(
		a: FloatLocalVariableExpression,
		b: FloatExpression
	): FloatExpression {
		return a.get().add(b);
	}

	@:op(A - B)
	static extern inline function subtract(
		a: FloatLocalVariableExpression,
		b: FloatExpression
	): FloatExpression {
		return a.get().subtract(b);
	}

	@:op(A - B)
	static extern inline function subtractR(
		a: FloatExpression,
		b: FloatLocalVariableExpression
	): FloatExpression {
		return a.subtract(b);
	}

	@:op(A * B) @:commutative
	static extern inline function multiply(
		a: FloatLocalVariableExpression,
		b: FloatExpression
	): FloatExpression {
		return a.get().multiply(b);
	}

	@:op(A / B)
	static extern inline function divide(
		a: FloatLocalVariableExpression,
		b: FloatExpression
	): FloatExpression {
		return a.get().divide(b);
	}

	@:op(A / B)
	static extern inline function divideR(
		a: FloatExpression,
		b: FloatLocalVariableExpression
	): FloatExpression {
		return a.divide(b);
	}

	@:op(A % B)
	static extern inline function modulo(
		a: FloatLocalVariableExpression,
		b: FloatExpression
	): FloatExpression {
		return a.get().modulo(b);
	}

	@:op(A % B)
	static extern inline function moduloR(
		a: FloatExpression,
		b: FloatLocalVariableExpression
	): FloatExpression {
		return a.modulo(b);
	}

	public function let(?initialValue: FloatExpression): DeclareLocalVariable {
		return DeclareLocalVariable.fromFloat(this, initialValue);
	}

	public function set(value: FloatExpression): OperateLocalVariable
		return { name: this, value: value, operation: Set };

	public function add(value: FloatExpression): OperateLocalVariable
		return { name: this, value: value, operation: Add };

	function get()
		return toFloatExpression();
}
