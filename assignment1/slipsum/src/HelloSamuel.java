/**
 * Samuel L Jackson says hi to the world!
 */
public class HelloSamuel {
    
    public static void main(String[] args) {
        printFirstParagraph();
        printFirstParagraphDuplicate();
        printSecondParagraph();
        printThirdParagraph();
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
}