{-
	This Server acts like a stripped-down IRCd. It relays messages and
	handles usernames, but doesn't have channels or many other features.
-}

import System.IO			-- For handles
import System.Environment	-- For getArgs
import Network.Socket		-- For sockets
import Control.Concurrent	-- For threads and channels

-- Global vars for configuration
max_connections = 30
listen_port = 8888

-- We'll define messages as (Username, Text)
type Msg = (String, String)

-- Does some initial setup, then turns over to listenLoop
main :: IO ()
main = do
	args <- getArgs
	if length args == 1 && isInteger (args !! 0)
	then
		do
		-- listen_port <- read (args !! 0) :: Int -- This bit isn't working yet
		msgs <- newChan						-- Stores all messages
		sock <- socket AF_INET Stream 0		-- Make new socket
		setSocketOption sock ReuseAddr 1	-- Set reusable listening socket
		bindSocket sock (SockAddrInet listen_port iNADDR_ANY) -- Bind any dev
		listen sock max_connections 		-- Set max connections
		listenLoop sock msgs
	else
		putStrLn "Usage: Server <port number>"

-- Listens for a new client, then forks off a handler
listenLoop :: Socket -> Chan Msg -> IO ()
listenLoop servSock msgs = do
	client <- accept servSock
	forkIO (handle client msgs) -- Run 'handle' on a background thread
	listenLoop servSock msgs

-- 'accept' returns a tuple of a socket and the address it's connected on
-- We're only interested in the socket right now
handle :: (Socket, SockAddr) -> Chan Msg -> IO ()
handle (sock, _) msgs = do
	s <- socketToHandle sock ReadWriteMode -- convert the socket to a handle
	hSetBuffering s NoBuffering -- Write byte by byte over the network
	hPutStr s "Your name: "
	name <- hGetLine s
	hPutStrLn s ("Hello " ++ name)
	hPutStrLn s "Welcome to the Server."
	write <- dupChan msgs
	read <- dupChan msgs
	forkIO (readUser name s write)
	readMsgs s read -- Do _not_ fork this line! We don't want hClose to run!
	hClose s -- This closes the handle _and_ the socket

-- This reads from the user and appends new messages to the global queue
readUser :: String -> Handle -> Chan Msg -> IO ()
readUser user sock msgs = do
	msg <- hGetLine sock
	writeChan msgs (user, msg)
	readUser user sock msgs

-- This reads from the message queue and prints results over socket to user
readMsgs :: Handle -> Chan Msg -> IO ()
readMsgs sock msgs = do
	(user, msg) <- readChan msgs
	hPutStrLn sock ("<" ++ user ++ "> " ++ msg)
	readMsgs sock msgs

-- Checks if a string contains only an integer
isInteger s = case reads s :: [(Integer, String)] of
	[(_, "")] -> True
	_         -> False
