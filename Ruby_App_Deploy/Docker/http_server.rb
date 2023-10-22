require 'socket'

server = TCPServer.new(80)

loop do
  client = server.accept

  begin
    request = client.readpartial(2048)
  rescue EOFError
    # Client closed the connection, so we can't read more data.
    client.close
    next
  end

  method, path, version = request.lines[0].split

  if path == "/healthcheck"
    response = "HTTP/1.1 200 OK\r\nContent-Length: 2\r\n\r\nOK"
  else
    response = "HTTP/1.1 200 OK\r\nContent-Length: 17\r\n\r\nWell, hello there!"
  end

  client.write(response)
  client.close
end
