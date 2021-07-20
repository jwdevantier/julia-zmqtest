using ZMQ
include("zmqext.jl")

REQUEST_TIMEOUT = 2500
REQUEST_RETRIES = 3
SERVER_ENDPOINT = "tcp://127.0.0.1:5555"

context = ZMQ.Context()
client2 = ZMQ.Socket(context, REQ)

function startServer(context::ZMQ.Context)
    @info "Connecting to server..."
    client = ZMQ.Socket(context, ZMQ.REQ)
    ZMQ.connect(client, SERVER_ENDPOINT)

    counter = 1
    while true
        request = counter
        @info "Sending ($(request))"
        ZMQ.send(client, request)

        retries_left = REQUEST_RETRIES
        while true
            items, err = ZMQExt.poll([client], ZMQ.POLLIN, REQUEST_TIMEOUT)
            if err == -1
                println("interrupted, break")
                break
            end

            if items[1] & ZMQ.POLLIN != 0
                reply = ZMQ.recv(client, Int)
                @info "got reply ($(reply)) - type: $(typeof(reply))"
                @info "Server replied OK ($(reply))"
                retries_left = REQUEST_RETRIES
                break
            end

            retries_left -= 1
            @warn "No response from server"
            client.linger = 0
            ZMQ.close(client)
            if retries_left == 0
                @error "Server seems to be offline, abandoning"
                exit(1)
            end

            @info "Reconnecting to server"
            client = ZMQ.Socket(context, ZMQ.REQ)
            ZMQ.connect(client, SERVER_ENDPOINT)
            @info "Resending ($(request))"
            ZMQ.send(client, request)
        end

        counter += 1
    end
end


function test()
    println("testing..")

end


if abspath(PROGRAM_FILE) == @__FILE__
    startServer(context)
end

