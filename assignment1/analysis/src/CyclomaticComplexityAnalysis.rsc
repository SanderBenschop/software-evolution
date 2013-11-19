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
			case \switch(_,_) : decisionPoints += 1;
		}
		cyclomaticComplexityPerUnit += (methodLocator : decisionPoints + 1);
	}
	return cyclomaticComplexityPerUnit;
}

public void determineRelativeComplexity(map[loc, int] complexityPerMethod) {
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
}

private int determineExpressionComplexity(Expression expr) {
	int expressionComplexity = visitExpression(expr);
	return (expressionComplexity == 0) ? 1 : expressionComplexity;
}

private int visitExpression(Expression expr) {
	top-down visit(expr) {
		case \infix(Expression lhs, str operator, Expression rhs, _) : {
			int complexityLhs = visitExpression(lhs), complexityRhs = visitExpression(rhs);
			int andComplexity = (operator == "&&") ? 2 : 0;
			return complexityLhs + complexityRhs + andComplexity;
		}
	}
	return 0;
}

//Refactor: getMethodASTEclipse oid
private map[loc, Declaration] getMethodDeclarations(set[Declaration] declarations) {
	map[loc,Declaration] methodDeclarations = ();
	for (Declaration compilationUnit <- declarations) {
		for (javaClass <- compilationUnit.types) {
			for (methodDeclaration <- javaClass.body) {
				methodDeclarations += (methodDeclaration@decl : methodDeclaration);
			}
		}
	}
	return methodDeclarations;
}