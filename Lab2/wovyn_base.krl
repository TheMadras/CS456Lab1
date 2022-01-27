ruleset wovyn_base {
  meta {
  }

  rule new_temperature_reading {
    select when wovyn new_temperature_reading
    pre {
      message = ("New Reading").klog("Sent Message: ")
    }
  
    send_directive("new_temperature_reading", {"body": message})
  }

  rule process_heartbeat {
    select when wovyn heartbeat where event:attrs >< "genericThing"
    pre {
      message = ("Hey" || "Empty Message").klog("Sent Message: ")
    }
    raise wovyn event "new_temperature_reading" attributes
      "temperature" : event:attrs{["genericThing", "data", "temperature"]},
      "timestamp" : event:time

  }
}
