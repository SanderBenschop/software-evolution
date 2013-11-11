module CodeAnalysis

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import analysis::m3::metrics::LOC;
import IO;
import List;
import Set;
import String;
import Map;

public void findDuplicates(loc projectLocator) {
	// [*x, block, *y] := anderefilecontent
}

public int countLinesOfCode(loc projectLocator) {
	map[loc, map[loc, str]] filteredClasses = filterEffectiveLinesInProject(projectLocator);
	
	int lines = 0;
	// Loop each class
	for (classLocation <- filteredClasses) {
		int classLines = 0;
		// Loop each method for the class
		for (method <- filteredClasses[classLocation]) {
			// Content of the method
			str content = filteredClasses[classLocation][method];
			println("method <method>: <content>");
			
			// Count lines in the method
			int methodLines = size(split("\n", content));
			println("Lines of method: <methodLines>");
			classLines += methodLines;
		}
		println("Class lines: <classLines>");
		lines += classLines;
	}
	
	println("Total lines: <lines>");
	return lines;
}

public map[loc, map[loc, str]] filterEffectiveLinesInProject(loc projectLocator) {
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
			
			// replace empty new lines
			for (/<emptyline:\s*\n\n>/ := contents) {
				contents = replaceAll(contents, emptyline, "\n");
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