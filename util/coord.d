module util.coord;

import std.math;
import util.dimension;

struct Coord {
	int y = -1;
	int x = -1;

	bool isSet() pure const {
		return (y != -1 && x != -1);
	}
}

bool isKnightMove(Coord a, Coord b) pure {
	return (abs(a.x - b.x) == 1 && abs(a.y - b.y) == 2)
		|| (abs(a.x - b.x) == 2 && abs(a.y - b.y) == 1);
}

bool isQueenMove(Coord a, Coord b) pure {
	if (a == b) return false;
	return (a.x == b.x || a.y == b.y ||
		abs(a.x - b.x) == abs(a.y - b.y));
}

private Coord[] calculateCoords(int lim = dim) {
	Coord[] res;
	for (int i = 0; i < lim; i++)
		for (int j = 0; j < lim; j++)
			res ~= Coord(i, j);

	return res;
}

enum Coord[dim^^2] allCoords = calculateCoords();
enum Coord[((dim+1)/2)^^2] quarterCoords = calculateCoords(((dim+1)/2));

unittest {
	import std.array;
	import std.algorithm;

	assert(isKnightMove(Coord(4, 1), Coord(5, 3)));
	assert(isKnightMove(Coord(4, 1), Coord(6, 2)));
	assert(isKnightMove(Coord(6, 1), Coord(5, 3)));
	assert(isKnightMove(Coord(7, 2), Coord(5, 3)));
	assert(!isKnightMove(Coord(5, 2), Coord(5, 2)));

	assert(isQueenMove(Coord(2, 2), Coord(1, 2)));
	assert(isQueenMove(Coord(2, 2), Coord(2, 1)));
	assert(isQueenMove(Coord(2, 2), Coord(0, 0)));
	assert(isQueenMove(Coord(2, 2), Coord(0, 4)));
	assert(!isQueenMove(Coord(2, 2), Coord(2, 2)));

	assert(allCoords[0] == Coord(0, 0));

	std.stdio.writeln(__FILE__ ~ ": unittest completed");
}
