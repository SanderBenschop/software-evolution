module SlipsumAnalysis

import CodeAnalysis;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Set;
import IO;
import String;

public void main() {
	tuple[set[Declaration] AST, M3 m3] analysis = performAnalysis(|project://Slipsum|);
	int lines = countLinesOfCode(analysis.m3);
	println("lines: <lines>");
	
	findDuplicates(analysis.m3);
	
	map[loc, int] unitSizes = getUnitSizes(analysis.AST, analysis.m3);
	for (unit <- unitSizes) {
		println("Unit size <unit> is <unitSizes[unit]>");
	}
}