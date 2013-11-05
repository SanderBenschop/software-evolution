module SmallSqlAnalysis

import CodeAnalysis;

public void main() {
	loc smallSqlLoc = |project://smallsql0.21_src|;
	tuple[set[Declaration] AST, M3 m3] analysis = performAnalysis(smallSqlLoc);

	M3 m3 = analysis.m3;
	set[Declaration] ast = analysis.AST;

	set[loc] classes = { x.to | x <- m3@containment, x.from.scheme == "java+compilationUnit", x.to.scheme == "java+class" };
	int totalLines = 0;
	for (class <- classes)
	{
		set[loc] methods = methods(m3, class);
		for (method <- methods)
		{
			 
			list[str] contents = [ x | x <- readFileLines(method), !(/^\s*(\/\/)?$/ := x) ];
			
			
			int lines = size (contents);
			totalLines += lines;
			println("method: <contents>\nloc: <lines>\n\n");
		}
	}
	
	println("Total lines: <totalLines>");
	
 	println("Classes: <classes>");	
	countLinesOfCode(smallSqlLoc);
}