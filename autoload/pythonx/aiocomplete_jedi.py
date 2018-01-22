import asyncio
import jedi
import pkgutil
try:
    import ujson as json
except ImportError:
    import json

try:
    import uvloop
    asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())
except ImportError:
    pass


def completions(src, line, col, path):
    script = jedi.Script(src, line, col, path)
    res = script.completions()

    return [{
        'name': c.name,
        'desc': '',
        'tail': c.complete,
        'kind': c.type
    } for c in res]


async def handle_echo(reader, writer):
    while not reader.at_eof():
        data = await reader.readline()
        message = data.decode()

        if not message:
            break

        request = json.loads(message)
        response = completions(**request[1])

        r = json.dumps([request[0], response])
        writer.write(r.encode())
        await writer.drain()

    print("Close the client socket")
    writer.close()


async def preload_modules():
    for (_, module, _) in pkgutil.iter_modules():
        jedi.preload_module(module)
        await asyncio.sleep(0.1)

loop = asyncio.get_event_loop()
coro = asyncio.start_server(handle_echo, '127.0.0.1', 8888, loop=loop)
server, _ = loop.run_until_complete(asyncio.gather(coro, preload_modules()))

# Serve requests until Ctrl+C is pressed
# print('Serving on {}'.format(server.sockets[0].getsockname()))
try:
    loop.run_forever()
except KeyboardInterrupt:
    pass

# Close the server
server.close()
loop.run_until_complete(server.wait_closed())
loop.close()
