package firedancer.assembly.operation;

/**
	Value that specifies a general operation.
**/
@:using(firedancer.assembly.operation.GeneralOperation.GeneralOperationExtension)
enum abstract GeneralOperation(Int) to Int {
	static function error(v: Int): String
		return 'Unknown general operation: $v';

	/**
		Converts `value` to `GeneralOperation`.
		Throws error if `value` does not match any `GeneralOperation` values.
	**/
	public static inline function from(value: Int): GeneralOperation {
		return switch value {
			case GeneralOperation.Break: Break;
			case GeneralOperation.CountDownBreak: CountDownBreak;
			case GeneralOperation.Jump: Jump;
			case GeneralOperation.CountDownJump: CountDownJump;
			case GeneralOperation.UseThread: UseThread;
			case GeneralOperation.UseThreadS: UseThreadS;
			case GeneralOperation.AwaitThread: AwaitThread;
			case GeneralOperation.End: End;
			case GeneralOperation.PushIntC: PushIntC;
			case GeneralOperation.PushFloatC: PushFloatC;
			case GeneralOperation.PushFloatV: PushFloatV;
			case GeneralOperation.PeekFloat: PeekFloat;
			case GeneralOperation.DropFloat: DropFloat;
			case GeneralOperation.PeekVec: PeekVec;
			case GeneralOperation.DropVec: DropVec;
			case GeneralOperation.LoadFloatCV: LoadFloatCV;
			case GeneralOperation.LoadVecCV: LoadVecCV;
			case GeneralOperation.LoadVecXCV: LoadVecXCV;
			case GeneralOperation.LoadVecYCV: LoadVecYCV;
			case GeneralOperation.AddFloatVCV: AddFloatVCV;
			case GeneralOperation.AddFloatVVV: AddFloatVVV;
			case GeneralOperation.SubFloatVCV: SubFloatVCV;
			case GeneralOperation.SubFloatCVV: SubFloatCVV;
			case GeneralOperation.SubFloatVVV: SubFloatVVV;
			case GeneralOperation.MinusFloatV: MinusFloatV;
			case GeneralOperation.MultFloatVCV: MultFloatVCV;
			case GeneralOperation.MultFloatVVV: MultFloatVVV;
			case GeneralOperation.MultFloatVCS: MultFloatVCS;
			case GeneralOperation.DivFloatCVV: DivFloatCVV;
			case GeneralOperation.DivFloatVVV: DivFloatVVV;
			case GeneralOperation.ModFloatVCV: ModFloatVCV;
			case GeneralOperation.ModFloatCVV: ModFloatCVV;
			case GeneralOperation.ModFloatVVV: ModFloatVVV;
			case GeneralOperation.MinusVecV: MinusVecV;
			case GeneralOperation.MultVecVCS: MultVecVCS;
			case GeneralOperation.SaveFloatV: SaveFloatV;
			case GeneralOperation.CastCartesianVV: CastCartesianVV;
			case GeneralOperation.CastPolarVV: CastPolarVV;
			case GeneralOperation.RandomFloatCV: RandomFloatCV;
			case GeneralOperation.RandomFloatVV: RandomFloatVV;
			case GeneralOperation.RandomFloatSignedCV: RandomFloatSignedCV;
			case GeneralOperation.RandomFloatSignedVV: RandomFloatSignedVV;
			case GeneralOperation.Fire: Fire;
			case GeneralOperation.FireWithType: FireWithType;
			default: throw error(value);
		}
	}

	// ---- control flow --------------------------------------------------------

	/**
		Breaks the current frame.
	**/
	final Break;

	/**
		Peeks the top integer (which should be the remaining loop count) from the stack
		and checks if it is zero.
		- If not zero, decrements the loop counter at the stack top and breaks the current frame.
		  The next frame will begin with this `CountDownBreak` opcode again.
		- If zero, drops the loop counter from the stack and goes to next.
	**/
	final CountDownBreak;

	/**
		Adds a given constant value to the current bytecode position.
	**/
	final Jump;

	/**
		Peeks the top integer (which should be the remaining loop count) from the stack
		and checks if it is zero.
		- If not zero, decrements the loop counter at the stack top and goes to next.
		- If zero, drops the loop counter from the stack and
			adds a given constant value to the current bytecode position.
	**/
	final CountDownJump;

	/**
		Activates a new thread with bytecode ID specified by a given constant integer.
	**/
	final UseThread;

	/**
		Activates a new thread with bytecode ID specified by a given constant integer,
		then pushes the thread ID to the stack.
	**/
	final UseThreadS;

	/**
		Peeks the top integer (which should be a thread ID) from the stack
		and checks if the thread is currently active.
		- If active, breaks the current frame.
		  The next frame will begin with this `AwaitThread` opcode again.
		- If not active, drops the thread ID from the stack and goes to next.
	**/
	final AwaitThread;

	/**
		Ends running bytecode and returns an end code specified by a given constant integer.
	**/
	final End;

	// ---- read/write/calc values ----------------------------------------------

	/**
		Pushes a given constant integer to the stack top.
	**/
	final PushIntC;

	/**
		Pushes a given constant float to the stack top.
	**/
	final PushFloatC;

	/**
		Pushes the current volatile float to the stack top.
	**/
	final PushFloatV;

	/**
		Reads a float at the stack top (skipping a given constant bytes from the top)
		and assigns it to the volatile float.
	**/
	final PeekFloat;

	/**
		Drops float from the stack top.
	**/
	final DropFloat;

	/**
		Reads a vector at the stack top (skipping a given constant bytes from the top)
		and assigns it to the volatile vector.
	**/
	final PeekVec;

	/**
		Drops vector from the stack top.
	**/
	final DropVec;

	/**
		Assigns a given constant float to the current volatile float.
	**/
	final LoadFloatCV;

	/**
		Assigns given constant float values to the current volatile vector.
	**/
	final LoadVecCV;

	/**
		Assigns a given constant float to the x-component of the current volatile vector.
	**/
	final LoadVecXCV;

	/**
		Assigns a given constant float to the y-component of the current volatile vector.
	**/
	final LoadVecYCV;

	/**
		Adds a given constant float to the current volatile float.
	**/
	final AddFloatVCV;

	/**
		Adds the last saved volatile float to the current volatile float.
	**/
	final AddFloatVVV;

	/**
		Subtracts a given constant float from the current volatile float.
	**/
	final SubFloatVCV;

	/**
		Subtracts the current volatile float from a given constant float and assigns it to the volatile float.
	**/
	final SubFloatCVV;

	/**
		Subtracts the current volatile float from the last saved volatile float and assigns it to the volatile float.
	**/
	final SubFloatVVV;

	/**
		Changes the sign of the current volatile float.
	**/
	final MinusFloatV;

	/**
		Multiplies the current volatile float by a given constant float.
	**/
	final MultFloatVCV;

	/**
		Multiplies the last saved volatile float and the current volatile float, and reassigns it to the volatile float.
	**/
	final MultFloatVVV;

	/**
		Multiplicates the current volatile float by a given constant float and pushes it to the stack top.
	**/
	final MultFloatVCS;

	/**
		Divides a given constant float by the current volatile float and reassigns it to the volatile float.
	**/
	final DivFloatCVV;

	/**
		Divides the last saved volatile float by the current volatile float, and reassigns it to the volatile float.
	**/
	final DivFloatVVV;

	/**
		Divides the current volatile float by a given constant float and assigns the modulo to the volatile float.
	**/
	final ModFloatVCV;

	/**
		Divides a given constant float by the current volatile float and assigns the modulo to the volatile float.
	**/
	final ModFloatCVV;

	/**
		Divides the last saved volatile float by the current volatile float, and assigns the modulo to the volatile float.
	**/
	final ModFloatVVV;

	/**
		Changes the sign of the current volatile vector.
	**/
	final MinusVecV;

	/**
		Multiplicates the current volatile vector by a given constant float and pushes it to the stack top.
	**/
	final MultVecVCS;

	/**
		Saves the current volatile float.
	**/
	final SaveFloatV;

	/**
		Interprets the last saved volatile float as `x` and the current volatile float as `y`,
		and assigns them to the volatile vector.
	**/
	final CastCartesianVV;

	/**
		Interprets the last saved volatile float as `length` and the current volatile float as `angle`,
		and assigns their cartesian representation to the volatile vector.
	**/
	final CastPolarVV;

	/**
		Multiplies the given constant float by a random value in range `[0, 1)`
		and assigns it to the volatile float.
	**/
	final RandomFloatCV;

	/**
		Multiplies the current volatile float by a random value in range `[0, 1)`
		and reassigns it to the volatile float.
	**/
	final RandomFloatVV;

	/**
		Multiplies the given constant float by a random value in range `[-1, 1)`
		and assigns it to the volatile float.
	**/
	final RandomFloatSignedCV;

	/**
		Multiplies the current volatile float by a random value in range `[-1, 1)`
		and reassigns it to the volatile float.
	**/
	final RandomFloatSignedVV;


	// ---- other operations ----------------------------------------------------

	/**
		Emits a new actor with a default type.

		Argument:
		- (int) Bytecode ID, or any negative value to emit without bytecode
	**/
	final Fire;

	/**
		Emits a new actor with a specified type.

		Arguments:
		1. (int) Bytecode ID, or any negative value to emit without bytecode
		2. (int) Fire type
	**/
	final FireWithType;

	public extern inline function int(): Int
		return this;
}

class GeneralOperationExtension {
	/**
		@return The mnemonic for `code`.
	**/
	public static inline function toString(code: GeneralOperation): String {
		return switch code {
			case Break: "break";
			case CountDownBreak: "count_down_break";
			case Jump: "jump";
			case CountDownJump: "count_down_jump";
			case UseThread: "use_thread";
			case UseThreadS: "use_thread_s";
			case AwaitThread: "await_thread";
			case End: "end";
			case PushIntC: "push_int_c";
			case PushFloatC: "push_float_c";
			case PushFloatV: "push_float_v";
			case PeekFloat: "peek_float";
			case DropFloat: "drop_float";
			case PeekVec: "peek_vec";
			case DropVec: "drop_vec";
			case LoadFloatCV: "load_float_cv";
			case LoadVecCV: "load_vec_cv";
			case LoadVecXCV: "load_vec_x_cv";
			case LoadVecYCV: "load_vec_y_cv";
			case AddFloatVCV: "add_float_vcv";
			case AddFloatVVV: "add_float_vvv";
			case SubFloatVCV: "sub_float_vcv";
			case SubFloatCVV: "sub_float_cvv";
			case SubFloatVVV: "sub_float_vvv";
			case MinusFloatV: "minus_float_v";
			case MultFloatVCV: "mult_float_vcv";
			case MultFloatVVV: "mult_float_vvv";
			case MultFloatVCS: "mult_float_vcs";
			case ModFloatVCV: "mod_float_vcv";
			case ModFloatCVV: "mod_float_cvv";
			case ModFloatVVV: "mod_float_vvv";
			case DivFloatCVV: "div_float_cvv";
			case DivFloatVVV: "div_float_vvv";
			case MinusVecV: "minus_vec_v";
			case MultVecVCS: "mult_vec_vcs";
			case SaveFloatV: "save_float_v";
			case CastCartesianVV: "cast_cartesian_vv";
			case CastPolarVV: "cast_polar_vv";
			case RandomFloatCV: "random_float_cv";
			case RandomFloatVV: "random_float_vv";
			case RandomFloatSignedCV: "random_float_signed_cv";
			case RandomFloatSignedVV: "random_float_signed_vv";
			case Fire: "fire";
			case FireWithType: "fire_with_type";
		}
	}

	/**
		Creates a `StatementType` instance that corresponds to `op`.
	**/
	public static inline function toStatementType(op: GeneralOperation): StatementType {
		return switch op {
			case Break: [];
			case CountDownBreak: [];
			case Jump: [Int]; // bytecode length to jump
			case CountDownJump: [Int]; // bytecode length to jump
			case UseThread | UseThreadS: [Int]; // bytecode ID
			case AwaitThread: [];
			case End: [Int]; // end code
			case PushIntC: [Int]; // integer to push
			case PushFloatC: [Float]; // float to push
			case PushFloatV: [];
			case PeekFloat | PeekVec: [Int]; // bytes to be skipped from the stack top
			case DropFloat | DropVec: [];
			case LoadFloatCV: [Float];
			case LoadVecCV: [Vec];
			case LoadVecXCV | LoadVecYCV: [Float];
			case AddFloatVCV: [Float]; // value to add
			case AddFloatVVV: [];
			case SubFloatVCV: [Float]; // value to subtract
			case SubFloatCVV: [Float]; // value from which to subtract
			case SubFloatVVV: [];
			case MinusFloatV: [];
			case MultFloatVVV: [];
			case MultFloatVCV | MultFloatVCS: [Float]; // multiplier value
			case ModFloatVCV: [Float]; // divisor
			case ModFloatCVV: [Float]; // value to be divided
			case ModFloatVVV: [];
			case DivFloatCVV: [Float]; // value to be divided
			case DivFloatVVV: [];
			case MinusVecV: [];
			case MultVecVCS: [Float]; // multiplier value
			case SaveFloatV: [];
			case CastCartesianVV | CastPolarVV: [];
			case RandomFloatCV: [Float];
			case RandomFloatVV: [];
			case RandomFloatSignedCV: [Float];
			case RandomFloatSignedVV: [];
			case Fire: [Int]; // bytecode ID or negative for null
			case FireWithType: [Int, Int]; // 1. bytecode ID or negative for null, 2. Fire type
		}
	}

	/**
		@return The bytecode length in bytes required for a statement with `op`.
	**/
	public static inline function getBytecodeLength(op: GeneralOperation): UInt
		return toStatementType(op).bytecodeLength();
}
