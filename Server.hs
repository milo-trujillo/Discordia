{-
	This Server acts like a stripped-down IRCd. It relays messages and
	handles usernames, but doesn't have channels or many other features.
-}

import System.IO						-- For handles
import System.Environment				-- For getArgs
import Network.Socket					-- For sockets
import Control.Concurrent				-- For threads and channels
import Control.Exception				-- For exceptions
import Data.Text (strip, pack, unpack)	-- For stripping whitespace
import Text.Regex.PCRE					-- For regexes

-- Global vars for configuration
max_connections = 30
announce_name = "Server" -- Name used by all server announcements
nick_regex = "([a-zA-Z0-9]+)" -- Valid characters for a nickname

-- We'll define messages as (Username, Text)
type Msg = (String, String)

-- Does some initial setup, then turns over to listenLoop
main :: IO ()
main = do
	args <- getArgs
	if length args == 1 && isInteger (args !! 0)
	then
		do
		putStrLn "Starting Discordia..."
		let portno = (read (head args) :: Integer) -- Convert first arg to Int
		msgs <- newChan						-- Stores all messages
		sock <- socket AF_INET Stream 0		-- Make new socket
		setSocketOption sock ReuseAddr 1	-- Set reusable listening socket
		-- Bind the socket to the listen port on every interface
		bindSocket sock (SockAddrInet (fromIntegral portno) iNADDR_ANY)
		listen sock max_connections 		-- Set max connections
		forkIO (clearChannel msgs)			-- Prevent memory leak in msgs
		putStrLn "Hail Eris!"
		listenLoop sock msgs
	else
		putStrLn "Usage: Server <port number>"

-- Listens for a new client, then forks off a handler
listenLoop :: Socket -> Chan Msg -> IO ()
listenLoop servSock msgs = do
	client <- Network.Socket.accept servSock
	forkIO (handleClient client msgs) -- Run 'handle' on a background thread
	listenLoop servSock msgs

-- 'accept' returns a tuple of a socket and the address it's connected on
-- We're only interested in the socket right now
handleClient :: (Socket, SockAddr) -> Chan Msg -> IO ()
handleClient (sock, _) msgs = do
	s <- socketToHandle sock ReadWriteMode -- convert the socket to a handle
	hSetBuffering s NoBuffering -- Write byte by byte over the network
	hPutStr s "Your name: "
	name <- hGetLine s
	hPutStrLn s "" -- Print a newline, since the previous hPutStr didn't
	if (name == announce_name || (name =~ nick_regex :: Bool) == False ) then do
		hPutStrLn s "Sorry, that's a forbidden name"
		hPutStr s   "You may use only alphanumeric characters, "
		hPutStrLn s "and may not impersonate the server."
		hClose s
	else do
		hPutStrLn s ("Hello, " ++ name)
		writeChan msgs (announce_name, name ++ " has entered the server")
		indiv <- dupChan msgs -- Copy the channel for this individial user
		forkIO (readUser name s indiv)
		readMsgs s indiv -- Do _not_ fork, we don't want hClose to run early!
		hClose s -- This closes the handle _and_ the socket

-- This reads from the user and appends new messages to the global queue
readUser :: String -> Handle -> Chan Msg -> IO ()
readUser user sock msgs = do
	eof <- hIsEOF sock -- Check if there's data to read before we try
	if eof then do
		hClose sock
		writeChan msgs (announce_name, user ++ " has left the server")
	else do
		Control.Exception.catch(getInput)
			(\(SomeException _) ->do
				hClose sock
				writeChan msgs (announce_name, user ++ " has left the server")
				return ()
			)
		where
			getInput = do
				fullmsg <- hGetLine sock
				let msg = stripMsg fullmsg
				if (length msg /= 0) -- Don't post blank messages
					then do
						-- We should probably break this out to a switch later
						if (msg =~ ("^/nick " ++ nick_regex) :: Bool) 
							then changeUsername user msg sock msgs
							else do
								writeChan msgs (user, msg)
								readUser user sock msgs
					else readUser user sock msgs

-- We parse the nick line to make sure it's okay, then change username
changeUsername :: String -> String -> Handle -> Chan Msg -> IO ()
changeUsername user msg sock msgs = do
	let results = (msg =~ ("^/nick " ++ nick_regex) :: [[String]])
	if (length (results !! 0) == 2 && (results !! 0 !! 1) /= announce_name)
		then do
			let newuser = results !! 0 !! 1
			writeChan msgs (announce_name, 
				user ++ " has changed their name to " ++ newuser)
			readUser newuser sock msgs
	else readUser user sock msgs

-- This reads from the message queue and prints results over socket to user
readMsgs :: Handle -> Chan Msg -> IO ()
readMsgs sock msgs = do
	(user, msg) <- readChan msgs
	-- hIsOpen blocks, so we use exceptions instead
	handle (\(SomeException _) -> hClose sock) $ do
		hPutStrLn sock ("<" ++ user ++ "> " ++ msg)
		readMsgs sock msgs

-- This function constantly empties a channel, and never returns.
-- This prevents a memory leak from the original channel never getting emptied.
clearChannel :: Chan Msg -> IO ()
clearChannel chan = do
	(_, _) <- readChan chan
	clearChannel chan

-- Strips whitespace from the start and end of a string
stripMsg :: String -> String
stripMsg = unpack . Data.Text.strip . pack

-- Checks if a string contains only an integer
isInteger :: String -> Bool
isInteger s = case reads s :: [(Integer, String)] of
	[(_, "")] -> True
	_         -> False

