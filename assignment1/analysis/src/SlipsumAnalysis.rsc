module SlipsumAnalysis

import CodeAnalysis;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Set;
import Map;
import IO;
import String;

public void main() {
	tuple[set[Declaration] AST, M3 m3] analysis = performAnalysis(|project://smallsql0.21_src|);
	int lines = countLinesOfCode(analysis.m3);
	println("Lines of code: <lines>");
	
	// findDuplicates(analysis.m3);
	
	map[loc, int] unitSizes = getUnitSizes(analysis.AST, analysis.m3);
/*	for (unit <- unitSizes) {
		println("Unit size <unit> is <unitSizes[unit]>");
	}
*/
	println("Units: <size(unitSizes)> total sizes: <sum(range(unitSizes))>");
	println("Assert statements: <calculateAssertStatements(analysis.AST, analysis.m3)>");

}