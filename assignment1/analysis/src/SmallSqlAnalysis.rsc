module SmallSqlAnalysis

import CodeAnalysis;
import CodeDuplicationAnalysis;
import CyclomaticComplexityAnalysis;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::Benchmark;
import Set;
import IO;
import String;

public void main() {
	tuple[set[Declaration] AST, M3 m3] analysis = performAnalysis(|project://smallsql0.21_src|);
	
	int beforeComplexity = cpuTime();
	map[loc, int] cyclomaticComplexityPerUnit = getCyclomaticComplexityPerUnit(analysis.AST);
	int secondsTakenComplexity = (cpuTime() - beforeComplexity) / 1000000;
	println("Total process \'determine complexity\' took <secondsTakenComplexity> milliseconds.");
	
	int beforeDuplicates = cpuTime();
	findDuplicates(analysis.m3);
	int secondsTakenDuplicates = (cpuTime() - beforeDuplicates) / 1000000;
	println("Total process \'find duplicates\' took <secondsTakenDuplicates> milliseconds.");
}