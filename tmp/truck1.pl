
:-dynamic truck_state/1,current_job/2,started/0,status_counter/1,assign_wait_counter/1,seen_pickup/1,seen_assignment/1,completed_local/1,last_monitor_ts/1,busy_logged_req/1,move_counter/1,collect_counter/1.

tesg(delta(4)).

move_time(2).

collect_time(1).

assign_wait_limit(6).

shared_token(city_token_2026).

monitor_interval_ms(1000).

major_truck_action(pickup_accept).

major_truck_action(move_start).

major_truck_action(collect_done).

evi(truck_print(_320163,_320165)):-major_truck_action(_320163),agent(_320185),atom_concat(truck,_320197,_320185),catch(atom_number(_320197,_320219),_320211,fail),!,_320235 is(_320219-1)*0.25,sleep(_320235),(atom_concat(smart_bin,_320289,_320165)->atom_concat(smartbin,_320289,_320299);_320299=_320165),format('[truck ~w] ~w at ~w~n',[_320185,_320163,_320299]).

evi(truck_print(_320143,_320145)):-true.

evi(truck_print_eta(_319959,_319961,_319963)):-major_truck_action(_319959),agent(_319983),atom_concat(truck,_319995,_319983),catch(atom_number(_319995,_320017),_320009,fail),!,_320033 is(_320017-1)*0.25,sleep(_320033),(atom_concat(smart_bin,_320087,_319961)->atom_concat(smartbin,_320087,_320097);_320097=_319961),format('[truck ~w] ~w to ~w eta=~ws~n',[_319983,_319959,_320097,_319963]).

evi(truck_print_eta(_319937,_319939,_319941)):-true.

evi(start):-retractall(started),assert(started),retractall(current_job(_319707,_319709)),retractall(truck_state(_319723)),retractall(assign_wait_counter(_319737)),retractall(seen_pickup(_319751)),retractall(seen_assignment(_319765)),retractall(completed_local(_319779)),retractall(busy_logged_req(_319793)),retractall(move_counter(_319807)),retractall(collect_counter(_319821)),retractall(last_monitor_ts(_319835)),assert(truck_state(idle)),tesg(delta(_319863)),retractall(status_counter(_319877)),assert(status_counter(_319863)),statistics(walltime,[_319905,_319909]),assert(last_monitor_ts(_319905)).

evi(status_check):-true.

send_message(send_message(_319631,_319633),_319627):-!,send_message(_319631,_319627).

send_message(inform(_319597,_319599),_319593):-!,send_message(_319597,_319593).

send_message(_319531,_319533):-agent(_319543),format('[truck ~w] RX from=~w msg=~w~n',[_319543,_319533,_319531]),evi(truck_in(_319531,_319533)).

evi(truck_in(request(pickup(_319507),_319503),_319497)):-evi(pickup_request(_319507,0)).

evi(truck_in(pickup_request(_319467),_319463)):-evi(pickup_request(_319467,0)).

evi(truck_in(pickup_request(_319419,_319421,_319423),control_center)):-shared_token(_319423),evi(pickup_request(_319419,_319421)).

evi(truck_in(confirm(assignment(_319385),_319381),_319375)):-evi(assignment(_319385,0)).

evi(truck_in(assignment(_319345),_319341)):-evi(assignment(_319345,0)).

evi(truck_in(assignment(_319297,_319299,_319301),control_center)):-shared_token(_319301),evi(assignment(_319297,_319299)).

evi(truck_in(assignment(_319261,_319263),control_center)):-evi(assignment(_319261,_319263)).

eve(pickup_request(_319207,_319209)):-_319209>0,completed_local(_319209),!,true.

eve(pickup_request(_319143,_319145)):-_319145>0,seen_pickup(_319145),\+current_job(_319143,_319145),!,true.

eve(pickup_request(_319043,_319045)):-seen_pickup(_319045),current_job(_319043,_319045),truck_state(waiting_assignment),_319045>0,!,agent(_319105),shared_token(_319115),evi(send_accept(_319043,_319045)).

eve(pickup_request(_318935,_318937)):-truck_state(_318947),_318947\=idle,_318937>0,\+busy_logged_req(_318937),assert(busy_logged_req(_318937)),!,agent(_319015),evi(send_refuse(_318935,_318937)).

eve(pickup_request(_318867,_318869)):-truck_state(_318879),_318879\=idle,!,agent(_318907),evi(send_refuse(_318867,_318869)).

eve(pickup_request(_318681,_318683)):-truck_state(idle),evi(truck_print(pickup_accept,_318681)),retract(truck_state(idle)),assert(truck_state(moving)),retractall(current_job(_318751,_318753)),assert(current_job(_318681,_318683)),move_time(_318779),retractall(move_counter(_318793)),assert(move_counter(_318779)),evi(truck_print_eta(move_start,_318681,_318779)),evi(mark_seen_pickup(_318683)),evi(send_accept(_318681,_318683)).

eve(assignment(_318633,_318635)):-_318635>0,completed_local(_318635),!,true.

eve(assignment(_318563,_318565)):-_318565>0,seen_assignment(_318565),current_job(_318563,_318565),!,evi(mark_assignment_ack(_318563,_318565)).

eve(assignment(_318401,_318403)):-current_job(_318401,_318403),!,agent(_318431),retractall(assign_wait_counter(_318445)),retractall(truck_state(_318459)),assert(truck_state(moving)),move_time(_318483),retractall(move_counter(_318497)),assert(move_counter(_318483)),evi(truck_print_eta(move_start,_318401,_318483)),evi(mark_assignment_ack(_318401,_318403)),true.

eve(assignment(_318381,_318383)):-true.

evi(decide_outcome(_318335,_318337)):-random(0,100,_318351),evi(decide_with_roll(_318351,_318335,_318337)).

evi(decide_with_roll(_318303,_318305,_318307)):-evi(success(_318305,_318307)).

evi(success(_318233,_318235)):-evi(truck_print(collect_done,_318233)),evi(send_complete(_318233,_318235)),evi(mark_completed(_318235)),evi(cleanup).

evi(cleanup):-retractall(current_job(_318149,_318151)),retractall(assign_wait_counter(_318165)),retractall(move_counter(_318179)),retractall(collect_counter(_318193)),retractall(truck_state(_318207)),assert(truck_state(idle)).

evi(assignment_timeout):-truck_state(waiting_assignment),current_job(_318099,_318101),evi(send_refuse(_318099,_318101)),evi(cleanup).

evi(mark_seen_pickup(_318045)):-_318045>0,assert(seen_pickup(_318045)).

evi(mark_seen_pickup(_318021)):-_318021=<0.

evi(mark_assignment_ack(_317895,_317897)):-_317897>0,agent(_317919),assert(seen_assignment(_317897)),shared_token(_317943),a(message(control_center,send_message(assignment_ack(_317919,_317895,_317897,_317943),_317919),_317919)),a(message(control_center,send_message(assignment_ack(_317919,_317895,_317897),_317919),_317919)).

evi(mark_assignment_ack(_317869,_317871)):-_317871=<0.

evi(mark_completed(_317831)):-_317831>0,assert(completed_local(_317831)).

evi(mark_completed(_317807)):-_317807=<0.

evi(send_refuse(_317727,_317729)):-_317729>0,agent(_317751),shared_token(_317761),a(message(control_center,send_message(job_refuse(_317751,_317727,_317729,_317761),_317751),_317751)).

evi(send_refuse(_317661,_317663)):-_317663=<0,agent(_317685),a(message(control_center,send_message(job_refuse(_317685,_317661),_317685),_317685)).

evi(send_accept(_317581,_317583)):-_317583>0,agent(_317605),shared_token(_317615),a(message(control_center,send_message(job_accept(_317605,_317581,_317583,_317615),_317605),_317605)).

evi(send_accept(_317515,_317517)):-_317517=<0,agent(_317539),a(message(control_center,send_message(job_accept(_317539,_317515),_317539),_317539)).

evi(send_complete(_317443,_317445)):-_317445>0,evi(send_complete_token(_317443,_317445)),evi(send_complete_req(_317443,_317445)),evi(send_complete_legacy(_317443)).

evi(send_complete_token(_317377,_317379)):-agent(_317389),shared_token(_317399),a(message(control_center,send_message(collection_complete(_317377,_317379,_317399),_317389),_317389)).

evi(send_complete_req(_317323,_317325)):-agent(_317335),a(message(control_center,send_message(collection_complete(_317323,_317325),_317335),_317335)).

evi(send_complete_legacy(_317273)):-agent(_317283),a(message(control_center,send_message(collection_complete(_317273),_317283),_317283)).

evi(send_complete(_317209,_317211)):-_317211=<0,agent(_317233),a(message(control_center,send_message(collection_complete(_317209),_317233),_317233)).

evi(monitor(dummy)):- \+started,evi(start).

evi(monitor(dummy)):-started,statistics(walltime,[_317109,_317113]),last_monitor_ts(_317125),monitor_interval_ms(_317135),_317109-_317125<_317135,!,true.

evi(monitor(dummy)):-started,statistics(walltime,[_316995,_316999]),last_monitor_ts(_317011),monitor_interval_ms(_317021),_316995-_317011>=_317021,retract(last_monitor_ts(_317011)),assert(last_monitor_ts(_316995)),evi(monitor_tick).

evi(monitor_tick):-evi(tick_status_counter),evi(tick_assignment_wait),evi(tick_move_phase),evi(tick_collect_phase).

evi(tick_status_counter):-status_counter(_316851),_316851>1,_316873 is _316851-1,retract(status_counter(_316851)),assert(status_counter(_316873)),!.

evi(tick_status_counter):-status_counter(1),tesg(delta(_316789)),retract(status_counter(1)),assert(status_counter(_316789)),evi(status_check),!.

evi(tick_status_counter):-true.

evi(tick_assignment_wait):-truck_state(waiting_assignment),assign_wait_counter(_316679),_316679>1,_316701 is _316679-1,retract(assign_wait_counter(_316679)),assert(assign_wait_counter(_316701)),!.

evi(tick_assignment_wait):-truck_state(waiting_assignment),assign_wait_counter(1),retract(assign_wait_counter(1)),evi(assignment_timeout),!.

evi(tick_assignment_wait):-true.

evi(tick_move_phase):-truck_state(moving),move_counter(_316515),_316515>1,_316537 is _316515-1,retract(move_counter(_316515)),assert(move_counter(_316537)),!.

evi(tick_move_phase):-truck_state(moving),move_counter(1),current_job(_316381,_316383),retract(move_counter(1)),collect_time(_316407),retractall(collect_counter(_316421)),assert(collect_counter(_316407)),retract(truck_state(moving)),assert(truck_state(collecting)),evi(truck_print_eta(collect_start,_316381,_316407)),!.

evi(tick_move_phase):-true.

evi(tick_collect_phase):-truck_state(collecting),collect_counter(_316265),_316265>1,_316287 is _316265-1,retract(collect_counter(_316265)),assert(collect_counter(_316287)),!.

evi(tick_collect_phase):-truck_state(collecting),collect_counter(1),current_job(_316199,_316201),retract(collect_counter(1)),evi(decide_outcome(_316199,_316201)),!.

evi(tick_collect_phase):-true.

monitor(dummy):-evi(monitor(dummy)).

:-dynamic receive/1.

:-dynamic send/2.

:-dynamic isa/3.

comm_trace(off).

log_comm(_315977,_315979,_315981):-comm_trace(on),!,write(comm),write(_315977),write(from),write(_315981),write(payload),write(_315979),nl.

log_comm(_315959,_315961,_315963).

safe_told(_315921,_315923):-current_predicate(told/2)->told(_315921,_315923);true.

safe_told(_315867,_315869,_315871):-current_predicate(told/3)->told(_315867,_315869,_315871);_315871=0.

safe_tell(_315819,_315821,_315823):-current_predicate(tell/3)->tell(_315819,_315821,_315823);true.

log_comm(var_Tag,var_X,var_Ag):-comm_trace(on),!,write(comm),write(var_Tag),write(from),write(var_Ag),write(payload),write(var_X),nl.

log_comm(_315707,_315709,_315711).

safe_told(var_Ag,var_M):-current_predicate(told/2)->told(var_Ag,var_M);true.

safe_told(var_Ag,var_M,var_T):-current_predicate(told/3)->told(var_Ag,var_M,var_T);var_T=0.

safe_tell(var_To,var_Ag,var_M):-current_predicate(tell/3)->tell(var_To,var_Ag,var_M);true.

receive(send_message(_315529,_315531)):-safe_told(_315531,send_message(_315529)),call_send_message(_315529,_315531).

send(_315473,send_message(_315479,_315481)):-safe_tell(_315473,_315481,send_message(_315479)),send_m(_315473,send_message(_315479,_315481)).

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

call_send_message(_313901,_313903):-nonvar(_313901)->log_comm(dispatch,_313901,_313903),(nonvar(_313903),_313903\=self,catch(send_message(_313901,_313903),_313967,fail);catch(send_message(_313901,_313995),_313987,fail);catch(call(evi(_313901)),_314007,fail);true);true.

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

trigger_inform_handlers(var_X,var_M,var_Ag):-catch(call(eve(inform_E(var_X,var_Ag))),_312737,true),catch(call(eve(inform_E(var_X,var_M,var_Ag))),_312765,true),catch(call(eve(inform_E(var_X))),_312795,true),catch(call(eve(inform_(var_X,var_Ag))),_312821,true),catch(call(eve(inform_(var_X,var_M,var_Ag))),_312849,true),catch(call(eve(inform_(var_X))),_312879,true),catch(call(eve(eve(inform_(var_X,var_Ag)))),_312905,true),catch(call(eve(eve(inform_(var_X,var_M,var_Ag)))),_312937,true),catch(call(eve(eve(inform_(var_X)))),_312965,true).

call_refuse(var_X,var_Ag,var_T):-clause(agent(var_A),var__),asse_cosa(past_event(var_X,var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(var_X,var__,var_Ag)),assert(past(var_X,var_Tp,var_Ag)),a(message(var_Ag,reply(received(var_X),var_A))).

call_cfp(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_312501,var_Ontology,_312505),_312495),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_cfp(var_A,var_C,var_Ag,_312539)),a(message(var_Ag,propose(var_A,[_312539],var_AgI))),retractall(ext_agent(var_Ag,_312577,var_Ontology,_312581)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_312375,var_Ontology,_312379),_312369),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,accept_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_312445,var_Ontology,_312449)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_312263,var_Ontology,_312267),_312257),not(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,reject_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_312319,var_Ontology,_312323)).

call_accept_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(accepted_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(accepted_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(accepted_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_reject_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(rejected_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(rejected_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(rejected_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_failure(var_A,var_M,var_Ag,var_T):-asse_cosa(past_event(failed_action(var_A,var_M,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(failed_action(var_A,var_M,var_Ag),var__,var_Ag)),assert(past(failed_action(var_A,var_M,var_Ag),var_Tp,var_Ag)).

call_cancel(var_A,var_Ag):-if(clause(high_action(var_A,var_Te,var_Ag),_311827),retractall(high_action(var_A,var_Te,var_Ag)),true),if(clause(normal_action(var_A,var_Te,var_Ag),_311861),retractall(normal_action(var_A,var_Te,var_Ag)),true).

external_refused_action_propose(var_A,var_Ag):-clause(not_executable_action_propose(var_A,var_Ag),var__).

evi(external_refused_action_propose(var_A,var_Ag)):-clause(agent(var_Ai),var__),a(message(var_Ag,failure(var_A,motivation(false_conditions),var_Ai))),retractall(not_executable_action_propose(var_A,var_Ag)).

refused_message(var_AgM,var_Con):-clause(eliminated_message(var_AgM,var__,var__,var_Con,var__),var__).

refused_message(var_To,var_M):-clause(eliminated_message(var_M,var_To,motivation(conditions_not_verified)),_311643).

evi(refused_message(var_AgM,var_Con)):-clause(agent(var_Ai),var__),a(message(var_AgM,inform(var_Con,motivation(refused_message),var_Ai))),retractall(eliminated_message(var_AgM,var__,var__,var_Con,var__)),retractall(eliminated_message(var_Con,var_AgM,motivation(conditions_not_verified))).

send_jasper_return_message(var_X,var_S,var_T,var_S0):-clause(agent(var_Ag),_311491),a(message(var_S,send_message(sent_rmi(var_X,var_T,var_S0),var_Ag))).

gest_learn(var_H):-clause(past(learn(var_H),var_T,var_U),_311439),learn_if(var_H,var_T,var_U).

evi(gest_learn(var_H)):-retractall(past(learn(var_H),_311315,_311317)),clause(agente(_311337,_311339,_311341,var_S),_311333),name(var_S,var_N),append(var_L,[46,112,108],var_N),name(var_F,var_L),manage_lg(var_H,var_F),a(learned(var_H)).

cllearn:-clause(agente(_311109,_311111,_311113,var_S),_311105),name(var_S,var_N),append(var_L,[46,112,108],var_N),append(var_L,[46,116,120,116],var_To),name(var_FI,var_To),open(var_FI,read,_311209,[]),repeat,read(_311209,var_T),arg(1,var_T,var_H),write(var_H),nl,var_T==end_of_file,!,close(_311209).

send_msg_learn(var_T,var_A,var_Ag):-a(message(var_Ag,confirm(learn(var_T),var_A))).

told(_311039,send_message(_311045)):-true.

told(_311015,inform(_311023,_311025),70):-true.

told(_310993,inform(_311001),70):-true.

told(_310973,refuse(_310979)):-true.

told(_310951,refuse(_310957,_310959)):-true.

tell(_310929,_310931,send_message(_310937)):-true.

tell(_310907,_310909,refuse(_310915)):-true.

tell(_310883,_310885,refuse(_310891,_310893)):-true.

tell(_310859,_310861,inform(_310867,_310869)):-true.

tell(_310837,_310839,inform(_310845)):-true.

meta(_310809,_310809,_310813):-nonvar(_310809),!.
