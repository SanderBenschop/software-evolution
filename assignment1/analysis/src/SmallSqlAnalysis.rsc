module SmallSqlAnalysis

import CodeAnalysis;

public void main() {
	loc smallSqlLoc = |project://smallsql0.21_src|;
	countLinesOfCode(smallSqlLoc);
}