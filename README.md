csChatServ
==========

Overview
--------
My goal is to create a multi-threaded chat system allowing communication be-tween machines. The system will consist of two parts: a chat server written in Haskell, and an accompanying chat client written in Java.  

Server
------
The chat server will be a tcp-daemon written in Haskell. It will wait for incoming connections, and upon receiving them, fork to handle the socket. Messages from a socket will be forwarded to all other sockets in an IRC-like manner. The server will manage usernames and inter-socket communication, but will not support
multiple channels or servers like a full IRC system. Haskell was chosen for its
succinctness and ease of multi-threading.

Client
------
The chat client will be a Java frontend to the socket APIs. It will manage a
GUI that takes messages from a user, breaks them into packets, and transmits
them to the server. Upon receiving a message from the server the message will
be displayed to the user. Java was chosen for its cross-platform GUI elements.

Dependencies
------------
### Client

The Java client requires javax, swing, and some networking libraries that probably all come with the JDK.

### Server

The Haskell server requires System.IO, which should come with ghc, and Network.Socket, which may not.
