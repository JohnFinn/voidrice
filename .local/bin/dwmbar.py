#!/usr/bin/env python3

from typing import List, Tuple, Iterable
import random
import subprocess
import datetime
import asyncio
import time
import re
import os


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
    await pactl.wait()


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

@block
async def battery():
    # TODO make this react faster
    BAT0 = Battery('/sys/class/power_supply/BAT0')
    upower_monitor = await asyncio.create_subprocess_exec('upower', '--monitor', stdout=asyncio.subprocess.PIPE)
    while True:
        status = BAT0.status()
        status_signs = {'Charging': '📈', 'Discharging': '📉', 'Unknown': '?', 'Full': 'voll'}
        status_sign = status_signs.get(status, status)
        now_percent = BAT0.energy_now() * 100 / BAT0.energy_full_design()
        yield f'🔋 {status_sign} {int(now_percent)}'
        await upower_monitor.stdout.readline()

    await upower_monitor.wait()

class Battery:

    def __init__(self, path):
        assert os.path.isdir(path)
        self.path = path

    def status(self) -> str:
        with open(os.path.join(self.path, 'status')) as file:
            return file.read().strip()

    def energy_now(self) -> int:
        with open(os.path.join(self.path, 'energy_now')) as file:
            return int(file.read())

    def energy_full_design(self) -> int:
        with open(os.path.join(self.path, 'energy_full_design')) as file:
            return int(file.read())

@block
async def wifi():
    iw = Iwconfig('wlp2s0')
    dbus_monitor = await asyncio.create_subprocess_exec('dbus-monitor', '--system', 'sender=org.freedesktop.NetworkManager, path=/org/freedesktop/NetworkManager', stdout=asyncio.subprocess.PIPE)
    while True:
        try:
            yield f'📶 {iw.ESSID} {int(100 * iw.link_quality())}'
        except IndexError:
            yield f'📶 ...'
        while b'signal' not in await dbus_monitor.stdout.readline():
            pass
    await dbus_monitor.wait()

class Iwconfig:

    def __init__(self, name):
        self.name = name
    
    def _get(self):
        iwconfig = subprocess.Popen(['iwconfig', self.name], stdout=subprocess.PIPE)
        stdout, stderr = iwconfig.communicate()
        iwconfig.wait()
        return stdout.strip().decode()
    
    @property
    def ESSID(self):
        return re.findall('ESSID:"(.*)"', self._get())[0]

    def link_quality(self):
        quality = int(re.findall('Link Quality=(\d*)/70', self._get())[0])
        return quality / 70

@block
async def keyboard_layout():
    while True:
        yield current_keyboard_layout()
        await asyncio.sleep(1)

@block
async def time1():
    while True:
        yield datetime.datetime.now().strftime('%H:%M')
        await asyncio.sleep(60)


def current_keyboard_layout() -> str:
    xkblayout = subprocess.Popen(['xkblayout'], stdout=subprocess.PIPE)
    stdout, stderr = xkblayout.communicate()
    xkblayout.wait()
    return stdout.rstrip().decode()




loop = asyncio.get_event_loop()
loop.run_until_complete(asyncio.gather(*tasks))