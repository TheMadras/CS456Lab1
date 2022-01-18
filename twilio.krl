ruleset twilio_app {
  meta {
    use module http
      with
        accountSid = ctx:rid_config{"account_sid"}
        authToken = ctx:rid_config{"auth_token"}
    shares messages
  }
  global {
    messages = function() {
      sdk:getPopular()
    }
  }

  rule send_message {
    select when message send
  }

}