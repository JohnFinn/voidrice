#!/usr/bin/env python3

from typing import List, Tuple, Iterable
import random
import subprocess
import datetime
import asyncio
import time
import re


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
async def volume():
    pactl = await asyncio.create_subprocess_exec('pactl', 'subscribe', stdout=asyncio.subprocess.PIPE)
    while True:
        yield ' '.join(map(str, get_volume()))
        # pactl returns many lines at once, so it is smarter to wait for all of them
        # TODO bug
        #   `amixer get Master` makes `pactl subscribe` produce extra lines
        #   this for loop is a workaround to this behaviour. It skips these lines
        for i in range(8):
            await pactl.stdout.readline()


class Speaker:

    def __init__(self, volume, status):
        self.volume = volume
        self.status = status
    
    def __str__(self):
        statuschar = '🔊' if self.status else '🔇'
        return f'{self.volume} {statuschar}'
    

def get_volume() -> Iterable[Tuple[int, bool]]:
    amixer = subprocess.Popen(['amixer', 'get', 'Master'], stdout=subprocess.PIPE)
    stdout, stderr = amixer.communicate()
    amixer.wait()
    for output_descr in re.findall('\[[0-9]*%\] \[(?:off|on)\]', stdout.decode()):
        volume_str, state_str = output_descr.split()
        volume = int(volume_str[1:-2])
        state = state_str == '[on]'
        yield Speaker(volume, state)

# @block
# async def battery():
#     # dbus-monitor --system
#     pass

@block
async def keyboard_layout():
    while True:
        yield current_keyboard_layout()
        await asyncio.sleep(0.2)

@block
async def time1():
    while True:
        yield datetime.datetime.now().strftime('%H:%M')
        await asyncio.sleep(60)


def current_keyboard_layout():
    setxkbmap = subprocess.Popen(['setxkbmap', '-query'], stdout=subprocess.PIPE)
    stdout, stderr = setxkbmap.communicate()
    setxkbmap.wait()
    regex = re.compile('layout:\s*([a-z]{2})')
    res, = regex.finditer(stdout.decode(), re.MULTILINE).__next__().groups()
    return res




loop = asyncio.get_event_loop()
loop.run_until_complete(asyncio.gather(*tasks))