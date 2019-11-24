-module(bclient).
-import(bserver,[makeRecord/3]).
-export([create/4,getall/1]).



create(Pid,Name,Age,Description)->
    Ref=erlang:monitor(process,Pid),
    Pid ! {sync,self(),Ref,{hire,{Name,Age,Description}}},
    receive
        {Ref,Msg}->Msg;
        {'DOWN',Ref,process,Pid,Reason}->did_not_hire
    end.

getall(Pid)->
    Ref=erlang:monitor(process,Pid),
    Pid ! {sync,self(),Ref,get_all},
    receive
        {{Pid,Ref},Emps}->Emps;
        Err ->"Could not fetch emps :"++Err
    end. 


    





