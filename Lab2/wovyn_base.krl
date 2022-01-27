ruleset wovyn_base {
  meta {
    
  }

  global {
    temperature_threshold = 71;
  }

  rule threshold_notification {
    select when woyvn threshold_violation
    pre {
      message = (event:attrs{"temperature"}).klog("Violation: ")
    }

    send_directive("threshold_notification", {"body": message})
  }

  rule find_high_temps {
    select when wovyn new_temperature_reading
    pre {
      message = (event:attrs{["temperature", "temperatureF"]}).klog("Sent Temperature: ")
    }
    noop();
    fired {
      raise wovyn event "threshold_violation" attributes {
        "temperature" : event:attrs{["genericThing", "data", "temperature"]}[0],
        "timestamp" : event:attrs{"timestamp"}
      } if (event:attrs{["temperature", "temperatureF"]} > temperature_threshold);
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
