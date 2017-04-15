extends SceneTree


#Mastodon Specific Variables
var api_base_url = "https://mastodon.cloud/"
var client_name = "mastodot"
var client_id
var client_secret
var access_token
var redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
var scopes = "read write follow"


var err=0
var http = HTTPClient.new() # Create the Client

var err = http.connect(mastodon_url,80) # Connect to host/port
assert(err==OK) # Make sure connection was OK

RESPONSE = HTTP.connect(apise_base_url, 80)

var data = {"client_name" : client_name, "redirect_uris": redirect_uri,
		"scopes": scopes}

while HTTP.get_status() == HTTPClient.STATUS_CONNECTING 
	or HTTP.get_status() = HTTPCLIENT.STATUS_RESOLVING:
		
		HTTP.poll()
		OS.delay_msec(300)
	assert(HTTP.get_status() == HTTPClient.STATUS_CONNECTED)

	if data == "":
		HEADERS =["User-Agent: Pirulo/1.0 (Godot)", "Accept: */*"]
		RESPONSE = HTTP.request(HTTPClient.METHOD_GET, url, HEADERS)
	else:
		QUERY = HTTP.query_string_from_dict(data)
		HEADERS = ["User-Agent: Pirulo/1.0 (Godot)", "Content-Type: application/x-www-form-urlencoded", "Content-Length: " + str(QUERY.length())]
		RESPONSE = HTTP.request(HTTPClient.METHOD_POST, url, HEADERS, QUERY)
	assert(RESPONSE = OK)

	while (HTTP.get_status() == HTTPClient.STATUS_REQUESTING):
		HTTP.poll()
		OS.delay_msec(300)
	
	assert(HTTP.get_status() == HTTPClient.STATUS_BODY or 
			HTTP.get_status() == HTTPClient.STATUS_CONNECTED)


