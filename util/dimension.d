module util.dimension;

version(dim6) {
	enum dim = 6;

} else version(dim7) {
	enum dim = 7;

} else version(dim8) {
	enum dim = 8;

} else version(dim9) {
	enum dim = 9;

} else version(dim10) {
	enum dim = 10;

} else {
	enum dim = 5;
}