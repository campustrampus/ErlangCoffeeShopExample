-module(customers).
-export([start/1]).

start(WaitressPID) ->
	Customer_data = [{'Srujan Reddy','Green tea'},
		 {'Srinath Goud','Espresso'},
		 {'Matthew', 'Americano'},
		 {'Ishit', 'Latte'},
		 {'Sri Devi', 'Pumpkin Spice Latte'},
		 {'Bhavani Hari', 'Cappuccino'},
		 {'Devaharsha', 'Decaf'},
		 {'Mahmoud', 'Earl grey tea'},
		 {'Sandeep', 'Red-eye'},
		 {'Saisharan', 'Cold brew coffee'},
		 {'Vienkata Jagadeesh', 'Coffee'},
		 {'Siva Venkata Sandeep', 'Double shot espresso'},
		 {'Keval', 'Mocha'},
		 {'Sai Naresh', 'Macchiato'},
		 {'Michael', 'Cafe ole'},
		 {'Wanessa', 'Hot Chocolate'},
		 {'Vishw', 'Vietnamese coffee'},
		 {'Kris', 'Irish Coffee'}],
	send_message(WaitressPID, Customer_data).

send_message(WaitressPID, Customer_array) -> 
	timer:sleep(2000),
	case length(Customer_array) of
		0 -> close_waitress(WaitressPID);
		_ -> WaitressPID ! hd(Customer_array),
			send_message(WaitressPID, tl(Customer_array)),
			ok
	end.	

close_waitress(WaitressPID) ->
	WaitressPID ! {goodbye, self()},
	receive
		goodbye -> ok
	end.
