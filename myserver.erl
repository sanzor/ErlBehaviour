-module(myserver).
-compile([export_all,debug_info]).
-record(cat,{name,color=green,description}).

start_link()->spawn_link(fun init/0).

init()->
    loop([]).


call(Pid,Msg)->
    Ref=erlang:monitor(process,Pid),
    Pid ! {Ref,Msg},
    receive 
        {Ref,Reply}->erlang:demonitor(Pid,[flush]),
                     Reply;
        {'DOWN',Ref,process,Pid,Reason}->
            erlang:error(Reason)
    after 5000 ->
        erlang:error(timeout)
end.

cast(Pid,Msg)->
    Pid ! {async,Msg},
    ok.

loop(Module,State)->
    receive
        {async,MSG}->loop(Module,Module:handle_cast(Msg,State));
        {sync,Pid,Ref,Msg}->loop(Module,Module_call(Pid,Ref,Msg))
end.
order_cat(Pid,Name,Color,Description)->
    myserver:call(Pid,{order,{Name,Color,Description}}).


close_shop(Pid)->
    myserver:call(Pid,terminate).
    
return_cat(Pid,Cat=#cat{})->
   myserver:call(Pid,Cat),
   ok.

loop(Cats)->
    receive 
    {Pid,Ref,{order,Name,Color,Description}}->
        if Cats =:= [] ->
              Pid !{Ref,make_cat(Name,Color,Description)},
              loop(Cats);
           Cats =/=[] ->
              Pid ! {Ref,hd(Cats)},
              loop(tl(Cats))
        end;
    {Pid,Ref,terminate}->
                Pid !{Ref,ok},
                terminate(Cats);
    {return,Cat=#cat{}}->
        
        loop([Cat|Cats]);
    Unknown -> io:format("unnkown message"),
               loop(Cats)
    end.
make_cat(Name,Color,Description)->#cat{name=Name,color=Color,description=Description}.

terminate(Cats)->
    [io:format("~p was set free",C#cat.name)|| C <-Cats ].
    

