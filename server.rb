require 'socket'

server = TCPServer.new("127.0.0.1", 2000)
loop do
  client = server.accept
  input = client.gets.chomp
  case input
  when "GET /welcome HTTP/1.1"
  client.puts <<-WELCOME
HTTP/1.1 200 OK
Server: Apache/1.3.3.7 (Unix) (Red-Hat/Linux)
Content-Type: text/html
Content-Length: 198
Connection: close

<html>
<head>
  <title>Welcome</title>
</head>
<body>
  <h1>Hello World</h1>
  <p>Welcome to the world's simplest web server.</p>
  <p><img src='http://i.imgur.com/A3crbYQ.gif'></p>
</body>
</html>
WELCOME
  when "GET /profile HTTP/1.1"
    client.puts <<-PROFILE
HTTP/1.1 200 OK
Server: Apache/1.3.3.7 (Unix) (Red-Hat/Linux)
Content-Type: text/html
Content-Length: 112
Connection: close

<html>
<head>
  <title>My Profile Page</title>
</head>
<body>
  <p>This is my profile page.</p>
</body>
</html>
PROFILE
  else
    client.puts <<-404
HTTP/1.1 404 REQUEST NOT FOUND
404
  end
client.close
end
