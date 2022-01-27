ruleset wovyn_base {
  meta {
    shares process_heartbeat
  }

  rule process_heartbeat {
    select when wovyn heartbeat
  }
}
