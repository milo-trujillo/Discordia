# Set compilers
HC= ghc
JAVAC= javac

# Set options for creating a jar file
JAR= jar
JAROPTS= cvfe
JARNAME= Client.jar

server:
	$(HC) Server.hs

client:
	$(JAVAC) Client.java SoundPlayer.java

jar:
	$(JAR) $(JAROPTS) $(JARNAME) Client Client.class ClientSetup.class SoundPlayer.class sounds/msg.wav

all:
	$(HC) Server.hs
	$(JAVAC) Client.java

clean:
	rm *.o *.hi *.class *.jar Server
