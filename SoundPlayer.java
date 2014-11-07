import java.io.*;
import java.net.URL;
import java.applet.*;

public class SoundPlayer
{
	private static AudioClip msgReceived;

	public SoundPlayer()
	{
		try
		{
			URL url = this.getClass().getResource("sounds/msg.wav");
			String file = url.toString();
			String urls = file.replaceFirst("file:/", "file:///");
			msgReceived = Applet.newAudioClip(new URL(urls));
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
			if( s == "new message" )
				msgReceived.play();
		}
		catch(Exception e)
		{
			System.err.println("Error playing sound: " + e.getMessage() + "\n");
		}
	}
}
