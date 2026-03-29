
:-dynamic bin_level/1,bin_state/1,hb_counter/1,started/0,last_reset_req/1.

:-dynamic last_monitor_ts/1.

bin_level(0).

max_capacity(100).

fill_step(20).

bin_state(idle).

shared_token(city_token_2026).

tesg(delta(2)).

monitor_interval_ms(1000).

short_bin_id(_169557,_169559):-atom_concat(smart_bin,_169571,_169557),!,atom_concat(sb,_169571,_169559).

short_bin_id(_169541,_169541).

evi(start):-retractall(started),assert(started),agent(_169377),write('[SMARTBIN '),write(_169377),write('] startI fired'),nl,tesg(delta(_169427)),retractall(hb_counter(_169441)),retractall(last_reset_req(_169455)),retractall(last_monitor_ts(_169469)),assert(hb_counter(_169427)),statistics(walltime,[_169497,_169501]),assert(last_monitor_ts(_169497)),format('[SMART_BIN ~w] START~n',[_169377]),true.

evi(monitor(dummy)):-statistics(walltime,[_169283,_169287]),last_monitor_ts(_169299),monitor_interval_ms(_169309),_169283-_169299<_169309,!,true.

evi(monitor(dummy)):-statistics(walltime,[_169175,_169179]),last_monitor_ts(_169191),monitor_interval_ms(_169201),_169175-_169191>=_169201,retract(last_monitor_ts(_169191)),assert(last_monitor_ts(_169175)),a(monitor_tick).

a(monitor_tick):-hb_counter(_169091),_169091>1,_169113 is _169091-1,retract(hb_counter(_169091)),assert(hb_counter(_169113)).

a(monitor_tick):-hb_counter(1),tesg(delta(_169035)),retract(hb_counter(1)),assert(hb_counter(_169035)),evi(tick).

a(monitor_tick):-true.

evi(tick):-bin_state(waiting),true.

evi(tick):-bin_state(idle),evi(maybe_fill).

evi(maybe_fill):-bin_state(idle),a(increase_level).

a(increase_level):-bin_level(_168747),max_capacity(_168757),_168747<_168757,fill_step(_168779),_168789 is min(_168747+_168779,_168757),retract(bin_level(_168747)),assert(bin_level(_168789)),agent(_168841),format('[SMART_BIN ~w] LEVEL=~w%~n',[_168841,_168789]),a(message(logger,send_message(log(info,level_update,_168841),_168841),_168841)),a(post_fill(_168789,_168757)).

a(post_fill(_168705,_168707)):-_168705>=_168707,evi(full_trigger).

a(post_fill(_168679,_168681)):-_168679<_168681.

evi(full_trigger):-bin_state(idle),retract(bin_state(idle)),assert(bin_state(waiting)),agent(_168579),format('[SMART_BIN ~w] FULL -> notify control_center~n',[_168579]),shared_token(_168605),a(message(control_center,send_message(bin_full(_168579,_168605),_168579),_168579)),a(message(logger,send_message(log(info,bin_full,_168579),_168579),_168579)).

eve(reset_bin):-a(apply_reset_now).

a(apply_reset_now):-retractall(bin_level(_168405)),assert(bin_level(0)),retractall(bin_state(_168433)),assert(bin_state(idle)),agent(_168457),format('[SMART_BIN ~w] RESET -> level=0%~n',[_168457]),a(message(logger,send_message(log(info,bin_reset,_168457),_168457),_168457)).

eve(retry_collection):-agent(_168343),shared_token(_168353),a(message(control_center,send_message(bin_full(_168343,_168353),_168343),_168343)).

send_message(bin_full(_168299,_168301),_168295):-shared_token(_168301),fire_event(bin_full(_168299)).

send_message(reset_bin,_168275):-fire_event(reset_bin).

send_message(reset_bin(_168199,_168201,_168203),control_center):-shared_token(_168203),agent(_168199),last_reset_req(_168201),a(message(control_center,send_message(reset_ack(_168199,_168201,_168203),_168199),_168199)).

send_message(reset_bin(_168091,_168093,_168095),control_center):-shared_token(_168095),agent(_168091),\+last_reset_req(_168093),assert(last_reset_req(_168093)),a(apply_reset_now),a(message(control_center,send_message(reset_ack(_168091,_168093,_168095),_168091),_168091)).

send_message(retry_collection,_168067):-fire_event(retry_collection).

send_message(retry_collection(_168003,_168005,_168007),control_center):-shared_token(_168007),agent(_168003),format('[SMART_BIN ~w] RETRY requested for request=~w~n',[_168003,_168005]),fire_event(retry_collection).

send_message(inform(reset_bin,_167979),_167973):-fire_event(reset_bin).

send_message(inform(retry_collection,_167953),_167947):-fire_event(retry_collection).

fire_event(_167887):-(catch(call(eve(_167887)),_167905,fail);catch(call(evi(_167887)),_167921,fail)),!.

fire_event(_167873).

monitor(dummy):-evi(monitor(dummy)).

:-dynamic receive/1.

:-dynamic send/2.

:-dynamic isa/3.

comm_trace(off).

log_comm(_167701,_167703,_167705):-comm_trace(on),!,write(comm),write(_167701),write(from),write(_167705),write(payload),write(_167703),nl.

log_comm(_167683,_167685,_167687).

safe_told(_167645,_167647):-current_predicate(told/2)->told(_167645,_167647);true.

safe_told(_167591,_167593,_167595):-current_predicate(told/3)->told(_167591,_167593,_167595);_167595=0.

safe_tell(_167543,_167545,_167547):-current_predicate(tell/3)->tell(_167543,_167545,_167547);true.

log_comm(var_Tag,var_X,var_Ag):-comm_trace(on),!,write(comm),write(var_Tag),write(from),write(var_Ag),write(payload),write(var_X),nl.

log_comm(_167431,_167433,_167435).

safe_told(var_Ag,var_M):-current_predicate(told/2)->told(var_Ag,var_M);true.

safe_told(var_Ag,var_M,var_T):-current_predicate(told/3)->told(var_Ag,var_M,var_T);var_T=0.

safe_tell(var_To,var_Ag,var_M):-current_predicate(tell/3)->tell(var_To,var_Ag,var_M);true.

receive(send_message(_167253,_167255)):-safe_told(_167255,send_message(_167253)),call_send_message(_167253,_167255).

send(_167197,send_message(_167203,_167205)):-safe_tell(_167197,_167205,send_message(_167203)),send_m(_167197,send_message(_167203,_167205)).

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

call_send_message(_165625,_165627):-nonvar(_165625)->log_comm(dispatch,_165625,_165627),(nonvar(_165627),_165627\=self,catch(send_message(_165625,_165627),_165691,fail);catch(send_message(_165625,_165719),_165711,fail);catch(call(evi(_165625)),_165731,fail);true);true.

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

trigger_inform_handlers(var_X,var_M,var_Ag):-catch(call(eve(inform_E(var_X,var_Ag))),_164461,true),catch(call(eve(inform_E(var_X,var_M,var_Ag))),_164489,true),catch(call(eve(inform_E(var_X))),_164519,true),catch(call(eve(inform_(var_X,var_Ag))),_164545,true),catch(call(eve(inform_(var_X,var_M,var_Ag))),_164573,true),catch(call(eve(inform_(var_X))),_164603,true),catch(call(eve(eve(inform_(var_X,var_Ag)))),_164629,true),catch(call(eve(eve(inform_(var_X,var_M,var_Ag)))),_164661,true),catch(call(eve(eve(inform_(var_X)))),_164689,true).

call_refuse(var_X,var_Ag,var_T):-clause(agent(var_A),var__),asse_cosa(past_event(var_X,var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(var_X,var__,var_Ag)),assert(past(var_X,var_Tp,var_Ag)),a(message(var_Ag,reply(received(var_X),var_A))).

call_cfp(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_164225,var_Ontology,_164229),_164219),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_cfp(var_A,var_C,var_Ag,_164263)),a(message(var_Ag,propose(var_A,[_164263],var_AgI))),retractall(ext_agent(var_Ag,_164301,var_Ontology,_164305)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_164099,var_Ontology,_164103),_164093),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,accept_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_164169,var_Ontology,_164173)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_163987,var_Ontology,_163991),_163981),not(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,reject_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_164043,var_Ontology,_164047)).

call_accept_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(accepted_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(accepted_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(accepted_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_reject_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(rejected_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(rejected_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(rejected_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_failure(var_A,var_M,var_Ag,var_T):-asse_cosa(past_event(failed_action(var_A,var_M,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(failed_action(var_A,var_M,var_Ag),var__,var_Ag)),assert(past(failed_action(var_A,var_M,var_Ag),var_Tp,var_Ag)).

call_cancel(var_A,var_Ag):-if(clause(high_action(var_A,var_Te,var_Ag),_163551),retractall(high_action(var_A,var_Te,var_Ag)),true),if(clause(normal_action(var_A,var_Te,var_Ag),_163585),retractall(normal_action(var_A,var_Te,var_Ag)),true).

external_refused_action_propose(var_A,var_Ag):-clause(not_executable_action_propose(var_A,var_Ag),var__).

evi(external_refused_action_propose(var_A,var_Ag)):-clause(agent(var_Ai),var__),a(message(var_Ag,failure(var_A,motivation(false_conditions),var_Ai))),retractall(not_executable_action_propose(var_A,var_Ag)).

refused_message(var_AgM,var_Con):-clause(eliminated_message(var_AgM,var__,var__,var_Con,var__),var__).

refused_message(var_To,var_M):-clause(eliminated_message(var_M,var_To,motivation(conditions_not_verified)),_163367).

evi(refused_message(var_AgM,var_Con)):-clause(agent(var_Ai),var__),a(message(var_AgM,inform(var_Con,motivation(refused_message),var_Ai))),retractall(eliminated_message(var_AgM,var__,var__,var_Con,var__)),retractall(eliminated_message(var_Con,var_AgM,motivation(conditions_not_verified))).

send_jasper_return_message(var_X,var_S,var_T,var_S0):-clause(agent(var_Ag),_163215),a(message(var_S,send_message(sent_rmi(var_X,var_T,var_S0),var_Ag))).

gest_learn(var_H):-clause(past(learn(var_H),var_T,var_U),_163163),learn_if(var_H,var_T,var_U).

evi(gest_learn(var_H)):-retractall(past(learn(var_H),_163039,_163041)),clause(agente(_163061,_163063,_163065,var_S),_163057),name(var_S,var_N),append(var_L,[46,112,108],var_N),name(var_F,var_L),manage_lg(var_H,var_F),a(learned(var_H)).

cllearn:-clause(agente(_162833,_162835,_162837,var_S),_162829),name(var_S,var_N),append(var_L,[46,112,108],var_N),append(var_L,[46,116,120,116],var_To),name(var_FI,var_To),open(var_FI,read,_162933,[]),repeat,read(_162933,var_T),arg(1,var_T,var_H),write(var_H),nl,var_T==end_of_file,!,close(_162933).

send_msg_learn(var_T,var_A,var_Ag):-a(message(var_Ag,confirm(learn(var_T),var_A))).

told(_162763,send_message(_162769)):-true.

told(_162739,inform(_162747,_162749),70):-true.

told(_162717,inform(_162725),70):-true.

told(_162697,refuse(_162703)):-true.

told(_162675,refuse(_162681,_162683)):-true.

tell(_162653,_162655,send_message(_162661)):-true.

tell(_162631,_162633,refuse(_162639)):-true.

tell(_162607,_162609,refuse(_162615,_162617)):-true.

tell(_162583,_162585,inform(_162591,_162593)):-true.

tell(_162561,_162563,inform(_162569)):-true.

meta(_162533,_162533,_162537):-nonvar(_162533),!.
