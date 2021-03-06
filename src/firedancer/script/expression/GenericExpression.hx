package firedancer.script.expression;

import firedancer.assembly.Instruction;
import firedancer.assembly.AssemblyCode;

abstract GenericExpression(Data) from Data {
	@:from
	static extern inline function fromIntExpr(expr: IntExpression): GenericExpression
		return IntExpr(expr);

	@:from
	static extern inline function fromFloatExpr(expr: FloatExpression): GenericExpression
		return FloatExpr(expr);

	@:from
	static extern inline function fromAngleExpr(expr: AngleExpression): GenericExpression
		return AngleExpr(expr);

	@:from
	static extern inline function fromVecExpr(expr: VecExpression): GenericExpression
		return VecExpr(expr);

	@:to function toIntExpr(): IntExpression {
		return switch this {
		case IntExpr(expr): expr;
		case FloatExpr(_): throw "Cannot cast FloatExpression to IntExpression.";
		case AngleExpr(_): throw "Cannot cast AngleExpression to IntExpression.";
		case VecExpr(_): throw "Cannot cast VecExpression to IntExpression.";
		}
	}

	@:to function toFloatExpr(): FloatExpression {
		return switch this {
		case IntExpr(expr): expr;
		case FloatExpr(expr): expr;
		case AngleExpr(_): throw "Cannot cast AngleExpression to FloatExpression.";
		case VecExpr(_): throw "Cannot cast VecExpression to FloatExpression.";
		}
	}

	@:to function toAngleExpr(): AngleExpression {
		return switch this {
		case IntExpr(expr): expr;
		case FloatExpr(_): throw "Cannot cast AngleExpression to FloatExpression.";
		case AngleExpr(expr): expr;
		case VecExpr(_): throw "Cannot cast VecExpression to AngleExpression.";
		}
	}

	@:to function toVecExpr(): VecExpression {
		return switch this {
		case IntExpr(_): throw "Cannot cast IntExpression to VecExpression.";
		case FloatExpr(_): throw "Cannot cast FloatExpression to VecExpression.";
		case AngleExpr(_): throw "Cannot cast AngleExpression to VecExpression.";
		case VecExpr(expr): expr;
		}
	}

	/**
		Creates an `AssemblyCode` that assigns `this` value to the register.
	**/
	public function load(context: CompileContext): AssemblyCode {
		return switch this {
		case IntExpr(expr): expr.load(context);
		case FloatExpr(expr): expr.load(context);
		case AngleExpr(expr): expr.load(context);
		case VecExpr(expr): expr.load(context);
		}
	}

	/**
		Creates an `AssemblyCode` that runs `instruction`
		receiving `this` value as argument.
	**/
	public function use(context: CompileContext, instruction: Instruction): AssemblyCode {
		return switch this {
		case IntExpr(expr): expr.use(context, instruction);
		case FloatExpr(expr): expr.use(context, instruction);
		case AngleExpr(expr): expr.use(context, instruction);
		case VecExpr(expr): expr.use(context, instruction);
		}
	}

	public extern inline function toEnum(): Data
		return this;
}

private enum Data {
	IntExpr(expr: IntExpression);
	FloatExpr(expr: FloatExpression);
	AngleExpr(expr: AngleExpression);
	VecExpr(expr: VecExpression);
}
