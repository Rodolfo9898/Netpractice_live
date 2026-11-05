# shellcheck shell=bash
#
# server.sh - the web server of the site and the browser opened on it: what the run.sh of the intranet archive does (same port,
# same openers, same messages). Serves the folder it is started in. Sourced by run.sh (it only defines functions).
# Variable it sets:
#   SERVER_PORT   the port the server listens on

# server_port   sets SERVER_PORT: the first port from 49152 up that nothing listens on (found with ss), or 49242 when there is no ss.
server_port()
{
	local port

	SERVER_PORT=49242
	if command -v ss >/dev/null 2>&1; then
		for port in $(seq 49152 65535); do
			if ! ss -lnt | grep -q ":$port "; then
				SERVER_PORT=$port
				break
			fi
		done
	else
		echo "ss not available, using port 49242."
	fi
}

# server_browser   opens the browser on the server in two seconds, with xdg-open (Linux) or open (macOS). Without one, tells the URL.
server_browser()
{
	if command -v xdg-open >/dev/null 2>&1; then
		echo "Netpractice server is starting, web browser will open."
		( sleep 2 ; xdg-open "http://localhost:$SERVER_PORT" >/dev/null 2>&1 || true ) &
	elif command -v open >/dev/null 2>&1; then
		echo "Netpractice server is starting, web browser will open."
		( sleep 2 ; open "http://localhost:$SERVER_PORT" >/dev/null 2>&1 || true ) &
	else
		echo "Netpractice server is starting. Open your web browser with URL: http://localhost:$SERVER_PORT"
	fi
}

# server_run   the whole of it. The server runs here, in the foreground, until Ctrl-C: its exit status is this function's.
server_run()
{
	server_port
	server_browser
	echo "Type Ctrl-C to shutdown the server."
	python3 -m http.server "$SERVER_PORT"
}
