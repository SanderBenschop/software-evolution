module SmallSqlAnalysis

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;

public void performAnalysis() {
									    loc smallSqlLoc = |project://smallsql0.21_src/src|;
									    //M3 m3 = createM3FromEclipseProject(smallSqlLoc);
									    set[Declaration] declarations = createAstsFromEclipseProject(smallSqlLoc, true);
									    int i = 0;
}