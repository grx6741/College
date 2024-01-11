![image](https://github.com/grx6741/College/assets/73749042/c3f85b68-6bb7-415c-8fd3-25976d793f01)- IP addr: `192.168.10.1`
- MAC addr: `00:09:0f:09:00:12`
- Date: Thursday 11 January 2024 03:26:23 PM IST

## Exercise 1

### Aim
To establish a connection between two devices through Copper Crossover wire using Cisco packet
tracer

### Requirements
- Cisco Packet Tracer 8.2.1
- Windows PC or 2 Linux PC, Each PC must Have One NIC cards.
- RJ-45 Sockets – Copper Cross-over Wire.
- Class C IP Address using Static IP configuration.

### Physical Connnection
![image](https://github.com/grx6741/College/assets/73749042/08d86409-d757-4ae7-bdad-9e733c0c8fac)

### Procedure
- Open the CISCO PACKET TRACER software.
- Use two PC from the End Device Icons. (Change Names PC0 to PC-A, PC1 to PC-B)
- Make the Connections using Copper Cross-over Ethernet Cable.
- Enter the IP Address to each machine

### Observation
- ipconfig command

```console
C:\>ipconfig

FastEthernet0 Connection:(default port)

   Connection-specific DNS Suffix..: 
   Link-local IPv6 Address.........: FE80::2E0:B0FF:FE85:8398
   IPv6 Address....................: ::
   IPv4 Address....................: 192.168.1.1
   Subnet Mask.....................: 255.255.255.0
   Default Gateway.................: ::
                                     192.168.1.1

Bluetooth Connection:

   Connection-specific DNS Suffix..: 
   Link-local IPv6 Address.........: ::
   IPv6 Address....................: ::
   IPv4 Address....................: 0.0.0.0
   Subnet Mask.....................: 0.0.0.0
   Default Gateway.................: ::
                                     0.0.0.0
```

- ping command from PC-A
  
```console
C:\>ping 192.168.1.2

Pinging 192.168.1.2 with 32 bytes of data:

Reply from 192.168.1.2: bytes=32 time<1ms TTL=128
Reply from 192.168.1.2: bytes=32 time<1ms TTL=128
Reply from 192.168.1.2: bytes=32 time<1ms TTL=128
Reply from 192.168.1.2: bytes=32 time<1ms TTL=128

Ping statistics for 192.168.1.2:
    Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
    Minimum = 0ms, Maximum = 0ms, Average = 0ms
```
- `arp -a` from PC-A

```console
C:\>arp -a
  Internet Address      Physical Address      Type
  192.168.1.2           00d0.d35e.960c        dynamic
```
- `arp -a` from PC-B

```console
C:\>arp -a
  Internet Address      Physical Address      Type
  192.168.1.2           00d0.d35e.960c        dynamic
```

## Exercise 2

### Aim
To establish the connection between two devices with one switch through Copper Straight
Through cable.

### Requirements
- Cisco Packet Tracer 8.2.1
- Windows PC or 2 Linux PC, Each PC must Have One NIC cards.
- RJ-45 Sockets – Copper Cross-over Wire.
- Class C IP Address using Static IP configuration.
- 2969-24TT switch

### Procedure
- Open the CISCO PACKET TRACER software.
- Use two PC from the End Device Icons. (Change Names PC0 to PC-A, PC1 to PC-B)
- Use 2960-24TT switch
- Make connection from PC-A and PC-B to switch over fastethernet0/1
  
## Physical Connection
![image](https://github.com/grx6741/College/assets/73749042/ba6c418b-3201-47b4-ad8d-211a878c88ae)

### Observation
- `ipconfig`
  ```console
  C:\>ipconfig

  FastEthernet0 Connection:(default port)

     Connection-specific DNS Suffix..: 
     Link-local IPv6 Address.........: FE80::203:E4FF:FE17:84EE
     IPv6 Address....................: ::
     IPv4 Address....................: 192.168.1.1
     Subnet Mask.....................: 255.255.255.0
     Default Gateway.................: ::
                                     192.168.1.1

  Bluetooth Connection:

     Connection-specific DNS Suffix..: 
     Link-local IPv6 Address.........: ::
     IPv6 Address....................: ::
     IPv4 Address....................: 0.0.0.0
     Subnet Mask.....................: 0.0.0.0
     Default Gateway.................: ::
                                     0.0.0.0
  ```
- ping from PC-A
  ```console
  C:\>ipconfig
  
  FastEthernet0 Connection:(default port)
  
     Connection-specific DNS Suffix..: 
     Link-local IPv6 Address.........: FE80::203:E4FF:FE17:84EE
     IPv6 Address....................: ::
     IPv4 Address....................: 192.168.1.1
     Subnet Mask.....................: 255.255.255.0
     Default Gateway.................: ::
                                       192.168.1.1
  
  Bluetooth Connection:
  
     Connection-specific DNS Suffix..: 
     Link-local IPv6 Address.........: ::
     IPv6 Address....................: ::
     IPv4 Address....................: 0.0.0.0
     Subnet Mask.....................: 0.0.0.0
     Default Gateway.................: ::
                                       0.0.0.0
  ```
- `arp -a` from PC-A
  ```console
  C:\>arp -a
  Internet Address      Physical Address      Type
  192.168.1.2           0030.a3b0.2052        dynamic
  ```
- `arp -a` from PC-B
  ```console
  C:\>arp -a
  Internet Address      Physical Address      Type
  192.168.1.1           0003.e417.84ee        dynamic
  ```
- MAC address from switch
  ```console
  %LINK-5-CHANGED: Interface FastEthernet0/1, changed state to up

  %LINEPROTO-5-UPDOWN: Line protocol on Interface FastEthernet0/1, changed state to up

  %LINK-5-CHANGED: Interface FastEthernet0/2, changed state to up

  %LINEPROTO-5-UPDOWN: Line protocol on Interface FastEthernet0/2, changed state to up


  Switch>enable
  Switch#show mac-address-table
          Mac Address Table
  -------------------------------------------

  Vlan    Mac Address       Type        Ports
  ----    -----------       --------    -----

  Switch#
  ```
## Exercise 3

## Aim

## Requirements

## Physical Connections

![image](https://github.com/grx6741/College/assets/73749042/e51224ee-fbbd-414b-a49d-7a9245188a6e)


## Procedure

## Observation

- ipconfig
  ```console
  C:\>ipconfig

  FastEthernet0 Connection:(default port)
  
     Connection-specific DNS Suffix..: 
     Link-local IPv6 Address.........: FE80::2E0:8FFF:FE45:A92E
     IPv6 Address....................: ::
     IPv4 Address....................: 192.168.1.4
     Subnet Mask.....................: 255.255.255.0
     Default Gateway.................: ::
                                       192.168.1.4
  
  Bluetooth Connection:
  
     Connection-specific DNS Suffix..: 
     Link-local IPv6 Address.........: ::
     IPv6 Address....................: ::
     IPv4 Address....................: 0.0.0.0
     Subnet Mask.....................: 0.0.0.0
     Default Gateway.................: ::
                                       0.0.0.0
  ```
- ping
  ```console
  C:\>ipconfig

  FastEthernet0 Connection:(default port)
  
     Connection-specific DNS Suffix..: 
     Link-local IPv6 Address.........: FE80::2E0:8FFF:FE45:A92E
     IPv6 Address....................: ::
     IPv4 Address....................: 192.168.1.4
     Subnet Mask.....................: 255.255.255.0
     Default Gateway.................: ::
                                       192.168.1.4
  
  Bluetooth Connection:
  
     Connection-specific DNS Suffix..: 
     Link-local IPv6 Address.........: ::
     IPv6 Address....................: ::
     IPv4 Address....................: 0.0.0.0
     Subnet Mask.....................: 0.0.0.0
     Default Gateway.................: ::
                                       0.0.0.0
  ```
  - `arp -a` from PC-A
    ```console
    C:\>arp -a
    Internet Address      Physical Address      Type
    192.168.1.4           00e0.8f45.a92e        dynamic
    ```

  - `arp -a` from PC-B
    ```console
    C:\>arp -a
    Internet Address      Physical Address      Type
    192.168.1.1           0003.e417.84ee        dynamic

    ```
