from godirect import GoDirect
from time import sleep
import sys
from csv import writer

#import logging
#logging.basicConfig(level=logging.INFO)

godirect = GoDirect(use_ble=False, use_usb=True) 
enum_devices = godirect.list_devices()
if len(enum_devices) != 1:
    print("Nonzero number of devices enumerated")
    sys.exit(0)

device = enum_devices[0]
if not device.open():
    print("Error while opening device?")
    sys.exit(0)
print("Chose device", device)

sensors = device.list_sensors()
sensor = next((s for s in sensors.values() if s.sensor_description == "Temperature"), None)
if sensor == None:
    print("No matching sensor found! Sensors:")
    [print(str(x)) for x in sensors.values()]
    sys.exit(0)

print("Chose sensor", str(sensor))
device.enable_sensors(sensors = [sensor.sensor_number])
sensor = sensors[sensor.sensor_number] # enable_sensors invalidates the sensor object

period = 60_000 # in milliseconds
device.start(period=period)

import csv
from pathlib import Path
from datetime import datetime

filepath = Path("measurements.csv")
if not filepath.exists():
    with filepath.open("w", newline="") as f:
        csv.writer(f).writerow(["datetime (local time)", "measurement (°C)"])

with filepath.open("a", newline="") as f:
    csv_writer = csv.writer(f)
    while True:
        device.read(timeout=period + 100)
        if len(sensor.values) == 0: 
            print(f"{datetime.now()} No measurement!")
            sys.exit(1)
        measurement = sensor.values[0]
        print(datetime.now(), measurement)
        csv_writer.writerow([datetime.now(), measurement])
        sensor.clear()
