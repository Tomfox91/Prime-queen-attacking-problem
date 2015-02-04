module forwardCheck.state;

import std.conv;
import std.stdio;
import std.array;
import util.dimension;
import util.primes;
import util.coord;
import util.arc;
import util.board;

version(PartialLA) {
	version = ForwardCheck;
}
version(FullLA) {
	version = ForwardCheck;
}


class Failure: Exception {
	this(string _file = __FILE__, size_t _line = __LINE__) {
		super("Failure", _file, _line);
	}
}

struct State {
	bool[dim][dim] assigned;
	Coord[dim^^2] values;
	Dom[dim^^2] domains;
	Cell last;
	immutable Coord queen;
	
	Coord opIndex(Cell n) const pure in {
		assert(values[n-1].isSet);
	} body {
		return values[n-1];
	}

	void opIndexAssign(Coord c, Cell n) {
		assigned[c.y][c.x] = true;
		values[n-1] = c;
		last = n;
		//TODO domain
	}

	this(Coord q) {
		queen = q;
		queenPropagation();
	}

	bool consistent(Cell n, Coord c) const in {
		assert(queen.isSet);
		assert(c.isSet);
		assert(n > 0);
		assert(n <= dim^^2);
		assert(!values[n-1].isSet);
		assert(n == 1 || values[n-2].isSet);
	} body {
		return
			!assigned[c.y][c.x] && // alldiff
			(n==1 || c.isKnightMove(values[n-2])) && // knight move (assuming progressive assignment)
			(!isPrime(n) || c.isQueenMove(queen)); // primes
	}

	auto dom(Cell n) const {
		return domains[n-1].range;
	}

	void queenPropagation() {
		version (ForwardCheck) {
			foreach (c; allCoords)
				if (!c.isQueenMove(queen))
					foreach (Cell n; 1..(dim^^2+1))
						if (n.isPrime)
							domains[n-1][c] = false;
		}
	}

	void propagation() {
		version (ForwardCheck) {
			immutable Coord lastCoord = values[last-1];

			// knight move
			foreach (c; domains[last+1-1].range)
				if (!c.isKnightMove(lastCoord))
					domains[last+1-1][c] = false;
			version(FCSkipEmptyCheck) {} else {
				if (domains[last+1-1].empty)
					throw new Failure;
			}

			// alldiff
			foreach (i; (last+1)..(dim^^2+1)) {
				domains[i-1][lastCoord] = false;
				
				version(FCSkipEmptyCheck) {} else {
					if (domains[i-1].empty)
						throw new Failure;
				}
			}

			version (PartialLA) {
				darc(domains[(last+1-1) .. $]);
			}

			version (FullLA) {
				ac3(domains[(last+1-1) .. $]);
			}
		}
	}

	void print() {
		Board b;
		b.queen = queen;
		foreach (Cell n, Coord c; values) {
			b[c] = (n+1).to!Cell;
		}
		b.print;
	}
}