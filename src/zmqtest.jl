using ZMQ

module zmqtest


# Write your package code here.

end

function ZMQ.recv(socket::ZMQ.Socket, timeout::Number)
    @info "try recv"
    t = @task (_ -> ZMQ.recv(socket))
    schedule(t)
    timedwait(_ -> istaskdone(t), timeout)
    return istaskdone(t) ? fetch(t) : nothing
end

REQUEST_TIMEOUT = 2500
