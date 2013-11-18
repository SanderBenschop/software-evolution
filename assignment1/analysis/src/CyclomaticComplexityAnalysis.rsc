module CyclomaticComplexityAnalysis

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
	//Hierna gaan we voor alle implementaties van de method blokken recursief op zoek naar if's, for's, while's, (do-while?) en mogelijk nog een paar dingen.
	for (loc methodLocator <- methodDeclarations) {
		Declaration methodDeclaration = methodDeclarations[methodLocator];
		int decisionPoints = 0, returnStatements = 0;
		visit(methodDeclaration.impl) {
			
			/* Decision points */
			case \if(_, _) : decisionPoints += 1;
			case \if(_, _, _) : decisionPoints += 1;
			
			case \do(_,_) : decisionPoints += 1;
			case \while(_,_) : decisionPoints += 1;
			case \for(_,_,_) : decisionPoints += 1;
			case \for(_,_,_,_) : decisionPoints += 1;
			case \foreach(_,_,_) : decisionPoints += 1;
						
			//case \switch(_,_) : decisionPoints += 1; Do we count this?
			case \case(_) : decisionPoints += 1;
			case \defaultCase() : decisionPoints += 1;

			/* Flow interruption, should we count it if it's on the last line as well? */
			case \return() : returnStatements += 1;
			case \return(_) : returnStatements += 1;
		}
		
		println("Function with loc <methodLocator> has <decisionPoints> decision points and <returnStatements> return statements.");
	}
	return ();
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