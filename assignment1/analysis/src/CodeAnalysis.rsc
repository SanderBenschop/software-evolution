module CodeAnalysis

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import analysis::m3::metrics::LOC;
import IO;
import List;
import Set;
import Map;
import String;

public void countLinesOfCode(loc projectLocator) {
	map[loc, map[loc, str]] filteredClasses = filterCommentsOutOfProject(projectLocator);
	int linesOfCode = 0;
	for (map[loc, str] filteredMethods <- range(filteredClasses)) {
		for (str method <- range(filteredMethods)) {
			for (/(\S)*\n/ := method) {
				linesOfCode = linesOfCode + 1;
			}
		}
	}
	
	println("Lines of code: <linesOfCode>");
}

public map[loc, map[loc, str]] filterCommentsOutOfProject(loc projectLocator) {
	tuple[set[Declaration] AST, M3 m3] analysis = performAnalysis(projectLocator);
	
	int lines = countProjectSourceLoc(analysis.m3);
	M3 m3 = analysis.m3;
	set[Declaration] ast = analysis.AST;

	set[loc] classes = getClasses(ast);
	int totalLines = 0;
	map[loc, map[loc, str]] filteredClasses = ();
	for (class <- classes)
	{
		set[loc] methods = methods(m3, class);
		map[loc, str] filteredMethods = ();
		for (method <- methods)
		{
		    list[str] filteredContents = [];
            str contents = ( "" | it + line + "\n" | str line <- readFileLines(method));
			for (/(?s)<comment:(\/\*+(.*)?\*+\/)|(\/\/(.*?)\n)>/ := contents) {
				contents = replaceAll(contents, comment, "");
			}
			filteredMethods = filteredMethods + (method : contents);
		}
		filteredClasses = filteredClasses + (class : filteredMethods);
	}
	return filteredClasses;
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