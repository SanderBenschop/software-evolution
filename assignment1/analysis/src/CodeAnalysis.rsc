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

public int countLinesOfCode(M3 model) {
	str code = filterEffectiveLines(getProjectJavaContents(model));	
	return size(split("\n", code));
}

public str getProjectJavaContents(M3 model) {
	set[loc] javaFiles = { file | file <- files(model), file.extension == "java" };
	
	str content = "";
	for (file <- javaFiles) {
		str fileContent = readFile(file);
		content += fileContent;
		if (!endsWith(fileContent, "\n")) {
			content += "\n";
		}
	}	
	
	return content;
}

public set[loc] getProjectClasses(set[Declaration] AST) {
	return getClasses(AST);
}

public str filterEffectiveLines(str code) {
    return removeTrailingAndEmptyLines(removeComments(code));
}

public str removeTrailingAndEmptyLines(str code) {
    str nonSpacingCode = "";
    for (/\s*<content:(.*)>(\n)*/ := code) {
        nonSpacingCode += trim(content) + "\n";
    }
    
    return nonSpacingCode; 	
}

public str removeComments(str code) {
	// multiline comments
	for (/(?s)<comment:(\/\*+(.*?)\*+\/)>/ := code) {
		code = replaceAll(code, comment, "");
	}

	// single line comments
	for (/(?s)<comment:(\/\/(.*?)\n)>/ := code) {
         code = replaceAll(code, comment, "");
	}	

	return code;
}

public tuple[set[Declaration], M3] performAnalysis(loc location) {
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