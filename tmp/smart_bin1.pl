
:-dynamic bin_level/1,bin_state/1,hb_counter/1,started/0,last_reset_req/1.

bin_level(0).

max_capacity(100).

fill_step(20).

bin_state(idle).

shared_token(city_token_2026).

tesg(delta(2)).

evi(start):-retractall(started),assert(started),agent(var_BinId),write('[SMARTBIN '),write(var_BinId),write('] startI fired'),nl,tesg(delta(var_D)),retractall(hb_counter(var__)),retractall(last_reset_req(var__)),assert(hb_counter(var_D)),true.

evi(monitor(dummy)):-hb_counter(var_C),var_C>1,var_C1 is var_C-1,retract(hb_counter(var_C)),assert(hb_counter(var_C1)).

evi(monitor(dummy)):-hb_counter(1),tesg(delta(var_D)),retract(hb_counter(1)),assert(hb_counter(var_D)),evi(tick).

evi(tick):-bin_state(waiting),true.

evi(tick):-bin_state(idle),evi(maybe_fill).

evi(maybe_fill):-bin_state(idle),a(increase_level).

a(increase_level):-bin_level(var_L),max_capacity(var_M),var_L<var_M,fill_step(var_S),var_NL is min(var_L+var_S,var_M),retract(bin_level(var_L)),assert(bin_level(var_NL)),agent(var_BinId),write('[SMARTBIN '),write(var_BinId),write('] level='),write(var_NL),write('%'),nl,a(message(logger,send_message(log(info,level_update,var_BinId),var_BinId),var_BinId)),a(post_fill(var_NL,var_M)).

a(post_fill(var_NL,var_M)):-var_NL>=var_M,evi(full_trigger).

a(post_fill(var_NL,var_M)):-var_NL<var_M.

evi(full_trigger):-bin_state(idle),retract(bin_state(idle)),assert(bin_state(waiting)),agent(var_BinId),write('[SMARTBIN '),write(var_BinId),write('] FULL -> notify control_center'),nl,shared_token(var_Token),a(message(control_center,send_message(bin_full(var_BinId,var_Token),var_BinId),var_BinId)),a(message(control_center,send_message(bin_full(var_BinId),var_BinId),var_BinId)),a(message(logger,send_message(log(info,bin_full,var_BinId),var_BinId),var_BinId)).

eve(reset_bin):-retract(bin_level(var__)),assert(bin_level(0)),retract(bin_state(var__)),assert(bin_state(idle)),agent(var_BinId),a(message(logger,send_message(log(info,bin_reset,var_BinId),var_BinId),var_BinId)).

eve(retry_collection):-agent(var_BinId),shared_token(var_Token),a(message(control_center,send_message(bin_full(var_BinId,var_Token),var_BinId),var_BinId)),a(message(control_center,send_message(bin_full(var_BinId),var_BinId),var_BinId)).

send_message(bin_full(var_Bin,var_Token),var__From):-shared_token(var_Token),evi(bin_full(var_Bin)).

send_message(reset_bin,var__From):-evi(reset_bin).

send_message(reset_bin(var_Bin,var_ReqId,var_Token),control_center):-shared_token(var_Token),agent(var_Bin),last_reset_req(var_ReqId),a(message(control_center,send_message(reset_ack(var_Bin,var_ReqId,var_Token),var_Bin),var_Bin)).

send_message(reset_bin(var_Bin,var_ReqId,var_Token),control_center):-shared_token(var_Token),agent(var_Bin),\+last_reset_req(var_ReqId),assert(last_reset_req(var_ReqId)),evi(reset_bin),a(message(control_center,send_message(reset_ack(var_Bin,var_ReqId,var_Token),var_Bin),var_Bin)).

send_message(retry_collection,var__From):-evi(retry_collection).

send_message(retry_collection(var_Bin,var_ReqId,var_Token),control_center):-shared_token(var_Token),agent(var_Bin),write('[SMARTBIN '),write(var_Bin),write('] retry requested for req='),write(var_ReqId),nl,evi(retry_collection).

send_message(inform(reset_bin,var__),var__From):-evi(reset_bin).

send_message(inform(retry_collection,var__),var__From):-evi(retry_collection).

monitor(dummy):-started.

monitor(dummy):- \+started,evi(start).

:-dynamic receive/1.

:-dynamic send/2.

:-dynamic isa/3.

comm_trace(on).

log_comm(var_Tag,var_X,var_Ag):-comm_trace(on),!,write(comm_trace),write(var_Tag),write(var_X),write(var_Ag),nl.

log_comm(_147339,_147341,_147343).

safe_told(var_Ag,var_M):-current_predicate(told/2)->told(var_Ag,var_M);true.

safe_told(var_Ag,var_M,var_T):-current_predicate(told/3)->told(var_Ag,var_M,var_T);var_T=0.

safe_tell(var_To,var_Ag,var_M):-current_predicate(tell/3)->tell(var_To,var_Ag,var_M);true.

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

call_send_message(var_X,var_Ag):-nonvar(var_X)->log_comm(dispatch,var_X,var_Ag),(nonvar(var_Ag),var_Ag\=self->send_message(var_X,var_Ag);send_message(var_X,_145743));true.

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

trigger_inform_handlers(var_X,var_M,var_Ag):-catch(call(eve(inform_E(var_X,var_Ag))),_144507,true),catch(call(eve(inform_E(var_X,var_M,var_Ag))),_144535,true),catch(call(eve(inform_E(var_X))),_144565,true),catch(call(eve(inform_(var_X,var_Ag))),_144591,true),catch(call(eve(inform_(var_X,var_M,var_Ag))),_144619,true),catch(call(eve(inform_(var_X))),_144649,true),catch(call(eve(eve(inform_(var_X,var_Ag)))),_144675,true),catch(call(eve(eve(inform_(var_X,var_M,var_Ag)))),_144707,true),catch(call(eve(eve(inform_(var_X)))),_144735,true).

call_refuse(var_X,var_Ag,var_T):-clause(agent(var_A),var__),asse_cosa(past_event(var_X,var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(var_X,var__,var_Ag)),assert(past(var_X,var_Tp,var_Ag)),a(message(var_Ag,reply(received(var_X),var_A))).

call_cfp(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_144271,var_Ontology,_144275),_144265),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_cfp(var_A,var_C,var_Ag,_144309)),a(message(var_Ag,propose(var_A,[_144309],var_AgI))),retractall(ext_agent(var_Ag,_144347,var_Ontology,_144351)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_144145,var_Ontology,_144149),_144139),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,accept_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_144215,var_Ontology,_144219)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_144033,var_Ontology,_144037),_144027),not(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,reject_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_144089,var_Ontology,_144093)).

call_accept_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(accepted_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(accepted_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(accepted_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_reject_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(rejected_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(rejected_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(rejected_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_failure(var_A,var_M,var_Ag,var_T):-asse_cosa(past_event(failed_action(var_A,var_M,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(failed_action(var_A,var_M,var_Ag),var__,var_Ag)),assert(past(failed_action(var_A,var_M,var_Ag),var_Tp,var_Ag)).

call_cancel(var_A,var_Ag):-if(clause(high_action(var_A,var_Te,var_Ag),_143597),retractall(high_action(var_A,var_Te,var_Ag)),true),if(clause(normal_action(var_A,var_Te,var_Ag),_143631),retractall(normal_action(var_A,var_Te,var_Ag)),true).

external_refused_action_propose(var_A,var_Ag):-clause(not_executable_action_propose(var_A,var_Ag),var__).

evi(external_refused_action_propose(var_A,var_Ag)):-clause(agent(var_Ai),var__),a(message(var_Ag,failure(var_A,motivation(false_conditions),var_Ai))),retractall(not_executable_action_propose(var_A,var_Ag)).

refused_message(var_AgM,var_Con):-clause(eliminated_message(var_AgM,var__,var__,var_Con,var__),var__).

refused_message(var_To,var_M):-clause(eliminated_message(var_M,var_To,motivation(conditions_not_verified)),_143413).

evi(refused_message(var_AgM,var_Con)):-clause(agent(var_Ai),var__),a(message(var_AgM,inform(var_Con,motivation(refused_message),var_Ai))),retractall(eliminated_message(var_AgM,var__,var__,var_Con,var__)),retractall(eliminated_message(var_Con,var_AgM,motivation(conditions_not_verified))).

send_jasper_return_message(var_X,var_S,var_T,var_S0):-clause(agent(var_Ag),_143261),a(message(var_S,send_message(sent_rmi(var_X,var_T,var_S0),var_Ag))).

gest_learn(var_H):-clause(past(learn(var_H),var_T,var_U),_143209),learn_if(var_H,var_T,var_U).

evi(gest_learn(var_H)):-retractall(past(learn(var_H),_143085,_143087)),clause(agente(_143107,_143109,_143111,var_S),_143103),name(var_S,var_N),append(var_L,[46,112,108],var_N),name(var_F,var_L),manage_lg(var_H,var_F),a(learned(var_H)).

cllearn:-clause(agente(_142879,_142881,_142883,var_S),_142875),name(var_S,var_N),append(var_L,[46,112,108],var_N),append(var_L,[46,116,120,116],var_To),name(var_FI,var_To),open(var_FI,read,_142979,[]),repeat,read(_142979,var_T),arg(1,var_T,var_H),write(var_H),nl,var_T==end_of_file,!,close(_142979).

send_msg_learn(var_T,var_A,var_Ag):-a(message(var_Ag,confirm(learn(var_T),var_A))).

told(var__,send_message(var__)):-true.

told(var__,inform(var__,var__),70):-true.

told(var__,inform(var__),70):-true.

told(var__,refuse(var__)):-true.

told(var__,refuse(var__,var__)):-true.

tell(var__,var__,send_message(var__)):-true.

tell(var__,var__,refuse(var__)):-true.

tell(var__,var__,refuse(var__,var__)):-true.

tell(var__,var__,inform(var__,var__)):-true.

tell(var__,var__,inform(var__)):-true.

meta(var_P,var_P,var__):-nonvar(var_P),!.
