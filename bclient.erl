-module(bclient).
-import(bserver,[makeRecord/3]).
-export([hire/4,getall/1,send/3]).

send(Pid,Mode,Msg)->
    if  Mode =:= sync ->
            Ref=erlang:monitor(process,Pid),
            Pid ! {Mode,Pid,Ref,Msg},
            receive 
                {Ref,Msg}->Msg;
                {'DOWN',Ref,process,Pid,Reason}->{unsuccessful,Reason}
            end;
        Mode =/= sync ->
            Pid ! {async,Msg}
    end.

hire(Pid,Name,Age,Wage)->
    bclient:send(Pid,sync,{hire,{Name,Age,Wage}}).


getall(Pid)->
    bclient:send(Pid,sync,get_all).




    





