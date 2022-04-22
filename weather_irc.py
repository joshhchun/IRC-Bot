import asyncio
import os
import sys
import re

# Constants

HOST = 'chat.ndlug.org'
PORT = 6697
NICK = f'ircle-{os.environ["USER"]}'

# Functions

async def parse_results(command):
    # If user called the command
    args = re.match(r"^!weather (.*), (.*)$", command)
    # If user inputed the correct arguments
    if args:
        zipcode = os.popen(f'./zipcode.sh -s "{args.group(2).title()}" -c "{args.group(1).title()}" | head -n 1').read().strip()
        # If there is weather data on that city, state
        if zipcode:
            mesg = os.popen(f'./weather.sh -f {zipcode}').read().splitlines()
            forecast = re.match(r"Forecast:\s*(.*)", mesg[0]).group(1)
            temp = re.match(r"Temperature:\s*(.*)", mesg[1]).group(1)
            return f"The temperature in {args.group(1).title()}, {args.group(2).title()} is {temp} and the forecast is {forecast}"
        else:
            return "zoo wee mama, no weather info found with those inputs"
    # If user did not input correct arguments, return the usage
    else:
        return "oops usage is '!weather [city], [state]'"
        
async def ircle():
    # Connect to IRC server
    reader, writer = await asyncio.open_connection(HOST, PORT, ssl=True)

    # Identify ourselves
    writer.write(f'USER {NICK} 0 * :{NICK}\r\n'.encode())
    writer.write(f'NICK {NICK}\r\n'.encode())
    await writer.drain()

    # Join #bots channel
    writer.write(f'JOIN #bots\r\n'.encode())
    await writer.drain()

    # Write message to channel
    writer.write(f"PRIVMSG #bots :i use spaces over tabs\r\n".encode())
    await writer.drain()

    # Read and display
    while True:
        message = (await reader.readline()).decode().strip()
        command = re.match(r":.*!\S+ PRIVMSG #bots :(.*)", message)
        # If there was a message and they called the weather command
        if command and command.group(1).startswith("!weather"):
            string = await parse_results(command.group(1))
            writer.write(f"PRIVMSG #bots :{string}\r\n".encode())
            await writer.drain()
        else: 
            pass

# Main eargsecution

def main():
    asyncio.run(ircle())

if __name__ == '__main__':
    main()
    