#!/usr/bin/env python3

from typing import List
import random
import subprocess
import datetime
import asyncio
import time

delimiter = ' | '

def update():
    set_bar(delimiter.join(blocks))

def set_bar(value: str):
    subprocess.Popen(['xsetroot', '-name', value]).wait()

blocks = []
tasks = []

def block(function):
    position = len(blocks)
    async def wrapper():
        async for i in function():
            blocks[position] = i
            update()
    blocks.append('')
    tasks.append(wrapper())
    return wrapper


@block
async def time1():
    while True:
        yield datetime.datetime.now().strftime('%H:%M:%S')
        await asyncio.sleep(1)


@block
async def time2():
    while True:
        yield str(time.time())
        await asyncio.sleep(0.2)


loop = asyncio.get_event_loop()
loop.run_until_complete(asyncio.gather(*tasks))