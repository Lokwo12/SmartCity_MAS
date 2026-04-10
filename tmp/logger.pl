
:-dynamic log_store/4,started/0,recent_log/2.

dedup_window_ms(1200).

evi(log_print(_118321,_118323,_118325)):-statistics(walltime,[_118339,_118343]),(_118321=info->_118373='INFO';_118321=warn->_118373='WARN';_118321=error->_118373='ERROR';_118373=_118321),format('[logger +~wms] ~w src=~w | ~w~n',[_118339,_118373,_118323,_118325]).

evi(start):-retractall(started),assert(started),retractall(log_store(_118287,_118289,_118291,_118293)),retractall(recent_log(_118301,_118303)).

evi(should_print(_118167,_118169,_118171,_118173)):-statistics(walltime,[_118187,_118191]),dedup_window_ms(_118203),recent_log(_118167,_118215),_118187-_118215<_118203,!,true.

evi(should_print(_118079,_118081,_118083,_118085)):-statistics(walltime,[_118099,_118103]),retractall(recent_log(_118079,_118121)),assert(recent_log(_118079,_118099)),evi(log_print(_118081,_118083,_118085)).

evi(log(log(_117995,_117997,_117999))):-statistics(walltime,[_118013,_118017]),assert(log_store(_118013,_117999,_117997,_117995)),evi(should_print(k(_117995,_117999,_117997),_117995,_117999,_117997)).

evi(log(log(_117765,event(_117773,req(_117785),bin(_117789),truck(_117793),note(_117797)),_117769))):-statistics(walltime,[_117811,_117815]),assert(log_store(_117811,_117769,event(_117773,req(_117785),bin(_117789),truck(_117793),note(_117797)),_117765)),(atom_concat(smart_bin,_117889,_117789)->atom_concat(smartbin,_117889,_117899);_117899=_117789),format(atom(_117923),'~w bin=~w truck=~w note=~w',[_117773,_117899,_117793,_117797]),evi(should_print(k(_117765,_117769,event(_117773,_117785,_117789,_117793,_117797)),_117765,_117769,_117923)).

evi(log(log(error,_117719,_117721))):-evi(should_print(k(error,_117721,_117719),error,_117721,_117719)).

send_message(send_message(_117681,_117683),_117677):-!,send_message(_117681,_117677).

send_message(inform(_117647,_117649),_117643):-!,send_message(_117647,_117643).

send_message(_117615,_117617):-evi(log_in(_117615,_117617)).

evi(log_in(inform(log(_117581,_117583,_117585),_117577),_117571)):-evi(log(log(_117581,_117583,_117585))).

evi(log_in(log(_117531,_117533,_117535),_117527)):-evi(log(log(_117531,_117533,_117535))).

evi(log_in(send_message(log(_117487,_117489,_117491),_117483),_117477)):-evi(log(log(_117487,_117489,_117491))).

evi(log_in(send_message(inform(log(_117437,_117439,_117441),_117433),_117427),_117421)):-evi(log(log(_117437,_117439,_117441))).

evi(monitor(dummy)):-started.

evi(monitor(dummy)):- \+started,evi(start).

monitor(dummy):-evi(monitor(dummy)).

:-dynamic receive/1.

:-dynamic send/2.

:-dynamic isa/3.

comm_trace(off).

log_comm(_117187,_117189,_117191):-comm_trace(on),!,write(comm),write(_117187),write(from),write(_117191),write(payload),write(_117189),nl.

log_comm(_117169,_117171,_117173).

safe_told(_117131,_117133):-current_predicate(told/2)->told(_117131,_117133);true.

safe_told(_117077,_117079,_117081):-current_predicate(told/3)->told(_117077,_117079,_117081);_117081=0.

safe_tell(_117029,_117031,_117033):-current_predicate(tell/3)->tell(_117029,_117031,_117033);true.

log_comm(var_Tag,var_X,var_Ag):-comm_trace(on),!,write(comm),write(var_Tag),write(from),write(var_Ag),write(payload),write(var_X),nl.

log_comm(_116917,_116919,_116921).

safe_told(var_Ag,var_M):-current_predicate(told/2)->told(var_Ag,var_M);true.

safe_told(var_Ag,var_M,var_T):-current_predicate(told/3)->told(var_Ag,var_M,var_T);var_T=0.

safe_tell(var_To,var_Ag,var_M):-current_predicate(tell/3)->tell(var_To,var_Ag,var_M);true.

receive(send_message(_116739,_116741)):-safe_told(_116741,send_message(_116739)),call_send_message(_116739,_116741).

send(_116683,send_message(_116689,_116691)):-safe_tell(_116683,_116691,send_message(_116689)),send_m(_116683,send_message(_116689,_116691)).

receive(send_message(var_X,var_Ag)):-safe_told(var_Ag,send_message(var_X)),call_send_message(var_X,var_Ag).

receive(propose(var_A,var_C,var_Ag)):-safe_told(var_Ag,propose(var_A,var_C)),call_propose(var_A,var_C,var_Ag).

receive(cfp(var_A,var_C,var_Ag)):-safe_told(var_Ag,cfp(var_A,var_C)),call_cfp(var_A,var_C,var_Ag).

receive(accept_proposal(var_A,var_Mp,var_Ag)):-safe_told(var_Ag,accept_proposal(var_A,var_Mp),var_T),call_accept_proposal(var_A,var_Mp,var_Ag,var_T).

receive(reject_proposal(var_A,var_Mp,var_Ag)):-safe_told(var_Ag,reject_proposal(var_A,var_Mp),var_T),call_reject_proposal(var_A,var_Mp,var_Ag,var_T).

receive(failure(var_A,var_M,var_Ag)):-safe_told(var_Ag,failure(var_A,var_M),var_T),call_failure(var_A,var_M,var_Ag,var_T).

receive(cancel(var_A,var_Ag)):-safe_told(var_Ag,cancel(var_A)),call_cancel(var_A,var_Ag).

receive(execute_proc(var_X,var_Ag)):-safe_told(var_Ag,execute_proc(var_X)),call_execute_proc(var_X,var_Ag).

receive(query_ref(var_X,var_N,var_Ag)):-safe_told(var_Ag,query_ref(var_X,var_N)),call_query_ref(var_X,var_N,var_Ag).

receive(inform(var_X,var_M,var_Ag)):-safe_told(var_Ag,inform(var_X,var_M),var_T),call_inform(var_X,var_Ag,var_M,var_T).

receive(inform(var_X,var_Ag)):-safe_told(var_Ag,inform(var_X),var_T),call_inform(var_X,var_Ag,var_T).

receive(refuse(var_X,var_Ag)):-safe_told(var_Ag,refuse(var_X),var_T),call_refuse(var_X,var_Ag,var_T).

receive(agree(var_X,var_Ag)):-safe_told(var_Ag,agree(var_X)),call_agree(var_X,var_Ag).

receive(confirm(var_X,var_Ag)):-safe_told(var_Ag,confirm(var_X),var_T),call_confirm(var_X,var_Ag,var_T).

receive(disconfirm(var_X,var_Ag)):-safe_told(var_Ag,disconfirm(var_X)),call_disconfirm(var_X,var_Ag).

receive(reply(var_X,var_Ag)):-safe_told(var_Ag,reply(var_X)).

send(var_To,query_ref(var_X,var_N,var_Ag)):-safe_tell(var_To,var_Ag,query_ref(var_X,var_N)),send_m(var_To,query_ref(var_X,var_N,var_Ag)).

send(var_To,send_message(var_X,var_Ag)):-safe_tell(var_To,var_Ag,send_message(var_X)),send_m(var_To,send_message(var_X,var_Ag)).

send(var_To,reject_proposal(var_X,var_L,var_Ag)):-safe_tell(var_To,var_Ag,reject_proposal(var_X,var_L)),send_m(var_To,reject_proposal(var_X,var_L,var_Ag)).

send(var_To,accept_proposal(var_X,var_L,var_Ag)):-safe_tell(var_To,var_Ag,accept_proposal(var_X,var_L)),send_m(var_To,accept_proposal(var_X,var_L,var_Ag)).

send(var_To,confirm(var_X,var_Ag)):-safe_tell(var_To,var_Ag,confirm(var_X)),send_m(var_To,confirm(var_X,var_Ag)).

send(var_To,propose(var_X,var_C,var_Ag)):-safe_tell(var_To,var_Ag,propose(var_X,var_C)),send_m(var_To,propose(var_X,var_C,var_Ag)).

send(var_To,disconfirm(var_X,var_Ag)):-safe_tell(var_To,var_Ag,disconfirm(var_X)),send_m(var_To,disconfirm(var_X,var_Ag)).

send(var_To,inform(var_X,var_M,var_Ag)):-safe_tell(var_To,var_Ag,inform(var_X,var_M)),send_m(var_To,inform(var_X,var_M,var_Ag)).

send(var_To,inform(var_X,var_Ag)):-safe_tell(var_To,var_Ag,inform(var_X)),send_m(var_To,inform(var_X,var_Ag)).

send(var_To,refuse(var_X,var_Ag)):-safe_tell(var_To,var_Ag,refuse(var_X)),send_m(var_To,refuse(var_X,var_Ag)).

send(var_To,failure(var_X,var_M,var_Ag)):-safe_tell(var_To,var_Ag,failure(var_X,var_M)),send_m(var_To,failure(var_X,var_M,var_Ag)).

send(var_To,execute_proc(var_X,var_Ag)):-safe_tell(var_To,var_Ag,execute_proc(var_X)),send_m(var_To,execute_proc(var_X,var_Ag)).

send(var_To,agree(var_X,var_Ag)):-safe_tell(var_To,var_Ag,agree(var_X)),send_m(var_To,agree(var_X,var_Ag)).

call_send_message(_115111,_115113):-nonvar(_115111)->log_comm(dispatch,_115111,_115113),(nonvar(_115113),_115113\=self,catch(send_message(_115111,_115113),_115177,fail);catch(send_message(_115111,_115205),_115197,fail);catch(call(evi(_115111)),_115217,fail);true);true.

call_execute_proc(var_X,var_Ag):-execute_proc(var_X,var_Ag).

call_query_ref(var_X,var_N,var_Ag):-clause(agent(var_A),var__),not(var(var_X)),meta_ref(var_X,var_N,var_L,var_Ag),a(message(var_Ag,inform(query_ref(var_X,var_N),values(var_L),var_A))).

call_query_ref(var_X,var__,var_Ag):-clause(agent(var_A),var__),var(var_X),a(message(var_Ag,refuse(query_ref(variable),motivation(refused_variables),var_A))).

call_query_ref(var_X,var_N,var_Ag):-clause(agent(var_A),var__),not(var(var_X)),not(meta_ref(var_X,var_N,var__,var__)),a(message(var_Ag,inform(query_ref(var_X,var_N),motivation(no_values),var_A))).

call_agree(var_X,var_Ag):-clause(agent(var_A),var__),ground(var_X),meta_agree(var_X,var_Ag),a(message(var_Ag,inform(agree(var_X),values(yes),var_A))).

call_confirm(var_X,var_Ag,var_T):-ground(var_X),statistics(walltime,[var_Tp,var__]),asse_cosa(past_event(var_X,var_T)),retractall(past(var_X,var_Tp,var_Ag)),assert(past(var_X,var_Tp,var_Ag)).

call_disconfirm(var_X,var_Ag):-ground(var_X),retractall(past(var_X,var__,var_Ag)),retractall(past_event(var_X,var__)).

call_agree(var_X,var_Ag):-clause(agent(var_A),var__),ground(var_X),not(meta_agree(var_X,var__)),a(message(var_Ag,inform(agree(var_X),values(no),var_A))).

call_agree(var_X,var_Ag):-clause(agent(var_A),var__),not(ground(var_X)),a(message(var_Ag,refuse(agree(variable),motivation(refused_variables),var_A))).

call_inform(var_X,var_Ag,var_M,var_T):-asse_cosa(past_event(inform(var_X,var_M,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(inform(var_X,var_M,var_Ag),var__,var_Ag)),assert(past(inform(var_X,var_M,var_Ag),var_Tp,var_Ag)),trigger_inform_handlers(var_X,var_M,var_Ag).

call_inform(var_X,var_Ag,var_T):-asse_cosa(past_event(inform(var_X,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(inform(var_X,var_Ag),var__,var_Ag)),assert(past(inform(var_X,var_Ag),var_Tp,var_Ag)),trigger_inform_handlers(var_X,none,var_Ag).

trigger_inform_handlers(var_X,var_M,var_Ag):-catch(call(eve(inform_E(var_X,var_Ag))),_113947,true),catch(call(eve(inform_E(var_X,var_M,var_Ag))),_113975,true),catch(call(eve(inform_E(var_X))),_114005,true),catch(call(eve(inform_(var_X,var_Ag))),_114031,true),catch(call(eve(inform_(var_X,var_M,var_Ag))),_114059,true),catch(call(eve(inform_(var_X))),_114089,true),catch(call(eve(eve(inform_(var_X,var_Ag)))),_114115,true),catch(call(eve(eve(inform_(var_X,var_M,var_Ag)))),_114147,true),catch(call(eve(eve(inform_(var_X)))),_114175,true).

call_refuse(var_X,var_Ag,var_T):-clause(agent(var_A),var__),asse_cosa(past_event(var_X,var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(var_X,var__,var_Ag)),assert(past(var_X,var_Tp,var_Ag)),a(message(var_Ag,reply(received(var_X),var_A))).

call_cfp(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_113711,var_Ontology,_113715),_113705),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_cfp(var_A,var_C,var_Ag,_113749)),a(message(var_Ag,propose(var_A,[_113749],var_AgI))),retractall(ext_agent(var_Ag,_113787,var_Ontology,_113791)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_113585,var_Ontology,_113589),_113579),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,accept_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_113655,var_Ontology,_113659)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_113473,var_Ontology,_113477),_113467),not(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,reject_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_113529,var_Ontology,_113533)).

call_accept_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(accepted_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(accepted_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(accepted_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_reject_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(rejected_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(rejected_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(rejected_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_failure(var_A,var_M,var_Ag,var_T):-asse_cosa(past_event(failed_action(var_A,var_M,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(failed_action(var_A,var_M,var_Ag),var__,var_Ag)),assert(past(failed_action(var_A,var_M,var_Ag),var_Tp,var_Ag)).

call_cancel(var_A,var_Ag):-if(clause(high_action(var_A,var_Te,var_Ag),_113037),retractall(high_action(var_A,var_Te,var_Ag)),true),if(clause(normal_action(var_A,var_Te,var_Ag),_113071),retractall(normal_action(var_A,var_Te,var_Ag)),true).

external_refused_action_propose(var_A,var_Ag):-clause(not_executable_action_propose(var_A,var_Ag),var__).

evi(external_refused_action_propose(var_A,var_Ag)):-clause(agent(var_Ai),var__),a(message(var_Ag,failure(var_A,motivation(false_conditions),var_Ai))),retractall(not_executable_action_propose(var_A,var_Ag)).

refused_message(var_AgM,var_Con):-clause(eliminated_message(var_AgM,var__,var__,var_Con,var__),var__).

refused_message(var_To,var_M):-clause(eliminated_message(var_M,var_To,motivation(conditions_not_verified)),_112853).

evi(refused_message(var_AgM,var_Con)):-clause(agent(var_Ai),var__),a(message(var_AgM,inform(var_Con,motivation(refused_message),var_Ai))),retractall(eliminated_message(var_AgM,var__,var__,var_Con,var__)),retractall(eliminated_message(var_Con,var_AgM,motivation(conditions_not_verified))).

send_jasper_return_message(var_X,var_S,var_T,var_S0):-clause(agent(var_Ag),_112701),a(message(var_S,send_message(sent_rmi(var_X,var_T,var_S0),var_Ag))).

gest_learn(var_H):-clause(past(learn(var_H),var_T,var_U),_112649),learn_if(var_H,var_T,var_U).

evi(gest_learn(var_H)):-retractall(past(learn(var_H),_112525,_112527)),clause(agente(_112547,_112549,_112551,var_S),_112543),name(var_S,var_N),append(var_L,[46,112,108],var_N),name(var_F,var_L),manage_lg(var_H,var_F),a(learned(var_H)).

cllearn:-clause(agente(_112319,_112321,_112323,var_S),_112315),name(var_S,var_N),append(var_L,[46,112,108],var_N),append(var_L,[46,116,120,116],var_To),name(var_FI,var_To),open(var_FI,read,_112419,[]),repeat,read(_112419,var_T),arg(1,var_T,var_H),write(var_H),nl,var_T==end_of_file,!,close(_112419).

send_msg_learn(var_T,var_A,var_Ag):-a(message(var_Ag,confirm(learn(var_T),var_A))).

told(_112249,send_message(_112255)):-true.

told(_112225,inform(_112233,_112235),70):-true.

told(_112203,inform(_112211),70):-true.

told(_112183,refuse(_112189)):-true.

told(_112161,refuse(_112167,_112169)):-true.

tell(_112139,_112141,send_message(_112147)):-true.

tell(_112117,_112119,refuse(_112125)):-true.

tell(_112093,_112095,refuse(_112101,_112103)):-true.

tell(_112069,_112071,inform(_112077,_112079)):-true.

tell(_112047,_112049,inform(_112055)):-true.

meta(_112019,_112019,_112023):-nonvar(_112019),!.
