module util.arc;

import std.algorithm;
import std.array;
import std.container;
import std.typecons;
import std.math;
import std.conv;
import util.dimension;
import util.primes;
import util.coord;

struct Dom {
	private static bool[dim][dim] _possibleInit() {
		bool[dim][dim] res;
		foreach (ref line; res) foreach (ref b; line)
			b = true;
		return res;
	}
	private bool[dim][dim] _possible = _possibleInit();
	private int _numPossible = dim^^2;

	bool opIndex(const Coord c) const pure {
		return _possible[c.y][c.x];
	}

	void opIndexAssign(const bool b, const Coord c) in {
		assert(c.isSet);
	} body {
		if (_possible[c.y][c.x] && !b) {
			_numPossible--;
		} else if (!_possible[c.y][c.x] && b) {
			_numPossible++;
		}
		_possible[c.y][c.x] = b;
	}

	bool empty() const {
		return _numPossible == 0;
	}

	Range range() const {
		Range res = Range(this);
		res.next();
		return res;
	}

	static private struct Range {
		private const Dom* _dom;
		private int i = 0;
		private int j = 0;
		private bool end;

		invariant {
			assert(end || (0<=i && i<dim && 0<=j && i<dim));
		}

		this(const ref Dom d) {
			_dom = &d;
			end = _dom.empty;
		}

		private void inc() {
			j++;
			if (j == dim) {
				j = 0;
				i++;
				if (i == dim) {
					end = true;
				}
			}			
		}

		private void next() {
			while (!end && !_dom._possible[i][j])
				inc();
		}

		bool empty() const {
			return end;
		}

		void popFront() {
			inc();
			next();
		}

		Coord front() {
			next();
			return Coord(i, j);
		}
	}
}

// slide ac+pc - s2
bool revise(alias constraint)(ref Dom a, const ref Dom b)
		if(is(typeof(constraint(Coord(0,0), Coord(0,1))) == bool)) {
	bool modified = false;

	foreach(ca; a.range) {
		if (!b.range.any!(cb => constraint(ca, cb))) {
			a[ca] = false;
			modified = true;
		}
	}

	return modified;
}

// slide ch7 - p47
void darc(Dom[] d) {
	foreach_reverse(j; 1..d.length) {
		foreach(i; 0..j) {
			if (abs(i-j) == 1) {
				revise!((a,b) => (a != b) && isKnightMove(a,b))(d[i], d[j]);
			} else {
				revise!((a,b) => (a != b)) (d[i], d[j]);
			}
		}
	}
}

//slide ac+pc - s4
void ac3(Dom[] d) {
	bool[][] todo;
	todo.length = d.length;
	auto queue = DList!(Tuple!(int,int))();
	
	foreach (int i; 0..d.length.to!int) {
		todo[i].length = d.length;
		foreach (int j; 0..d.length.to!int) {
			if (i!=j) {
				queue.insertBack(tuple(i,j));
				todo[i][j] = true;
			}
		}
	}

	while (!queue.empty()) {
		//std.stdio.writeln; std.stdio.writeln;
		//foreach (x; queue) std.stdio.write("(", x[0], ",", x[1], ") ");

		auto x = queue.front();
		int i = x[0], j = x[1];
		queue.removeFront();
		todo[i][j] = false;
		bool modified = false;

		if (abs(i-j) == 1) {
			modified = revise!((a,b) => (a != b) && isKnightMove(a,b))
				(d[i],d[j]);
		} else {
			modified = revise!((a,b) => (a != b)) (d[i],d[j]);
		}

		if (modified) {
			foreach (int k; 0..d.length.to!int) {
				if (i != k && !todo[i][k]) {
					queue.insertBack(tuple(k, i));
					todo[i][k] = true;
				}
			}
		}
	}
}

unittest {
	Dom d;
	assert(d[Coord(1,1)]);
	d[Coord(1,1)] = false;
	assert(!d[Coord(1,1)]);

	assert(d.range.array.sort == 
		[Coord(0, 0), Coord(0, 1), Coord(0, 2), Coord(0, 3), Coord(0, 4),
		 Coord(1, 0),              Coord(1, 2), Coord(1, 3), Coord(1, 4),
		 Coord(2, 0), Coord(2, 1), Coord(2, 2), Coord(2, 3), Coord(2, 4),
		 Coord(3, 0), Coord(3, 1), Coord(3, 2), Coord(3, 3), Coord(3, 4),
		 Coord(4, 0), Coord(4, 1), Coord(4, 2), Coord(4, 3), Coord(4, 4)].sort);

	Dom da, db;
	revise!((a, b) => a.x==4)(da, db);
	assert(da.range.array.sort == 
		[Coord(0, 4), Coord(1, 4), Coord(2, 4), Coord(3, 4), Coord(4, 4)].sort);

	std.stdio.writeln(__FILE__ ~ ": unittest completed");
}