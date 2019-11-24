-module(script).
-import(bserver,[start_link/0]).
-export([start/0]).

start()->
    Server=bserver:start_link(),
    Client=spawn(fun()->receive MSG-> error(MSG)end end),
    {MServ,MCl}={get_mon(Server),get_mon(Client)},
    {{Server,MServ},{Client,MCl}},
    Server.
    

get_mon(PID)->erlang:monitor(process,PID).