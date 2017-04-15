#https://www.reddit.com/r/godot/comments/4f5fkv/returning_json_files_using_httpclient/
extends Node
var HEADERS
var HTTP
var RESPONSE
var QUERY
var global



func talkToServer(url, mode, data):
    # Connect to host/port
	HTTP = HTTPClient.new()
	RESPONSE = HTTP.connect(url, 443, true, true)
	print("Connecting...")
	
	# Wait until resolved and connected
	while HTTP.get_status() == HTTPClient.STATUS_CONNECTING or HTTP.get_status() == HTTPClient.STATUS_RESOLVING:
		HTTP.poll()
		OS.delay_msec(300)
	# Error catch: Could not connect
	assert(HTTP.get_status() == HTTPClient.STATUS_CONNECTED)
	
	print("Connected.")
	# Check for a GET or POST command
	if data == "":
		print("It is a get.")
		HEADERS =["User-Agent: Pirulo/1.0 (Godot)", "Accept: */*"]
		RESPONSE = HTTP.request(HTTPClient.METHOD_GET, url, HEADERS)
	else:
		print("It is a post.")
		QUERY = data.to_json()
		print(QUERY)
		#Header json example: http://docs.godotengine.org/en/stable/classes/class_httpclient.html#class-httpclient-query-string-from-dict
		HEADERS = ["User-Agent: Pirulo/1.0 (Godot)", "Content-Type: application/json; charset=UTF-8", "Content-Length: " + str(QUERY.length())]
		RESPONSE = HTTP.request(HTTPClient.METHOD_POST, url, HEADERS, QUERY)
	# Make sure all is OK
	assert(RESPONSE == OK)
	print("response ok.")
	# Keep polling until the request is going on
	while (HTTP.get_status() == HTTPClient.STATUS_REQUESTING):
		HTTP.poll()
		OS.delay_msec(300)
	# Make sure request finished
	assert(HTTP.get_status() == HTTPClient.STATUS_BODY or HTTP.get_status() == HTTPClient.STATUS_CONNECTED)
	print("Request finished.")
	
func serverResponse(mode):
	print("Processing HTTP response")
	# Set up some variables
	var RB = RawArray()
	var CHUNK = 0
	var RESULT = 0
	# Was there a response?
	print("Response received?: "+str(HTTP.has_response()))
	# Raw data array
	if HTTP.has_response():
		# Get response headers
		var headers = HTTP.get_response_headers_as_dictionary()
		print("Response code: ", HTTP.get_response_code())
		while(HTTP.get_status() == HTTPClient.STATUS_BODY):
			HTTP.poll()
			CHUNK = HTTP.read_response_body_chunk()
			if(CHUNK.size() == 0):
				OS.delay_usec(100)
			else:
				RB = RB + CHUNK
			serverClose()
			RESULT = RB.get_string_from_ascii()
			print("Response was: ", RESULT)
			# Do something with the response
		
		#What to actually do with these?
		if mode == 'check':
			print(global)
		if mode == 'leaders':
			print(global)

func serverClose():
	print("Closing HTTP connection")
	HTTP.close()
	print(HTTP)
	
func _ready():
	#mastodon vars
	var api_base_url = "mastodon.cloud"
	var register_app = "/api/v1/apps"
	var client_name = "mastodot"
	var client_id
	var client_secret
	var access_token
	var redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
	var scopes = "read write follow"
	var request_data = {
	"client_name" : client_name, 
	"redirect_uris": redirect_uri, 
	"scopes" : scopes}
	talkToServer(api_base_url + register_app, "leaders", request_data)
	serverResponse("check")