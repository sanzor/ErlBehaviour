-module(script).
-import(bserver,[start_link/0]).
-export([start/0,svinit/0]).

start()->
    Server=bserver:start_link(),
    Client=spawn(fun()->receive MSG-> error(MSG)end end),
    {MServ,MCl}={get_mon(Server),get_mon(Client)},
    {{Server,MServ},{Client,MCl}},
    Server.
    
svinit()->
    Server=bserver:start_link(),
    Server.

get_mon(PID)->erlang:monitor(process,PID).