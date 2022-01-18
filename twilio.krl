ruleset org.twilio.sdk {
  meta {
    configure using
      accountSid = ""
      authToken = ""
    provides sendMessage, getMessages
  }
  global {
    base_url = "https://api.twilio.com/2010-04-01"

    getMessages = function() {
      response = http:get("https://postman-echo.com/get")
      response{"content"}.decode()
    }
  
    sendMessage = defaction(message) {
      post_url = <<#{base_url}/Accounts/#{accountSid}/Messages.json>>.klog("Url to post to: ")
      // From and to sections are hardcoded because they are the only legitimate numbers for the Twilio account
      form = {
        "To": "+14806690991",
        "From": "+19378822560",
        "Body": message
      }
      authentication = {"username":accountSid,"password":authToken}
      http:post(post_url, auth=authentication, form=form) setting(response)
      return response.klog("Twilio Response: ")
    }
  }
}