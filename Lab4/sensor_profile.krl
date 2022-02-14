ruleset sensor_profile {
  meta {
    provides threshold, contact_number, current_name, location
    shares threshold, contact_number, current_name, location
  }

  global {
    threshold = function() {
      ent:threshold.defaultsTo(74);
    }

    contact_number = function() {
      ent:contact_number.defaultsTo("+14806690991");
    }

    current_name = function() {
      ent:current_name.defaultsTo("default sensor");
    }

    location = function() {
      ent:location.defaultsTo("home");
    }
  }

  rule collect_temperatures {
    select when sensor profile_updated
    pre {
      thresh = (event:attrs{"threshold"} || ent:threshold || 74).klog("Recording New Threshold: ");
      contact_number = (event:attrs{"contact_number" || ent:contact_number}).klog("Recording New contact_number: ");
      current_name = (event:attrs{"current_name" || ent:current_name}).klog("Recording New current_name: ");
      location = (event:attrs{"location"} || ent:location).klog("Recording New Location: ");
    }
    noop();
    fired {
      ent:threshold := thresh;
      ent:contact_number := contact_number;
      ent:current_name := current_name;
      ent:location := location;
    }
  }
}
