module CyclomaticComplexityAnalysis

import CodeAnalysis;
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import analysis::m3::metrics::LOC;
import IO;
import List;
import Set;
import Map;
import String;
import Map;
import util::Math;

public map[loc, int] getCyclomaticComplexityPerUnit(set[Declaration] AST) {
	map[loc,int] cyclomaticComplexityPerUnit = ();
	
	map[loc, Declaration] methodDeclarations = getMethodDeclarations(AST);
	for (loc methodLocator <- methodDeclarations) {
		Declaration methodDeclaration = methodDeclarations[methodLocator];
		int decisionPoints = 0;
		top-down visit(methodDeclaration.impl) {
			
			case \if(Expression condition, _) : decisionPoints += determineExpressionComplexity(condition);
			case \if(Expression condition, _, _) : decisionPoints += determineExpressionComplexity(condition);				
			case \while(Expression condition,_) : decisionPoints += determineExpressionComplexity(condition); 
			case \for(_,Expression condition,_) : decisionPoints += determineExpressionComplexity(condition);
			case \for(_,Expression condition,_,_) : decisionPoints += determineExpressionComplexity(condition);
			case \foreach(_,_,_) : decisionPoints += 1;
			
			case \case(_) : decisionPoints += 1;
			case \defaultCase() : decisionPoints += 1;
			
			case \catch(_,_) : decisionPoints += 1;
		}
		cyclomaticComplexityPerUnit += (methodLocator : decisionPoints + 1);
	}
	return cyclomaticComplexityPerUnit;
}

public tuple[int, int, int, int] determineRelativeComplexity(map[loc, int] complexityPerMethod, int totalLines) {
	int simple = 0, moderate = 0, high = 0, veryHigh = 0;
	for (loc methodLocator <- complexityPerMethod) {
		int complexity = complexityPerMethod[methodLocator], unitSize = getUnitSize(methodLocator);
		if (complexity > 50) {
			veryHigh += unitSize;
		} else if(complexity >= 21) {
			high += unitSize;
		} else if(complexity >= 11) {
			moderate += unitSize;
		} else {
			simple += unitSize;
		}
	}
	println("Total simple lines: <simple>, total moderate: <moderate>, total high: <high> and total very high: <veryHigh>");
	return <simple, moderate, high, veryHigh>;
}

public int getComplexityRanking(tuple[int simple, int moderate, int high, int veryHigh] complexity, int total) {
	int simple = complexity.simple, moderate = complexity.moderate, high = complexity.moderate, veryHigh = complexity.veryHigh;
	
	real totalLines = toReal(total), 
	simplePercentage = (toReal(simple) / totalLines) * 100,
	moderatePercentage = (toReal(moderate) / totalLines) * 100,
	highPercentage = (toReal(high) / totalLines) * 100,
	veryHighPercentage = (toReal(veryHigh) / totalLines) * 100;
	
	int rankingNumber;
	str ranking;
	if (moderatePercentage <= 25 && highPercentage == 0 && veryHighPercentage == 0) {
		ranking = "++";
		rankingNumber = 2;
	} else if (moderatePercentage <= 30 && highPercentage <= 5 && veryHigh == 0) {
		ranking = "+";
		rankingNumber = 1;
	} else if (moderatePercentage <= 40 && highPercentage <= 10 && veryHigh == 0) {
		ranking = "0";
		rankingNumber = 0;
	} else if (moderatePercentage <= 50 && highPercentage <= 15 && veryHigh <= 5) {
		ranking = "-";
		rankingNumber = -1;
	} else {
		ranking = "--";
		rankingNumber = -2;
	}
	
	println("The percentage of simple code is <simplePercentage>%, moderate: <moderatePercentage>%, high: <highPercentage>% and very high: <veryHighPercentage>%");
	println("The cyclomatic complexity rank is <ranking>");
	
	return rankingNumber;
}

private int determineExpressionComplexity(Expression expr) {
	int expressionComplexity = visitExpression(expr);
	return (expressionComplexity == 0) ? 1 : expressionComplexity;
}

private int visitExpression(Expression expr) {
	top-down visit(expr) {
		case \infix(Expression lhs, str operator, Expression rhs, _) : {
			int complexityLhs = visitExpression(lhs), complexityRhs = visitExpression(rhs);
			int andComplexity = (operator == "&&") || (operator == "||") ? 2 : 0;
			return complexityLhs + complexityRhs + andComplexity;
		}
	}
	return 0;
}

private map[loc, Declaration] getMethodDeclarations(set[Declaration] declarations) {
	map[loc,Declaration] methodDeclarations = ();
	for (Declaration compilationUnit <- declarations) {
		visit (compilationUnit) {
			case m:\method(_,_,_,_,_) : methodDeclarations += (m@decl : m);
		}
	}
	return methodDeclarations;
}