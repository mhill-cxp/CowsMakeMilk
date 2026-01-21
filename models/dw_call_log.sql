--
select -- cxp_five9 (Broker, Caresource, Assurance, Eternal Health)
    'cxp_five9' as src,
    cl.session_id as uuid,
    cl.call_id,
    date(convert_timezone('US/Mountain','US/Eastern',cl.timestamp::timestamp)) as date_est,
    time(convert_timezone('US/Mountain','US/Eastern',cl.timestamp::timestamp)) as time_est,
    nullif(cl.call_type,'[None]') as call_type,
    iff(cl.agent_last_name is not null or cl.agent_last_name != '[None]',1,0) as cxp_handled,
    cl.abandoned,
    iff(xfr.session_id is null,0,1) as call_xferred,
    xfr.dnis as xferred_to,
    round(((split_part(cl.handle_time,':',0)*60)*60)
        +(split_part(cl.handle_time,':',2)*60)
            +split_part(cl.handle_time,':',3),0)
      as handle_time,
    round(((split_part(cl.queue_wait_time,':',0)*60)*60)
        +(split_part(cl.queue_wait_time,':',2)*60)
            +split_part(cl.queue_wait_time,':',3),0)
      as queue_wait_time,
    round(((split_part(cl.time_to_abandon,':',0)*60)*60)
        +(split_part(cl.time_to_abandon,':',2)*60)
            +split_part(cl.time_to_abandon,':',3),0)
      as time_to_abandon,
    round(((split_part(cl.after_call_work_time,':',0)*60)*60)
        +(split_part(cl.after_call_work_time,':',2)*60)
            +split_part(cl.after_call_work_time,':',3),0)
      as after_call_time,
    round(((split_part(cl.hold_time,':',0)*60)*60)
        +(split_part(cl.hold_time,':',2)*60)
            +split_part(cl.hold_time,':',3),0)
      as hold_time,
    round(((split_part(cl.talk_time,':',0)*60)*60)
        +(split_part(cl.talk_time,':',2)*60)
            +split_part(cl.talk_time,':',3),0)
      as talk_time,
    nullif(cl.campaign,'[None]') as campaign,
    nullif(cl.skill,'[None]') as queue, 
    nullif(cl.agent_last_name,'[None]') as agent_id,
    cl.agent_id::varchar(10) as agent_system_id,
    nullif(cl.disposition,'[None]') as disposition
from
    fivetran.cxp_five9.call_log cl
        left join
    fivetran.cxp_five9.call_log xfr
        on xfr.call_id=cl.call_id
        and xfr.call_type ilike '3rd party transfer'
where
    cl.call_type ilike any('inbound','outbound','preview')
    and cl.timestamp::date = date(current_timestamp()-interval '1 day')
    
union all

select -- elv_five9 (ELV SS)
    'elv_five9' as src,
    cl.session_id as uuid,
    cl.call_id,
    date(convert_timezone('US/Mountain','US/Eastern',cl.timestamp::timestamp)) as date_est,
    time(convert_timezone('US/Mountain','US/Eastern',cl.timestamp::timestamp)) as time_est,
    nullif(cl.call_type,'[None]') as call_type,
    iff(cl.agent_last_name is not null or cl.agent_last_name != '[None]',1,0) as cxp_handled,
    cl.abandoned,
    iff(xfr.session_id is null,0,1) as call_xferred,
    xfr.dnis as xferred_to,
    round(((split_part(cl.handle_time,':',0)*60)*60)
        +(split_part(cl.handle_time,':',2)*60)
            +split_part(cl.handle_time,':',3),0)
      as handle_time,
    round(((split_part(cl.queue_wait_time,':',0)*60)*60)
        +(split_part(cl.queue_wait_time,':',2)*60)
            +split_part(cl.queue_wait_time,':',3),0)
      as queue_wait_time,
    round(((split_part(cl.time_to_abandon,':',0)*60)*60)
        +(split_part(cl.time_to_abandon,':',2)*60)
            +split_part(cl.time_to_abandon,':',3),0)
      as time_to_abandon,
    round(((split_part(cl.after_call_work_time,':',0)*60)*60)
        +(split_part(cl.after_call_work_time,':',2)*60)
            +split_part(cl.after_call_work_time,':',3),0)
      as after_call_time,
    round(((split_part(cl.hold_time,':',0)*60)*60)
        +(split_part(cl.hold_time,':',2)*60)
            +split_part(cl.hold_time,':',3),0)
      as hold_time,
    round(((split_part(cl.talk_time,':',0)*60)*60)
        +(split_part(cl.talk_time,':',2)*60)
            +split_part(cl.talk_time,':',3),0)
      as talk_time,
    nullif(cl.campaign,'[None]') as campaign,
    nullif(cl.skill,'[None]') as queue, 
    nullif(cl.agent_last_name,'[None]') as agent_id,
    cl.agent_id::varchar(10) as agent_system_id,
    nullif(cl.disposition,'[None]') as disposition
from
    fivetran.elevance_five9.call_log cl
        left join
    fivetran.elevance_five9.call_log xfr
        on xfr.call_id=cl.call_id
        and xfr.call_type ilike '3rd party transfer'
where
    cl.call_type ilike any('inbound','outbound','preview')
    and cl.timestamp::date = date(current_timestamp()-interval '1 day')

union all

select -- elv_five9 (ELV SS)
    'elv_salesforce' as src,
    cl.contact_id as uuid,
    null as call_id,
    date(to_timestamp(initiation_timestamp,'MM/DD/YYYY, HH12:MI PM')) as date_est,
    time(to_timestamp(initiation_timestamp,'MM/DD/YYYY, HH12:MI PM')) as time_est,
    cl.initiation_method as call_type,
    iff(cl.agent is not null,1,0) as cxp_handled,
    cl.abandoned,
    0 as call_xferred,
    null as xferred_to,
    handle_time,
    queue_duration,
    null as time_to_abandon,
    after_contact_work_duration as after_call_time,
    agent_customer_hold_duration as hold_time,
    agent_interaction_duration as talk_time,
    campaign_name as campaign,
    queue_name as queue, 
    agent_username as agent_id,
    agent_username::varchar(10) as agent_system_id,
    'Not Available' as disposition
from
    fivetran.elevance.call_log cl
        join
    fivetran.aurora_spotfire_db_spotfire.elevance_usd_cxpid usd
        on usd.usb = cl.agent_username
        and usd.hard_deleted is null
        and usd._fivetran_deleted=FALSE 
where
    cl.initiation_method ilike any('inbound','transfer','outbound')
    and date_est::date = date(current_timestamp()-interval '1 day')
    