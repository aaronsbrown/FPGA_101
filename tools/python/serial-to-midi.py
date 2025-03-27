import serial
import mido
from mido import Message

SERIAL_PORT = '/dev/tty.usbserial-FT4MG9OV1'
BAUD_RATE = 115200

ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=0.1)

print("Available MIDI output ports:")
print(mido.get_output_names())

outport = mido.open_output('FPGA Midi Bus 1')

print(f"Bridging {SERIAL_PORT} → IAC Driver Bus 1...")

# Buffer to accumulate incoming bytes
buffer = bytearray()

while True:
    data = ser.read(3)
    if data:
        print("Raw data received:", [hex(b) for b in data])
        buffer.extend(data)
    
    if len(buffer) < 3:
        print("Buffer length:", len(buffer), "Contents:", list(buffer))
    
    # Process complete messages (3 bytes per message)
    while len(buffer) >= 3:
        # Extract a 3-byte message
        msg_bytes = buffer[:3]
        del buffer[:3]
        status, note, velocity = msg_bytes
        # Create a message only if it's a Note On or Note Off message
        if (status & 0xF0) == 0x90 or (status & 0xF0) == 0x80:
            # Using mido, a Note On with velocity 0 is equivalent to Note Off.
            msg_type = 'note_on' if (status & 0xF0) == 0x90 and velocity != 0 else 'note_off'
            channel = status & 0x0F
            msg = Message(msg_type, channel=channel, note=note, velocity=velocity)
            outport.send(msg)
            print(f"Sent MIDI {msg_type}: Channel {channel}, Note {note}, Velocity {velocity}")