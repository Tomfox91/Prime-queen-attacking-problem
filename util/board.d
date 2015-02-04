module util.board;

import std.math;
import std.algorithm;
import std.conv;
import util.dimension;
import util.primes;
import util.coord;

struct Board {
	private Cell[dim][dim] _board;
	private Coord _queen;

	this (Cell[dim][dim] b, Coord q) {
		_board = b;
		_queen = q;
	}

	this (Board oth) {
		_board = oth._board;
		_queen = oth._queen;
	}

	bool isValidCoord(Coord c) const pure {
		return (c.x >= 0) && (c.y >= 0) && (c.x < dim) && (c.y < dim);
	}

	Cell opIndex(Coord c) const pure {
		return _board[c.y][c.x];
	}

	void opIndexAssign(Cell n, Coord c) {
		_board[c.y][c.x] = n;
	}

	bool isEmpty(Coord c) const pure {
		return this[c] == 0;
	}


	Coord queen() const @property
	in {
		assert(_queen.isSet);
	} body {
		return _queen;
	}

	void queen(Coord c) @property {
		_queen = c;
	}


	auto validEmptyKnightMoves(Coord from) const pure {
		Coord[] candidates = [
			Coord(from.y +1, from.x +2),
			Coord(from.y +2, from.x +1),
			Coord(from.y -1, from.x +2),
			Coord(from.y -2, from.x +1),
			Coord(from.y +1, from.x -2),
			Coord(from.y +2, from.x -1),
			Coord(from.y -1, from.x -2),
			Coord(from.y -2, from.x -1)
		];

		return candidates.filter!(c => isValidCoord(c) && isEmpty(c));
	}


	bool canContainPrime(Coord c) const {
		return isQueenMove(queen, c);
	}



	void print() const {
		import std.stdio;

		write("    \x1b[2;31m");
		for (int j = 0; j < dim; j++)
			writef("%3d ", j);
		writeln;

		foreach (int i, line; _board) {
			writef("\x1B[2;31m%3d \x1B[0m", i);
			foreach (int j, Cell n; line) {
				if (isQueenMove(Coord(i, j), _queen))
					write("\x1B[44m");
				if (Coord(i, j) == _queen)
					write("\x1B[1;44m");
				if (isPrime(n))
					write("\x1B[1;33m");
				writef("%3d \x1B[0m", n);
			}
			writeln;
		}
	}
}

unittest {
	import std.exception;
	import core.exception;
	import std.array;

	Board b;

	b[Coord(2,3)] = 5;
	assert(b[Coord(2,3)] == 5);
	assert(b.isValidCoord(Coord(2, 3)));
	assert(!b.isValidCoord(Coord(5, 3)));
	assert(!b.isValidCoord(Coord(3, -1)));

	assert(b.validEmptyKnightMoves(Coord(2,3)).array.sort == 
		[Coord(4, 4), Coord(0, 4), Coord(3, 1), Coord(4, 2), Coord(1, 1), Coord(0, 2)].sort);

	assertThrown!AssertError(b.canContainPrime(Coord(1, 2)));
	b.queen = Coord(2, 2);
	assert(b.canContainPrime(Coord(2, 3)));
	assert(!b.canContainPrime(Coord(2, 2)));

	std.stdio.writeln(__FILE__ ~ ": unittest completed");
}
