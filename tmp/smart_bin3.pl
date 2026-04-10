
:-dynamic bin_level/1,bin_state/1,hb_counter/1,started/0,last_reset_req/1,last_monitor_ts/1.

bin_level(0).

max_capacity(100).

fill_step(20).

bin_state(idle).

shared_token(city_token_2026).

tesg(delta(2)).

monitor_interval_ms(1000).

a(send_level_log_trace(_186441)):-a(message(logger,send_message(log(info,level_update,_186441),_186441),_186441)),!,format('[SMART_BIN ~w] SEND_OK logger level_update~n',[_186441]).

a(send_level_log_trace(_186413)):-format('[SMART_BIN ~w] SEND_FAIL logger level_update~n',[_186413]).

a(send_full_trace(_186347,_186349)):-a(message(control_center,send_message(bin_full(_186347,_186349),_186347),_186347)),!,format('[SMART_BIN ~w] SEND_OK control_center bin_full~n',[_186347]).

a(send_full_trace(_186317,_186319)):-format('[SMART_BIN ~w] SEND_FAIL control_center bin_full~n',[_186317]).

a(send_bin_full_log_trace(_186251)):-a(message(logger,send_message(log(info,bin_full,_186251),_186251),_186251)),!,format('[SMART_BIN ~w] SEND_OK logger bin_full~n',[_186251]).

a(send_bin_full_log_trace(_186223)):-format('[SMART_BIN ~w] SEND_FAIL logger bin_full~n',[_186223]).

evi(start):-retractall(started),assert(started),agent(_186049),write('[SMARTBIN '),write(_186049),write('] startI fired'),nl,tesg(delta(_186099)),retractall(hb_counter(_186113)),retractall(last_reset_req(_186127)),retractall(last_monitor_ts(_186141)),assert(hb_counter(_186099)),statistics(walltime,[_186169,_186173]),assert(last_monitor_ts(_186169)),format('[SMART_BIN ~w] START~n',[_186049]),true.

evi(monitor(dummy)):-statistics(walltime,[_185955,_185959]),last_monitor_ts(_185971),monitor_interval_ms(_185981),_185955-_185971<_185981,!,true.

evi(monitor(dummy)):-statistics(walltime,[_185847,_185851]),last_monitor_ts(_185863),monitor_interval_ms(_185873),_185847-_185863>=_185873,retract(last_monitor_ts(_185863)),assert(last_monitor_ts(_185847)),evi(monitor_tick).

evi(monitor_tick):-hb_counter(_185763),_185763>1,_185785 is _185763-1,retract(hb_counter(_185763)),assert(hb_counter(_185785)).

evi(monitor_tick):-hb_counter(1),tesg(delta(_185707)),retract(hb_counter(1)),assert(hb_counter(_185707)),evi(tick).

evi(monitor_tick):-true.

evi(tick):-bin_state(waiting),true.

evi(tick):-bin_state(idle),evi(maybe_fill).

evi(maybe_fill):-bin_state(idle),evi(increase_level).

evi(increase_level):-bin_level(_185425),max_capacity(_185435),_185425<_185435,fill_step(_185457),_185467 is min(_185425+_185457,_185435),retract(bin_level(_185425)),assert(bin_level(_185467)),agent(_185519),format('[SMART_BIN ~w] LEVEL=~w%~n',[_185519,_185467]),a(send_level_log_trace(_185519)),(_185467>=_185435->evi(full_trigger);true).

evi(full_trigger):-bin_state(idle),retract(bin_state(idle)),assert(bin_state(waiting)),agent(_185351),format('[SMART_BIN ~w] FULL -> notify control_center~n',[_185351]),shared_token(_185377),a(send_full_trace(_185351,_185377)),a(send_bin_full_log_trace(_185351)).

evi(reset_bin):-evi(apply_reset_now).

evi(apply_reset_now):-retractall(bin_level(_185177)),assert(bin_level(0)),retractall(bin_state(_185205)),assert(bin_state(idle)),agent(_185229),format('[SMART_BIN ~w] RESET -> level=0%~n',[_185229]),a(message(logger,send_message(log(info,bin_reset,_185229),_185229),_185229)).

evi(retry_collection):-agent(_185115),shared_token(_185125),a(message(control_center,send_message(bin_full(_185115,_185125),_185115),_185115)).

send_message(send_message(_185077,_185079),_185073):-!,send_message(_185077,_185073).

send_message(inform(_185043,_185045),_185039):-!,send_message(_185043,_185039).

send_message(_185011,_185013):-evi(bin_in(_185011,_185013)).

evi(bin_in(bin_full(_184977,_184979),_184973)):-shared_token(_184979),evi(bin_full(_184977)).

evi(bin_in(reset_bin,_184949)):-evi(reset_bin).

evi(bin_in(reset_bin(_184869,_184871,_184873),control_center)):-shared_token(_184873),agent(_184869),last_reset_req(_184871),a(message(control_center,send_message(reset_ack(_184869,_184871,_184873),_184869),_184869)).

evi(bin_in(reset_bin(_184757,_184759,_184761),control_center)):-shared_token(_184761),agent(_184757),\+last_reset_req(_184759),assert(last_reset_req(_184759)),evi(apply_reset_now),a(message(control_center,send_message(reset_ack(_184757,_184759,_184761),_184757),_184757)).

evi(bin_in(retry_collection,_184729)):-evi(retry_collection).

evi(bin_in(retry_collection(_184661,_184663,_184665),control_center)):-shared_token(_184665),agent(_184661),format('[SMART_BIN ~w] RETRY requested for request=~w~n',[_184661,_184663]),evi(retry_collection).

evi(bin_in(inform(reset_bin,_184633),_184627)):-evi(reset_bin).

evi(bin_in(inform(retry_collection,_184603),_184597)):-evi(retry_collection).

monitor(dummy):-evi(monitor(dummy)).

:-dynamic receive/1.

:-dynamic send/2.

:-dynamic isa/3.

comm_trace(off).

log_comm(_184413,_184415,_184417):-comm_trace(on),!,write(comm),write(_184413),write(from),write(_184417),write(payload),write(_184415),nl.

log_comm(_184395,_184397,_184399).

safe_told(_184357,_184359):-current_predicate(told/2)->told(_184357,_184359);true.

safe_told(_184303,_184305,_184307):-current_predicate(told/3)->told(_184303,_184305,_184307);_184307=0.

safe_tell(_184255,_184257,_184259):-current_predicate(tell/3)->tell(_184255,_184257,_184259);true.

log_comm(var_Tag,var_X,var_Ag):-comm_trace(on),!,write(comm),write(var_Tag),write(from),write(var_Ag),write(payload),write(var_X),nl.

log_comm(_184143,_184145,_184147).

safe_told(var_Ag,var_M):-current_predicate(told/2)->told(var_Ag,var_M);true.

safe_told(var_Ag,var_M,var_T):-current_predicate(told/3)->told(var_Ag,var_M,var_T);var_T=0.

safe_tell(var_To,var_Ag,var_M):-current_predicate(tell/3)->tell(var_To,var_Ag,var_M);true.

receive(send_message(_183965,_183967)):-safe_told(_183967,send_message(_183965)),call_send_message(_183965,_183967).

send(_183909,send_message(_183915,_183917)):-safe_tell(_183909,_183917,send_message(_183915)),send_m(_183909,send_message(_183915,_183917)).

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

call_send_message(_182337,_182339):-nonvar(_182337)->log_comm(dispatch,_182337,_182339),(nonvar(_182339),_182339\=self,catch(send_message(_182337,_182339),_182403,fail);catch(send_message(_182337,_182431),_182423,fail);catch(call(evi(_182337)),_182443,fail);true);true.

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

trigger_inform_handlers(var_X,var_M,var_Ag):-catch(call(eve(inform_E(var_X,var_Ag))),_181173,true),catch(call(eve(inform_E(var_X,var_M,var_Ag))),_181201,true),catch(call(eve(inform_E(var_X))),_181231,true),catch(call(eve(inform_(var_X,var_Ag))),_181257,true),catch(call(eve(inform_(var_X,var_M,var_Ag))),_181285,true),catch(call(eve(inform_(var_X))),_181315,true),catch(call(eve(eve(inform_(var_X,var_Ag)))),_181341,true),catch(call(eve(eve(inform_(var_X,var_M,var_Ag)))),_181373,true),catch(call(eve(eve(inform_(var_X)))),_181401,true).

call_refuse(var_X,var_Ag,var_T):-clause(agent(var_A),var__),asse_cosa(past_event(var_X,var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(var_X,var__,var_Ag)),assert(past(var_X,var_Tp,var_Ag)),a(message(var_Ag,reply(received(var_X),var_A))).

call_cfp(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_180937,var_Ontology,_180941),_180931),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_cfp(var_A,var_C,var_Ag,_180975)),a(message(var_Ag,propose(var_A,[_180975],var_AgI))),retractall(ext_agent(var_Ag,_181013,var_Ontology,_181017)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_180811,var_Ontology,_180815),_180805),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,accept_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_180881,var_Ontology,_180885)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_180699,var_Ontology,_180703),_180693),not(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,reject_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_180755,var_Ontology,_180759)).

call_accept_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(accepted_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(accepted_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(accepted_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_reject_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(rejected_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(rejected_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(rejected_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_failure(var_A,var_M,var_Ag,var_T):-asse_cosa(past_event(failed_action(var_A,var_M,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(failed_action(var_A,var_M,var_Ag),var__,var_Ag)),assert(past(failed_action(var_A,var_M,var_Ag),var_Tp,var_Ag)).

call_cancel(var_A,var_Ag):-if(clause(high_action(var_A,var_Te,var_Ag),_180263),retractall(high_action(var_A,var_Te,var_Ag)),true),if(clause(normal_action(var_A,var_Te,var_Ag),_180297),retractall(normal_action(var_A,var_Te,var_Ag)),true).

external_refused_action_propose(var_A,var_Ag):-clause(not_executable_action_propose(var_A,var_Ag),var__).

evi(external_refused_action_propose(var_A,var_Ag)):-clause(agent(var_Ai),var__),a(message(var_Ag,failure(var_A,motivation(false_conditions),var_Ai))),retractall(not_executable_action_propose(var_A,var_Ag)).

refused_message(var_AgM,var_Con):-clause(eliminated_message(var_AgM,var__,var__,var_Con,var__),var__).

refused_message(var_To,var_M):-clause(eliminated_message(var_M,var_To,motivation(conditions_not_verified)),_180079).

evi(refused_message(var_AgM,var_Con)):-clause(agent(var_Ai),var__),a(message(var_AgM,inform(var_Con,motivation(refused_message),var_Ai))),retractall(eliminated_message(var_AgM,var__,var__,var_Con,var__)),retractall(eliminated_message(var_Con,var_AgM,motivation(conditions_not_verified))).

send_jasper_return_message(var_X,var_S,var_T,var_S0):-clause(agent(var_Ag),_179927),a(message(var_S,send_message(sent_rmi(var_X,var_T,var_S0),var_Ag))).

gest_learn(var_H):-clause(past(learn(var_H),var_T,var_U),_179875),learn_if(var_H,var_T,var_U).

evi(gest_learn(var_H)):-retractall(past(learn(var_H),_179751,_179753)),clause(agente(_179773,_179775,_179777,var_S),_179769),name(var_S,var_N),append(var_L,[46,112,108],var_N),name(var_F,var_L),manage_lg(var_H,var_F),a(learned(var_H)).

cllearn:-clause(agente(_179545,_179547,_179549,var_S),_179541),name(var_S,var_N),append(var_L,[46,112,108],var_N),append(var_L,[46,116,120,116],var_To),name(var_FI,var_To),open(var_FI,read,_179645,[]),repeat,read(_179645,var_T),arg(1,var_T,var_H),write(var_H),nl,var_T==end_of_file,!,close(_179645).

send_msg_learn(var_T,var_A,var_Ag):-a(message(var_Ag,confirm(learn(var_T),var_A))).

told(_179475,send_message(_179481)):-true.

told(_179451,inform(_179459,_179461),70):-true.

told(_179429,inform(_179437),70):-true.

told(_179409,refuse(_179415)):-true.

told(_179387,refuse(_179393,_179395)):-true.

tell(_179365,_179367,send_message(_179373)):-true.

tell(_179343,_179345,refuse(_179351)):-true.

tell(_179319,_179321,refuse(_179327,_179329)):-true.

tell(_179295,_179297,inform(_179303,_179305)):-true.

tell(_179273,_179275,inform(_179281)):-true.

meta(_179245,_179245,_179249):-nonvar(_179245),!.
