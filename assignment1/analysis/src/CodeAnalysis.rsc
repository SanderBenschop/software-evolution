module CodeAnalysis

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import analysis::m3::metrics::LOC;
import IO;
import List;
import Set;
import Map;
import String;
import Map;
import util::ValueUI;

public void findDuplicates(M3 model) {
    str code = removeTrailingAndEmptyLines(getProjectJavaContentsAsString(model));
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
	return countLinesOfCode(getProjectJavaContentsAsString(model));
}
	
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

public int countLinesOfCode(str code) {
	return size(split("\n", filterEffectiveLines(code)));
}

public str getProjectJavaContentsAsString(M3 model) {
	map[loc, str] contentMap = getProjectJavaContentsAsMap(model);
	
	str resultContent = "";
	for (content <- contentMap) {
		str fileContent = contentMap[content];
		resultContent += fileContent;
		if (!endsWith(fileContent, "\n")) {
			resultContent += "\n";
		}
	}	
	
	return resultContent;
}

public map[loc, str] getProjectJavaContentsAsMap(M3 model) {
	set[loc] javaFiles = { file | file <- files(model), file.extension == "java" };
	
	map[loc, str] contentMap = ();
	for (file <- javaFiles) {
		contentMap += (file: readFile(file));
	}	


	return contentMap;
}

public int countAsserts(Statement AST) {
	int c = 0;
	visit(AST) {
		case \assert(Expression e, _): c = printAndIncrease(c, e);
		case \assert(Expression e): c = printAndIncrease(c, e);
		case /<regexStatement:(assert(.*)(\(.*?\))*)>/: 
			c = printAndIncrease(c, regexStatement);
	};
			
	return c;
}

private int printAndIncrease(int x, value line) {
	// iprintln(line);
	return (x + 1);
} 

public map[loc, tuple[loc, int]] createClassMethodAssertMap(set[Declaration] AST, M3 model) {
	map[loc, set[loc]] classesMethodMap = getClassMethodsMap(AST, model);
	map[loc, tuple[loc, int]] classMethodAssertMap = (); 

	for (class <- classesMethodMap) {
		for (method <- classesMethodMap[class]) {
			methodAST = getMethodASTEclipse(method, model=model);	
			statements = [s | /Statement s := methodAST];
			int assertCount = 0;
			for (statement <- statements) {
				assertCount += countAsserts(statement);
			}
			classMethodAssertMap += (class: <method, assertCount>);
		}
	}
	
	return classMethodAssertMap;
} 

public num calculateAssertStatements(set[Declaration] AST, M3 model) {
	classMethodAssertMap = createClassMethodAssertMap(AST, model); 
	// sum the int values for each method for each class method
	return sum([tuples[1] | tuples <- range(classMethodAssertMap)]);
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
   int unitSize = getUnitSize(method);
   sizes += (method: unitSize);
  }  
 }
 
 return sizes;
} 

public int getUnitSize(loc method) {
 return countLinesOfCode(readFile(method));
}
