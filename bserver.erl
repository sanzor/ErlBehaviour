-module(bserver).
-behaviour(gen_server).
-compile(export_all).
-export([start_link/0,init/1]).
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
makeRecord(Name,Age,Wage)->
    #emp{name=Name,age=Age,wage=Wage}.

start_link()->start(?MODULE,bserver:init([])).

init(_)->#company{
   name="Aberco",
   founded=1993,
   emps=orddict:new()
}.

start(Module,InitialState)->
    spawn(fun()-> init(Module,InitialState) end).
start_link(Module,InitialState)->
    spawn_link(fun()-> init(Module,InitialState) end).


init(Module,InitialState)->
    loop(Module,Module:init(InitialState)).

loop(Module,C)->
    receive 
        {async,Msg}->loop(Module,bserver:handle_cast(Msg,C));
        {sync,Pid,Ref,Msg}->loop(Module,bserver:handle_call(Msg,{Pid,Ref},C));
        Msg ->exit(Msg)
    end.


make_emp(Name,Age,Wage)->
    #emp{
    name=Name,
    age=Age,
    wage=Wage
}.
reply({Pid,Ref},Msg)->
    Pid ! {Ref,Msg}.

terminate(Ref,Emps)->
    case orddict:find(Ref,Emps) of 
            {ok,Emp}->
                {orddict:erase(Ref,Emps),Emp};
            _ -> {Emps,not_found}
    end.
    
    
getMessage(Emp)when Emp==not_found->"Could not find Employee";
getMessage(Emp)->{kicked,Emp}.

empExists(Emp=#emp{name=Sname},Emps)->
    lists:foldl(fun({K,#emp{name=Name}},Exists)->
                Exists, Name =:=Sname
                end,false,Emps).

handle_call(get_all,{Pid,Ref},Emps=#company.emps)->
    bserver:reply({Pid,Ref},Emps);
handle_call({hire,{Name,Age,Wage}},{Pid,Ref},C=#company{emps=Emps})->
    Emp=bserver:make_emp(Name,Age,Wage),
    NewEmps=orddict:store(Ref,Emp,Emps),
    bserver:reply({Pid,Ref},{hired,Name}),
    C#company{emps=NewEmps};
handle_call(terminate,{Pid,Ref},C)->
    {Emps,MaybeEmp}=bserver:terminate(Ref,C#company.emps),
    Result=getMessage(MaybeEmp),
    bserver:reply({Pid,Ref},Result),
    C#company{emps=Emps};
handle_call(relocate,{Pid,Ref},C=#company{emps=Emps})->
     Refs=orddict:fetch_keys(Emps),
     Dict=orddict:foldl(fun(Ref,Acc)->bserver:terminate(Ref,Acc) end,Emps,Refs),
     C#company{emps=Dict}.

handle_cast({promote,Increase},C)->
    NewEmps=orddict:foldl(fun({K,V},T)->[{K,V+Increase}|T] end,[],C#company.emps),
    C#company{emps=NewEmps}.


