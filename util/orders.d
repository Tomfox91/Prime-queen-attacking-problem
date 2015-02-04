module util.orders;

import std.algorithm;
import std.array;
import util.dimension;
import util.coord;

private ulong attackedCells(Coord c) {
	return allCoords.array.count!(cc => isQueenMove(c, cc));
}

Coord[] queenOrderMostCoverageFirst() {
	return quarterCoords.array.sort!((a, b) => attackedCells(a) > attackedCells(b)).array;
}

version (queenAll) {
	enum Coord[] queenOrder = allCoords;
} else version (queenNaturalOrder) {
	enum Coord[] queenOrder = quarterCoords;
} else { // queenMostCoverageFirstOrder
	enum Coord[] queenOrder = queenOrderMostCoverageFirst;
}

