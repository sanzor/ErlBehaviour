-module(bclient).
-import(bserver,[emp]).


create(Pid,Name,Age,Description)->
    Ref=erlang:make_ref(),
    Pid !{}