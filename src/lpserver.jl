using ZMQ

context = ZMQ.Context()
server = ZMQ.Socket(context, ZMQ.REP)
ZMQ.bind(server, "tcp://127.0.0.1:5555")

cycles = 0
while true
    global cycles

    @info "Waiting for request... (cycles: $(cycles))"
    request = ZMQ.recv(server, Int)
    if cycles > 3 && rand(0:3) == 0
        @info "Simulating a crash"
        break
    elseif cycles > 3 && rand(0:3) == 0
        @info "Simulating CPU overload"
        sleep(2)
    end

    @info "Normal request $(request)"
    sleep(1)
    ZMQ.send(server, request)

    cycles += 1
end
