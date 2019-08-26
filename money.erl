-module(money).
-import(io,[fwrite/2,fwrite/1]).
-import(lists,[concat/1,reverse/1,append/2,nth/2,delete/2]).
-import(rand,[uniform/1]).
-import(file,[consult/1]).
-export([start/0,print_msgs/3,end_bank_processes/2,print_end_part/1]).

print_end_part([])->ok;
print_end_part([H|T])->
	fwrite("~s ~n",[H]),
	print_end_part(T).

end_bank_processes([],MsgList)->MsgList;	
end_bank_processes(BankPidNameLst,MsgList)->
	BankNo=uniform(length(BankPidNameLst)),
	{PID_Bank,Name}=nth(BankNo,BankPidNameLst),
	PID_Bank ! {endProcess,BankNo},
	receive
		{ActualVal,Val,Pos}->
			Msg=concat([Name, " has ",Val," dollar(s) remaining."]),
			end_bank_processes(delete(nth(Pos,BankPidNameLst), BankPidNameLst),[Msg|MsgList])
	end.

print_msgs(EndList,Count,BankPidNameLst)->
	
	if
		Count==0->
			NewEndList=append(end_bank_processes(BankPidNameLst,[]),EndList),
			fwrite("~n"),
			print_end_part(reverse(NewEndList));		
			
		true->
			
			receive
				{Msg,Params}->
					fwrite(Msg,Params),
					print_msgs(EndList,Count,BankPidNameLst);
				
				{endProcess,Name,ActualVal,Val}->
					if
						Val==0->
							Msg=concat([Name, " has reached the objective of ",ActualVal," dollar(s). Woo Hoo!"]),
							print_msgs([Msg|EndList],Count-1,BankPidNameLst);
						true->
							Msg=concat([Name, "  was only able to borrow ",ActualVal-Val," dollar(s). Boo Hoo!"]),
							print_msgs([Msg|EndList],Count-1,BankPidNameLst)
					end
			end
	end.		
			
make_bank_process([],Master_process,BankPIDLst)->BankPIDLst;
make_bank_process([H|T],Master_process,BankPIDLst)->
	{Name,Val}=H,
	fwrite("~s: ~p~n",[Name,Val]),
	PID_BANK=spawn(bank,bank_process,[Name,Val,Val,Master_process]),
	make_bank_process(T,Master_process,[{PID_BANK,Name}|BankPIDLst]).
	

createNewList([],NewBankPidNameLst)->NewBankPidNameLst;
createNewList([H|T],NewBankPidNameLst)->
	createNewList(T,[H|NewBankPidNameLst]).
	

make_customer_process([],BankPidNameLst,Master_process)->ok;
make_customer_process([H|T],BankPidNameLst,Master_process)->
	{Name,Val}=H,
	BPNLst=createNewList(BankPidNameLst,[]),
	spawn(customer,cust,[Name,Val,Val,BPNLst,Master_process]),
	make_customer_process(T,BankPidNameLst,Master_process).
	
	
print_customer_details([])->ok;
print_customer_details([H|T])->
	{Name,Val}=H,
	fwrite("~s: ~p~n",[Name,Val]),
	print_customer_details(T).


start()->
	BankTxt=consult("banks.txt"),
	CustTxt=consult("customers.txt"),
	if
		(length(element(2,BankTxt))>0) and (length(element(2,CustTxt))>0)->
				register(master_process,self()),
				Banks=element(2,BankTxt),
				Customers=element(2,CustTxt),
				
				fwrite("** Customers and loan objectives **"),
				fwrite("~n"),
				print_customer_details(Customers),
				fwrite("~n"),
				
				fwrite("** Banks and financial resources **"),
				fwrite("~n"),
				BankPidNameLst=make_bank_process(Banks,master_process,[]),
				fwrite("~n"),
	
				make_customer_process(Customers,BankPidNameLst,master_process),			
				print_msgs([],length(Customers),BankPidNameLst),
						
				unregister(master_process),
				fwrite("");
				
		true->
				fwrite("Please provide atleast one record of each banks and customers..~n")
				
	end.
%----latest%