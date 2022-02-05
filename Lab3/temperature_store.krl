ruleset wovyn_base {
  meta {
    provides temperatures, threshold_violations, inrange_temperatures
  }

  global {
    temperature_record = [];
    violating_temperatures = [];

    temperatures = function() {
      ent:temperature_record;
    }

    threshold_violations = function() {
      ent:violating_temperatures;
    }

    inrange_temperatures = function() {
      ent:temperature_record.filter(function(x) {ent:violating_temperatures.none(function(y) {y == x});}); 
    }
  }

  rule clear_temperatures {
    select when sensor reading_reset
    noop();
    fired {
      ent:violating_temperatures := [];
      ent:temperature_record := [];
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
      ent:temperature_record := ent:temperature_record.append({"temperature": temp, "timestamp": event:attrs{"timestamp"}});
    }
  }
}
