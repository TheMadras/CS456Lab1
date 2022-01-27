ruleset wovyn_base {
  meta {
    use module org.twilio.sdk alias sdk
      with
        accountSid = ctx:rid_config{"account_sid"}
        authToken = ctx:rid_config{"auth_token"}
  }

  global {
    temperature_threshold = 74;
  }

  rule threshold_notification {
    select when wovyn threshold_violation
    pre {
      message = (<<Recieved high temp of #{event:attrs{"high_temp"}} at time #{event:attrs{"time_recorded"}}.>>).klog("Sent notification: ")
    }
    sdk:sendMessage(message) setting(response)
    fired {
      ent:lastResponse := response
      ent:lastTimestamp := time:now()
    }
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
