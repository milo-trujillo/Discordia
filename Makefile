# Set compilers
HC= ghc
JAVAC= javac
JAR= jar

server:
	$(HC) Server.hs

client:
	$(JAVAC) Client.java SoundPlayer.java

jar:
	$(JAR) cvfe Client.jar Client Client.class ClientSetup.class SoundPlayer.class sounds/msg.wav

all:
	$(HC) Server.hs
	$(JAVAC) Client.java

clean:
	rm *.o *.hi *.class *.jar Server
