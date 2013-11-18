module CodeDuplicationAnalysisTest

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import analysis::m3::metrics::LOC;
import IO;
import List;
import Set;
import String;
import Map;
import CodeDuplicationAnalysis;
import CodeAnalysis;

test bool testDuplicateCodeCount() {
	tuple[set[Declaration] AST, M3 m3] analysis = performAnalysis(|project://Slipsum|);
	int duplicateLines = findDuplicates(analysis.m3); 
	return duplicateLines == 26;
}