-module(coffeeshop).
-export([start/1]).

start(Number) ->
	io:format("~nWelcome to StarLang's!~n~n"),
	WaitressPID = spawn(fun() -> waitress:start() end),
	start_baristas(Number, WaitressPID),
	customers:start(WaitressPID).

% Start up the desired number of baristas
start_baristas(Number, WaitressPID) ->
	case Number of
		0 -> 
			ok;
		_ ->  
			spawn(fun() -> barista:start(Number, WaitressPID) end),
			start_baristas(Number-1, WaitressPID)
	end.
