
:-dynamic request/3,tried/2,truck_state/2,started/0,cycle_counter/1.

:-dynamic req_seq/1,inflight/6,processed_reply/3,completed_req/1,dead_letter/4.

truck(truck1).

truck(truck2).

truck(truck3).

bin(smart_bin1).

bin(smart_bin2).

bin(smart_bin3).

shared_token(city_token_2026).

tesg(delta(3)).

reply_ttl(3).

assign_ack_ttl(3).

completion_ttl(5).

reset_ack_ttl(3).

evi(start):-retractall(started),assert(started),tesg(delta(var_D)),retractall(cycle_counter(var__)),assert(cycle_counter(var_D)),retractall(req_seq(var__)),assert(req_seq(1)),a(init_trucks),true.

a(init_trucks):-retractall(truck_state(var__,var__)),forall(truck(var_T),assert(truck_state(var_T,idle))).

evi(cycle):-write('[CC] autonomous cycle'),nl,evi(monitor_system).

evi(monitor_system):-a(check_stuck_requests),a(process_timeouts).

a(check_stuck_requests):-forall(request(var_ReqId,var_Bin,var_T),(write('[CC monitor] active request: '),write(req(var_ReqId)-var_Bin-var_T),nl)).

a(new_req_id(var_ReqId)):-req_seq(var_N),var_ReqId is var_N,var_N1 is var_N+1,retract(req_seq(var_N)),assert(req_seq(var_N1)).

pending_bin(var_Bin):-request(var__,var_Bin,var__).

trusted_bin(var_B):-bin(var_B).

trusted_truck(var_T):-truck(var_T).

a(telemetry(var_Level,var_Name,var_ReqId,var_Bin,var_Truck,var_Note)):-a(message(logger,send_message(log(var_Level,event(var_Name,req(var_ReqId),bin(var_Bin),truck(var_Truck),note(var_Note)),control_center),control_center),control_center)).

a(persist_dead_letter(var_ReqId,var_Bin,var_Reason)):-statistics(walltime,[var_Ts,var__]),assert(dead_letter(var_ReqId,var_Bin,var_Reason,var_Ts)),a(telemetry(error,dead_letter,var_ReqId,var_Bin,none,var_Reason)).

eve(bin_full(var_Bin)):-trusted_bin(var_Bin),\+pending_bin(var_Bin),!,write('[CC] bin_full received from '),write(var_Bin),nl,a(new_req_id(var_ReqId)),a(clear_tried_list(var_Bin)),a(telemetry(info,request_opened,var_ReqId,var_Bin,none,accepted)),evi(select_truck(var_ReqId,var_Bin)).

eve(bin_full(var_Bin)):-pending_bin(var_Bin),a(telemetry(warn,duplicate_bin_full,0,var_Bin,none,ignored)).

send_message(inform(bin_full(var_Bin),var_Token),var_From):-shared_token(var_Token),trusted_bin(var_From),evi(bin_full(var_Bin)).

send_message(bin_full(var_Bin),var_From):-trusted_bin(var_From),evi(bin_full(var_Bin)).

send_message(bin_full(var_Bin,var_Token),var_From):-shared_token(var_Token),trusted_bin(var_From),evi(bin_full(var_Bin)).

send_message(agree(pickup(var_Bin),var_T),var_From):-trusted_truck(var_From),evi(job_accept(var_T,var_Bin,0)).

send_message(job_accept(var_T,var_Bin),var_From):-trusted_truck(var_From),evi(job_accept(var_T,var_Bin,0)).

send_message(job_accept(var_T,var_Bin,var_ReqId,var_Token),var_From):-shared_token(var_Token),trusted_truck(var_From),evi(job_accept(var_T,var_Bin,var_ReqId)).

send_message(refuse(pickup(var_Bin),var_T),var_From):-trusted_truck(var_From),evi(job_refuse(var_T,var_Bin,0)).

send_message(job_refuse(var_T,var_Bin),var_From):-trusted_truck(var_From),evi(job_refuse(var_T,var_Bin,0)).

send_message(job_refuse(var_T,var_Bin,var_ReqId,var_Token),var_From):-shared_token(var_Token),trusted_truck(var_From),evi(job_refuse(var_T,var_Bin,var_ReqId)).

send_message(assignment_ack(var_T,var_Bin,var_ReqId,var_Token),var_From):-shared_token(var_Token),trusted_truck(var_From),evi(assignment_ack(var_T,var_Bin,var_ReqId)).

send_message(inform(collection_complete(var_Bin),var__),var_From):-trusted_truck(var_From),evi(collection_complete(var_Bin,0)).

send_message(collection_complete(var_Bin),var_From):-trusted_truck(var_From),evi(collection_complete(var_Bin,0)).

send_message(collection_complete(var_Bin,var_ReqId,var_Token),var_From):-shared_token(var_Token),trusted_truck(var_From),evi(collection_complete(var_Bin,var_ReqId)).

send_message(inform(collection_failed(var_T,var_Bin),var__),var_From):-trusted_truck(var_From),evi(collection_failed(var_T,var_Bin,0)).

send_message(collection_failed(var_T,var_Bin),var_From):-trusted_truck(var_From),evi(collection_failed(var_T,var_Bin,0)).

send_message(collection_failed(var_T,var_Bin,var_ReqId,var_Token),var_From):-shared_token(var_Token),trusted_truck(var_From),evi(collection_failed(var_T,var_Bin,var_ReqId)).

send_message(reset_ack(var_Bin,var_ReqId,var_Token),var_From):-shared_token(var_Token),trusted_bin(var_From),evi(reset_ack(var_Bin,var_ReqId)).

evi(select_truck(var_ReqId,var_Bin)):-findall(var_T,(truck(var_T),\+tried(var_Bin,var_T)),var_Candidates),write('[CC] candidates for '),write(var_Bin),write(': '),write(var_Candidates),nl,evi(dispatch(var_ReqId,var_Bin,var_Candidates)).

evi(dispatch(var_ReqId,var_Bin,[])):-shared_token(var_Token),a(message(var_Bin,send_message(retry_collection(var_Bin,var_ReqId,var_Token),control_center),control_center)),a(message(logger,send_message(log(warn,no_truck_available,var_Bin),control_center),control_center)),a(persist_dead_letter(var_ReqId,var_Bin,no_truck_available)),retractall(request(var_ReqId,var_Bin,var__)),retractall(inflight(var_ReqId,var_Bin,var__,var__,var__,var__)).

evi(dispatch(var_ReqId,var_Bin,[var_T|var__])):-assert(request(var_ReqId,var_Bin,var_T)),reply_ttl(var_Ttl),retractall(inflight(var_ReqId,var_Bin,var_T,var__,var__,var__)),assert(inflight(var_ReqId,var_Bin,var_T,awaiting_reply,var_Ttl,0)),write('[CC] dispatch '),write(req(var_ReqId)-var_Bin),write(' -> '),write(var_T),nl,shared_token(var_Token),a(message(var_T,send_message(pickup_request(var_Bin,var_ReqId,var_Token),control_center),control_center)),a(message(var_T,send_message(pickup_request(var_Bin),control_center),control_center)),a(telemetry(info,pickup_request_sent,var_ReqId,var_Bin,var_T,awaiting_reply)).

eve(job_accept(var_T,var_Bin,var_ReqId)):-request(var_ReqId,var_Bin,var_T),\+processed_reply(var_ReqId,var_T,accept),!,assert(processed_reply(var_ReqId,var_T,accept)),assign_ack_ttl(var_AckTtl),retractall(inflight(var_ReqId,var_Bin,var_T,var__,var__,var__)),assert(inflight(var_ReqId,var_Bin,var_T,awaiting_assign_ack,var_AckTtl,0)),shared_token(var_Token),a(message(var_T,send_message(assignment(var_Bin,var_ReqId,var_Token),control_center),control_center)),a(message(var_T,send_message(assignment(var_Bin),control_center),control_center)),a(telemetry(info,assignment_sent,var_ReqId,var_Bin,var_T,awaiting_assign_ack)).

eve(job_refuse(var_T,var_Bin,var_ReqId)):-request(var_ReqId,var_Bin,var_T),\+processed_reply(var_ReqId,var_T,refuse),!,assert(processed_reply(var_ReqId,var_T,refuse)),retract(request(var_ReqId,var_Bin,var_T)),retractall(inflight(var_ReqId,var_Bin,var_T,var__,var__,var__)),assert(tried(var_Bin,var_T)),a(telemetry(warn,truck_refused,var_ReqId,var_Bin,var_T,retry_select)),evi(select_truck(var_ReqId,var_Bin)).

eve(assignment_ack(var_T,var_Bin,var_ReqId)):-request(var_ReqId,var_Bin,var_T),inflight(var_ReqId,var_Bin,var_T,awaiting_assign_ack,var__,var_R),!,completion_ttl(var_Ttl),retract(inflight(var_ReqId,var_Bin,var_T,awaiting_assign_ack,var__,var_R)),assert(inflight(var_ReqId,var_Bin,var_T,awaiting_completion,var_Ttl,0)),a(telemetry(info,assignment_acked,var_ReqId,var_Bin,var_T,awaiting_completion)).

eve(collection_complete(var_Bin,var_ReqId)):-request(var_ReqId,var_Bin,var_T),\+completed_req(var_ReqId),!,assert(completed_req(var_ReqId)),retract(request(var_ReqId,var_Bin,var_T)),reset_ack_ttl(var_Ttl),retractall(inflight(var_ReqId,var_Bin,var_T,var__,var__,var__)),assert(inflight(var_ReqId,var_Bin,var_T,awaiting_reset_ack,var_Ttl,0)),shared_token(var_Token),a(message(var_Bin,send_message(reset_bin(var_Bin,var_ReqId,var_Token),control_center),control_center)),a(message(var_Bin,send_message(reset_bin,control_center),control_center)),a(message(logger,send_message(log(info,collection_complete,var_Bin),control_center),control_center)),a(telemetry(info,reset_sent,var_ReqId,var_Bin,var_T,awaiting_reset_ack)).

eve(collection_failed(var_T,var_Bin,var_ReqId)):-request(var_ReqId,var_Bin,var_T),!,retract(request(var_ReqId,var_Bin,var_T)),retractall(inflight(var_ReqId,var_Bin,var_T,var__,var__,var__)),assert(tried(var_Bin,var_T)),a(telemetry(warn,collection_failed,var_ReqId,var_Bin,var_T,retry_select)),evi(select_truck(var_ReqId,var_Bin)).

eve(reset_ack(var_Bin,var_ReqId)):-inflight(var_ReqId,var_Bin,var_T,awaiting_reset_ack,var__,var__),!,retractall(inflight(var_ReqId,var_Bin,var_T,awaiting_reset_ack,var__,var__)),a(clear_tried_list(var_Bin)),a(telemetry(info,request_closed,var_ReqId,var_Bin,var_T,reset_acked)).

a(process_timeouts):-findall(inflight(var_ReqId,var_Bin,var_T,var_Stage,var_Ttl,var_R),inflight(var_ReqId,var_Bin,var_T,var_Stage,var_Ttl,var_R),var_L),forall(member(inflight(var_ReqId,var_Bin,var_T,var_Stage,var_Ttl,var_R),var_L),a(timeout_step(var_ReqId,var_Bin,var_T,var_Stage,var_Ttl,var_R))).

a(timeout_step(var_ReqId,var_Bin,var_T,var_Stage,var_Ttl,var_R)):-var_Ttl>1,var_Ttl1 is var_Ttl-1,retract(inflight(var_ReqId,var_Bin,var_T,var_Stage,var_Ttl,var_R)),assert(inflight(var_ReqId,var_Bin,var_T,var_Stage,var_Ttl1,var_R)).

a(timeout_step(var_ReqId,var_Bin,var_T,awaiting_reply,1,var__)):-retractall(inflight(var_ReqId,var_Bin,var_T,awaiting_reply,1,var__)),retractall(request(var_ReqId,var_Bin,var_T)),assert(tried(var_Bin,var_T)),a(telemetry(warn,reply_timeout,var_ReqId,var_Bin,var_T,retry_select)),evi(select_truck(var_ReqId,var_Bin)).

a(timeout_step(var_ReqId,var_Bin,var_T,awaiting_assign_ack,1,var_R)):-var_R<1,retractall(inflight(var_ReqId,var_Bin,var_T,awaiting_assign_ack,1,var_R)),assign_ack_ttl(var_Ttl),var_R1 is var_R+1,assert(inflight(var_ReqId,var_Bin,var_T,awaiting_assign_ack,var_Ttl,var_R1)),shared_token(var_Token),a(message(var_T,send_message(assignment(var_Bin,var_ReqId,var_Token),control_center),control_center)),a(message(var_T,send_message(assignment(var_Bin),control_center),control_center)),a(telemetry(warn,assign_ack_timeout_resend,var_ReqId,var_Bin,var_T,resend_assignment)).

a(timeout_step(var_ReqId,var_Bin,var_T,awaiting_assign_ack,1,var_R)):-var_R>=1,retractall(inflight(var_ReqId,var_Bin,var_T,awaiting_assign_ack,1,var_R)),retractall(request(var_ReqId,var_Bin,var_T)),assert(tried(var_Bin,var_T)),a(telemetry(error,assign_ack_timeout_drop,var_ReqId,var_Bin,var_T,retry_select)),evi(select_truck(var_ReqId,var_Bin)).

a(timeout_step(var_ReqId,var_Bin,var_T,awaiting_completion,1,var__)):-retractall(inflight(var_ReqId,var_Bin,var_T,awaiting_completion,1,var__)),retractall(request(var_ReqId,var_Bin,var_T)),assert(tried(var_Bin,var_T)),a(telemetry(error,completion_timeout,var_ReqId,var_Bin,var_T,retry_select)),evi(select_truck(var_ReqId,var_Bin)).

a(timeout_step(var_ReqId,var_Bin,var_T,awaiting_reset_ack,1,var__)):-retractall(inflight(var_ReqId,var_Bin,var_T,awaiting_reset_ack,1,var__)),a(clear_tried_list(var_Bin)),a(telemetry(warn,reset_ack_timeout,var_ReqId,var_Bin,var_T,closed_without_ack)).

a(clear_tried_list(var_Bin)):-retractall(tried(var_Bin,var__)).

evi(monitor(dummy)):- \+started,evi(start).

evi(monitor(dummy)):-started,cycle_counter(var_C),var_C>1,var_C1 is var_C-1,retract(cycle_counter(var_C)),assert(cycle_counter(var_C1)).

evi(monitor(dummy)):-started,cycle_counter(1),tesg(delta(var_D)),retract(cycle_counter(1)),assert(cycle_counter(var_D)),evi(cycle).

:-dynamic receive/1.

:-dynamic send/2.

:-dynamic isa/3.

comm_trace(on).

log_comm(var_Tag,var_X,var_Ag):-comm_trace(on),!,write(comm_trace),write(var_Tag),write(var_X),write(var_Ag),nl.

log_comm(_343121,_343123,_343125).

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

call_send_message(var_X,var_Ag):-nonvar(var_X)->log_comm(dispatch,var_X,var_Ag),(nonvar(var_Ag),var_Ag\=self->send_message(var_X,var_Ag);send_message(var_X,_341525));true.

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

trigger_inform_handlers(var_X,var_M,var_Ag):-catch(call(eve(inform_E(var_X,var_Ag))),_340289,true),catch(call(eve(inform_E(var_X,var_M,var_Ag))),_340317,true),catch(call(eve(inform_E(var_X))),_340347,true),catch(call(eve(inform_(var_X,var_Ag))),_340373,true),catch(call(eve(inform_(var_X,var_M,var_Ag))),_340401,true),catch(call(eve(inform_(var_X))),_340431,true),catch(call(eve(eve(inform_(var_X,var_Ag)))),_340457,true),catch(call(eve(eve(inform_(var_X,var_M,var_Ag)))),_340489,true),catch(call(eve(eve(inform_(var_X)))),_340517,true).

call_refuse(var_X,var_Ag,var_T):-clause(agent(var_A),var__),asse_cosa(past_event(var_X,var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(var_X,var__,var_Ag)),assert(past(var_X,var_Tp,var_Ag)),a(message(var_Ag,reply(received(var_X),var_A))).

call_cfp(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_340053,var_Ontology,_340057),_340047),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_cfp(var_A,var_C,var_Ag,_340091)),a(message(var_Ag,propose(var_A,[_340091],var_AgI))),retractall(ext_agent(var_Ag,_340129,var_Ontology,_340133)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_339927,var_Ontology,_339931),_339921),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,accept_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_339997,var_Ontology,_340001)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_339815,var_Ontology,_339819),_339809),not(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,reject_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_339871,var_Ontology,_339875)).

call_accept_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(accepted_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(accepted_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(accepted_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_reject_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(rejected_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(rejected_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(rejected_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_failure(var_A,var_M,var_Ag,var_T):-asse_cosa(past_event(failed_action(var_A,var_M,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(failed_action(var_A,var_M,var_Ag),var__,var_Ag)),assert(past(failed_action(var_A,var_M,var_Ag),var_Tp,var_Ag)).

call_cancel(var_A,var_Ag):-if(clause(high_action(var_A,var_Te,var_Ag),_339379),retractall(high_action(var_A,var_Te,var_Ag)),true),if(clause(normal_action(var_A,var_Te,var_Ag),_339413),retractall(normal_action(var_A,var_Te,var_Ag)),true).

external_refused_action_propose(var_A,var_Ag):-clause(not_executable_action_propose(var_A,var_Ag),var__).

evi(external_refused_action_propose(var_A,var_Ag)):-clause(agent(var_Ai),var__),a(message(var_Ag,failure(var_A,motivation(false_conditions),var_Ai))),retractall(not_executable_action_propose(var_A,var_Ag)).

refused_message(var_AgM,var_Con):-clause(eliminated_message(var_AgM,var__,var__,var_Con,var__),var__).

refused_message(var_To,var_M):-clause(eliminated_message(var_M,var_To,motivation(conditions_not_verified)),_339195).

evi(refused_message(var_AgM,var_Con)):-clause(agent(var_Ai),var__),a(message(var_AgM,inform(var_Con,motivation(refused_message),var_Ai))),retractall(eliminated_message(var_AgM,var__,var__,var_Con,var__)),retractall(eliminated_message(var_Con,var_AgM,motivation(conditions_not_verified))).

send_jasper_return_message(var_X,var_S,var_T,var_S0):-clause(agent(var_Ag),_339043),a(message(var_S,send_message(sent_rmi(var_X,var_T,var_S0),var_Ag))).

gest_learn(var_H):-clause(past(learn(var_H),var_T,var_U),_338991),learn_if(var_H,var_T,var_U).

evi(gest_learn(var_H)):-retractall(past(learn(var_H),_338867,_338869)),clause(agente(_338889,_338891,_338893,var_S),_338885),name(var_S,var_N),append(var_L,[46,112,108],var_N),name(var_F,var_L),manage_lg(var_H,var_F),a(learned(var_H)).

cllearn:-clause(agente(_338661,_338663,_338665,var_S),_338657),name(var_S,var_N),append(var_L,[46,112,108],var_N),append(var_L,[46,116,120,116],var_To),name(var_FI,var_To),open(var_FI,read,_338761,[]),repeat,read(_338761,var_T),arg(1,var_T,var_H),write(var_H),nl,var_T==end_of_file,!,close(_338761).

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
