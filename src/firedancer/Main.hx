package firedancer;

import sneaker.print.Printer.println;
import firedancer.types.NInt;
import firedancer.types.Azimuth;
import firedancer.ast.Ast;
import firedancer.ast.nodes.*;
import firedancer.ast.nodes.OperateVecConst;
import firedancer.bytecode.Bytecode;

class Main {
	/**
		Provides functions for operating position.
	**/
	public static final position = new Position();

	/**
		Provides functions for operating velocity.
	**/
	public static final velocity = new Velocity();

	/**
		Provides functions for operating shot position/velocity.
	**/
	public static final shot = new Shot();

	/**
		Waits `frames`.
	**/
	public static inline function wait(frames: NInt)
		return new Wait(frames);

	/**
		Repeats the given pattern.
		Use `count()` to make a finite loop. Otherwise the loop runs endlessly.
	**/
	public static inline function loop(ast: Ast): Loop
		return new Loop(ast);

	/**
		Compiles `Ast` or `AstNode` into `Bytecode`.
	**/
	public static inline function compile(ast: Ast): Bytecode {
		final assemblyCode = ast.toAssembly();
		final bytecode = assemblyCode.compile();
		#if debug
		println('[ASSEMBLY]\n${assemblyCode.toString()}\n');
		println('[BYTECODE]\n${bytecode.toHex()}\n');
		#end
		return bytecode;
	}
}

private class Position {
	/**
		Provides functions for operating position in polar coordinates.
	**/
	public final polar = new PolarPosition();

	public function new() {}

	/**
		Sets position to `(x, y)`.
	**/
	public inline function set(x: Float, y: Float)
		return new OperateVectorConst(SetPositionConst, x, y);

	/**
		Adds `(x, y)` to position.
	**/
	public inline function add(x: Float, y: Float)
		return new OperateVectorConst(AddPositionConst, x, y);
}

private class PolarPosition {
	public function new() {}

	/**
		Sets position to `(distance, bearing)`.
	**/
	public inline function set(distance: Float, bearing: Azimuth) {
		return new OperateVectorConst(
			SetPositionConst,
			distance * bearing.cos(),
			distance * bearing.sin()
		);
	}

	/**
		Adds a vector of `(distance, bearing)` to position.
	**/
	public inline function add(distance: Float, bearing: Azimuth) {
		return new OperateVectorConst(
			AddPositionConst,
			distance * bearing.cos(),
			distance * bearing.sin()
		);
	}
}

private class Velocity {
	/**
		Provides functions for operating velocity in polar coordinates.
	**/
	public final polar = new PolarVelocity();

	public function new() {}

	/**
		Sets velocity to `(vx, vy)`.
	**/
	public inline function set(vx: Float, vy: Float)
		return new OperateVectorConst(SetVelocityConst, vx, vy);

	/**
		Adds `(x, y)` to velocity.
	**/
	public inline function add(x: Float, y: Float)
		return new OperateVectorConst(AddVelocityConst, x, y);
}

private class PolarVelocity {
	public function new() {}

	/**
		Sets velocity to `(speed, direction)`.
	**/
	public inline function set(speed: Float, direction: Azimuth) {
		return new OperateVectorConst(
			SetVelocityConst,
			speed * direction.cos(),
			speed * direction.sin()
		);
	}

	/**
		Adds a vector of `(speed, direction)` to velocity.
	**/
	public inline function add(speed: Float, direction: Azimuth) {
		return new OperateVectorConst(
			AddVelocityConst,
			speed * direction.cos(),
			speed * direction.sin()
		);
	}
}

private class Shot {
	public function new() {}

	/**
		Provides functions for operating shot position.
	**/
	public final position = new ShotPosition();

	/**
		Provides functions for operating shot velocity.
	**/
	public final velocity = new ShotVelocity();
}

private class ShotPosition {
	/**
		Provides functions for operating shot position in polar coordinates.
	**/
	public final polar = new PolarShotPosition();

	public function new() {}

	/**
		Sets shot position to `(x, y)`.
	**/
	public inline function set(x: Float, y: Float)
		throw "Not yet implemented."; // TODO: implement

	/**
		Adds `(x, y)` to shot position.
	**/
	public inline function add(x: Float, y: Float)
		throw "Not yet implemented."; // TODO: implement

}

private class PolarShotPosition {
	public function new() {}

	/**
		Sets shot position to `(distance, bearing)`.
	**/
	public inline function set(distance: Float, bearing: Azimuth) {
		throw "Not yet implemented."; // TODO: implement
	}

	/**
		Adds a vector of `(distance, bearing)` to shot position.
	**/
	public inline function add(distance: Float, bearing: Azimuth) {
		throw "Not yet implemented."; // TODO: implement
	}
}

private class ShotVelocity {
	/**
		Provides functions for operating shot velocity in polar coordinates.
	**/
	public final polar = new PolarShotVelocity();

	public function new() {}

	/**
		Sets shot velocity to `(vx, vy)`.
	**/
	public inline function set(vx: Float, vy: Float)
		throw "Not yet implemented."; // TODO: implement

	/**
		Adds `(x, y)` to shot velocity.
	**/
	public inline function add(x: Float, y: Float)
		throw "Not yet implemented."; // TODO: implement

}

private class PolarShotVelocity {
	public function new() {}

	/**
		Sets shot velocity to `(speed, direction)`.
	**/
	public inline function set(speed: Float, direction: Azimuth) {
		throw "Not yet implemented."; // TODO: implement
	}

	/**
		Adds a vector of `(distance, bearing)` to shot velocity.
	**/
	public inline function add(distance: Float, bearing: Azimuth) {
		throw "Not yet implemented."; // TODO: implement
	}
}
