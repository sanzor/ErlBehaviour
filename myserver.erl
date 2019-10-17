-module(myserver).
-record(cat,{name,color=green,description}).
-export([start_link/0,order_cat/4,return_cat/4,close_shop/1]).

start_link()->spawn_link(fun init/0).

order_cat(Pid,Name,Color,Description)->
    Ref=erlang:monitor(process,Pid),
    Pid ! {self(),Ref,{order,Name,Color,Description}},
    receive
        {Ref,Cat}->erlang:demonitor(process,[flush]),
                   Cat;
        {'DOWN',MsgRef,process,Pid,Reason}->
            erlang:error(Reason)
    after 5000
        erlang:error(timeout)
    end.