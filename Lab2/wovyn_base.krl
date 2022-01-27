ruleset wovyn_base {
  meta {
    
  }

  global {
    temperature_threshold = 74;
  }

  rule threshold_notification {
    select when woyvn threshold_violation where event:attrs{"temperature"} > temperature_threshold
    pre {
      message = (event:attrs{"temperature"}).klog("Violation: ")
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
        "temperature" : event:attrs{["genericThing", "data", "temperature"]}[0],
        "timestamp" : event:attrs{"timestamp"}
      }
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
