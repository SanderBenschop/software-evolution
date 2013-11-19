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
import util::Math;

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

public void determineLinesOfCodeRanking(int linesOfCode) {
	set[tuple[int lowerboundary, int upperboundary, str rank]] ranking = { <0,66000,"++">, <66000,246000,"+">, <246000,665000,"0">, <665000,1310000,"-">, <1310000,-1,"--"> };
	
	for (r <- ranking) {
	   if (r.lowerboundary <= linesOfCode) {
	        if (r.upperboundary == -1 || linesOfCode < r.upperboundary) {
	        	println("Lines of code ranking is: <r.rank>");
	        	break;
	        }
	   }
	}
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


public map[loc, set[loc]] getClassMethodsMap(set[Declaration] AST, M3 model) {
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

public void determineAndPrintUnitSizes(set[Declaration] AST, M3 model) {
	int veryHigh = 0, high = 0, medium = 0, low = 0;
	map[loc, int] unitSizeMap = getUnitSizes(AST, model);
	for (unit <- unitSizeMap) {
		int size = unitSizeMap[unit];
		if (size > 100) veryHigh += 1;
		else if (size > 50) high += 1;
		else if (medium > 10) medium += 1;
		else low += 1;
	}
	
	printUnitSizes(medium, high, veryHigh, size(unitSizeMap));
}

private void printUnitSizes(int moderate, int high, int veryHigh, int total) {
	real totalLines = toReal(total), 
	
	moderatePercentage = (toReal(moderate) / totalLines) * 100,
	highPercentage = (toReal(high) / totalLines) * 100,
	veryHighPercentage = (toReal(veryHigh) / totalLines) * 100;
	
	str ranking;
	if (moderatePercentage <= 25 && highPercentage == 0 && veryHighPercentage == 0) {
		ranking = "++";
	} else if (moderatePercentage <= 30 && highPercentage <= 5 && veryHigh == 0) {
		ranking = "+";
	} else if (moderatePercentage <= 40 && highPercentage <= 10 && veryHigh == 0) {
		ranking = "0";
	} else if (moderatePercentage <= 50 && highPercentage <= 15 && veryHigh <= 5) {
		ranking = "-";
	} else {
		ranking = "--";
	}
	println("The unit size rank is <ranking>");
}
