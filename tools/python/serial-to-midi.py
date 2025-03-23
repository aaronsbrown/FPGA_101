import serial
import mido
from mido import Message

# Replace this with the actual name of your FPGA's serial device
SERIAL_PORT = '/dev/tty.usbserial-FT4MG9OV1'
BAUD_RATE = 115200

# Open the serial port
ser = serial.Serial(SERIAL_PORT, BAUD_RATE)


print("Available MIDI output ports:")
print(mido.get_output_names())

# Open the virtual MIDI port (created via IAC Bus)
outport = mido.open_output('FPGA Midi Bus 1')

print(f"Bridging {SERIAL_PORT} → IAC Driver Bus 1...")

while True:
    byte = ser.read()
    note = int.from_bytes(byte, 'big') & 0x7F  # MIDI note range
    msg = Message('note_on', note=note, velocity=100)
    outport.send(msg)
    print(f"Sent MIDI note_on: {note}")
