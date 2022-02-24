ruleset temperature_store {
  meta {
    provides temperatures, threshold_violations, inrange_temperatures
    shares temperatures, threshold_violations, inrange_temperatures
  }

  global {
    temperatures = function() {
      ent:temperature_record.defaultsTo([]);
    }

    threshold_violations = function() {
      ent:violating_temperatures.defaultsTo([]);
    }

    inrange_temperatures = function() {
      ent:temperature_record.defaultsTo([]).filter(function(x) {ent:violating_temperatures.none(function(y) {y == x});}); 
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
      temp = (event:attrs{"high_temp"}).klog("Recording Violating Temperature: ")
    }
    noop();
    fired {
      ent:violating_temperatures := ent:violating_temperatures.defaultsTo([]).append({"temperature": temp, "timestamp": event:attrs{"time_recorded"}});
    }
  }

  rule collect_temperatures {
    select when wovyn new_temperature_reading
    pre {
      temp = (event:attrs{["temperature", "temperatureF"]}).klog("Recording Temperature: ")
    }
    noop();
    fired {
      ent:temperature_record := ent:temperature_record.defaultsTo([]).append({"temperature": temp, "timestamp": event:attrs{"timestamp"}});
    }
  }
}
