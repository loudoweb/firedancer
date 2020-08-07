package firedancer.script.expression;

import firedancer.assembly.Opcode;
import firedancer.assembly.Opcode.*;
import firedancer.assembly.AssemblyStatement;
import firedancer.assembly.AssemblyCode;
import firedancer.script.expression.subtypes.IntLikeRuntimeExpression;
import firedancer.script.expression.subtypes.IntLikeConstant;
import firedancer.script.expression.subtypes.UnaryOperator;
import firedancer.script.expression.subtypes.BinaryOperator;

enum IntLikeExpressionEnum {
	Constant(value: IntLikeConstant);
	Runtime(expression: IntLikeRuntimeExpression);
}

/**
	Expression representing any float value.
**/
@:structInit
class IntLikeExpressionData implements ExpressionData {
	public static extern inline function create(
		data: IntLikeExpressionEnum
	): IntLikeExpressionData {
		return { data: data };
	}

	public final data: IntLikeExpressionEnum;

	/**
		Creates an `AssemblyCode` that assigns `this` value to the current volatile float.
	**/
	public function loadToVolatile(): AssemblyCode {
		return switch this.data {
			case Constant(value):
				new AssemblyStatement(calc(LoadIntCV), [value.toOperand()]);
			case Runtime(expression):
				expression.loadToVolatile();
		}
	}

	/**
		Creates an `AssemblyCode` that runs either `constantOpcode` or `volatileOpcode`
		receiving `this` value as argument.
	**/
	public function use(constantOpcode: Opcode, volatileOpcode: Opcode): AssemblyCode {
		return switch this.data {
			case Constant(value):
				new AssemblyStatement(constantOpcode, [value.toOperand()]);
			case Runtime(expression):
				final code = expression.loadToVolatile();
				code.push(new AssemblyStatement(volatileOpcode, []));
				code;
		}
	}

	public function unaryOperation(
		type: UnaryOperator<Int>
	): IntLikeExpressionData {
		return create(Runtime(IntLikeRuntimeExpressionEnum.UnaryOperation(
			type,
			this
		)));
	}

	public function binaryOperation(
		type: BinaryOperator<Int>,
		otherOperand: IntLikeExpressionData
	): IntLikeExpressionData {
		return create(Runtime(IntLikeRuntimeExpressionEnum.BinaryOperation(
			type,
			this,
			otherOperand
		)));
	}

	public function unaryMinus(): IntLikeExpressionData {
		return unaryOperation({
			constantOperator: Immediate(v -> -v),
			runtimeOperator: calc(MinusIntV)
		});
	}

	public function add(other: IntLikeExpressionData): IntLikeExpressionData {
		return binaryOperation({
			operateConstants: (a, b) -> a + b,
			operateVCV: calc(AddIntVCV),
			operateCVV: calc(AddIntVCV),
			operateVVV: calc(AddIntVVV)
		}, other);
	}

	public function subtract(other: IntLikeExpressionData): IntLikeExpressionData {
		return binaryOperation({
			operateConstants: (a, b) -> a - b,
			operateVCV: calc(SubIntVCV),
			operateCVV: calc(SubIntCVV),
			operateVVV: calc(SubIntVVV)
		}, other);
	}

	public function multiply(other: IntLikeExpressionData): IntLikeExpressionData {
		return binaryOperation({
			operateConstants: (a, b) -> a * b,
			operateVCV: calc(MultIntVCV),
			operateCVV: calc(MultIntVCV),
			operateVVV: calc(MultIntVVV)
		}, other);
	}

	public function divide(other: IntLikeExpressionData): IntLikeExpressionData {
		return binaryOperation({
			operateConstants: (a, b) -> Ints.divide(a, b),
			operateVCV: calc(DivIntVCV),
			operateCVV: calc(DivIntCVV),
			operateVVV: calc(DivIntVVV)
		}, other);
	}

	public function modulo(other: IntLikeExpressionData): IntLikeExpressionData {
		return binaryOperation({
			operateConstants: (a, b) -> a % b,
			operateVCV: calc(ModIntVCV),
			operateCVV: calc(ModIntCVV),
			operateVVV: calc(ModIntVVV)
		}, other);
	}

	public extern inline function toEnum()
		return this.data;
}