-module(coffeeshop).
-export([start/1]).

start(Number) ->
	WaitressPID = spawn(fun() -> waitress() end),
	start_baristas(Number, WaitressPID),
	customers:start(WaitressPID).

% Start up the desired number of baristas
start_baristas(Number, WaitressPID) ->
	case Number of
		0 -> 
			ok;
		_ ->  
			spawn(fun() -> barista(Number, WaitressPID) end),
			start_baristas(Number-1, WaitressPID)
	end.
	
% Represents a waitress bot. Takes orders from Customers.
waitress() ->
	receive
		% Handle a ready barista message 
		{X, PID} when is_integer(X) -> 
			receive
				{Customer, Beverage} when is_pid(Beverage) /= true -> 
					io:format("Waitress: Barista ~p, please make a ~s for ~s!~n", [X, Beverage, Customer]),
					PID ! {Customer, Beverage},
					waitress();
				{goodbye, CustPID} -> 
					io:format("Waitress: ALL THE CUSTOMERS ARE GONE. QUITTIN' TIME!~n", []),
					clear_orders(X, PID),
					CustPID ! goodbye
				end;
		% Handle a customer order message
		{Customer, Beverage} when is_pid(Beverage) /= true -> 
			receive
				{X, PID} when is_integer(X) ->
					io:format("Waitress: Barista ~p, please make a ~s for ~s!~n", [X, Beverage, Customer]),
					PID ! {Customer, Beverage},
					waitress();
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
clear_orders(_, PID) ->
	receive
		{Customer, Beverage} when is_pid(Beverage) /= true ->
			 PID ! {Customer, Beverage},
			 clear_orders();
		_ -> 
			PID ! goodbye,
			clear_orders()
	end.

% Clear all remaining orders
clear_orders() -> 
	receive
		% Handle a customer order message
		{Customer, Beverage} when is_pid(Beverage) /= true -> 
			receive
				{X, PID} when is_integer(X) ->
					io:format("Waitress: Barista ~p, please make a ~s for ~s!~n", [X, Beverage, Customer]),
					PID ! {Customer, Beverage},
					clear_orders()
			end

		after 6000 -> 
			close_baristas()
	end.

% Tell the baristas to end operation
close_baristas() -> 
	receive 
		{_, PID} when is_pid(PID) -> 
			PID ! goodbye,
			close_baristas()
	
		after 6000 -> ok
	end.

% Represents a barista bot. Makes the requested beverages for customers.
barista(Number, WaitressPID) ->
	io:format("Barista~p: Ready for an order.~n", [Number]),
	WaitressPID ! {Number, self()},
	receive
		{Customer, Beverage} when is_pid(Beverage) /= true -> 
			io:format("Barista~p: Making ~s a ~s.~n", [Number, Customer, Beverage]),
			timer:sleep(5000),
			io:format("Barista~p: Order up! I have a ~s for ~s.~n", [Number, Beverage, Customer]),
			barista(Number, WaitressPID);
		
		goodbye -> 
			io:format("Barista~p: SHUTTING DOWN.~n", [Number])
		
		end.
