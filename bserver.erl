-module(bserver).
-behaviour(gen_server).
-record(company,{
    name,
    founded,
    emps
}).
-record(emp,{
    name,
    age,
    wage=0
}).

init(_)->#comapny{
   name="Aberco",
   founded=1993,
   emps=orddict:new()
}.
start(Module,InitialState)->spawn(fun()->init(Module,InitialState)).
start_link(Module,InitialState)->spawn_link(fun()->init(Module,InitialState)).


init(Module,InitialState)->
    loop(Module,Module:init(InitialState)).

loop(Module,C)->
    receive 
        {async,Msg}->loop(Module,bserver:handle_cast(Msg,C));
        {sync,Pid,Ref,Msg}->loop(Module,bserver:handle_call(Msg,{Pid,Ref},C))
    end.
make_emp(Name,Age,Wage)->
    #emp{
    name=Name,
    age=Age,
    wage=Wage
}.
reply({Pid,Ref},Msg)->
    Pid ! {Ref,Msg}.

terminate(Name,Emps)->
    NewEmps=case orddict:find(Name,Emps) of 
            {ok,Emp}->
                orddict:erase(Name,Emps);
            _ -> Emps
            end,
    NewEmps.
    


handle_call({hire,{Name,Age,Wage}},{Pid,Ref},C=#company{emps=Emps})->
    Emp=bserver:make_emp(Name,Age,Wage),
    NewEmps=orddict:store(Ref,Emp,Emps),
    bserver:reply({Pid,Ref},{hired,Name}),
    C#company{emps=NewEmps};
handle_call({terminate,Name,From,C)->
    NewEmps=bserver:terminate(Name,C#company.emps),
    C#company{emps=NewEmps};
handle_call({relocate,{Pid,Ref},C=#company{emps=Emps}})->
    Refs=orddict:fetch_keys(Emps),
    Dict=orddict:foldl(terminate,Emps,Refs),
    C#company{emps=Dict}.













init(Module,State)->