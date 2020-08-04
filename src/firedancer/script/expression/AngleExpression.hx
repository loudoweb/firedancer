package firedancer.script.expression;

import firedancer.types.Angle;

/**
	Abstract over `FloatLikeExpressionEnum` that can be implicitly converted from `Angle`.
**/
@:notNull @:forward
abstract AngleExpression(
	FloatLikeExpressionEnum
) from FloatLikeExpressionEnum to FloatLikeExpressionEnum {
	@:from public static extern inline function fromConstantAngle(value: Angle): AngleExpression
		return FloatLikeExpressionEnum.Constant(constantAngle(value));

	@:from static extern inline function fromConstantFloat(value: Float): AngleExpression
		return fromConstantAngle(value);

	@:from static extern inline function fromConstantInt(value: Int): AngleExpression
		return fromConstantAngle(value);

	@:op(A + B)
	static extern inline function add(
		a: AngleExpression,
		b: AngleExpression
	): AngleExpression {
		return a.add(b);
	}

	@:op(A - B)
	static extern inline function subtract(
		a: AngleExpression,
		b: AngleExpression
	): AngleExpression {
		return a.subtract(b);
	}

	@:op(A * B) @:commutative
	static extern inline function multiply(
		expr: AngleExpression,
		factor: FloatExpression
	): AngleExpression {
		return expr.multiply(factor);
	}

	@:op(A / B)
	extern inline function divide(divisor: FloatExpression): AngleExpression
		return this.divide(divisor);

	public extern inline function toEnum(): FloatLikeExpressionEnum
		return this;
}
