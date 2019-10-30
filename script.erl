-module(script).
-import([bserver]).

start_script()->
    Server=bserver:start_link(),
    Client=spawn(fun()->receive MSG-> error(MSG)end end),
    {MServ,MCl}={get_mon(Server),get_mon(Client)}.
    

get_mon(PID)->erlang:monitor(process,PID).