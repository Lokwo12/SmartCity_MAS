
:-dynamic request/3,tried/2,truck_state/2,started/0,cycle_counter/1.

:-dynamic req_seq/1,inflight/6,processed_reply/3,completed_req/1,dead_letter/4.

:-dynamic last_cycle_ts/1,pending_dup_notified/1.

:-dynamic rr_idx/1.

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

evi(start):-retractall(started),assert(started),tesg(delta(_208897)),retractall(cycle_counter(_208911)),assert(cycle_counter(_208897)),retractall(req_seq(_208939)),assert(req_seq(1)),retractall(rr_idx(_208967)),assert(rr_idx(1)),retractall(last_cycle_ts(_208995)),statistics(walltime,[_209009,_209013]),assert(last_cycle_ts(_209009)),a(init_trucks),true.

a(init_trucks):-retractall(truck_state(_208827,_208829)),forall(truck(_208839),assert(truck_state(_208839,idle))).

evi(cycle):-evi(monitor_system).

evi(monitor_system):-a(check_stuck_requests),a(process_timeouts).

a(check_stuck_requests):-true.

a(new_req_id(_208677)):-req_seq(_208687),_208677 is _208687,_208709 is _208687+1,retract(req_seq(_208687)),assert(req_seq(_208709)).

pending_bin(_208651):-request(_208655,_208651,_208659).

trusted_bin(_208633):-bin(_208633).

trusted_truck(_208615):-truck(_208615).

short_bin_id(_208571,_208573):-atom_concat(smart_bin,_208585,_208571),!,atom_concat(sb,_208585,_208573).

short_bin_id(_208555,_208555).

short_truck_id(_208517,_208519):-atom_concat(truck,_208531,_208517),!,atom_concat(t,_208531,_208519).

short_truck_id(_208501,_208501).

a(telemetry(_208429,_208431,_208433,_208435,_208437,_208439)):-a(message(logger,send_message(log(_208429,event(_208431,req(_208433),bin(_208435),truck(_208437),note(_208439)),control_center),control_center),control_center)).

a(persist_dead_letter(_208349,_208351,_208353)):-statistics(walltime,[_208367,_208371]),assert(dead_letter(_208349,_208351,_208353,_208367)),a(telemetry(error,dead_letter,_208349,_208351,none,_208353)).

eve(bin_full(_208209)):-trusted_bin(_208209),\+pending_bin(_208209),!,retractall(pending_dup_notified(_208209)),format('[CONTROL_CENTER] BIN_FULL received from bin=~w~n',[_208209]),a(new_req_id(_208283)),a(clear_tried_list(_208209)),a(telemetry(info,request_opened,_208283,_208209,none,accepted)),evi(select_truck(_208283,_208209)).

eve(bin_full(_208129)):-pending_bin(_208129),\+pending_dup_notified(_208129),!,assert(pending_dup_notified(_208129)),a(telemetry(warn,duplicate_bin_full,0,_208129,none,ignored)).

eve(bin_full(_208085)):-pending_bin(_208085),pending_dup_notified(_208085),!,true.

send_message(inform(bin_full(_208039),_208035),_208029):-shared_token(_208035),trusted_bin(_208029),fire_event(bin_full(_208039)).

send_message(bin_full(_207995),_207991):-trusted_bin(_207991),fire_event(bin_full(_207995)).

send_message(bin_full(_207945,_207947),_207941):-shared_token(_207947),trusted_bin(_207941),fire_event(bin_full(_207945)).

send_message(agree(pickup(_207913),_207909),_207903):-fire_event(job_accept(_207909,_207913,0)).

send_message(job_accept(_207873,_207875),_207869):-fire_event(job_accept(_207873,_207875,0)).

send_message(job_accept(_207825,_207827,_207829,_207831),_207821):-shared_token(_207831),fire_event(job_accept(_207825,_207827,_207829)).

send_message(refuse(pickup(_207793),_207789),_207783):-fire_event(job_refuse(_207789,_207793,0)).

send_message(job_refuse(_207753,_207755),_207749):-fire_event(job_refuse(_207753,_207755,0)).

send_message(job_refuse(_207705,_207707,_207709,_207711),_207701):-shared_token(_207711),fire_event(job_refuse(_207705,_207707,_207709)).

send_message(assignment_ack(_207657,_207659,_207661,_207663),_207653):-shared_token(_207663),fire_event(assignment_ack(_207657,_207659,_207661)).

send_message(assignment_ack(_207621,_207623,_207625),_207617):-fire_event(assignment_ack(_207621,_207623,_207625)).

send_message(inform(collection_complete(_207591),_207587),_207581):-fire_event(collection_complete(_207591,0)).

send_message(collection_complete(_207555),_207551):-fire_event(collection_complete(_207555,0)).

send_message(collection_complete(_207511,_207513,_207515),_207507):-shared_token(_207515),fire_event(collection_complete(_207511,_207513)).

send_message(collection_complete(_207479,_207481),_207475):-fire_event(collection_complete(_207479,_207481)).

send_message(inform(collection_failed(_207445,_207447),_207441),_207435):-fire_event(collection_failed(_207445,_207447,0)).

send_message(collection_failed(_207405,_207407),_207401):-fire_event(collection_failed(_207405,_207407,0)).

send_message(collection_failed(_207357,_207359,_207361,_207363),_207353):-shared_token(_207363),fire_event(collection_failed(_207357,_207359,_207361)).

send_message(collection_failed(_207321,_207323,_207325),_207317):-fire_event(collection_failed(_207321,_207323,_207325)).

send_message(reset_ack(_207267,_207269,_207271),_207263):-shared_token(_207271),trusted_bin(_207263),fire_event(reset_ack(_207267,_207269)).

fire_event(_207203):-(catch(call(eve(_207203)),_207221,fail);catch(call(evi(_207203)),_207237,fail)),!.

fire_event(_207189).

evi(select_truck(_207103,_207105)):-findall(_207115,(truck(_207115),truck_state(_207115,idle),\+tried(_207105,_207115)),_207119),_207119\=[],!,evi(dispatch(_207103,_207105,_207119)).

evi(select_truck(_207037,_207039)):-findall(_207049,(truck(_207049),\+tried(_207039,_207049)),_207053),evi(dispatch(_207037,_207039,_207053)).

a(choose_candidate(_206899,_206901)):-rr_idx(_206911),length(_206899,_206923),_206923>0,_206945 is(_206911-1)mod _206923+1,nth1(_206945,_206899,_206901),_206989 is _206911+1,retract(rr_idx(_206911)),assert(rr_idx(_206989)).

evi(dispatch(_206811,_206813,[])):-retractall(inflight(_206811,_206813,_206833,_206835,_206837,_206839)),assert(inflight(_206811,_206813,none,awaiting_retry,2,0)),a(telemetry(warn,no_truck_available_retry,_206811,_206813,none,awaiting_retry)).

evi(dispatch(_206613,_206615,_206617)):-a(choose_candidate(_206617,_206633)),assert(request(_206613,_206615,_206633)),reply_ttl(_206661),retractall(inflight(_206613,_206615,_206633,_206681,_206683,_206685)),assert(inflight(_206613,_206615,_206633,awaiting_reply,_206661,0)),format('[CONTROL_CENTER] DISPATCH request=~w bin=~w truck=~w~n',[_206613,_206615,_206633]),shared_token(_206743),a(message(_206633,send_message(pickup_request(_206615,_206613,_206743),control_center),control_center)),a(telemetry(info,pickup_request_sent,_206613,_206615,_206633,awaiting_reply)).

eve(job_accept(_206383,_206385,_206387)):-request(_206387,_206385,_206383),inflight(_206387,_206385,_206383,awaiting_reply,_206419,_206421),\+processed_reply(_206387,_206383,accept),!,format('[CONTROL_CENTER] ACCEPT request=~w bin=~w truck=~w~n',[_206387,_206385,_206383]),assert(processed_reply(_206387,_206383,accept)),retractall(truck_state(_206383,_206503)),assert(truck_state(_206383,busy)),completion_ttl(_206529),retractall(inflight(_206387,_206385,_206383,_206549,_206551,_206553)),assert(inflight(_206387,_206385,_206383,awaiting_completion,_206529,0)),a(telemetry(info,pickup_accepted_start_collection,_206387,_206385,_206383,awaiting_completion)).

eve(job_refuse(_206169,_206171,_206173)):-request(_206173,_206171,_206169),inflight(_206173,_206171,_206169,awaiting_reply,_206205,_206207),\+processed_reply(_206173,_206169,refuse),!,format('[CONTROL_CENTER] REFUSE request=~w bin=~w truck=~w -> reselection~n',[_206173,_206171,_206169]),assert(processed_reply(_206173,_206169,refuse)),retract(request(_206173,_206171,_206169)),retractall(inflight(_206173,_206171,_206169,_206311,_206313,_206315)),assert(tried(_206171,_206169)),a(telemetry(warn,truck_refused,_206173,_206171,_206169,retry_select)),evi(select_truck(_206173,_206171)).

eve(job_accept(_206091,_206093,_206095)):-request(_206095,_206093,_206091),\+inflight(_206095,_206093,_206091,awaiting_reply,_206131,_206133),a(telemetry(info,late_accept_ignored,_206095,_206093,_206091,non_reply_stage)).

eve(job_refuse(_206013,_206015,_206017)):-request(_206017,_206015,_206013),\+inflight(_206017,_206015,_206013,awaiting_reply,_206053,_206055),a(telemetry(info,late_refuse_ignored,_206017,_206015,_206013,non_reply_stage)).

eve(assignment_ack(_205851,_205853,_205855)):-request(_205855,_205853,_205851),inflight(_205855,_205853,_205851,awaiting_assign_ack,_205887,_205889),!,format('[CONTROL_CENTER] ASSIGNMENT_ACK request=~w bin=~w truck=~w~n',[_205855,_205853,_205851]),completion_ttl(_205929),retract(inflight(_205855,_205853,_205851,awaiting_assign_ack,_205951,_205889)),assert(inflight(_205855,_205853,_205851,awaiting_completion,_205929,0)),a(telemetry(info,assignment_acked,_205855,_205853,_205851,awaiting_completion)).

eve(collection_complete(_205565,_205567)):-request(_205567,_205565,_205581),\+completed_req(_205567),!,format('[CONTROL_CENTER] COLLECTION_COMPLETE request=~w bin=~w truck=~w~n',[_205567,_205565,_205581]),assert(completed_req(_205567)),retractall(truck_state(_205581,_205655)),assert(truck_state(_205581,idle)),retractall(inflight(_205567,_205565,_205581,_205691,_205693,_205695)),shared_token(_205705),a(message(_205565,send_message(reset_bin(_205565,_205567,_205705),control_center),control_center)),retractall(request(_205567,_205565,_205755)),retractall(pending_dup_notified(_205565)),a(clear_tried_list(_205565)),a(message(logger,send_message(log(info,collection_complete,_205565),control_center),control_center)),a(telemetry(info,reset_sent_async,_205567,_205565,_205581,closed_after_reset_send)).

eve(collection_complete(_205509,0)):-request(_205521,_205509,_205525),_205521>0,fire_event(collection_complete(_205509,_205521)).

eve(collection_failed(_205319,_205321,_205323)):-request(_205323,_205321,_205319),!,format('[CONTROL_CENTER] COLLECTION_FAILED request=~w bin=~w truck=~w -> reselection~n',[_205323,_205321,_205319]),retractall(truck_state(_205319,_205383)),assert(truck_state(_205319,idle)),retract(request(_205323,_205321,_205319)),retractall(inflight(_205323,_205321,_205319,_205437,_205439,_205441)),assert(tried(_205321,_205319)),a(telemetry(warn,collection_failed,_205323,_205321,_205319,retry_select)),evi(select_truck(_205323,_205321)).

eve(collection_failed(_205259,_205261,0)):-request(_205273,_205261,_205259),_205273>0,fire_event(collection_failed(_205259,_205261,_205273)).

eve(reset_ack(_205101,_205103)):-inflight(_205103,_205101,_205117,awaiting_reset_ack,_205121,_205123),!,format('[CONTROL_CENTER] RESET_ACK request=~w bin=~w truck=~w -> closed~n',[_205103,_205101,_205117]),retractall(inflight(_205103,_205101,_205117,awaiting_reset_ack,_205175,_205177)),retractall(request(_205103,_205101,_205195)),retractall(pending_dup_notified(_205101)),a(clear_tried_list(_205101)),a(telemetry(info,request_closed,_205103,_205101,_205117,reset_acked)).

eve(reset_ack(_205039,_205041)):- \+inflight(_205041,_205039,_205059,awaiting_reset_ack,_205063,_205065),a(telemetry(info,late_reset_ack,_205041,_205039,none,ignored_after_async_close)).

a(process_timeouts):-findall(inflight(_204953,_204955,_204957,_204959,_204961,_204963),inflight(_204953,_204955,_204957,_204959,_204961,_204963),_204949),forall(member(inflight(_204953,_204955,_204957,_204959,_204961,_204963),_204949),a(timeout_step(_204953,_204955,_204957,_204959,_204961,_204963))).

a(timeout_step(_204839,_204841,_204843,_204845,_204847,_204849)):-_204847>1,_204871 is _204847-1,retract(inflight(_204839,_204841,_204843,_204845,_204847,_204849)),assert(inflight(_204839,_204841,_204843,_204845,_204871,_204849)).

a(timeout_step(_204719,_204721,_204723,awaiting_reply,1,_204729)):-retractall(inflight(_204719,_204721,_204723,awaiting_reply,1,_204753)),retractall(request(_204719,_204721,_204723)),assert(tried(_204721,_204723)),a(telemetry(warn,reply_timeout,_204719,_204721,_204723,retry_select)),evi(select_truck(_204719,_204721)).

a(timeout_step(_204513,_204515,_204517,awaiting_assign_ack,1,_204523)):-_204523<1,retractall(inflight(_204513,_204515,_204517,awaiting_assign_ack,1,_204523)),assign_ack_ttl(_204569),_204579 is _204523+1,assert(inflight(_204513,_204515,_204517,awaiting_assign_ack,_204569,_204579)),shared_token(_204621),a(message(_204517,send_message(assignment(_204515,_204513,_204621),control_center),control_center)),a(message(_204517,send_message(assignment(_204515,_204513),control_center),control_center)),a(telemetry(warn,assign_ack_timeout_resend,_204513,_204515,_204517,resend_assignment)).

a(timeout_step(_204381,_204383,_204385,awaiting_assign_ack,1,_204391)):-_204391>=1,retractall(inflight(_204381,_204383,_204385,awaiting_assign_ack,1,_204391)),retractall(request(_204381,_204383,_204385)),assert(tried(_204383,_204385)),a(telemetry(error,assign_ack_timeout_drop,_204381,_204383,_204385,retry_select)),evi(select_truck(_204381,_204383)).

a(timeout_step(_204261,_204263,_204265,awaiting_completion,1,_204271)):-retractall(inflight(_204261,_204263,_204265,awaiting_completion,1,_204295)),retractall(request(_204261,_204263,_204265)),assert(tried(_204263,_204265)),a(telemetry(error,completion_timeout,_204261,_204263,_204265,retry_select)),evi(select_truck(_204261,_204263)).

a(timeout_step(_204145,_204147,_204149,awaiting_reset_ack,1,_204155)):-retractall(inflight(_204145,_204147,_204149,awaiting_reset_ack,1,_204179)),retractall(request(_204145,_204147,_204197)),retractall(pending_dup_notified(_204147)),a(clear_tried_list(_204147)),a(telemetry(warn,reset_ack_timeout,_204145,_204147,_204149,closed_without_ack)).

a(timeout_step(_204045,_204047,none,awaiting_retry,1,_204055)):-retractall(inflight(_204045,_204047,none,awaiting_retry,1,_204079)),a(clear_tried_list(_204047)),a(telemetry(info,retry_dispatch,_204045,_204047,none,reselect)),evi(select_truck(_204045,_204047)).

a(clear_tried_list(_204017)):-retractall(tried(_204017,_204027)).

evi(monitor(dummy)):- \+started,evi(start).

evi(monitor(dummy)):-started,statistics(walltime,[_203917,_203921]),last_cycle_ts(_203933),cycle_interval_ms(_203943),_203917-_203933<_203943,!,true.

evi(monitor(dummy)):-started,statistics(walltime,[_203803,_203807]),last_cycle_ts(_203819),cycle_interval_ms(_203829),_203803-_203819>=_203829,retract(last_cycle_ts(_203819)),assert(last_cycle_ts(_203803)),evi(cycle).

monitor(dummy):-evi(monitor(dummy)).

:-dynamic receive/1.

:-dynamic send/2.

:-dynamic isa/3.

comm_trace(off).

log_comm(_203601,_203603,_203605):-comm_trace(on),!,write(comm),write(_203601),write(from),write(_203605),write(payload),write(_203603),nl.

log_comm(_203583,_203585,_203587).

safe_told(_203545,_203547):-current_predicate(told/2)->told(_203545,_203547);true.

safe_told(_203491,_203493,_203495):-current_predicate(told/3)->told(_203491,_203493,_203495);_203495=0.

safe_tell(_203443,_203445,_203447):-current_predicate(tell/3)->tell(_203443,_203445,_203447);true.

log_comm(var_Tag,var_X,var_Ag):-comm_trace(on),!,write(comm),write(var_Tag),write(from),write(var_Ag),write(payload),write(var_X),nl.

log_comm(_203331,_203333,_203335).

safe_told(var_Ag,var_M):-current_predicate(told/2)->told(var_Ag,var_M);true.

safe_told(var_Ag,var_M,var_T):-current_predicate(told/3)->told(var_Ag,var_M,var_T);var_T=0.

safe_tell(var_To,var_Ag,var_M):-current_predicate(tell/3)->tell(var_To,var_Ag,var_M);true.

receive(send_message(_203153,_203155)):-safe_told(_203155,send_message(_203153)),call_send_message(_203153,_203155).

send(_203097,send_message(_203103,_203105)):-safe_tell(_203097,_203105,send_message(_203103)),send_m(_203097,send_message(_203103,_203105)).

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

call_send_message(_201525,_201527):-nonvar(_201525)->log_comm(dispatch,_201525,_201527),(nonvar(_201527),_201527\=self,catch(send_message(_201525,_201527),_201591,fail);catch(send_message(_201525,_201619),_201611,fail);catch(call(evi(_201525)),_201631,fail);true);true.

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

trigger_inform_handlers(var_X,var_M,var_Ag):-catch(call(eve(inform_E(var_X,var_Ag))),_200361,true),catch(call(eve(inform_E(var_X,var_M,var_Ag))),_200389,true),catch(call(eve(inform_E(var_X))),_200419,true),catch(call(eve(inform_(var_X,var_Ag))),_200445,true),catch(call(eve(inform_(var_X,var_M,var_Ag))),_200473,true),catch(call(eve(inform_(var_X))),_200503,true),catch(call(eve(eve(inform_(var_X,var_Ag)))),_200529,true),catch(call(eve(eve(inform_(var_X,var_M,var_Ag)))),_200561,true),catch(call(eve(eve(inform_(var_X)))),_200589,true).

call_refuse(var_X,var_Ag,var_T):-clause(agent(var_A),var__),asse_cosa(past_event(var_X,var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(var_X,var__,var_Ag)),assert(past(var_X,var_Tp,var_Ag)),a(message(var_Ag,reply(received(var_X),var_A))).

call_cfp(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_200125,var_Ontology,_200129),_200119),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_cfp(var_A,var_C,var_Ag,_200163)),a(message(var_Ag,propose(var_A,[_200163],var_AgI))),retractall(ext_agent(var_Ag,_200201,var_Ontology,_200205)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_199999,var_Ontology,_200003),_199993),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,accept_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_200069,var_Ontology,_200073)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_199887,var_Ontology,_199891),_199881),not(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,reject_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_199943,var_Ontology,_199947)).

call_accept_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(accepted_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(accepted_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(accepted_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_reject_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(rejected_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(rejected_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(rejected_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_failure(var_A,var_M,var_Ag,var_T):-asse_cosa(past_event(failed_action(var_A,var_M,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(failed_action(var_A,var_M,var_Ag),var__,var_Ag)),assert(past(failed_action(var_A,var_M,var_Ag),var_Tp,var_Ag)).

call_cancel(var_A,var_Ag):-if(clause(high_action(var_A,var_Te,var_Ag),_199451),retractall(high_action(var_A,var_Te,var_Ag)),true),if(clause(normal_action(var_A,var_Te,var_Ag),_199485),retractall(normal_action(var_A,var_Te,var_Ag)),true).

external_refused_action_propose(var_A,var_Ag):-clause(not_executable_action_propose(var_A,var_Ag),var__).

evi(external_refused_action_propose(var_A,var_Ag)):-clause(agent(var_Ai),var__),a(message(var_Ag,failure(var_A,motivation(false_conditions),var_Ai))),retractall(not_executable_action_propose(var_A,var_Ag)).

refused_message(var_AgM,var_Con):-clause(eliminated_message(var_AgM,var__,var__,var_Con,var__),var__).

refused_message(var_To,var_M):-clause(eliminated_message(var_M,var_To,motivation(conditions_not_verified)),_199267).

evi(refused_message(var_AgM,var_Con)):-clause(agent(var_Ai),var__),a(message(var_AgM,inform(var_Con,motivation(refused_message),var_Ai))),retractall(eliminated_message(var_AgM,var__,var__,var_Con,var__)),retractall(eliminated_message(var_Con,var_AgM,motivation(conditions_not_verified))).

send_jasper_return_message(var_X,var_S,var_T,var_S0):-clause(agent(var_Ag),_199115),a(message(var_S,send_message(sent_rmi(var_X,var_T,var_S0),var_Ag))).

gest_learn(var_H):-clause(past(learn(var_H),var_T,var_U),_199063),learn_if(var_H,var_T,var_U).

evi(gest_learn(var_H)):-retractall(past(learn(var_H),_198939,_198941)),clause(agente(_198961,_198963,_198965,var_S),_198957),name(var_S,var_N),append(var_L,[46,112,108],var_N),name(var_F,var_L),manage_lg(var_H,var_F),a(learned(var_H)).

cllearn:-clause(agente(_198733,_198735,_198737,var_S),_198729),name(var_S,var_N),append(var_L,[46,112,108],var_N),append(var_L,[46,116,120,116],var_To),name(var_FI,var_To),open(var_FI,read,_198833,[]),repeat,read(_198833,var_T),arg(1,var_T,var_H),write(var_H),nl,var_T==end_of_file,!,close(_198833).

send_msg_learn(var_T,var_A,var_Ag):-a(message(var_Ag,confirm(learn(var_T),var_A))).

told(_198663,send_message(_198669)):-true.

told(_198639,inform(_198647,_198649),70):-true.

told(_198617,inform(_198625),70):-true.

told(_198597,refuse(_198603)):-true.

told(_198575,refuse(_198581,_198583)):-true.

tell(_198553,_198555,send_message(_198561)):-true.

tell(_198531,_198533,refuse(_198539)):-true.

tell(_198507,_198509,refuse(_198515,_198517)):-true.

tell(_198483,_198485,inform(_198491,_198493)):-true.

tell(_198461,_198463,inform(_198469)):-true.

meta(_198433,_198433,_198437):-nonvar(_198433),!.
