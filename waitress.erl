-module(waitress).
-export([start/0]).

% Represents a waitress bot. Takes orders from Customers.
start() ->
	receive
		% Handle a ready barista message 
		{BaristaNumber, BaristaPID} when is_integer(BaristaNumber) -> 
			receive
				{Customer, Beverage} when is_pid(Beverage) /= true -> 
					io:format("Waitress: Barista ~p, please make a ~s for ~s!~n", [BaristaNumber, Beverage, Customer]),
					BaristaPID ! {Customer, Beverage},
					start();
				{goodbye, CustPID} -> 
					io:format("Waitress: ALL THE CUSTOMERS ARE GONE. QUITTIN' TIME!~n", []),
					clear_orders(BaristaNumber, BaristaPID),
					CustPID ! goodbye
				end;
		% Handle a customer order message
		{Customer, Beverage} when is_pid(Beverage) /= true -> 
			receive
				{BaristaNumber, BaristaPID} when is_integer(BaristaNumber) ->
					io:format("Waitress: Barista ~p, please make a ~s for ~s!~n", [BaristaNumber, Beverage, Customer]),
					BaristaPID ! {Customer, Beverage},
					start();
				{goodbye, CustPID} -> 
					io:format("Waitress: ALL THE CUSTOMERS ARE GONE. QUITTIN' TIME!~n", []),
					clear_orders(),
					CustPID ! goodbye
				end;
		% Handle no more customers message, close up shop!
		{goodbye, CustPID} -> 
			io:format("Waitress: ALL THE CUSTOMERS ARE GONE. QUITTIN' TIME!~n", []),
			clear_orders(),
			CustPID ! goodbye
	end.

% Clears orders once a barista "Ready" has already been consumed
clear_orders(_, BaristaPID) ->
	receive
		{Customer, Beverage} when is_pid(Beverage) /= true ->
			 BaristaPID ! {Customer, Beverage},
			 clear_orders();
		_ -> 
			BaristaPID ! goodbye,
			clear_orders()
	end.

% Clear all remaining orders
clear_orders() -> 
	receive
		% Handle a customer order message
		{Customer, Beverage} when is_pid(Beverage) /= true -> 
			receive
				{BaristaNumber, BaristaPID} when is_integer(BaristaNumber) ->
					io:format("Waitress: Barista ~p, please make a ~s for ~s!~n", [BaristaNumber, Beverage, Customer]),
					BaristaPID ! {Customer, Beverage},
					clear_orders()
			end

		after 6000 -> 
			close_baristas()
	end.

% Tell the baristas to end operation
close_baristas() -> 
	receive 
		{_, BaristaPID} when is_pid(BaristaPID) -> 
			BaristaPID ! goodbye,
			close_baristas()
	
		after 6000 -> ok
	end.
