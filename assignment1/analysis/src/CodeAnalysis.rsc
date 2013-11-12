module CodeAnalysis

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import analysis::m3::metrics::LOC;
import IO;
import List;
import Set;
import String;
import Map;

public void findDuplicates(M3 model) {
    str code = removeTrailingAndEmptyLines(getProjectJavaContents(model));
    list[str] splitted = split("\n", code);
    
    //println("Original content: \n <code>");
    list[str] duplicates = [];
    int n = size(splitted), end = 6;
    while(end <= n, n >= 6) {
        int begin = end - 6;
        list[str] sublist = splitted[begin..end];
        str rejoined = intercalate("\n", sublist);
        int occurences = findOccurrences(rejoined, code);
        if (occurences > 1) {
            duplicates = duplicates + sublist;
        } 
        end = end + 1;
    }
    str duplicatedCode = intercalate("\n", dup(duplicates));
    println("The following code is duplicated: \n <duplicatedCode>");
}

private int findOccurrences(str snippet, str allCode) {
    return size(findAll(allCode, snippet));
}

public int countLinesOfCode(M3 model) {
	return countLinesOfCode(getProjectJavaContents(model));
}

public int countLinesOfCode(str code) {
	return size(split("\n", filterEffectiveLines(code)));
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


private map[loc, set[loc]] getClassMethodsMap(set[Declaration] AST, M3 model) {
	map[loc, set[loc]] classesToMethodsMap = ();
	for (class <- getProjectClasses(AST)) {
		classesToMethodsMap += (class: methods(model, class));
	}
	
	return classesToMethodsMap;
}

public map[loc, int] getUnitSizes(set[Declaration] AST, M3 model) {
	return getUnitSizes(getClassMethodsMap(AST, model));
}

public map[loc, int] getUnitSizes(map[loc, set[loc]] classesToMethodsMap) {
	map[loc, int] sizes = ();

	for (class <- classesToMethodsMap) {
		set[loc] methods = classesToMethodsMap[class];
		for (method <- methods) {
			int unitSize = countLinesOfCode(readFile(method));
			sizes += (method: unitSize);
		}  
	}
	
	return sizes;
} 