function fib(n, a, b)
    if n == 0 then
     coroutine.yield(a) 
    else
        return fib(n - 1, b, a + b)
    end
end

function fibonacci(n)
    return coroutine.wrap(function() return fib(n, 0, 1) end)
end

print(fibonacci(1000)())
