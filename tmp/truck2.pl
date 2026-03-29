
:-dynamic truck_state/1,current_job/2,started/0,status_counter/1,assign_wait_counter/1.

:-dynamic seen_pickup/1,seen_assignment/1,completed_local/1.

:-dynamic last_monitor_ts/1.

:-dynamic busy_logged_req/1.

:-dynamic move_counter/1,collect_counter/1.

tesg(delta(4)).

move_time(3).

collect_time(3).

assign_wait_limit(6).

shared_token(city_token_2026).

monitor_interval_ms(1000).

short_bin_id(_334839,_334841):-atom_concat(smart_bin,_334853,_334839),!,atom_concat(sb,_334853,_334841).

short_bin_id(_334823,_334823).

short_truck_id(_334785,_334787):-atom_concat(truck,_334799,_334785),!,atom_concat(t,_334799,_334787).

short_truck_id(_334769,_334769).

evi(start):-retractall(started),assert(started),retractall(current_job(_334549,_334551)),retractall(truck_state(_334565)),retractall(assign_wait_counter(_334579)),retractall(seen_pickup(_334593)),retractall(seen_assignment(_334607)),retractall(completed_local(_334621)),retractall(busy_logged_req(_334635)),retractall(move_counter(_334649)),retractall(collect_counter(_334663)),retractall(last_monitor_ts(_334677)),assert(truck_state(idle)),tesg(delta(_334705)),retractall(status_counter(_334719)),assert(status_counter(_334705)),statistics(walltime,[_334747,_334751]),assert(last_monitor_ts(_334747)).

evi(status_check):-true.

send_message(request(pickup(_334477),_334473),_334467):-fire_event(pickup_request(_334477,0)).

send_message(pickup_request(_334441),_334437):-fire_event(pickup_request(_334441,0)).

send_message(pickup_request(_334397,_334399,_334401),control_center):-shared_token(_334401),fire_event(pickup_request(_334397,_334399)).

send_message(confirm(assignment(_334367),_334363),_334357):-fire_event(assignment(_334367,0)).

send_message(assignment(_334331),_334327):-fire_event(assignment(_334331,0)).

send_message(assignment(_334287,_334289,_334291),control_center):-shared_token(_334291),fire_event(assignment(_334287,_334289)).

send_message(assignment(_334255,_334257),control_center):-fire_event(assignment(_334255,_334257)).

fire_event(_334191):-(catch(call(eve(_334191)),_334209,fail);catch(call(evi(_334191)),_334225,fail)),!.

fire_event(_334177).

eve(pickup_request(_334139,_334141)):-_334141>0,completed_local(_334141),!,true.

eve(pickup_request(_334075,_334077)):-_334077>0,seen_pickup(_334077),\+current_job(_334075,_334077),!,true.

eve(pickup_request(_333957,_333959)):-seen_pickup(_333959),current_job(_333957,_333959),truck_state(waiting_assignment),_333959>0,!,agent(_334019),shared_token(_334029),a(message(control_center,send_message(job_accept(_334019,_333957,_333959,_334029),_334019),_334019)).

eve(pickup_request(_333823,_333825)):-truck_state(_333835),_333835\=idle,_333825>0,\+busy_logged_req(_333825),assert(busy_logged_req(_333825)),!,agent(_333903),format('[TRUCK ~w] PICKUP_BUSY bin=~w request=~w~n',[_333903,_333823,_333825]),a(send_refuse(_333903,_333823,_333825)).

eve(pickup_request(_333753,_333755)):-truck_state(_333765),_333765\=idle,!,agent(_333793),a(send_refuse(_333793,_333753,_333755)).

eve(pickup_request(_333537,_333539)):-truck_state(idle),agent(_333559),format('[TRUCK ~w] PICKUP_ACCEPTED bin=~w request=~w~n',[_333559,_333537,_333539]),retract(truck_state(idle)),assert(truck_state(moving)),retractall(current_job(_333625,_333627)),assert(current_job(_333537,_333539)),move_time(_333653),retractall(move_counter(_333667)),assert(move_counter(_333653)),format('[TRUCK ~w] MOVE_START bin=~w request=~w eta=~ws~n',[_333559,_333537,_333539,_333653]),a(mark_seen_pickup(_333539)),a(send_accept(_333559,_333537,_333539)).

eve(assignment(_333489,_333491)):-_333491>0,completed_local(_333491),!,true.

eve(assignment(_333381,_333383)):-_333383>0,seen_assignment(_333383),current_job(_333381,_333383),!,agent(_333433),shared_token(_333443),a(message(control_center,send_message(assignment_ack(_333433,_333381,_333383,_333443),_333433),_333433)).

eve(assignment(_333183,_333185)):-current_job(_333183,_333185),!,agent(_333213),format('[TRUCK ~w] ASSIGNMENT_RECEIVED bin=~w request=~w~n',[_333213,_333183,_333185]),retractall(assign_wait_counter(_333251)),retractall(truck_state(_333265)),assert(truck_state(moving)),move_time(_333289),retractall(move_counter(_333303)),assert(move_counter(_333289)),format('[TRUCK ~w] MOVE_START bin=~w request=~w eta=~ws~n',[_333213,_333183,_333185,_333289]),a(mark_assignment_ack(_333213,_333183,_333185)),true.

eve(assignment(_333163,_333165)):-true.

evi(decide_outcome(_333117,_333119)):-random(0,100,_333133),a(decide_with_roll(_333133,_333117,_333119)).

a(decide_with_roll(_333073,_333075,_333077)):-_333073<90,a(success(_333075,_333077)).

a(decide_with_roll(_333029,_333031,_333033)):-_333029>=90,a(failure(_333031,_333033)).

a(success(_332939,_332941)):-agent(_332951),format('[TRUCK ~w] SUCCESS bin=~w request=~w~n',[_332951,_332939,_332941]),a(send_complete(_332951,_332939,_332941)),a(mark_completed(_332941)),a(cleanup).

a(failure(_332863,_332865)):-agent(_332875),format('[TRUCK ~w] FAILURE bin=~w request=~w~n',[_332875,_332863,_332865]),a(send_failed(_332875,_332863,_332865)),a(cleanup).

a(cleanup):-retractall(current_job(_332779,_332781)),retractall(assign_wait_counter(_332795)),retractall(move_counter(_332809)),retractall(collect_counter(_332823)),retractall(truck_state(_332837)),assert(truck_state(idle)).

evi(assignment_timeout):-truck_state(waiting_assignment),current_job(_332693,_332695),agent(_332705),format('[TRUCK ~w] ASSIGNMENT_TIMEOUT bin=~w request=~w~n',[_332705,_332693,_332695]),a(send_refuse(_332705,_332693,_332695)),a(cleanup).

a(mark_seen_pickup(_332639)):-_332639>0,assert(seen_pickup(_332639)).

a(mark_seen_pickup(_332615)):-_332615=<0.

a(mark_assignment_ack(_332497,_332499,_332501)):-_332501>0,assert(seen_assignment(_332501)),shared_token(_332537),a(safe_send(control_center,send_message(assignment_ack(_332497,_332499,_332501,_332537),_332497),_332497)),a(safe_send(control_center,send_message(assignment_ack(_332497,_332499,_332501),_332497),_332497)).

a(mark_assignment_ack(_332469,_332471,_332473)):-_332473=<0.

a(mark_completed(_332431)):-_332431>0,assert(completed_local(_332431)).

a(mark_completed(_332407)):-_332407=<0.

a(send_refuse(_332335,_332337,_332339)):-_332339>0,shared_token(_332361),a(message(control_center,send_message(job_refuse(_332335,_332337,_332339,_332361),_332335),_332335)).

a(send_refuse(_332277,_332279,_332281)):-_332281=<0,a(message(control_center,send_message(job_refuse(_332277,_332279),_332277),_332277)).

a(send_accept(_332205,_332207,_332209)):-_332209>0,shared_token(_332231),a(message(control_center,send_message(job_accept(_332205,_332207,_332209,_332231),_332205),_332205)).

a(send_accept(_332147,_332149,_332151)):-_332151=<0,a(message(control_center,send_message(job_accept(_332147,_332149),_332147),_332147)).

a(send_complete(_332019,_332021,_332023)):-_332023>0,shared_token(_332045),a(safe_send(control_center,send_message(collection_complete(_332021,_332023,_332045),_332019),_332019)),a(safe_send(control_center,send_message(collection_complete(_332021,_332023),_332019),_332019)),a(safe_send(control_center,send_message(collection_complete(_332021),_332019),_332019)).

a(send_complete(_331963,_331965,_331967)):-_331967=<0,a(message(control_center,send_message(collection_complete(_331965),_331963),_331963)).

a(send_failed(_331829,_331831,_331833)):-_331833>0,shared_token(_331855),a(safe_send(control_center,send_message(collection_failed(_331829,_331831,_331833,_331855),_331829),_331829)),a(safe_send(control_center,send_message(collection_failed(_331829,_331831,_331833),_331829),_331829)),a(safe_send(control_center,send_message(collection_failed(_331829,_331831),_331829),_331829)).

a(safe_send(_331789,_331791,_331793)):-a(message(_331789,_331791,_331793)),!.

a(safe_send(_331767,_331769,_331771)).

a(send_failed(_331715,_331717,_331719)):-_331719=<0,a(message(control_center,send_message(collection_failed(_331715,_331717),_331715),_331715)).

evi(monitor(dummy)):- \+started,evi(start).

evi(monitor(dummy)):-started,statistics(walltime,[_331615,_331619]),last_monitor_ts(_331631),monitor_interval_ms(_331641),_331615-_331631<_331641,!,true.

evi(monitor(dummy)):-started,statistics(walltime,[_331501,_331505]),last_monitor_ts(_331517),monitor_interval_ms(_331527),_331501-_331517>=_331527,retract(last_monitor_ts(_331517)),assert(last_monitor_ts(_331501)),a(monitor_tick).

a(monitor_tick):-a(tick_status_counter),a(tick_assignment_wait),a(tick_move_phase),a(tick_collect_phase).

a(tick_status_counter):-status_counter(_331357),_331357>1,_331379 is _331357-1,retract(status_counter(_331357)),assert(status_counter(_331379)),!.

a(tick_status_counter):-status_counter(1),tesg(delta(_331295)),retract(status_counter(1)),assert(status_counter(_331295)),evi(status_check),!.

a(tick_status_counter).

a(tick_assignment_wait):-truck_state(waiting_assignment),assign_wait_counter(_331191),_331191>1,_331213 is _331191-1,retract(assign_wait_counter(_331191)),assert(assign_wait_counter(_331213)),!.

a(tick_assignment_wait):-truck_state(waiting_assignment),assign_wait_counter(1),retract(assign_wait_counter(1)),evi(assignment_timeout),!.

a(tick_assignment_wait).

a(tick_move_phase):-truck_state(moving),move_counter(_331033),_331033>1,_331055 is _331033-1,retract(move_counter(_331033)),assert(move_counter(_331055)),!.

a(tick_move_phase):-truck_state(moving),move_counter(1),current_job(_330855,_330857),agent(_330867),retract(move_counter(1)),format('[TRUCK ~w] MOVE_DONE bin=~w request=~w~n',[_330867,_330855,_330857]),collect_time(_330915),retractall(collect_counter(_330929)),assert(collect_counter(_330915)),retract(truck_state(moving)),assert(truck_state(collecting)),format('[TRUCK ~w] COLLECT_START bin=~w request=~w eta=~ws~n',[_330867,_330855,_330857,_330915]),!.

a(tick_move_phase).

a(tick_collect_phase):-truck_state(collecting),collect_counter(_330745),_330745>1,_330767 is _330745-1,retract(collect_counter(_330745)),assert(collect_counter(_330767)),!.

a(tick_collect_phase):-truck_state(collecting),collect_counter(1),current_job(_330645,_330647),agent(_330657),retract(collect_counter(1)),format('[TRUCK ~w] COLLECT_DONE bin=~w request=~w~n',[_330657,_330645,_330647]),evi(decide_outcome(_330645,_330647)),!.

a(tick_collect_phase).

monitor(dummy):-evi(monitor(dummy)).

:-dynamic receive/1.

:-dynamic send/2.

:-dynamic isa/3.

comm_trace(off).

log_comm(_330429,_330431,_330433):-comm_trace(on),!,write(comm),write(_330429),write(from),write(_330433),write(payload),write(_330431),nl.

log_comm(_330411,_330413,_330415).

safe_told(_330373,_330375):-current_predicate(told/2)->told(_330373,_330375);true.

safe_told(_330319,_330321,_330323):-current_predicate(told/3)->told(_330319,_330321,_330323);_330323=0.

safe_tell(_330271,_330273,_330275):-current_predicate(tell/3)->tell(_330271,_330273,_330275);true.

log_comm(var_Tag,var_X,var_Ag):-comm_trace(on),!,write(comm),write(var_Tag),write(from),write(var_Ag),write(payload),write(var_X),nl.

log_comm(_330159,_330161,_330163).

safe_told(var_Ag,var_M):-current_predicate(told/2)->told(var_Ag,var_M);true.

safe_told(var_Ag,var_M,var_T):-current_predicate(told/3)->told(var_Ag,var_M,var_T);var_T=0.

safe_tell(var_To,var_Ag,var_M):-current_predicate(tell/3)->tell(var_To,var_Ag,var_M);true.

receive(send_message(_329981,_329983)):-safe_told(_329983,send_message(_329981)),call_send_message(_329981,_329983).

send(_329925,send_message(_329931,_329933)):-safe_tell(_329925,_329933,send_message(_329931)),send_m(_329925,send_message(_329931,_329933)).

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

call_send_message(_328353,_328355):-nonvar(_328353)->log_comm(dispatch,_328353,_328355),(nonvar(_328355),_328355\=self,catch(send_message(_328353,_328355),_328419,fail);catch(send_message(_328353,_328447),_328439,fail);catch(call(evi(_328353)),_328459,fail);true);true.

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

trigger_inform_handlers(var_X,var_M,var_Ag):-catch(call(eve(inform_E(var_X,var_Ag))),_327189,true),catch(call(eve(inform_E(var_X,var_M,var_Ag))),_327217,true),catch(call(eve(inform_E(var_X))),_327247,true),catch(call(eve(inform_(var_X,var_Ag))),_327273,true),catch(call(eve(inform_(var_X,var_M,var_Ag))),_327301,true),catch(call(eve(inform_(var_X))),_327331,true),catch(call(eve(eve(inform_(var_X,var_Ag)))),_327357,true),catch(call(eve(eve(inform_(var_X,var_M,var_Ag)))),_327389,true),catch(call(eve(eve(inform_(var_X)))),_327417,true).

call_refuse(var_X,var_Ag,var_T):-clause(agent(var_A),var__),asse_cosa(past_event(var_X,var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(var_X,var__,var_Ag)),assert(past(var_X,var_Tp,var_Ag)),a(message(var_Ag,reply(received(var_X),var_A))).

call_cfp(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_326953,var_Ontology,_326957),_326947),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_cfp(var_A,var_C,var_Ag,_326991)),a(message(var_Ag,propose(var_A,[_326991],var_AgI))),retractall(ext_agent(var_Ag,_327029,var_Ontology,_327033)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_326827,var_Ontology,_326831),_326821),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,accept_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_326897,var_Ontology,_326901)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_326715,var_Ontology,_326719),_326709),not(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,reject_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_326771,var_Ontology,_326775)).

call_accept_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(accepted_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(accepted_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(accepted_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_reject_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(rejected_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(rejected_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(rejected_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_failure(var_A,var_M,var_Ag,var_T):-asse_cosa(past_event(failed_action(var_A,var_M,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(failed_action(var_A,var_M,var_Ag),var__,var_Ag)),assert(past(failed_action(var_A,var_M,var_Ag),var_Tp,var_Ag)).

call_cancel(var_A,var_Ag):-if(clause(high_action(var_A,var_Te,var_Ag),_326279),retractall(high_action(var_A,var_Te,var_Ag)),true),if(clause(normal_action(var_A,var_Te,var_Ag),_326313),retractall(normal_action(var_A,var_Te,var_Ag)),true).

external_refused_action_propose(var_A,var_Ag):-clause(not_executable_action_propose(var_A,var_Ag),var__).

evi(external_refused_action_propose(var_A,var_Ag)):-clause(agent(var_Ai),var__),a(message(var_Ag,failure(var_A,motivation(false_conditions),var_Ai))),retractall(not_executable_action_propose(var_A,var_Ag)).

refused_message(var_AgM,var_Con):-clause(eliminated_message(var_AgM,var__,var__,var_Con,var__),var__).

refused_message(var_To,var_M):-clause(eliminated_message(var_M,var_To,motivation(conditions_not_verified)),_326095).

evi(refused_message(var_AgM,var_Con)):-clause(agent(var_Ai),var__),a(message(var_AgM,inform(var_Con,motivation(refused_message),var_Ai))),retractall(eliminated_message(var_AgM,var__,var__,var_Con,var__)),retractall(eliminated_message(var_Con,var_AgM,motivation(conditions_not_verified))).

send_jasper_return_message(var_X,var_S,var_T,var_S0):-clause(agent(var_Ag),_325943),a(message(var_S,send_message(sent_rmi(var_X,var_T,var_S0),var_Ag))).

gest_learn(var_H):-clause(past(learn(var_H),var_T,var_U),_325891),learn_if(var_H,var_T,var_U).

evi(gest_learn(var_H)):-retractall(past(learn(var_H),_325767,_325769)),clause(agente(_325789,_325791,_325793,var_S),_325785),name(var_S,var_N),append(var_L,[46,112,108],var_N),name(var_F,var_L),manage_lg(var_H,var_F),a(learned(var_H)).

cllearn:-clause(agente(_325561,_325563,_325565,var_S),_325557),name(var_S,var_N),append(var_L,[46,112,108],var_N),append(var_L,[46,116,120,116],var_To),name(var_FI,var_To),open(var_FI,read,_325661,[]),repeat,read(_325661,var_T),arg(1,var_T,var_H),write(var_H),nl,var_T==end_of_file,!,close(_325661).

send_msg_learn(var_T,var_A,var_Ag):-a(message(var_Ag,confirm(learn(var_T),var_A))).

told(_325491,send_message(_325497)):-true.

told(_325467,inform(_325475,_325477),70):-true.

told(_325445,inform(_325453),70):-true.

told(_325425,refuse(_325431)):-true.

told(_325403,refuse(_325409,_325411)):-true.

tell(_325381,_325383,send_message(_325389)):-true.

tell(_325359,_325361,refuse(_325367)):-true.

tell(_325335,_325337,refuse(_325343,_325345)):-true.

tell(_325311,_325313,inform(_325319,_325321)):-true.

tell(_325289,_325291,inform(_325297)):-true.

meta(_325261,_325261,_325265):-nonvar(_325261),!.
