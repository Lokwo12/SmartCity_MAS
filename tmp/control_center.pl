
:-dynamic request/3,tried/2,truck_state/2,started/0,cycle_counter/1.

:-dynamic req_seq/1,inflight/6,processed_reply/3,completed_req/1,dead_letter/4.

:-dynamic last_cycle_ts/1.

:-dynamic rr_idx/1.

:-dynamic processed_reset_ack/2.

truck(truck1).

truck(truck2).

truck(truck3).

bin(smart_bin1).

bin(smart_bin2).

bin(smart_bin3).

shared_token(city_token_2026).

tesg(delta(3)).

reply_ttl(6).

assign_ack_ttl(6).

completion_ttl(10).

reset_ack_ttl(3).

cycle_interval_ms(1000).

evi(start):-retractall(started),assert(started),tesg(delta(_207183)),retractall(cycle_counter(_207197)),assert(cycle_counter(_207183)),retractall(req_seq(_207225)),assert(req_seq(1)),retractall(rr_idx(_207253)),assert(rr_idx(1)),retractall(last_cycle_ts(_207281)),statistics(walltime,[_207295,_207299]),assert(last_cycle_ts(_207295)),a(init_trucks),true.

a(init_trucks):-retractall(truck_state(_207113,_207115)),forall(truck(_207125),assert(truck_state(_207125,idle))).

evi(cycle):-evi(monitor_system).

evi(monitor_system):-a(check_stuck_requests),a(process_timeouts).

a(check_stuck_requests):-true.

a(new_req_id(_206963)):-req_seq(_206973),_206963 is _206973,_206995 is _206973+1,retract(req_seq(_206973)),assert(req_seq(_206995)).

pending_bin(_206937):-request(_206941,_206937,_206945).

trusted_bin(_206919):-bin(_206919).

trusted_truck(_206901):-truck(_206901).

short_bin_id(_206857,_206859):-atom_concat(smart_bin,_206871,_206857),!,atom_concat(sb,_206871,_206859).

short_bin_id(_206841,_206841).

short_truck_id(_206803,_206805):-atom_concat(truck,_206817,_206803),!,atom_concat(t,_206817,_206805).

short_truck_id(_206787,_206787).

a(telemetry(_206723,_206725,_206727,_206729,_206731,_206733)):-a(message(logger,log(_206723,event(_206725,req(_206727),bin(_206729),truck(_206731),note(_206733)),control_center))).

a(persist_dead_letter(_206643,_206645,_206647)):-statistics(walltime,[_206661,_206665]),assert(dead_letter(_206643,_206645,_206647,_206661)),a(telemetry(error,dead_letter,_206643,_206645,none,_206647)).

eve(bin_full(_206599,_206601)):-shared_token(_206601),!,eve(bin_full(_206599)).

eve(bin_full(_206473)):-trusted_bin(_206473),\+pending_bin(_206473),!,format('~n[CC] *** ALERT *** BIN FULL from ~w | Opening new request...~n',[_206473]),a(new_req_id(_206533)),a(clear_tried_list(_206473)),a(telemetry(info,request_opened,_206533,_206473,none,accepted)),evi(select_truck(_206533,_206473)).

eve(bin_full(_206445)):-pending_bin(_206445),!.

a(fireEvent(_206383)):-(catch(call(eve(_206383)),_206401,fail);catch(call(evi(_206383)),_206417,fail)),!.

a(fireEvent(_206365)).

fire_event(_206345):-a(fireEvent(_206345)).

:-dynamic receive/1.

:-dynamic send/2.

:-dynamic isa/3.

comm_trace(off).

log_comm(_206189,_206191,_206193):-comm_trace(on),!,write(comm),write(_206189),write(from),write(_206193),write(payload),write(_206191),nl.

log_comm(_206171,_206173,_206175).

safe_told(_206133,_206135):-current_predicate(told/2)->told(_206133,_206135);true.

safe_told(_206079,_206081,_206083):-current_predicate(told/3)->told(_206079,_206081,_206083);_206083=0.

safe_tell(_206031,_206033,_206035):-current_predicate(tell/3)->tell(_206031,_206033,_206035);true.

log_comm(var_Tag,var_X,var_Ag):-comm_trace(on),!,write(comm),write(var_Tag),write(from),write(var_Ag),write(payload),write(var_X),nl.

log_comm(_205919,_205921,_205923).

safe_told(var_Ag,var_M):-current_predicate(told/2)->told(var_Ag,var_M);true.

safe_told(var_Ag,var_M,var_T):-current_predicate(told/3)->told(var_Ag,var_M,var_T);var_T=0.

safe_tell(var_To,var_Ag,var_M):-current_predicate(tell/3)->tell(var_To,var_Ag,var_M);true.

receive(send_message(_205741,_205743)):-safe_told(_205743,send_message(_205741)),call_send_message(_205741,_205743).

send(_205685,send_message(_205691,_205693)):-safe_tell(_205685,_205693,send_message(_205691)),send_m(_205685,send_message(_205691,_205693)).

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

call_send_message(_204091,_204093):-nonvar(_204091)->log_comm(dispatch,_204091,_204093),(nonvar(_204093),_204093\=self,catch(send_message(_204091,_204093),_204157,fail);catch(send_message(_204091,_204185),_204177,fail);catch(call(eve(_204091)),_204197,fail);catch(call(evi(_204091)),_204219,fail);true);true.

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

trigger_inform_handlers(var_X,var_M,var_Ag):-catch(call(eve(inform_E(var_X,var_Ag))),_202927,true),catch(call(eve(inform_E(var_X,var_M,var_Ag))),_202955,true),catch(call(eve(inform_E(var_X))),_202985,true),catch(call(eve(inform_(var_X,var_Ag))),_203011,true),catch(call(eve(inform_(var_X,var_M,var_Ag))),_203039,true),catch(call(eve(inform_(var_X))),_203069,true),catch(call(eve(eve(inform_(var_X,var_Ag)))),_203095,true),catch(call(eve(eve(inform_(var_X,var_M,var_Ag)))),_203127,true),catch(call(eve(eve(inform_(var_X)))),_203155,true).

call_refuse(var_X,var_Ag,var_T):-clause(agent(var_A),var__),asse_cosa(past_event(var_X,var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(var_X,var__,var_Ag)),assert(past(var_X,var_Tp,var_Ag)),a(message(var_Ag,reply(received(var_X),var_A))).

call_cfp(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_202691,var_Ontology,_202695),_202685),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_cfp(var_A,var_C,var_Ag,_202729)),a(message(var_Ag,propose(var_A,[_202729],var_AgI))),retractall(ext_agent(var_Ag,_202767,var_Ontology,_202771)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_202565,var_Ontology,_202569),_202559),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,accept_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_202635,var_Ontology,_202639)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_202453,var_Ontology,_202457),_202447),not(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,reject_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_202509,var_Ontology,_202513)).

call_accept_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(accepted_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(accepted_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(accepted_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_reject_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(rejected_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(rejected_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(rejected_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_failure(var_A,var_M,var_Ag,var_T):-asse_cosa(past_event(failed_action(var_A,var_M,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(failed_action(var_A,var_M,var_Ag),var__,var_Ag)),assert(past(failed_action(var_A,var_M,var_Ag),var_Tp,var_Ag)).

call_cancel(var_A,var_Ag):-if(clause(high_action(var_A,var_Te,var_Ag),_202017),retractall(high_action(var_A,var_Te,var_Ag)),true),if(clause(normal_action(var_A,var_Te,var_Ag),_202051),retractall(normal_action(var_A,var_Te,var_Ag)),true).

external_refused_action_propose(var_A,var_Ag):-clause(not_executable_action_propose(var_A,var_Ag),var__).

evi(external_refused_action_propose(var_A,var_Ag)):-clause(agent(var_Ai),var__),a(message(var_Ag,failure(var_A,motivation(false_conditions),var_Ai))),retractall(not_executable_action_propose(var_A,var_Ag)).

refused_message(var_AgM,var_Con):-clause(eliminated_message(var_AgM,var__,var__,var_Con,var__),var__).

refused_message(var_To,var_M):-clause(eliminated_message(var_M,var_To,motivation(conditions_not_verified)),_201833).

evi(refused_message(var_AgM,var_Con)):-clause(agent(var_Ai),var__),a(message(var_AgM,inform(var_Con,motivation(refused_message),var_Ai))),retractall(eliminated_message(var_AgM,var__,var__,var_Con,var__)),retractall(eliminated_message(var_Con,var_AgM,motivation(conditions_not_verified))).

send_jasper_return_message(var_X,var_S,var_T,var_S0):-clause(agent(var_Ag),_201681),a(message(var_S,send_message(sent_rmi(var_X,var_T,var_S0),var_Ag))).

gest_learn(var_H):-clause(past(learn(var_H),var_T,var_U),_201629),learn_if(var_H,var_T,var_U).

evi(gest_learn(var_H)):-retractall(past(learn(var_H),_201505,_201507)),clause(agente(_201527,_201529,_201531,var_S),_201523),name(var_S,var_N),append(var_L,[46,112,108],var_N),name(var_F,var_L),manage_lg(var_H,var_F),a(learned(var_H)).

cllearn:-clause(agente(_201299,_201301,_201303,var_S),_201295),name(var_S,var_N),append(var_L,[46,112,108],var_N),append(var_L,[46,116,120,116],var_To),name(var_FI,var_To),open(var_FI,read,_201399,[]),repeat,read(_201399,var_T),arg(1,var_T,var_H),write(var_H),nl,var_T==end_of_file,!,close(_201399).

send_msg_learn(var_T,var_A,var_Ag):-a(message(var_Ag,confirm(learn(var_T),var_A))).

told(_201229,send_message(_201235)):-true.

told(_201205,inform(_201213,_201215),70):-true.

told(_201183,inform(_201191),70):-true.

told(_201163,refuse(_201169)):-true.

told(_201141,refuse(_201147,_201149)):-true.

tell(_201119,_201121,send_message(_201127)):-true.

tell(_201097,_201099,refuse(_201105)):-true.

tell(_201073,_201075,refuse(_201081,_201083)):-true.

tell(_201049,_201051,inform(_201057,_201059)):-true.

tell(_201027,_201029,inform(_201035)):-true.

meta(_200999,_200999,_201003):-nonvar(_200999),!.
