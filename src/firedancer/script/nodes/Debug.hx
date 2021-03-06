package firedancer.script.nodes;

import firedancer.vm.DebugCode;

/**
	Runs debug process specified by `debugCode`.
**/
@:ripper_verified
class Debug extends AstNode implements ripper.Data {
	final debugCode: DebugCode;

	override inline function containsWait(): Bool
		return false;

	override function toAssembly(context: CompileContext): AssemblyCode {
		return [Debug(debugCode)];
	}
}
