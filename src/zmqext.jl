module ZMQExt

import ZeroMQ_jll
import czmq_jll
import ZMQ

function resolve(s::ZMQ.Socket)
    val = ccall((:zsock_resolve, czmq_jll.libczmq), Ptr{Cvoid}, (Ptr{Cvoid},), s)
    return val
end

struct pollitem_t
    socket::Ptr{Cvoid}
    fd::Cint
    events::Cshort
    revents::Cshort
end

function poll(sockets::Vector{ZMQ.Socket}, events::Int, timeout::Int)
    items = map((s) -> pollitem_t(resolve(s), 0, events, 0), sockets)
    val = ccall((:zmq_poll, ZeroMQ_jll.libzmq),
                Cint,
                (Ptr{pollitem_t}, Cint, Clong),
                items, length(sockets), timeout)

    if val == -1
        return Vector{Int16}[], val
    else
        return map((i) -> i.revents, items), val
    end
end

end
