
:-dynamic log_store/4,started/0.

:-dynamic recent_log/2.

dedup_window_ms(1200).

evi(start):-retractall(started),assert(started),retractall(log_store(_127157,_127159,_127161,_127163)),retractall(recent_log(_127171,_127173)).

a(should_print(_127043)):-statistics(walltime,[_127057,_127061]),dedup_window_ms(_127073),recent_log(_127043,_127085),_127057-_127085<_127073,!,false.

a(should_print(_126973)):-statistics(walltime,[_126987,_126991]),retractall(recent_log(_126973,_127009)),assert(recent_log(_126973,_126987)),true.

eve(log(log(_126803,_126805,_126807))):-statistics(walltime,[_126821,_126825]),assert(log_store(_126821,_126807,_126805,_126803)),a(should_print(k(_126803,_126807,_126805))),!,write('[LOG-'),write(_126803),write('] '),write(_126821),write(' ['),write(_126807),write('] -> '),write(_126805),nl.

eve(log(log(_126737,_126739,_126741))):-statistics(walltime,[_126755,_126759]),assert(log_store(_126755,_126741,_126739,_126737)),true.

eve(log(log(_126415,event(_126423,req(_126435),bin(_126439),truck(_126443),note(_126447)),_126419))):-statistics(walltime,[_126461,_126465]),assert(log_store(_126461,_126419,event(_126423,req(_126435),bin(_126439),truck(_126443),note(_126447)),_126415)),a(should_print(k(_126415,_126419,event(_126423,_126435,_126439,_126443,_126447)))),!,write('[LOG-'),write(_126415),write('] '),write(_126461),write(' ['),write(_126419),write('] '),write(_126423),write(' req='),write(_126435),write(' bin='),write(_126439),write(' truck='),write(_126443),write(' note='),write(_126447),nl.

eve(log(log(_126293,event(_126301,req(_126313),bin(_126317),truck(_126321),note(_126325)),_126297))):-statistics(walltime,[_126339,_126343]),assert(log_store(_126339,_126297,event(_126301,req(_126313),bin(_126317),truck(_126321),note(_126325)),_126293)),true.

eve(log(log(error,_126201,_126203))):-a(should_print(k(error,_126203,_126201))),!,write('[ALERT] '),write(_126203),write(' -> '),write(_126201),nl.

eve(log(log(error,_126175,_126177))):-true.

send_message(inform(log(_126131,_126133,_126135),_126127),_126121):-fire_event(log(log(_126131,_126133,_126135))).

send_message(log(_126085,_126087,_126089),_126081):-fire_event(log(log(_126085,_126087,_126089))).

send_message(send_message(log(_126045,_126047,_126049),_126041),_126035):-fire_event(log(log(_126045,_126047,_126049))).

send_message(send_message(inform(log(_125999,_126001,_126003),_125995),_125989),_125983):-fire_event(log(log(_125999,_126001,_126003))).

fire_event(_125923):-(catch(call(eve(_125923)),_125941,fail);catch(call(evi(_125923)),_125957,fail)),!.

fire_event(_125909).

evi(monitor(dummy)):-started.

evi(monitor(dummy)):- \+started,evi(start).

monitor(dummy):-evi(monitor(dummy)).

:-dynamic receive/1.

:-dynamic send/2.

:-dynamic isa/3.

comm_trace(off).

log_comm(_125687,_125689,_125691):-comm_trace(on),!,write(comm),write(_125687),write(from),write(_125691),write(payload),write(_125689),nl.

log_comm(_125669,_125671,_125673).

safe_told(_125631,_125633):-current_predicate(told/2)->told(_125631,_125633);true.

safe_told(_125577,_125579,_125581):-current_predicate(told/3)->told(_125577,_125579,_125581);_125581=0.

safe_tell(_125529,_125531,_125533):-current_predicate(tell/3)->tell(_125529,_125531,_125533);true.

log_comm(var_Tag,var_X,var_Ag):-comm_trace(on),!,write(comm),write(var_Tag),write(from),write(var_Ag),write(payload),write(var_X),nl.

log_comm(_125417,_125419,_125421).

safe_told(var_Ag,var_M):-current_predicate(told/2)->told(var_Ag,var_M);true.

safe_told(var_Ag,var_M,var_T):-current_predicate(told/3)->told(var_Ag,var_M,var_T);var_T=0.

safe_tell(var_To,var_Ag,var_M):-current_predicate(tell/3)->tell(var_To,var_Ag,var_M);true.

receive(send_message(_125239,_125241)):-safe_told(_125241,send_message(_125239)),call_send_message(_125239,_125241).

send(_125183,send_message(_125189,_125191)):-safe_tell(_125183,_125191,send_message(_125189)),send_m(_125183,send_message(_125189,_125191)).

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

call_send_message(_123611,_123613):-nonvar(_123611)->log_comm(dispatch,_123611,_123613),(nonvar(_123613),_123613\=self,catch(send_message(_123611,_123613),_123677,fail);catch(send_message(_123611,_123705),_123697,fail);catch(call(evi(_123611)),_123717,fail);true);true.

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

trigger_inform_handlers(var_X,var_M,var_Ag):-catch(call(eve(inform_E(var_X,var_Ag))),_122447,true),catch(call(eve(inform_E(var_X,var_M,var_Ag))),_122475,true),catch(call(eve(inform_E(var_X))),_122505,true),catch(call(eve(inform_(var_X,var_Ag))),_122531,true),catch(call(eve(inform_(var_X,var_M,var_Ag))),_122559,true),catch(call(eve(inform_(var_X))),_122589,true),catch(call(eve(eve(inform_(var_X,var_Ag)))),_122615,true),catch(call(eve(eve(inform_(var_X,var_M,var_Ag)))),_122647,true),catch(call(eve(eve(inform_(var_X)))),_122675,true).

call_refuse(var_X,var_Ag,var_T):-clause(agent(var_A),var__),asse_cosa(past_event(var_X,var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(var_X,var__,var_Ag)),assert(past(var_X,var_Tp,var_Ag)),a(message(var_Ag,reply(received(var_X),var_A))).

call_cfp(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_122211,var_Ontology,_122215),_122205),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_cfp(var_A,var_C,var_Ag,_122249)),a(message(var_Ag,propose(var_A,[_122249],var_AgI))),retractall(ext_agent(var_Ag,_122287,var_Ontology,_122291)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_122085,var_Ontology,_122089),_122079),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,accept_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_122155,var_Ontology,_122159)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_121973,var_Ontology,_121977),_121967),not(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,reject_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_122029,var_Ontology,_122033)).

call_accept_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(accepted_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(accepted_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(accepted_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_reject_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(rejected_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(rejected_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(rejected_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_failure(var_A,var_M,var_Ag,var_T):-asse_cosa(past_event(failed_action(var_A,var_M,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(failed_action(var_A,var_M,var_Ag),var__,var_Ag)),assert(past(failed_action(var_A,var_M,var_Ag),var_Tp,var_Ag)).

call_cancel(var_A,var_Ag):-if(clause(high_action(var_A,var_Te,var_Ag),_121537),retractall(high_action(var_A,var_Te,var_Ag)),true),if(clause(normal_action(var_A,var_Te,var_Ag),_121571),retractall(normal_action(var_A,var_Te,var_Ag)),true).

external_refused_action_propose(var_A,var_Ag):-clause(not_executable_action_propose(var_A,var_Ag),var__).

evi(external_refused_action_propose(var_A,var_Ag)):-clause(agent(var_Ai),var__),a(message(var_Ag,failure(var_A,motivation(false_conditions),var_Ai))),retractall(not_executable_action_propose(var_A,var_Ag)).

refused_message(var_AgM,var_Con):-clause(eliminated_message(var_AgM,var__,var__,var_Con,var__),var__).

refused_message(var_To,var_M):-clause(eliminated_message(var_M,var_To,motivation(conditions_not_verified)),_121353).

evi(refused_message(var_AgM,var_Con)):-clause(agent(var_Ai),var__),a(message(var_AgM,inform(var_Con,motivation(refused_message),var_Ai))),retractall(eliminated_message(var_AgM,var__,var__,var_Con,var__)),retractall(eliminated_message(var_Con,var_AgM,motivation(conditions_not_verified))).

send_jasper_return_message(var_X,var_S,var_T,var_S0):-clause(agent(var_Ag),_121201),a(message(var_S,send_message(sent_rmi(var_X,var_T,var_S0),var_Ag))).

gest_learn(var_H):-clause(past(learn(var_H),var_T,var_U),_121149),learn_if(var_H,var_T,var_U).

evi(gest_learn(var_H)):-retractall(past(learn(var_H),_121025,_121027)),clause(agente(_121047,_121049,_121051,var_S),_121043),name(var_S,var_N),append(var_L,[46,112,108],var_N),name(var_F,var_L),manage_lg(var_H,var_F),a(learned(var_H)).

cllearn:-clause(agente(_120819,_120821,_120823,var_S),_120815),name(var_S,var_N),append(var_L,[46,112,108],var_N),append(var_L,[46,116,120,116],var_To),name(var_FI,var_To),open(var_FI,read,_120919,[]),repeat,read(_120919,var_T),arg(1,var_T,var_H),write(var_H),nl,var_T==end_of_file,!,close(_120919).

send_msg_learn(var_T,var_A,var_Ag):-a(message(var_Ag,confirm(learn(var_T),var_A))).

told(_120749,send_message(_120755)):-true.

told(_120725,inform(_120733,_120735),70):-true.

told(_120703,inform(_120711),70):-true.

told(_120683,refuse(_120689)):-true.

told(_120661,refuse(_120667,_120669)):-true.

tell(_120639,_120641,send_message(_120647)):-true.

tell(_120617,_120619,refuse(_120625)):-true.

tell(_120593,_120595,refuse(_120601,_120603)):-true.

tell(_120569,_120571,inform(_120577,_120579)):-true.

tell(_120547,_120549,inform(_120555)):-true.

meta(_120519,_120519,_120523):-nonvar(_120519),!.
