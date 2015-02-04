module simple;

import std.algorithm;
import std.typecons;
import std.stdio;
import std.array;
import util.dimension;
import util.coord;
import util.board;
import util.primes;
import util.orders;

private alias NBoard = Nullable!Board;

private immutable NBoard nothing;

NBoard simple() {
	Board board;

	foreach (q; queenOrder) {
		auto res = tryAssignQueen(board, q);
		if (!res.isNull)
			return res;
	}

	return nothing;
}

NBoard tryAssignQueen(Board board, const Coord queen) {
	board.queen = queen;

	foreach (c; allCoords) {
		write("\rTrying...\t Queen: ", queen, "\t 1: ", c);
		stdout.flush;
		if (tryAssign(board, 1, c)) {
			writeln;
			return NBoard(board);
		}
	}

	return nothing;
}

bool tryAssign(ref Board board, Cell next, const Coord nextCoord) in {
	assert(next >= 1);
	assert(next <= dim^^2);
	assert(board[nextCoord] == 0);
} body {

	board[nextCoord] = next;

	if (next == dim^^2) {
		return true;
	} else {
		auto candidates = board.validEmptyKnightMoves(nextCoord);
		next++;

		foreach (c; candidates)
			if (! (isPrime(next) && !board.canContainPrime(c))) {
				if (tryAssign(board, next, c))
					return true;
			}

		board[nextCoord] = 0;
		return false;
	}
}

void main() {
	simple().get.print;
}
