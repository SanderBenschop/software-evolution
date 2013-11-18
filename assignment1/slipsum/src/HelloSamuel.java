/**
 * Samuel L Jackson says hi to the world!
 */
public class HelloSamuel {
    
    public static void main(String[] args) {
        printFirstParagraph();
        printFirstParagraphDuplicate();
        printSecondParagraph();
        printThirdParagraph();
        printFirstParagraphDuplicate2();
        printFirstParagraphPartialDuplicate();
        printConditionally(true);
        printConditionally(false);
        getReleaseYear();
    }
    
    //This is the first paragraph
    private static void printFirstParagraph() {
        System.out.println("You think water moves fast? "
                + "You should see ice. It moves like it has a mind. "
                + "Like it knows it killed the world once and got a taste for murder. "
                + "After the avalanche, it took us a week to climb out. "
                + "Now, I don't know exactly when we turned on each other, "
                + "but I know that seven of us survived the slide... and only five made it out. "
                + "Now we took an oath, that I'm breaking now. We said we'd say it was the snow that "
                + "killed the other two, but it wasn't. Nature is lethal but it doesn't hold a candle to man.");
        "".replace("", "");
    }
    
    private static void printFirstParagraphDuplicate() {
        System.out.println("You think water moves fast? "
                + "You should see ice. It moves like it has a mind. "
                + "Like it knows it killed the world once and got a taste for murder. "
                + "After the avalanche, it took us a week to climb out. "
                + "Now, I don't know exactly when we turned on each other, "
                + "but I know that seven of us survived the slide... and only five made it out. "
                + "Now we took an oath, that I'm breaking now. We said we'd say it was the snow that "
                + "killed the other two, but it wasn't. Nature is lethal but it doesn't hold a candle to man.");
        "".replace("", "");
    }

    /** This is the second paragraph. */
    private static void printSecondParagraph() {
        System.out.println("Look, just because I don't be givin' no man a foot massage don't make"
                + " it right for Marsellus to throw Antwone into a glass motherfuckin' house, fuckin'"
                + " up the way the nigger talks. Motherfucker do that shit to me, he better paralyze my "
                + "ass, 'cause I'll kill the motherfucker, know what I'm sayin'?");
    }

    /** These are **/ /** multiple comments **/ //on one line
    private static void printThirdParagraph() {
        System.out.println("Do you see any Teletubbies in here? Do you see a slender plastic tag clipped "
                + "to my shirt with my name printed on it? Do you see a little Asian child with a blank "
                + "expression on his face sitting outside on a mechanical helicopter that shakes when you "
                + "put quarters in it? No? Well, that's what you see at a toy store. And you must think you're "
                + "in a toy store, because you're here shopping for an infant named Jeb.");
    }
    
    private static void printFirstParagraphDuplicate2() {
        System.out.println("You think water moves fast? "
                + "You should see ice. It moves like it has a mind. "
                + "Like it knows it killed the world once and got a taste for murder. "
                + "After the avalanche, it took us a week to climb out. "
                + "Now, I don't know exactly when we turned on each other, "
                + "but I know that seven of us survived the slide... and only five made it out. "
                + "Now we took an oath, that I'm breaking now. We said we'd say it was the snow that "
                + "killed the other two, but it wasn't. Nature is lethal but it doesn't hold a candle to man.");
        "".replace("", "");
    }
    
    private static void printFirstParagraphPartialDuplicate() {
        System.out.println("You think water moves fast? "
                + "You should see ice. It moves like it has a mind. "
                + "Like it knows it killed the world once and got a taste for murder. "
                + "After the avalanche, it took us a week to climb out. "
                + "Now, I don't know exactly when we turned on each other, "
                + "but I know that seven of us survived the slide... and only five made it out. "
                + "Now we took an oath, that I'm breaking now. We said we'd say it was the snow that ");
    }
    
    private static void printConditionally(boolean first) {
    	if (first) {
    		System.out.println("Your bones don't break, mine do. That's clear. Your cells react to bacteria and "
    				+ "viruses differently than mine. You don't get sick, I do. That's also clear. But for some "
    				+ "reason, you and I react the exact same way to water. We swallow it too fast, we choke. "
    				+ "We get some in our lungs, we drown. However unreal it may seem, we are connected, you and I. "
    				+ "We're on the same curve, just on opposite ends.");
        	if (true) {
        		System.out.println("Ah hamburgers, the cornerstone of any nutricious breakfast.");
        	}
    	} else {
    		System.out.println("Normally, both your asses would be dead as fucking fried chicken, but you happen to "
    				+ "pull this shit while I'm in a transitional period so I don't wanna kill you, I wanna help you. "
    				+ "But I can't give you this case, it don't belong to me. Besides, I've already been through too "
    				+ "much shit this morning over this case to hand it over to your dumb ass.");
    	}
    	
    	for(int i = 0; i < 10; i++) {
    		System.out.println("Royale With Cheese!");
    	}
    	
    	int runTwice = 0;
    	do {
    		System.out.println("And you will know my name if the lord when I lay my vengeance upon thee.");
    		runTwice += 1;
    	} while(runTwice < 2);
    	
    	return;
    }
    
    private static int getReleaseYear() {
    	return 1994;
    }
}