-module(script).
-import(bserver,[start_link/0]).
-export([start_script/0]).

start_script()->
    Server=bserver:start_link(),
    Client=spawn(fun()->receive MSG-> error(MSG)end end),
    {MServ,MCl}={get_mon(Server),get_mon(Client)},
    {{Server,MServ},{Client,MCl}}.
    

get_mon(PID)->erlang:monitor(process,PID).