
:-dynamic bin_level/1,bin_state/1,hb_counter/1,started/0,last_reset_req/1.

:-dynamic last_monitor_ts/1.

bin_level(0).

max_capacity(100).

fill_step(20).

bin_state(idle).

shared_token(city_token_2026).

tesg(delta(2)).

monitor_interval_ms(1000).

short_bin_id(_164327,_164329):-atom_concat(smart_bin,_164341,_164327),!,atom_concat(sb,_164341,_164329).

short_bin_id(_164311,_164311).

evi(start):-retractall(started),assert(started),agent(_164147),write('[SMARTBIN '),write(_164147),write('] startI fired'),nl,tesg(delta(_164197)),retractall(hb_counter(_164211)),retractall(last_reset_req(_164225)),retractall(last_monitor_ts(_164239)),assert(hb_counter(_164197)),statistics(walltime,[_164267,_164271]),assert(last_monitor_ts(_164267)),format('[BIN ~w] Online | Level=0% | Monitoring...~n',[_164147]),true.

evi(monitor(dummy)):-statistics(walltime,[_164053,_164057]),last_monitor_ts(_164069),monitor_interval_ms(_164079),_164053-_164069<_164079,!,true.

evi(monitor(dummy)):-statistics(walltime,[_163945,_163949]),last_monitor_ts(_163961),monitor_interval_ms(_163971),_163945-_163961>=_163971,retract(last_monitor_ts(_163961)),assert(last_monitor_ts(_163945)),a(monitor_tick).

a(monitor_tick):-hb_counter(_163861),_163861>1,_163883 is _163861-1,retract(hb_counter(_163861)),assert(hb_counter(_163883)).

a(monitor_tick):-hb_counter(1),tesg(delta(_163805)),retract(hb_counter(1)),assert(hb_counter(_163805)),evi(tick).

a(monitor_tick):-true.

evi(tick):-bin_state(waiting),true.

evi(tick):-bin_state(idle),evi(maybe_fill).

evi(maybe_fill):-bin_state(idle),bin_level(_163669),max_capacity(_163679),_163669>=_163679,!,evi(full_trigger).

evi(maybe_fill):-bin_state(idle),a(increase_level).

a(increase_level):-bin_level(_163443),max_capacity(_163453),_163443<_163453,fill_step(_163475),_163485 is min(_163443+_163475,_163453),retract(bin_level(_163443)),assert(bin_level(_163485)),agent(_163537),format('[BIN ~w] Level: ~w% -> ~w%~n',[_163537,_163443,_163485]),a(message(logger,log(info,level_update,_163537))),(_163485>=_163453->evi(full_trigger);true).

evi(full_trigger):-retract(bin_state(idle)),assert(bin_state(waiting)),agent(_163353),format('~n[BIN ~w] *** FULL (100%) *** Sending alert to Control Center~n',[_163353]),shared_token(_163379),a(message(control_center,bin_full(_163353,_163379))),a(message(logger,log(info,bin_full,_163353))).

eve(reset_bin(_163215,_163217,_163219)):-shared_token(_163219),agent(_163215),\+last_reset_req(_163217),!,assert(last_reset_req(_163217)),a(apply_reset_now),a(message(control_center,reset_ack(_163215,_163217,_163219))).

eve(reset_bin(_163163,_163165,_163167)):-shared_token(_163167),agent(_163163),last_reset_req(_163165),!.

a(apply_reset_now):-retractall(bin_level(_163059)),assert(bin_level(0)),retractall(bin_state(_163087)),assert(bin_state(idle)),agent(_163111),format('[BIN ~w] EMPTIED by truck | Level reset to 0% | Resuming fill~n',[_163111]),a(message(logger,log(info,bin_reset,_163111))).

eve(retry_collection(_162981,_162983,_162985)):-shared_token(_162985),agent(_162981),shared_token(_163015),a(message(control_center,bin_full(_162981,_163015))).

a(fireEvent(_162919)):-(catch(call(eve(_162919)),_162937,fail);catch(call(evi(_162919)),_162953,fail)),!.

a(fireEvent(_162901)).

fire_event(_162881):-a(fireEvent(_162881)).

:-dynamic receive/1.

:-dynamic send/2.

:-dynamic isa/3.

comm_trace(off).

log_comm(_162725,_162727,_162729):-comm_trace(on),!,write(comm),write(_162725),write(from),write(_162729),write(payload),write(_162727),nl.

log_comm(_162707,_162709,_162711).

safe_told(_162669,_162671):-current_predicate(told/2)->told(_162669,_162671);true.

safe_told(_162615,_162617,_162619):-current_predicate(told/3)->told(_162615,_162617,_162619);_162619=0.

safe_tell(_162567,_162569,_162571):-current_predicate(tell/3)->tell(_162567,_162569,_162571);true.

log_comm(var_Tag,var_X,var_Ag):-comm_trace(on),!,write(comm),write(var_Tag),write(from),write(var_Ag),write(payload),write(var_X),nl.

log_comm(_162455,_162457,_162459).

safe_told(var_Ag,var_M):-current_predicate(told/2)->told(var_Ag,var_M);true.

safe_told(var_Ag,var_M,var_T):-current_predicate(told/3)->told(var_Ag,var_M,var_T);var_T=0.

safe_tell(var_To,var_Ag,var_M):-current_predicate(tell/3)->tell(var_To,var_Ag,var_M);true.

receive(send_message(_162277,_162279)):-safe_told(_162279,send_message(_162277)),call_send_message(_162277,_162279).

send(_162221,send_message(_162227,_162229)):-safe_tell(_162221,_162229,send_message(_162227)),send_m(_162221,send_message(_162227,_162229)).

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

call_send_message(_160627,_160629):-nonvar(_160627)->log_comm(dispatch,_160627,_160629),(nonvar(_160629),_160629\=self,catch(send_message(_160627,_160629),_160693,fail);catch(send_message(_160627,_160721),_160713,fail);catch(call(eve(_160627)),_160733,fail);catch(call(evi(_160627)),_160755,fail);true);true.

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

trigger_inform_handlers(var_X,var_M,var_Ag):-catch(call(eve(inform_E(var_X,var_Ag))),_159463,true),catch(call(eve(inform_E(var_X,var_M,var_Ag))),_159491,true),catch(call(eve(inform_E(var_X))),_159521,true),catch(call(eve(inform_(var_X,var_Ag))),_159547,true),catch(call(eve(inform_(var_X,var_M,var_Ag))),_159575,true),catch(call(eve(inform_(var_X))),_159605,true),catch(call(eve(eve(inform_(var_X,var_Ag)))),_159631,true),catch(call(eve(eve(inform_(var_X,var_M,var_Ag)))),_159663,true),catch(call(eve(eve(inform_(var_X)))),_159691,true).

call_refuse(var_X,var_Ag,var_T):-clause(agent(var_A),var__),asse_cosa(past_event(var_X,var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(var_X,var__,var_Ag)),assert(past(var_X,var_Tp,var_Ag)),a(message(var_Ag,reply(received(var_X),var_A))).

call_cfp(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_159227,var_Ontology,_159231),_159221),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_cfp(var_A,var_C,var_Ag,_159265)),a(message(var_Ag,propose(var_A,[_159265],var_AgI))),retractall(ext_agent(var_Ag,_159303,var_Ontology,_159307)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_159101,var_Ontology,_159105),_159095),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,accept_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_159171,var_Ontology,_159175)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_158989,var_Ontology,_158993),_158983),not(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,reject_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_159045,var_Ontology,_159049)).

call_accept_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(accepted_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(accepted_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(accepted_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_reject_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(rejected_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(rejected_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(rejected_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_failure(var_A,var_M,var_Ag,var_T):-asse_cosa(past_event(failed_action(var_A,var_M,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(failed_action(var_A,var_M,var_Ag),var__,var_Ag)),assert(past(failed_action(var_A,var_M,var_Ag),var_Tp,var_Ag)).

call_cancel(var_A,var_Ag):-if(clause(high_action(var_A,var_Te,var_Ag),_158553),retractall(high_action(var_A,var_Te,var_Ag)),true),if(clause(normal_action(var_A,var_Te,var_Ag),_158587),retractall(normal_action(var_A,var_Te,var_Ag)),true).

external_refused_action_propose(var_A,var_Ag):-clause(not_executable_action_propose(var_A,var_Ag),var__).

evi(external_refused_action_propose(var_A,var_Ag)):-clause(agent(var_Ai),var__),a(message(var_Ag,failure(var_A,motivation(false_conditions),var_Ai))),retractall(not_executable_action_propose(var_A,var_Ag)).

refused_message(var_AgM,var_Con):-clause(eliminated_message(var_AgM,var__,var__,var_Con,var__),var__).

refused_message(var_To,var_M):-clause(eliminated_message(var_M,var_To,motivation(conditions_not_verified)),_158369).

evi(refused_message(var_AgM,var_Con)):-clause(agent(var_Ai),var__),a(message(var_AgM,inform(var_Con,motivation(refused_message),var_Ai))),retractall(eliminated_message(var_AgM,var__,var__,var_Con,var__)),retractall(eliminated_message(var_Con,var_AgM,motivation(conditions_not_verified))).

send_jasper_return_message(var_X,var_S,var_T,var_S0):-clause(agent(var_Ag),_158217),a(message(var_S,send_message(sent_rmi(var_X,var_T,var_S0),var_Ag))).

gest_learn(var_H):-clause(past(learn(var_H),var_T,var_U),_158165),learn_if(var_H,var_T,var_U).

evi(gest_learn(var_H)):-retractall(past(learn(var_H),_158041,_158043)),clause(agente(_158063,_158065,_158067,var_S),_158059),name(var_S,var_N),append(var_L,[46,112,108],var_N),name(var_F,var_L),manage_lg(var_H,var_F),a(learned(var_H)).

cllearn:-clause(agente(_157835,_157837,_157839,var_S),_157831),name(var_S,var_N),append(var_L,[46,112,108],var_N),append(var_L,[46,116,120,116],var_To),name(var_FI,var_To),open(var_FI,read,_157935,[]),repeat,read(_157935,var_T),arg(1,var_T,var_H),write(var_H),nl,var_T==end_of_file,!,close(_157935).

send_msg_learn(var_T,var_A,var_Ag):-a(message(var_Ag,confirm(learn(var_T),var_A))).

told(_157765,send_message(_157771)):-true.

told(_157741,inform(_157749,_157751),70):-true.

told(_157719,inform(_157727),70):-true.

told(_157699,refuse(_157705)):-true.

told(_157677,refuse(_157683,_157685)):-true.

tell(_157655,_157657,send_message(_157663)):-true.

tell(_157633,_157635,refuse(_157641)):-true.

tell(_157609,_157611,refuse(_157617,_157619)):-true.

tell(_157585,_157587,inform(_157593,_157595)):-true.

tell(_157563,_157565,inform(_157571)):-true.

meta(_157535,_157535,_157539):-nonvar(_157535),!.
