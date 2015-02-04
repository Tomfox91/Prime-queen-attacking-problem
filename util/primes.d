module util.primes;

import std.math;
import std.conv;

alias Cell = ubyte;

private enum size_t max = 15^^2;

private bool calculateIsPrime(int n) {
	if (n < 2)
		return false;

	if (n == 2)
		return true;

	foreach (i; 2 .. n/2 +1) {
		if (n % i == 0)
			return false;
	}
	return true;
}

private bool[max+1] calculatePrimality() {
	bool[max+1] temp;

	foreach (int i, ref bool p; temp) {
		p = calculateIsPrime(i);
	}

	return temp;
}

private enum bool[max+1] primality = calculatePrimality();

bool isPrime(Cell n) {
	return primality[n];
}

unittest {
	import std.exception;
	import core.exception;

	assert(isPrime(2));
	assert(isPrime(5));
	assert(isPrime(17));
	assert(!isPrime(1));
	assert(!isPrime(9));
	assert(!isPrime(15));
	assertThrown!RangeError(isPrime(max+1));

	std.stdio.writeln(__FILE__ ~ ": unittest completed");
}