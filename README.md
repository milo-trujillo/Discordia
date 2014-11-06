Discordia
=========

Overview
--------
This is a tiny, rapidly deployable chat server and accompanying client. Lighter than IRC, dead simple to deploy, and better than netcat!

The server portion is built in Haskell for concurrency and avoiding memory leaks, while the client is written in Java to be cross platform.

Server
------

The server is a multithreaded, IRC-esque creation. You just open a socket to it, choose a username, and then everything you write will be relayed by the server to any other connected clients.

Client
------

The client is mostly just a Java frontend to some sockets. It connects to the server, sends and receives messages, and generally tries to make the chat process better than netcat would.

Dependencies
------------
### Client

The Java client requires javax, swing, and some networking libraries that probably all come with the JDK.

### Server

The Haskell server requires System.IO, which should come with ghc, and Network.Socket, which may not.

History
-------

This project started as a highschool compsci project, which is archived at [csChatServ.](https://github.com/milo-trujillo/csChatServ)
