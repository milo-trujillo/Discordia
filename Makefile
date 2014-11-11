# Set compilers
HC= ghc
JAVAC= javac

# Set options for creating a jar file
JAR= jar
JAROPTS= cvfe
JARNAME= Client.jar

JAVASRC= Client.java SoundPlayer.java

server:
	$(HC) Server.hs

client:
	$(JAVAC) $(JAVASRC)

jar:
	$(JAR) $(JAROPTS) $(JARNAME) Client Client.class ClientSetup.class SoundPlayer.class sounds/msg.wav

all:
	$(HC) Server.hs
	$(JAVAC) $(JAVASRC)

clean:
	rm *.o *.hi *.class *.jar Server
