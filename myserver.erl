-module(myserver).

-record(cat,{name,color=green,description}).

start_link()->spawn_link(fun init/0).

init()->
    loop([]).

order_cat(Pid,Name,Color,Description)->
    Ref=erlang:monitor(process,Pid),
    Pid ! {self(),Ref,{order,Name,Color,Description}},
    receive 
        {Ref,Cat}->
            erlang:demonitor(Ref,[flush]),
            Cat;
        {'DOWN',Ref,process,Pid,Reason}->
            Pid ! error(Reason)
    after 5000 ->
        erlang:error(timeout)
    end.


close_shop(Pid)->
    Ref=erlang:monitor(process,Pid),
    Pid ! {self(),Ref,terminate},
    receive 
        {Ref,ok}->erlang:demonitor(Ref,[flush]),
                  ok;
        {'DOWN',Ref,process,Pid,Reason}->
            erlang:error(Reason)
    after 5000 ->
        erlang:error(timeout)
    end.

return_cat(Pid,Cat=#cat{})->
    Pid ! {return,Cat},
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
    

