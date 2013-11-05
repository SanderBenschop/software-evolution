module CodeAnalysis

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import analysis::m3::metrics::LOC;
import IO;
import List;
import Set;

public void countLinesOfCode(loc projectLocator) {
	tuple[set[Declaration] AST, M3 m3] analysis = performAnalysis(projectLocator);
	
	int lines = countProjectSourceLoc(analysis.m3);
	M3 m3 = analysis.m3;
	set[Declaration] ast = analysis.AST;

	set[loc] classes = getClasses(ast);
	int totalLines = 0;
	for (class <- classes)
	{
		set[loc] methods = methods(m3, class);
		for (method <- methods)
		{
	        list[str] contents = [ x | x <- readFileLines(method), !(/^\s*(\/\/)?$/ := x), !(/^(\t|\r|\n)+$/ := x) ];
            str body = "";
            for (str line <- contents) { 
    	        body += line;
            }
            totalLines += size(contents);
		}
	}
	
	println("Total lines: <totalLines>");
	
 	println("Classes: <classes>");	
}

private tuple[set[Declaration], M3] performAnalysis(loc location) {
	set[Declaration] declarations = createAstsFromEclipseProject(location, true);
	M3 m3 = createM3FromEclipseProject(location);
	
	return <declarations, m3>;
}

private set[loc] getClasses(set[Declaration] declarations) {
	set[loc] classes = {};
	for (Declaration compilationUnit <- declarations) {
		for (javaClass <- compilationUnit.types) {
			classes += javaClass@decl;
		}
	}
	return classes;
}