package firedancer.script.expression.subtypes;

import firedancer.assembly.AssemblyCode;

typedef FloatLikeRuntimeExpressionEnum = RuntimeExpressionEnum<FloatLikeConstant, FloatLikeExpressionData>;

/**
	Abstract over `FloatLikeRuntimeExpressionEnum`.
**/
@:notNull @:forward
abstract FloatLikeRuntimeExpression(
	FloatLikeRuntimeExpressionEnum
) from FloatLikeRuntimeExpressionEnum to FloatLikeRuntimeExpressionEnum {
	@:to public function toString(): String {
		return switch this {
		case Inst(loadV):
			'Inst(${loadV.toString()})';
		case UnaryOperation(_, operand):
			'UnOp(${operand.toString()})';
		case BinaryOperation(_, operandA, operandB):
			'BiOp(${operandA.toString()}, ${operandB.toString()})';
		case Custom(_):
			"Custom";
		}
	}

	/**
		Creates an `AssemblyCode` that assigns `this` value to the float register.
	**/
	public function load(context: CompileContext): AssemblyCode {
		return switch this {
		case Inst(loadV):
			loadV;

		case UnaryOperation(instruction, operandExpr):
			final code = operandExpr.load(context);
			code.push(instruction);
			code;

		case BinaryOperation(instruction, operandExprA, operandExprB):
			final code:AssemblyCode = [];
			code.pushFromArray(operandExprB.load(context));
			code.push(Push(Float(Reg)));
			code.pushFromArray(operandExprA.load(context));
			code.push(Save(Float(Reg)));
			code.push(Pop(Float));
			code.push(instruction);
			code;

		case Custom(load):
			load(context);
		}
	}

	public extern inline function toEnum(): FloatLikeRuntimeExpressionEnum
		return this;
}
