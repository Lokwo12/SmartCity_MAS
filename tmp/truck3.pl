
:-dynamic truck_state/1,current_job/2,started/0,status_counter/1,assign_wait_counter/1.

:-dynamic seen_pickup/1,seen_assignment/1,completed_local/1.

tesg(delta(4)).

move_time(3).

collect_time(3).

assign_wait_limit(3).

shared_token(city_token_2026).

evi(start):-retractall(started),assert(started),retractall(current_job(var__,var__)),retractall(truck_state(var__)),retractall(assign_wait_counter(var__)),retractall(seen_pickup(var__)),retractall(seen_assignment(var__)),retractall(completed_local(var__)),assert(truck_state(idle)),tesg(delta(var_D)),retractall(status_counter(var__)),assert(status_counter(var_D)).

evi(status_check):-truck_state(var_S),agent(var_T),write('[TRUCK '),write(var_T),write('] state: '),write(var_S),nl.

send_message(request(pickup(var_Bin),var__),var__From):-evi(pickup_request(var_Bin,0)).

send_message(pickup_request(var_Bin),var__From):-evi(pickup_request(var_Bin,0)).

send_message(pickup_request(var_Bin,var_ReqId,var_Token),control_center):-shared_token(var_Token),evi(pickup_request(var_Bin,var_ReqId)).

send_message(confirm(assignment(var_Bin),var__),var__From):-evi(assignment(var_Bin,0)).

send_message(assignment(var_Bin),var__From):-evi(assignment(var_Bin,0)).

send_message(assignment(var_Bin,var_ReqId,var_Token),control_center):-shared_token(var_Token),evi(assignment(var_Bin,var_ReqId)).

eve(pickup_request(var_Bin,var_ReqId)):-seen_pickup(var_ReqId),current_job(var_Bin,var_ReqId),truck_state(waiting_assignment),var_ReqId>0,!,agent(var_T),shared_token(var_Token),a(message(control_center,send_message(job_accept(var_T,var_Bin,var_ReqId,var_Token),var_T),var_T)).

eve(pickup_request(var_Bin,var_ReqId)):-(truck_state(busy);truck_state(waiting_assignment)),!,agent(var_T),write('[TRUCK '),write(var_T),write('] pickup request while busy for '),write(var_Bin),nl,a(send_refuse(var_T,var_Bin,var_ReqId)).

eve(pickup_request(var_Bin,var_ReqId)):-truck_state(idle),agent(var_T),write('[TRUCK '),write(var_T),write('] pickup request accepted for '),write(var_Bin),nl,retract(truck_state(idle)),assert(truck_state(waiting_assignment)),retractall(current_job(var__,var__)),assign_wait_limit(var_W),retractall(assign_wait_counter(var__)),assert(assign_wait_counter(var_W)),assert(current_job(var_Bin,var_ReqId)),a(mark_seen_pickup(var_ReqId)),a(send_accept(var_T,var_Bin,var_ReqId)).

eve(assignment(var_Bin,var_ReqId)):-var_ReqId>0,seen_assignment(var_ReqId),current_job(var_Bin,var_ReqId),!,agent(var_T),shared_token(var_Token),a(message(control_center,send_message(assignment_ack(var_T,var_Bin,var_ReqId,var_Token),var_T),var_T)).

eve(assignment(var_Bin,var_ReqId)):-current_job(var_Bin,var_ReqId),!,agent(var_T),retractall(assign_wait_counter(var__)),retractall(truck_state(var__)),assert(truck_state(busy)),a(mark_assignment_ack(var_T,var_Bin,var_ReqId)),a(schedule_move(var_Bin,var_ReqId)).

eve(assignment(var__,var__)):-true.

a(schedule_move(var_Bin,var_ReqId)):-move_time(var__),evi(move_done(var_Bin,var_ReqId)).

evi(move_done(var_Bin,var_ReqId)):-agent(var_T),write('[TRUCK '),write(var_T),write('] move done for '),write(var_Bin),nl,a(schedule_collect(var_Bin,var_ReqId)).

a(schedule_collect(var_Bin,var_ReqId)):-collect_time(var__),evi(collect_done(var_Bin,var_ReqId)).

evi(collect_done(var_Bin,var_ReqId)):-agent(var_T),write('[TRUCK '),write(var_T),write('] collect done for '),write(var_Bin),nl,evi(decide_outcome(var_Bin,var_ReqId)).

evi(decide_outcome(var_Bin,var_ReqId)):-random(0,100,var_R),a(decide_with_roll(var_R,var_Bin,var_ReqId)).

a(decide_with_roll(var_R,var_Bin,var_ReqId)):-var_R<80,a(success(var_Bin,var_ReqId)).

a(decide_with_roll(var_R,var_Bin,var_ReqId)):-var_R>=80,a(failure(var_Bin,var_ReqId)).

a(success(var_Bin,var_ReqId)):-agent(var_T),a(send_complete(var_T,var_Bin,var_ReqId)),a(mark_completed(var_ReqId)),a(cleanup).

a(failure(var_Bin,var_ReqId)):-agent(var_T),a(send_failed(var_T,var_Bin,var_ReqId)),a(cleanup).

a(cleanup):-retractall(current_job(var__,var__)),retractall(assign_wait_counter(var__)),retractall(truck_state(var__)),assert(truck_state(idle)).

evi(assignment_timeout):-truck_state(waiting_assignment),current_job(var_Bin,var_ReqId),agent(var_T),write('[TRUCK '),write(var_T),write('] assignment timeout for '),write(var_Bin),nl,a(send_refuse(var_T,var_Bin,var_ReqId)),a(cleanup).

a(mark_seen_pickup(var_ReqId)):-var_ReqId>0,assert(seen_pickup(var_ReqId)).

a(mark_seen_pickup(var_ReqId)):-var_ReqId=<0.

a(mark_assignment_ack(var_T,var_Bin,var_ReqId)):-var_ReqId>0,assert(seen_assignment(var_ReqId)),shared_token(var_Token),a(message(control_center,send_message(assignment_ack(var_T,var_Bin,var_ReqId,var_Token),var_T),var_T)).

a(mark_assignment_ack(var__T,var__Bin,var_ReqId)):-var_ReqId=<0.

a(mark_completed(var_ReqId)):-var_ReqId>0,assert(completed_local(var_ReqId)).

a(mark_completed(var_ReqId)):-var_ReqId=<0.

a(send_refuse(var_T,var_Bin,var_ReqId)):-var_ReqId>0,shared_token(var_Token),a(message(control_center,send_message(job_refuse(var_T,var_Bin,var_ReqId,var_Token),var_T),var_T)),a(message(control_center,send_message(job_refuse(var_T,var_Bin),var_T),var_T)).

a(send_refuse(var_T,var_Bin,var_ReqId)):-var_ReqId=<0,a(message(control_center,send_message(job_refuse(var_T,var_Bin),var_T),var_T)).

a(send_accept(var_T,var_Bin,var_ReqId)):-var_ReqId>0,shared_token(var_Token),a(message(control_center,send_message(job_accept(var_T,var_Bin,var_ReqId,var_Token),var_T),var_T)),a(message(control_center,send_message(job_accept(var_T,var_Bin),var_T),var_T)).

a(send_accept(var_T,var_Bin,var_ReqId)):-var_ReqId=<0,a(message(control_center,send_message(job_accept(var_T,var_Bin),var_T),var_T)).

a(send_complete(var_T,var_Bin,var_ReqId)):-var_ReqId>0,shared_token(var_Token),a(message(control_center,send_message(collection_complete(var_Bin,var_ReqId,var_Token),var_T),var_T)),a(message(control_center,send_message(collection_complete(var_Bin),var_T),var_T)).

a(send_complete(var_T,var_Bin,var_ReqId)):-var_ReqId=<0,a(message(control_center,send_message(collection_complete(var_Bin),var_T),var_T)).

a(send_failed(var_T,var_Bin,var_ReqId)):-var_ReqId>0,shared_token(var_Token),a(message(control_center,send_message(collection_failed(var_T,var_Bin,var_ReqId,var_Token),var_T),var_T)),a(message(control_center,send_message(collection_failed(var_T,var_Bin),var_T),var_T)).

a(send_failed(var_T,var_Bin,var_ReqId)):-var_ReqId=<0,a(message(control_center,send_message(collection_failed(var_T,var_Bin),var_T),var_T)).

evi(monitor(dummy)):- \+started,evi(start).

evi(monitor(dummy)):-started,status_counter(var_C),var_C>1,var_C1 is var_C-1,retract(status_counter(var_C)),assert(status_counter(var_C1)).

evi(monitor(dummy)):-started,status_counter(1),tesg(delta(var_D)),retract(status_counter(1)),assert(status_counter(var_D)),evi(status_check).

evi(monitor(dummy)):-truck_state(waiting_assignment),assign_wait_counter(var_C),var_C>1,var_C1 is var_C-1,retract(assign_wait_counter(var_C)),assert(assign_wait_counter(var_C1)).

evi(monitor(dummy)):-truck_state(waiting_assignment),assign_wait_counter(1),retract(assign_wait_counter(1)),evi(assignment_timeout).

:-dynamic receive/1.

:-dynamic send/2.

:-dynamic isa/3.

comm_trace(on).

log_comm(var_Tag,var_X,var_Ag):-comm_trace(on),!,write(comm_trace),write(var_Tag),write(var_X),write(var_Ag),nl.

log_comm(_242799,_242801,_242803).

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

call_send_message(var_X,var_Ag):-nonvar(var_X)->log_comm(dispatch,var_X,var_Ag),(nonvar(var_Ag),var_Ag\=self->send_message(var_X,var_Ag);send_message(var_X,_241203));true.

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

trigger_inform_handlers(var_X,var_M,var_Ag):-catch(call(eve(inform_E(var_X,var_Ag))),_239967,true),catch(call(eve(inform_E(var_X,var_M,var_Ag))),_239995,true),catch(call(eve(inform_E(var_X))),_240025,true),catch(call(eve(inform_(var_X,var_Ag))),_240051,true),catch(call(eve(inform_(var_X,var_M,var_Ag))),_240079,true),catch(call(eve(inform_(var_X))),_240109,true),catch(call(eve(eve(inform_(var_X,var_Ag)))),_240135,true),catch(call(eve(eve(inform_(var_X,var_M,var_Ag)))),_240167,true),catch(call(eve(eve(inform_(var_X)))),_240195,true).

call_refuse(var_X,var_Ag,var_T):-clause(agent(var_A),var__),asse_cosa(past_event(var_X,var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(var_X,var__,var_Ag)),assert(past(var_X,var_Tp,var_Ag)),a(message(var_Ag,reply(received(var_X),var_A))).

call_cfp(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_239731,var_Ontology,_239735),_239725),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_cfp(var_A,var_C,var_Ag,_239769)),a(message(var_Ag,propose(var_A,[_239769],var_AgI))),retractall(ext_agent(var_Ag,_239807,var_Ontology,_239811)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_239605,var_Ontology,_239609),_239599),asserisci_ontologia(var_Ag,var_Ontology,var_A),once(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,accept_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_239675,var_Ontology,_239679)).

call_propose(var_A,var_C,var_Ag):-clause(agent(var_AgI),var__),clause(ext_agent(var_Ag,_239493,var_Ontology,_239497),_239487),not(call_meta_execute_propose(var_A,var_C,var_Ag)),a(message(var_Ag,reject_proposal(var_A,[],var_AgI))),retractall(ext_agent(var_Ag,_239549,var_Ontology,_239553)).

call_accept_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(accepted_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(accepted_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(accepted_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_reject_proposal(var_A,var_Mp,var_Ag,var_T):-asse_cosa(past_event(rejected_proposal(var_A,var_Mp,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(rejected_proposal(var_A,var_Mp,var_Ag),var__,var_Ag)),assert(past(rejected_proposal(var_A,var_Mp,var_Ag),var_Tp,var_Ag)).

call_failure(var_A,var_M,var_Ag,var_T):-asse_cosa(past_event(failed_action(var_A,var_M,var_Ag),var_T)),statistics(walltime,[var_Tp,var__]),retractall(past(failed_action(var_A,var_M,var_Ag),var__,var_Ag)),assert(past(failed_action(var_A,var_M,var_Ag),var_Tp,var_Ag)).

call_cancel(var_A,var_Ag):-if(clause(high_action(var_A,var_Te,var_Ag),_239057),retractall(high_action(var_A,var_Te,var_Ag)),true),if(clause(normal_action(var_A,var_Te,var_Ag),_239091),retractall(normal_action(var_A,var_Te,var_Ag)),true).

external_refused_action_propose(var_A,var_Ag):-clause(not_executable_action_propose(var_A,var_Ag),var__).

evi(external_refused_action_propose(var_A,var_Ag)):-clause(agent(var_Ai),var__),a(message(var_Ag,failure(var_A,motivation(false_conditions),var_Ai))),retractall(not_executable_action_propose(var_A,var_Ag)).

refused_message(var_AgM,var_Con):-clause(eliminated_message(var_AgM,var__,var__,var_Con,var__),var__).

refused_message(var_To,var_M):-clause(eliminated_message(var_M,var_To,motivation(conditions_not_verified)),_238873).

evi(refused_message(var_AgM,var_Con)):-clause(agent(var_Ai),var__),a(message(var_AgM,inform(var_Con,motivation(refused_message),var_Ai))),retractall(eliminated_message(var_AgM,var__,var__,var_Con,var__)),retractall(eliminated_message(var_Con,var_AgM,motivation(conditions_not_verified))).

send_jasper_return_message(var_X,var_S,var_T,var_S0):-clause(agent(var_Ag),_238721),a(message(var_S,send_message(sent_rmi(var_X,var_T,var_S0),var_Ag))).

gest_learn(var_H):-clause(past(learn(var_H),var_T,var_U),_238669),learn_if(var_H,var_T,var_U).

evi(gest_learn(var_H)):-retractall(past(learn(var_H),_238545,_238547)),clause(agente(_238567,_238569,_238571,var_S),_238563),name(var_S,var_N),append(var_L,[46,112,108],var_N),name(var_F,var_L),manage_lg(var_H,var_F),a(learned(var_H)).

cllearn:-clause(agente(_238339,_238341,_238343,var_S),_238335),name(var_S,var_N),append(var_L,[46,112,108],var_N),append(var_L,[46,116,120,116],var_To),name(var_FI,var_To),open(var_FI,read,_238439,[]),repeat,read(_238439,var_T),arg(1,var_T,var_H),write(var_H),nl,var_T==end_of_file,!,close(_238439).

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
