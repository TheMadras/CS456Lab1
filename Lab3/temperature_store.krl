ruleset wovyn_base {
  meta {
    use module org.twilio.sdk alias sdk
      with
        accountSid = ctx:rid_config{"account_sid"}
        authToken = ctx:rid_config{"auth_token"}
  }

  global {
    temperatures = [];
    violating_temperatures = [];
  }

  rule clear_temperatures {
    select when sensor reading_reset
    noop();
    fired {
      ent:violating_temperatures := [];
      ent:temperatures := [];
    }
  }

  rule collect_threshold_violations {
    select when wovyn threshold_violation
    pre {
      temp = (event:attrs{["temperature", "temperatureF"]}).klog("Recording Violating Temperature: ")
    }
    noop();
    fired {
      ent:violating_temperatures := ent:violating_temperatures.append({"temperature": temp, "timestamp": event:attrs{"timestamp"}});
    }
  }

  rule collect_temperatures {
    select when wovyn new_temperature_reading
    pre {
      temp = (event:attrs{["temperature", "temperatureF"]}).klog("Recording Temperature: ")
    }
    noop();
    fired {
      ent:temperatures := ent:temperatures.append({"temperature": temp, "timestamp": event:attrs{"timestamp"}});
    }
  }
}
