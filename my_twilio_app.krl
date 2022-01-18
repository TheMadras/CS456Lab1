ruleset my_twilio_app {
  meta {
    use module org.twilio.sdk alias sdk
      with
        accountSid = ctx:rid_config{"account_sid"}
        authToken = ctx:rid_config{"auth_token"}
    shares getMessages
  }

  global {
    getMessages = function() {
      sdk:getMessages()
    }
  }

  rule sms {
    select when twilio sms
    sdk:sendMessage("hey there") setting(response)
    fired {
      ent:lastResponse := response
      ent:lastTimestamp := time:now()
      raise movie event "rated" attributes event:attrs
    }
  } 
}