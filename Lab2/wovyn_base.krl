ruleset wovyn_base {
  meta {
    
  }

  global {
    temperature_threshold = 74;
  }

  rule threshold_notification {
    select when wovyn threshold_violation
    pre {
      message = (event:attrs{"high_temp"}).klog("Violation: ")
    }

    send_directive("threshold_notification", {"body": message})
  }

  rule find_high_temps {
    select when wovyn new_temperature_reading
    pre {
      temp = (event:attrs{["temperature", "temperatureF"]}).klog("Sent Temperature: ")
    }
    noop();
    fired {
      raise wovyn event "threshold_violation" attributes {
        "high_temp" : temp,
        "time_recorded" : event:attrs{"timestamp"}
      } if (temp > temperature_threshold);
    }
  }

  rule process_heartbeat {
    select when wovyn heartbeat where event:attrs >< "genericThing"
    pre {
      message = ("Hey" || "Empty Message").klog("Sent Message: ")
    }
    noop();
    fired {
      raise wovyn event "new_temperature_reading" attributes {
        "temperature" : event:attrs{["genericThing", "data", "temperature"]}[0],
        "timestamp" : event:time
      }
    }
  }
}
