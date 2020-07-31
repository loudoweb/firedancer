package firedancer.script;

import firedancer.types.NInt;
import firedancer.bytecode.RuntimeContext;
import firedancer.script.nodes.*;
import firedancer.script.api_components.Position;
import firedancer.script.api_components.Velocity;
import firedancer.script.api_components.Shot;
#if debug
import sneaker.print.Printer.println;
#end

class Api {
	/**
		Provides functions for operating position.
	**/
	public static final position = new Position();

	/**
		Provides functions for operating the length of position vector.
	**/
	public static final distance = new Distance();

	/**
		Provides functions for operating the angle of position vector.
	**/
	public static final bearing = new Bearing();

	/**
		Provides functions for operating velocity.
	**/
	public static final velocity = new Velocity();

	/**
		Provides functions for operating the length of velocity vector.
	**/
	public static final speed = new Speed();

	/**
		Provides functions for operating the angle of velocity vector.
	**/
	public static final direction = new Direction();

	/**
		Provides functions for operating shot position/velocity.
	**/
	public static final shot = new Shot();

	/**
		Waits `frames`.
	**/
	public static inline function wait(frames: NInt): Wait
		return new Wait(frames);

	/**
		Repeats the given pattern.
		Use `count()` to make a finite loop. Otherwise the loop runs endlessly.
	**/
	public static inline function loop(ast: Ast): Loop
		return new Loop(ast);

	/**
		Emits a new actor with a pattern represented by the given `ast`.
	**/
	public static inline function fire(?ast: Ast): Fire {
		return new Fire(Maybe.from(ast));
	}

	/**
		Sets shot direction to the bearing to the target position.
	**/
	public static inline function aim(): Aim {
		return new Aim();
	}

	/**
		Runs `ast` each frame within the current node list.
	**/
	public static inline function eachFrame(ast: Ast): EachFrame {
		return new EachFrame(ast);
	}

	/**
		Runs any pattern in another thread.

		The initial shot position/veocity are the same as that in the current thread,
		but any change to shot position/velocity does not affect other threads.
	**/
	public static inline function async(ast: Ast): Async {
		return new Async(ast);
	}

	/**
		Compiles `Ast` or `AstNode` into `Bytecode`.
	**/
	public static inline function compile(namedAstMap: Map<String, Ast>): RuntimeContext {
		final compileContext = new CompileContext();

		for (name => ast in namedAstMap) {
			final assemblyCode = ast.toAssembly(compileContext);
			compileContext.setNamedCode(assemblyCode, name);
			#if debug
			println('[ASSEMBLY]\n${assemblyCode.toString()}\n');
			#end
		}

		return compileContext.createRuntimeContext();
	}
}
