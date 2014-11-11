import java.io.*;
import java.net.URL;
import java.applet.*;

public class SoundPlayer
{
	// Make this static so if we instantiate multiple sound players the 
	// memory for the sound clip is only allocated once
	private static AudioClip msgReceived = null;
	// This is marked volatile to make it threadsafe, so playing two sounds
	// won't yield an exception
	private volatile boolean playing = false;

	public SoundPlayer()
	{
		try
		{
			// Load all the sound files from disk if needed
			if( msgReceived == null )
			{
				URL url = this.getClass().getResource("sounds/msg.wav");
				String file = url.toString();
				String urls = file.replaceFirst("file:/", "file:///");
				msgReceived = Applet.newAudioClip(new URL(urls));
			}
		}
		catch(Exception e)
		{
			System.err.println("Error loading sound: " + e.getMessage() + "\n");
		}	
	}

	public void play(String s)
	{
		try
		{
			if( playing ) // Abort if a sound is already playing
				return;
			playing = true;
			if( s == "new message" )
				msgReceived.play();
			playing = false;
		}
		catch(Exception e)
		{
			System.err.println("Error playing sound: " + e.getMessage() + "\n");
		}
	}
}
