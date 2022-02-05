ruleset wovyn_base {
  meta {
    use module org.twilio.sdk alias sdk
      with
        accountSid = ctx:rid_config{"account_sid"}
        authToken = ctx:rid_config{"auth_token"}
  }

  global {
    temperatures = [];

  }

  rule collect_temperatures {
    select when wovyn new_temperature_reading
    pre {
      temp = (event:attrs{["temperature", "temperatureF"]}).klog("Sent Temperature: ")
    }
    noop();
    fired {
      temperatures.append(temp);
    }
  }
}
