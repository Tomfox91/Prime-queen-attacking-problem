module forwardCheck.main;

import std.conv;
import std.stdio;
import util.primes;
import util.dimension;
import util.orders;
import util.coord;
import forwardCheck.state;

void tryQueens() {
	foreach(q; queenOrder) {
		write("\rTrying queen: ", q);
		stdout.flush;

		State s = State(q);
		tryValue(s, 1);
	}
	throw new Failure;
}

void tryValue(ref const State s, const Cell n) in {
	assert(n > 0);
	assert(n <= dim^^2);
} body {
	foreach(c; s.dom(n)) {
		if (s.consistent(n, c)) {
			State state = s;
			state[n] = c;

			if (n == dim^^2) {
				throw new Found(state);

			} else {
				try {
					state.propagation();
					tryValue(state, (n+1).to!Cell);
				} catch (Failure) {}
			}
		}
	}
}

class Found: Exception {
	State state;
	this(State s, string _file = __FILE__, size_t _line = __LINE__) {
		super("Found", _file, _line);
		state = s;
	}
}

void main() {
	try {
		tryQueens();
	} catch (Found s) {
		writeln;
		s.state.print;
	}
}
