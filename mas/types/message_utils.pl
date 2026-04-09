% messageA(+To, +Msg, +From)
% Sends a message (Msg) from agent From to agent To using DALI's tell/3 primitive.
% This implementation assumes DALI's tell/3 is available in the environment.

messageA(To, Msg, From) :-
    format('[DEBUG] messageA: ~w -> ~w : ~w~n', [From, To, Msg]),
    ( To == logger ->
        format('[LOGGER-DEBUG] ~w <- ~w : ~w~n', [To, From, Msg])
    ; true ),
    tell(To, Msg, From).

% messageA(+To, +Msg)
% Sends a message from the current agent (inferred from context)
messageA(To, Msg) :-
    agent(From),
    !,
    messageA(To, Msg, From).

messageA(To, Msg) :-
    messageA(To, Msg, unknown).
