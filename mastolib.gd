#https://www.reddit.com/r/godot/comments/4f5fkv/returning_json_files_using_httpclient/
extends Node
var HEADERS
var http
var DEFAULT_BASE_URL = "mastodon.cloud"
var access_json = {}
var access_token
func remove_html_tags(string):
	var clean_string = ""
	var possible_tag = ""
	var tag_found = -1
	var bin = []
	for i in range(0, string.length()):
		
		if string[i] == "<":
			for j in range(i, string.length()):
				possible_tag += string[j]
				
				if string[j] == ">" and (j - i) <= 5:
					bin.push_back(possible_tag)
					possible_tag = ""
					tag_found = j
					clean_string += " "
					print(tag_found)
					break

		if i > tag_found:
			clean_string += string[i]
		
	return clean_string

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

func server_get(url, headers):
	var err = http.request(HTTPClient.METHOD_GET, url, headers)

	assert( err == OK ) # Make sure all is OK

	while (http.get_status() == HTTPClient.STATUS_REQUESTING):
    # Keep polling until the request is going on
		http.poll()
		print("Requesting..")
		OS.delay_msec(500)


	assert( http.get_status() == HTTPClient.STATUS_BODY or http.get_status() == HTTPClient.STATUS_CONNECTED ) # Make sure request finished well.

	print("response? ",http.has_response()) # Site might not have a response.

	if (http.has_response()):

		var rb = RawArray() # Array that will hold the data

		while(http.get_status()==HTTPClient.STATUS_BODY):
        # While there is body left to be read
			http.poll()
			var chunk = http.read_response_body_chunk() # Get a chunk
			if (chunk.size()==0):
            # Got nothing, wait for buffers to fill a bit
				OS.delay_usec(1000)
			else:
				rb = rb + chunk # Append to read buffer
		return rb.get_string_from_ascii()
		



func server_post(url, data):
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
	
	connectToServer()
	
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
	var response = server_post("/api/v1/apps", request_data)
	
	var file = File.new()
	if to_file == null:
		file.open("oauth_app_creds.txt", file.WRITE)
	else:
		file.open(to_file, file.WRITE)
	file.store_var(response)

func get_oauth_json():
	var file = File.new()
	file.open("oauth_app_creds.txt", file.READ)
	var oauth_creds = file.get_var()
	var oauth_json = {}
	oauth_json.parse_json(oauth_creds)
	return oauth_json

func get_access_token():
	var file = File.new()
	file.open("user_access_token", file.READ)
	access_token = file.get_var()

func authorize():
	
	connectToServer()
	
	var oauth_json = get_oauth_json()
	print(oauth_json)
	var scope = "read write follow"
	OS.shell_open("https://mastodon.cloud/oauth/authorize?scope=%s&response_type=code&client_id=%s&redirect_uri=%s" 
					% [scope, oauth_json['client_id'], oauth_json['redirect_uri']])
	var button = get_node("Control/Button")
	yield(button, "button_down")
	var code = get_node("Control/Button/LineEdit").get_text()

	var data = {
	"grant_type" : "authorization_code",
	"code" : code,
	"client_id" : oauth_json['client_id'],
	"client_secret": oauth_json['client_secret'],
	"redirect_uri": oauth_json['redirect_uri']}
	
	var authorization = server_post("/oauth/token", data)
	access_json.parse_json(authorization)
	
	access_token = access_json['access_token']
	var file = File.new()
	file.open("user_access_token", file.WRITE)
	file.store_var(access_token)



func fetch_user_data(url):
	
	connectToServer()
	
	var auth = "Authorization: Bearer %s" % access_token
	var agent = "User-Agent: Pirulo/1.0 (Godot)"
	var accept = "Accept: */*"
	var headers = [agent, accept, auth]
	
	var resp = server_get(url, headers)
	return resp

func get_timeline(index):
	var resp = fetch_user_data("/api/v1/timelines/home")
	var json = str('{"array":',  resp, '}')
	var dict = {}
	dict.parse_json(json)
	return dict['array'][index]
func _ready():

	# Should only be necessary once: 
	#create_app("mastodot")
	#authorize()
	get_access_token()
	print(remove_html_tags(get_timeline(5)['content']))


	
	
