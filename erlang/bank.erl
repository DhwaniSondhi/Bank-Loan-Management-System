-module(bank).
-import(timer,[sleep/1]).
-export([bank_process/4]).

bank_process(Name,ActualVal,Val,Master_process)->
	sleep(50),
	receive
		{CustPos,CustVal,CustName,cust,PID_CUST}->
			if
				Val-CustVal>=0->
					Master_process ! {"~s approves a loan of ~p dollars from ~s~n",[Name,CustVal,CustName]},
					PID_CUST ! {1,CustPos},
					bank_process(Name,ActualVal,Val-CustVal,Master_process);
				true->
					Master_process ! {"~s denies a loan of ~p dollars from ~s~n",[Name,CustVal,CustName]},
					PID_CUST ! {0,CustPos},
					bank_process(Name,ActualVal,Val,Master_process)
			end;
		
		{endProcess,BankNo}->
			Master_process ! {ActualVal,Val,BankNo}
	end.
%---latest%