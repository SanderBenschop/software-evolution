module SmallSqlAnalysis

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import analysis::m3::metrics::LOC;
import IO;

public tuple[set[Declaration], M3] performAnalysis(loc location) {
	set[Declaration] declarations = createAstsFromEclipseProject(location, true);
	M3 m3 = createM3FromEclipseProject(location);
	
	return <declarations, m3>;
}

public void main() {
	loc smallSqlLoc = |project://smallsql0.21_src|;
	tuple[set[Declaration] AST, M3 m3] analysis = performAnalysis(smallSqlLoc);
	
	int lines = countProjectSourceLoc(analysis.m3);
	set[str] classNames = getClasses(analysis.AST);
	println("Lines: <lines>");
}

private set[str] getClasses(set[Declaration] declarations) {
	set[str] classNames = {};
	for (Declaration compilationUnit <- declarations) {
		for (javaClass <- compilationUnit.types) {
			classNames += javaClass.name;
		}
	}
	return classNames;
}