module SmallSqlAnalysis

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import analysis::m3::metrics::LOC;
import IO;
import List;
import Set;

public tuple[set[Declaration], M3] performAnalysis(loc location) {
	set[Declaration] declarations = createAstsFromEclipseProject(location, true);
	M3 m3 = createM3FromEclipseProject(location);
	
	return <declarations, m3>;
}

public void main() {
	loc smallSqlLoc = |project://smallsql0.21_src|;
	tuple[set[Declaration] AST, M3 m3] analysis = performAnalysis(smallSqlLoc);
	
	int lines = countProjectSourceLoc(analysis.m3);

	M3 m3 = analysis.m3;
	set[Declaration] ast = analysis.AST;

	set[loc] classes = { x.to | x <- m3@containment, x.from.scheme == "java+compilationUnit", x.to.scheme == "java+class" };
	int totalLines = 0;
	for (class <- classes)
	{
		set[loc] methods = methods(m3, class);
		for (method <- methods)
		{
			list[str] contents = [ x | x <- readFileLines(method), !(/^\s*$/ := x) ];
			list[str] filteredLines = [ x | x <- contents, !(/\\*+\\s*|\\s*\\*+/ := x), !(/^\s+\/\/$/ := x) ];
			int lines = size (filteredLines);
			totalLines += lines;
			println("method: <contents>\nloc: <lines>\n\n");
		}
	}
	
	println("Total lines: <totalLines>");
	
 	println("Classes: <classes>");	
}