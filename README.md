# OVH-REST

OVH-REST is a (really) tiny, unofficial helper library OVH management [API](https://api.ovh.com/console/), wrapping the authentication parts and simplifying interaction in Ruby programs.

You need an `appKey` and an `appSecret` to use it, which can be obtained [there](https://www.ovh.com/fr/cgi-bin/api/createApplication.cgi).

## Usage

First, you need to generate a `consumerKey` which is grants access to specific methods and parts of the API.

```ruby
require 'ovh/rest'

access = {
  "accessRules" => [
    { "method" => "GET", "path" => "/sms/*" },
    { "method" => "POST", "path" => "/sms/*" },
    { "method" => "PUT", "path" => "/sms/*" },
    { "method" => "DELETE", "path" => "/sms/*" },
  ]
}

OVH::REST.generate_consumer_key("your_appKey", access)
=> {
  "validationUrl" => "https://www.ovh.com/fr/cgi-bin/api/requestCredential.cgi?credentialToken=XXXXXXXXXXXXXXXXXXXXXXX",
  "consumerKey" => "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ",
  "state" => "pendingValidation"
}

```

You now have your `consumerKey`, which needs validation before use. Validation is done by following the `validationUrl` and entering your credentials.

Then you can use API features:

```ruby
require 'ovh/rest'

ovh = OVH::REST.new(apiKey, appSecret, consumerKey)

# Get sms account status
result = ovh.get("/sms/sms-xx12345-1")

puts JSON.pretty_generate(result)
=>
{
  "status": "enable",
  "creditsLeft": 42,
  "name": "sms-xx12345-1",
  "userQuantityWithQuota": 0,
  "description": "",
[...]
}

# Send sms
result = ovh.post("/sms/sms-xx12345-1"/jobs", {
  "charset" => "UTF-8",
  "class" => "phoneDisplay",
  "coding" => "7bit",
  "priority" => "high",
  "validityPeriod" => 2880
  "message" => "Dude! Disk is CRITICAL!",
  "receivers" => ["+12345678900", "+12009876543"],
  "sender" => "+12424242424",
})

puts JSON.pretty_generate(result)
=>
{
  "totalCreditsRemoved": 2,
  "ids": [
    12345,
    12346
  ]
}
```

All methods and parameters are described on the API documentation

## Setup

Only tested with MRI >= 1.9.3

Dependencies: none

Install:
 * git clone https://github.com/Fotolia/ovh-rest
OR
 * gem install ovh-rest

## Links

Introduction, in french: http://www.ovh.com/fr/g934.premiers-pas-avec-l-api
