ruleset my_twilio_app {
  meta {
    use module org.twilio.sdk alias sdk
      with
        accountSid = ctx:rid_config{"account_sid"}
        authToken = ctx:rid_config{"auth_token"}
    shares getMessages
  }

  global {
    getMessages = function(sender, receiver, page, pageToken) {
      sdk:getMessages(sender, receiver, page, pageToken)
    }
  }

  rule sms {
    select when twilio sms
    pre {
      message = (event:attrs{"message"} || "Empty Message").klog("Sent Message: ")
    }
    sdk:sendMessage(message) setting(response)
    fired {
      ent:lastResponse := response
      ent:lastTimestamp := time:now()
      raise movie event "rated" attributes event:attrs
    }
  } 
}