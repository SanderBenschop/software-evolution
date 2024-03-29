module CodeDuplicationAnalysis

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import analysis::m3::metrics::LOC;
import IO;
import List;
import Set;
import String;
import Map;
import CodeAnalysis;
import util::Math;

public int findDuplicates(M3 model) {
	println("Starting on reading code into string");
    str code = removeTrailingAndEmptyLines(getProjectJavaContentsAsString(model));
    println("Finished reading code into string");
    
    str deduplicatedCode = code;
    int n = countLinesOfCode(code), end = 6;
    while(end <= n, n >= 6) {
        int begin = end - 6;
        //println("Main loop: begin is <begin>, end is <end>, n is <n>");
        deduplicatedCode = removeDuplicate(begin, end, n, deduplicatedCode);
        end = end + 1;
    }
    
    int duplicatedLines = n - countLinesOfCode(deduplicatedCode);
    printDuplicationRating(duplicatedLines, n);
    
    return duplicatedLines;
}

private void printDuplicationRating(int duplicatedLines, int linesOfCode) {
	set[tuple[real lowerboundary, real upperboundary, str rank]] ranking = { <0.0,3.0,"++">, <3.0,5.0,"+">, <5.0,10.0,"0">, <10.0,20.0,"-">, <20.0,100.0,"--"> };
	for (r <- ranking) {
		real percentageDuplicated = (toReal(duplicatedLines) / toReal(linesOfCode)) * 100;
   		if (r.lowerboundary <= percentageDuplicated && percentageDuplicated < r.upperboundary) {
   			println("The duplication rank is <r.rank>, total number of duplicated lines is <duplicatedLines> which is <percentageDuplicated>% of the total of <linesOfCode> lines.");
   			break;
   		}
	}
}

private str removeDuplicate(int begin, int end, int rightMax, str code) {
	//println("Looking for duplicates from <begin> to <end>, max is <rightMax>");
    
    list[str] splitted = split("\n", code);
    int sizeSplitted = size(splitted);
    if (end > sizeSplitted || end > rightMax) {
    	return code;
    }
    
    str rejoined = joinStringRange(splitted, begin, end);
    list[int] occurences = findOccurrences(rejoined, code);
    
    //Keep trying a larger block until either you're out of the file or you find no more duplicates
    str deduplicatedCode = code;
    if (size(occurences) > 1) {
    	deduplicatedCode = removeDuplicate(begin, end+1, rightMax, code);
    	occurences = findOccurrences(rejoined, deduplicatedCode);
    }

    int numberOfOccurences = size(occurences);
    if (numberOfOccurences > 1) {
    	int wordLength = size(rejoined);
        //Remove duplicates in all but first place.
        for (int x <- [1..end-1], x < numberOfOccurences) {
            int location = occurences[x], remainingSize = size(deduplicatedCode);
            //println("Removing duplicate starting on location <location>, remaining code size is <remainingSize>");
            str before = substring(deduplicatedCode, 0, location-1), after = substring(deduplicatedCode, location + wordLength + 1);
            deduplicatedCode = before + "\n" + after;
            occurences = decrementIntegers(occurences, wordLength);
        }
    }
    return deduplicatedCode;
}

private list[int] findOccurrences(str snippet, str allCode) {
    return findAll(allCode, snippet);
}

private list[int] decrementIntegers(list[int] integers, int x) {
	int decrementByX(int element) { return element - x; }
	return mapper(integers, decrementByX);
}


private str joinStringRange(list[str] fullStringList, int begin, int end) {
	list[str] sublist = fullStringList[begin..end];
    return intercalate("\n", sublist);
}
