module SlipsumAnalysis

import CodeAnalysis;
import CodeDuplicationAnalysis;
import CyclomaticComplexityAnalysis;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::Benchmark;
import Set;
import Map;
import IO;
import String;

public void main() {
	tuple[set[Declaration] AST, M3 m3] analysis = performAnalysis(|project://Slipsum|);
	map[loc, int] cyclomaticComplexityPerUnit = getCyclomaticComplexityPerUnit(analysis.AST);
	int lines = countLinesOfCode(analysis.m3);
	println("Lines of code: <lines>");

	int before = cpuTime();
	findDuplicates(analysis.m3);
	int secondsTaken = (cpuTime() - before) / 1000000;
	println("Duplication search process took <secondsTaken> milliseconds.");
	
	map[loc, int] unitSizes = getUnitSizes(analysis.AST, analysis.m3);
/*	for (unit <- unitSizes) {
		println("Unit size <unit> is <unitSizes[unit]>");
	}
*/
	println("Units: <size(unitSizes)> total sizes: <sum(range(unitSizes))>");
	println("Assert statements: <calculateAssertStatements(analysis.AST, analysis.m3)>");
}
