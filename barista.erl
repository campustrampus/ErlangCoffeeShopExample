-module(barista).
-export([start/2]).

% Represents a barista bot that makes the requested beverages for customers.
start(Number, WaitressPID) ->
	io:format("Barista~p: Ready for an order.~n", [Number]),
	WaitressPID ! {Number, self()},
	receive
		{Customer, Beverage} when is_pid(Beverage) /= true -> 
			io:format("Barista~p: Making ~s a ~s.~n", [Number, Customer, Beverage]),
			timer:sleep(5000),
			io:format("Barista~p: Order up! I have a ~s for ~s.~n", [Number, Beverage, Customer]),
			start(Number, WaitressPID);
		
		goodbye -> 
			io:format("Barista~p: SHUTTING DOWN.~n", [Number])
		
		end.
