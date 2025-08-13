import serial
import serial.tools.list_ports
import time

def list_serial_ports():
    """List all available serial ports"""
    ports = serial.tools.list_ports.comports()
    available_ports = []

    print("Available serial ports:")
    if not ports:
        print("  No serial ports found!")
        return available_ports

    for i, port in enumerate(ports, 1):
        print(f"  {i}. {port.device} - {port.description}")
        available_ports.append(port.device)

    return available_ports

def connect_to_serial(port, baudrate=9600):
    """Attempt to connect to a serial port"""
    try:
        ser = serial.Serial(
            port=port,
            baudrate=baudrate,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE,
            bytesize=serial.EIGHTBITS,
            timeout=1
        )
        print(f"[OK] Successfully connected to {port} at {baudrate} baud")
        return ser
    except serial.SerialException as e:
        print(f"[ERROR] Failed to connect to {port}: {e}")
        return None
    except Exception as e:
        print(f"[ERROR] Unexpected error connecting to {port}: {e}")
        return None

def is_port_available(port):
    """Check if a port is still available"""
    available_ports = [p.device for p in serial.tools.list_ports.comports()]
    return port in available_ports

def main():
    # List available ports
    available_ports = list_serial_ports()

    if not available_ports:
        print("No serial ports available. Exiting...")
        return

    # Select port
    selected_port = available_ports[0]
    print(f"\nAttempting to connect to {selected_port}...")

    # Connection parameters
    baudrate = 9600
    reconnect_delay = 2  # seconds between reconnection attempts
    max_reconnect_attempts = 5  # max attempts before asking user

    ser = None
    reconnect_count = 0

    try:
        while True:
            # Try to connect if not connected
            if ser is None or not ser.is_open:
                if reconnect_count > 0:
                    print(f"[RECONNECT] Attempting to reconnect... (attempt {reconnect_count})")

                # Check if port is still available
                if not is_port_available(selected_port):
                    print(f"[WARNING] Port {selected_port} is no longer available")
                    print("Checking for available ports...")
                    available_ports = list_serial_ports()

                    if not available_ports:
                        print("No serial ports available. Waiting...")
                        time.sleep(reconnect_delay)
                        reconnect_count += 1
                        continue

                    if selected_port not in [p for p in available_ports]:
                        print(f"Switching to {available_ports[0]}")
                        selected_port = available_ports[0]

                ser = connect_to_serial(selected_port, baudrate)

                if ser is None:
                    reconnect_count += 1
                    if reconnect_count >= max_reconnect_attempts:
                        print(f"\n[WARNING] Failed to reconnect after {max_reconnect_attempts} attempts")
                        print("Continue trying? (y/n): ", end="")
                        choice = input().lower()
                        if choice != 'y':
                            break
                        reconnect_count = 0  # Reset counter

                    print(f"Waiting {reconnect_delay} seconds before retry...")
                    time.sleep(reconnect_delay)
                    continue
                else:
                    # Successfully connected
                    if reconnect_count > 0:
                        print(f"[OK] Reconnected successfully after {reconnect_count} attempts!")
                    reconnect_count = 0
                    print("\nSerial Monitor Active (Press Ctrl+C to exit)")
                    print("-" * 40)

            # Try to read data
            try:
                if ser and ser.is_open and ser.in_waiting > 0:
                    try:
                        data = ser.readline().decode('utf-8').rstrip()
                        if data:  # Only print non-empty data
                            print(f"Received: {data}")
                    except UnicodeDecodeError:
                        # Handle binary data
                        data = ser.readline()
                        print(f"Received (hex): {data.hex()}")

                time.sleep(0.1)

            except serial.SerialException as e:
                print(f"\n[ERROR] Serial connection lost: {e}")
                if ser:
                    try:
                        ser.close()
                    except:
                        pass
                    ser = None
                print("Will attempt to reconnect...")
                continue

            except Exception as e:
                print(f"\n[ERROR] Unexpected error during communication: {e}")
                if ser:
                    try:
                        ser.close()
                    except:
                        pass
                    ser = None
                continue

    except KeyboardInterrupt:
        print("\n\nShutting down...")

    finally:
        if ser and ser.is_open:
            try:
                ser.close()
                print("Serial connection closed.")
            except:
                pass

if __name__ == "__main__":
    main()