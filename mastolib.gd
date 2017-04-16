#https://www.reddit.com/r/godot/comments/4f5fkv/returning_json_files_using_httpclient/
extends Node
var HEADERS
var http
var DEFAULT_BASE_URL = "hex.bz"
var client_name = "mastodot"
var client_id
var client_secret
var access_token
var redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
var scopes = "read write follow"



func connectToServer(url=DEFAULT_BASE_URL):
	http = HTTPClient.new()
	var resp = http.connect(url, 443, true)
	print("Connecting...")
	while http.get_status() == HTTPClient.STATUS_CONNECTING or http.get_status() == HTTPClient.STATUS_RESOLVING:
		http.poll()
		OS.delay_msec(500)
		
	# Error catch: Could not connect
	assert(http.get_status() == HTTPClient.STATUS_CONNECTED)
	
	print("Connected.")

func postServer(url, data):
	var json_bin = data.to_json().to_utf8()
	var headers = ["Content-Type: application/json; charset=UTF-8", "Content-Length: " + str(json_bin.size())]
	var response = http.request_raw(HTTPClient.METHOD_POST, url, headers, json_bin)
	# Keep polling until the request is going on
	while (http.get_status() == HTTPClient.STATUS_REQUESTING):
		http.poll()
		OS.delay_msec(300)
	# Make sure request finished
	print(http.get_status())
	assert(http.get_status() == HTTPClient.STATUS_BODY or http.get_status() == HTTPClient.STATUS_CONNECTED)
	
	print("Processing HTTP response")
	# Set up some variables
	var rb = RawArray()
	var chunk = 0
	var result = 0
	# Was there a response?
	print("Response received?: "+str(http.has_response()))
	# Raw data array
	if http.has_response():
		# Get response headers
		var headers = http.get_response_headers_as_dictionary()
		print("Response code: ", http.get_response_code())
		while(http.get_status() == HTTPClient.STATUS_BODY):
			http.poll()
			chunk = http.read_response_body_chunk()
			if(chunk.size() == 0):
				OS.delay_usec(100)
			else:
				rb = rb + chunk
			result = rb.get_string_from_ascii()
			print(result.to_ascii().get_string_from_ascii())
			return result
			
func create_app(client_name, scopes = "read write follow", 
				redirect_uris = null, website = null, to_file = null, api_base_url = DEFAULT_BASE_URL):
	
	var request_data = {
	'client_name': client_name,
	'scopes': scopes
	}
	if redirect_uris != null:
		request_data['redirect_uris'] = redirect_uris
	else:
		request_data['redirect_uris'] = "urn:ietf:wg:oauth:2.0:oob"
	if website != null:
		request_data['website'] = website
	print(request_data)
	var query = request_data.to_json().to_utf8()
	var response = postServer("/api/v1/apps", request_data)
	
	var file = File.new()
	if to_file == null:
		file.open("oauth_app_creds.txt", file.WRITE)
	else:
		file.open(to_file, file.WRITE)
	file.store_var(response)

func log_in(user, password):
	var file = File.new()
	file.open("oauth_app_creds.txt", file.READ)
	var oauth_creds = file.get_var()
	var oauth_json = {}
	oauth_json.parse_json(oauth_creds)
	var data = {
		'client_id' : oauth_json['client_id'],
		'client_secret' : oauth_json['client_secret'],
		'grant_type' : "password",
		'username' : user,
		'password' : password}
		
	var result = postServer("/oauth/token", data)
	print(result)

func fetch_user_data(url):
	pass
	
func _ready():
	connectToServer()
	var user_file = File.new()
	user_file.open("usercreds.txt", user_file.READ)
	var user_creds = {}
	user_creds.parse_json(user_file.get_as_text())

	log_in(user_creds['username'], user_creds['password'])
	
	# Should only be necessary once: 
	#create_app("mastodot")
	
	
	#curl -X POST -d "client_id=CLIENT_ID_HERE&client_secret=CLIENT_SECRET_HERE&grant_type=password&username=YOUR_EMAIL&password=YOUR_PASSWORD" -Ss https://mastodon.social/oauth/token
	