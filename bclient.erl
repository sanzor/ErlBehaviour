-module(bclient).
-import(bserver,[makeRecord/3]).
-export([hire/4,getall/1,send/3,initLoop/1,loopProc/1]).

initLoop(Server)->
    spawn(?MODULE,loopProc,[Server]).
loopProc(Server)->
    receive
        {Pid,Mode,Msg}->
            send(Server,Mode,Msg),
            loopProc(Server);
        stop->exit(normal);
        _ -> io:format("Could not process message")
     end.


% loop()->
%     receive 
%         {Pid,Name,Age,Wage}->hire(Pid,Name,Age,Wage);
%         {Pid}->get_all()
send(Mode,Pid,Msg)->
    if  Mode =:= sync ->
            Ref=erlang:monitor(process,Pid),
            Pid ! {sync,Pid,Ref,Msg},
            receive 
                {Ref,Msg}->Msg;
                {'DOWN',Ref,process,Pid,Reason}->{unsuccessful,Reason}
            end;
        Mode =/= sync ->
            Pid ! {async,Msg}
    end.

hire(Pid,Name,Age,Wage)->
    bclient:send(sync,Pid,{hire,{Name,Age,Wage}}).


getall(Pid)->
    bclient:send(sync,Pid,get_all).




    





