ruleset manage_sensors {
  meta {
    use module io.picolabs.wrangler alias wrangler
    shares threshold, sensors, contact_number, temperatures
    configure using
      accountSid = ctx:rid_config{"account_sid"}
      authToken = ctx:rid_config{"auth_token"}
  }
  global {
    sensors = function() {
      ent:sensors.defaultsTo({});
    }
    threshold = function() {
      ent:threshold.defaultsTo(74);
    }
    contact_number = function() {
      ent:contact_number.defaultsTo("+14806690991");
    }

    temperatures = function() {
      ent:sensors.defaultsTo({}).map(function(v, k) {wrangler:picoQuery(v,"temperature_store","temperatures",{})}) || {};
    }

    required_rulesets = [

      {
        "domain": "wrangler",
        "type": "install_ruleset_request",
        "attrs": {
          "absoluteURL": "file:///Users/braydonhunt/School/CS462/pico/Lab1/Lab1/twilio.krl",
          "rid": "org.twilio.sdk",
          "config": {},
        }
      },
    ];
  }

  rule sensor_manager_set_threshold {
    select when sensor_manager set_threshold
    pre {
      thresh = (event:attrs{"threshold"} || ent:threshold || 74).klog("Recording New Threshold For All Sensors: ");
    }
    noop();
    fired {
      ent:threshold := thresh;
    }
  }

  rule sensor_manager_set_contact {
    select when sensor_manager set_contact
    pre {
      contact_number = (event:attrs{"contact_number"} || ent:contact_number || "+14806690991").klog("Recording New contact_number: ");
    }
    noop();
    fired {
      ent:contact_number := contact_number;
    }
  }

  rule sensor_complete {
    select when sensor install_complete
    pre {
      eci = (event:attrs{"eci"} || "not found").klog("Adding sensor with eci: ");
      name = (event:attrs{"name"} || "not found").klog("Adding sensor with name: ");
    }
    event:send(
      { "eci": eci,
        "domain": "sensor", "type": "profile_updated",
        "attrs": {
          "threshold": ent:threshold.defaultsTo(74),
          "contact_number": ent:contact_number.defaultsTo("+14806690991"),
          "current_name": name,
        }
      }
    );
    fired {
      ent:sensors := ent:sensors.put(name, eci);
    }
  }

  rule sensor_created {
    select when wrangler new_child_created 
    foreach required_rulesets setting (i)
    pre {
      eci = (event:attrs{"eci"} || "not found").klog("Creating sensor with eci: ");
      name = (event:attrs{"name"} || "not found").klog("Creating sensor with name: ");
      res = (i).klog("Here is my iteration: ");
      attrs = i{"attrs"}.put(["config"], {"account_sid": accountSid, "auth_token": authToken});
    }
    event:send(
      { "eci": eci,
        "domain": i{"domain"}, "type": i{"type"},
        "attrs": i{"attrs"}
      }
    );
    fired {
      raise sensor event "install_complete" attributes {"eci": eci, "name": name} on final;
    }

  }

  rule unneeded_sensor {
    select when sensor unneeded_sensor
    pre {
      sensor_name = event:attrs{"sensor_name"};
      exists = ent:sensors && ent:sensors >< sensor_name;
      eci = ent:sensors.get([sensor_name]);
    }
    if not exists then
      send_directive("sensor_not_exists", {"sensor_name": sensor_name})
    notfired {
      ent:sensors := ent:sensors.defaultsTo({}).delete(sensor_name)
      raise wrangler event "child_deletion_request" attributes {
        "eci": eci
      }
    }
  }

  rule new_sensor {
    select when sensor new_sensor
    pre {
      sensor_name = event:attrs{"sensor_name"}
      exists = ent:sensors && ent:sensors >< sensor_name
    }
    if exists then
      send_directive("sensor_exists", {"sensor_name":sensor_name})
    notfired {
      ent:sensors := ent:sensors.defaultsTo({}).put(sensor_name, 0)
      raise wrangler event "new_child_request"
        attributes { "name": sensor_name, "backgroundColor": "#ff69b4" }
    }
  }
}
