-module(customer).
-import(lists,[nth/2,delete/2]).
-import(rand,[uniform/1]).
-import(timer,[sleep/1]).
-export([cust/5]).

getAmt(Val)->
	if
		Val>50->
			50;
		true->
			Val
	end.

cust(Name,ActualVal,Val,BankPidNameLst,Master_process)->
	sleep(100),
	if	
		((Val>0)  and  (length(BankPidNameLst)>0))->
			BankNo=uniform(length(BankPidNameLst)),
			{PID_BANK,BankName}=nth(BankNo,BankPidNameLst),
			Amt=uniform(getAmt(Val)),
			sleep(uniform(90)+10),
			Master_process ! {"~s requests a loan of ~p dollar(s) from ~s~n",[Name,Amt,BankName]},
			PID_BANK ! {BankNo,Amt,Name,cust,self()},
			receive
				{Res,Pos}->
					if
						Res==1->
							cust(Name,ActualVal,Val-Amt,BankPidNameLst,Master_process);
						true->
							NewBankPidNameLst=delete(nth(Pos,BankPidNameLst), BankPidNameLst),
							cust(Name,ActualVal,Val,NewBankPidNameLst,Master_process)
					end
			end;
			
		true->
				Master_process ! {endProcess,Name,ActualVal,Val}
	end.
%----latest%