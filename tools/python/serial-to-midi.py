# import serial
# import mido
# from mido import Message

# SERIAL_PORT = '/dev/tty.usbserial-FT4MG9OV1'
# # BAUD_RATE = 115200
# BAUD_RATE = 31250

# ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=0.1)

# print("Available MIDI output ports:")
# print(mido.get_output_names())

# outport = mido.open_output('FPGA Midi Bus 1')

# print(f"Bridging {SERIAL_PORT} → IAC Driver Bus 1...")

# # Buffer to accumulate incoming bytes
# buffer = bytearray()

# while True:
#     data = ser.read(3)
#     if data:
#         print("Raw data received:", [hex(b) for b in data])
#         buffer.extend(data)
    
#     if len(buffer) < 3:
#         print("Buffer length:", len(buffer), "Contents:", list(buffer))
    
#     # Process complete messages (3 bytes per message)
#     while len(buffer) >= 3:
#         # Extract a 3-byte message
#         msg_bytes = buffer[:3]
#         del buffer[:3]
#         status, note, velocity = msg_bytes
#         # Create a message only if it's a Note On or Note Off message
#         if (status & 0xF0) == 0x90 or (status & 0xF0) == 0x80:
#             # Using mido, a Note On with velocity 0 is equivalent to Note Off.
#             msg_type = 'note_on' if (status & 0xF0) == 0x90 and velocity != 0 else 'note_off'
#             channel = status & 0x0F
#             msg = Message(msg_type, channel=channel, note=note, velocity=velocity)
#             outport.send(msg)
#             print(f"Sent MIDI {msg_type}: Channel {channel}, Note {note}, Velocity {velocity}")


# PRINT ONE BYTE AT A TIME
import serial
import time

# Configure with your actual serial port and BAUD rate
PORT = '/dev/tty.usbserial-FT4MG9OV1' # Or your port name
BAUD = 31250

try:
    ser = serial.Serial(PORT, BAUD, timeout=0.1) # Small timeout
    print(f"Listening on {PORT} at {BAUD} baud...")

    while True:
        if ser.in_waiting > 0:
            # Read all available bytes (up to a reasonable chunk size)
            byte_chunk = ser.read(ser.in_waiting)
            hex_list = [hex(b) for b in byte_chunk]
            print(f"Raw Bytes: {hex_list}")
        else:
            # Optional: sleep briefly if nothing is waiting
            # to avoid pegging the CPU, but this might delay reading.
            # For debugging, maybe just let it spin or use a very short sleep.
            time.sleep(0.001) # 1ms sleep


except serial.SerialException as e:
    print(f"Error opening or reading from serial port: {e}")
except KeyboardInterrupt:
    print("\nExiting.")
finally:
    if 'ser' in locals() and ser.is_open:
        ser.close()
        print("Serial port closed.")