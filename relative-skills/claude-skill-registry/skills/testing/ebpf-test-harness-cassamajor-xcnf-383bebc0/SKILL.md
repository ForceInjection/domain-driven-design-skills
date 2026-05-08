---
name: ebpf-test-harness
description: Generate test infrastructure for eBPF CNF programs including network namespace setup, virtual interface creation, traffic generation, packet injection, and validation of packet processing logic. Use when implementing automated tests for CNFs.
---

# eBPF Test Harness Skill

This skill generates comprehensive test infrastructure for validating eBPF-based CNF programs.

## What This Skill Does

Generates test code for:
1. Network namespace setup and teardown
2. Virtual interface (veth/netkit) creation
3. Traffic generation (ping, netcat, iperf)
4. Packet injection and capture
5. Map validation (checking counters, stats)
6. Event verification (ringbuf events)
7. Integration tests with real packet flows
8. Unit tests for eBPF helper functions

## When to Use

- Writing automated tests for CNFs
- Validating packet processing logic
- Testing eBPF map operations
- Verifying event generation
- CI/CD integration
- Performance benchmarking
- Regression testing

## Test Types

### 1. Unit Tests
- Test individual eBPF programs in isolation
- Mock traffic patterns
- Validate map operations

### 2. Integration Tests
- Full CNF setup with real network interfaces
- Multi-namespace scenarios
- End-to-end packet flows

### 3. Performance Tests
- Throughput benchmarks
- Latency measurements
- Resource usage validation

## Information to Gather

Ask the user:

1. **CNF Type**: What does the CNF do? (filter, forward, monitor, etc.)
2. **Test Scope**: Unit tests, integration tests, or both?
3. **Network Setup**: Single namespace or multi-namespace?
4. **Traffic Type**: TCP, UDP, ICMP, or mixed?
5. **Validation**: Check maps, events, packet modifications?
6. **Performance**: Need benchmarks?

## Go Test Setup

### Basic Test Structure

```go
package main

import (
    "testing"

    "github.com/cilium/ebpf"
)

func TestMain(m *testing.M) {
    // Setup before all tests
    // Teardown after all tests
    os.Exit(m.Run())
}

func TestCNFBasic(t *testing.T) {
    // Load eBPF program
    spec, err := LoadMyCNF()
    if err != nil {
        t.Fatalf("loading spec: %v", err)
    }

    objs := &MyCNFObjects{}
    if err := spec.LoadAndAssign(objs, nil); err != nil {
        t.Fatalf("loading objects: %v", err)
    }
    defer objs.Close()

    // Run test
    // Validate results
}
```

**Tip:** For cleaner assertions, use stretchr/testify (`require.NoError`, `assert.Equal`). See [EXAMPLES.md](EXAMPLES.md) for patterns and when to use `require` vs `assert`.

## Network Namespace Setup

### Creating Test Namespaces

```go
import (
    "runtime"
    "github.com/vishvananda/netns"
    "github.com/vishvananda/netlink"
)

type TestEnv struct {
    OrigNS  netns.NsHandle
    TestNS  netns.NsHandle
    Cleanup func()
}

func setupTestNamespace(t *testing.T) *TestEnv {
    t.Helper()

    // Lock to current OS thread
    runtime.LockOSThread()

    // Save original namespace
    origNS, err := netns.Get()
    if err != nil {
        t.Fatalf("getting original netns: %v", err)
    }

    // Create test namespace
    testNS, err := netns.New()
    if err != nil {
        origNS.Close()
        t.Fatalf("creating test netns: %v", err)
    }

    // Switch back to original for test setup
    if err := netns.Set(origNS); err != nil {
        testNS.Close()
        origNS.Close()
        t.Fatalf("switching back to original netns: %v", err)
    }

    env := &TestEnv{
        OrigNS: origNS,
        TestNS: testNS,
        Cleanup: func() {
            testNS.Close()
            origNS.Close()
            runtime.UnlockOSThread()
        },
    }

    return env
}

func TestWithNamespace(t *testing.T) {
    env := setupTestNamespace(t)
    defer env.Cleanup()

    // Switch to test namespace
    if err := netns.Set(env.TestNS); err != nil {
        t.Fatalf("switching to test netns: %v", err)
    }
    defer netns.Set(env.OrigNS)

    // Run tests in isolated namespace
    // Create interfaces, attach programs, etc.
}
```

## Virtual Interface Setup

### Creating veth Pairs

```go
import (
    "github.com/vishvananda/netlink"
)

func createVethPair(t *testing.T, name1, name2 string) {
    t.Helper()

    veth := &netlink.Veth{
        LinkAttrs: netlink.LinkAttrs{
            Name: name1,
        },
        PeerName: name2,
    }

    if err := netlink.LinkAdd(veth); err != nil {
        t.Fatalf("creating veth pair: %v", err)
    }

    // Cleanup
    t.Cleanup(func() {
        netlink.LinkDel(veth)
    })

    // Bring up interfaces
    link1, _ := netlink.LinkByName(name1)
    link2, _ := netlink.LinkByName(name2)

    if err := netlink.LinkSetUp(link1); err != nil {
        t.Fatalf("bringing up %s: %v", name1, err)
    }

    if err := netlink.LinkSetUp(link2); err != nil {
        t.Fatalf("bringing up %s: %v", name2, err)
    }
}

func TestWithVethPair(t *testing.T) {
    createVethPair(t, "veth0", "veth1")

    // Use veth0 and veth1 in test
}
```

### Creating netkit Pairs

```go
func createNetkitPair(t *testing.T, name1, name2 string) {
    t.Helper()

    // Note: Requires kernel 6.6+ and recent netlink library
    netkit := &netlink.Netkit{
        LinkAttrs: netlink.LinkAttrs{
            Name: name1,
        },
        PeerName: name2,
        Mode:     netlink.NETKIT_MODE_L3,
    }

    if err := netlink.LinkAdd(netkit); err != nil {
        t.Fatalf("creating netkit pair: %v", err)
    }

    t.Cleanup(func() {
        netlink.LinkDel(netkit)
    })

    // Bring up interfaces
    link1, _ := netlink.LinkByName(name1)
    link2, _ := netlink.LinkByName(name2)

    netlink.LinkSetUp(link1)
    netlink.LinkSetUp(link2)
}
```

## Traffic Generation

### ICMP Ping

```go
import (
    "os/exec"
    "time"
)

func sendPing(t *testing.T, target string, count int) {
    t.Helper()

    cmd := exec.Command("ping", "-c", fmt.Sprintf("%d", count), target)
    if err := cmd.Run(); err != nil {
        t.Logf("ping failed (may be expected): %v", err)
    }
}

func TestPingProcessing(t *testing.T) {
    // Setup namespace, interfaces, attach program...

    // Generate ICMP traffic
    sendPing(t, "10.0.0.2", 5)

    // Wait for processing
    time.Sleep(100 * time.Millisecond)

    // Validate results (check maps, counters, etc.)
}
```

### TCP Traffic

```go
func sendTCPTraffic(t *testing.T, addr string, data []byte) {
    t.Helper()

    conn, err := net.DialTimeout("tcp", addr, 5*time.Second)
    if err != nil {
        t.Fatalf("dialing: %v", err)
    }
    defer conn.Close()

    if _, err := conn.Write(data); err != nil {
        t.Fatalf("writing: %v", err)
    }
}

func TestTCPProcessing(t *testing.T) {
    // Start TCP server in background
    listener, err := net.Listen("tcp", "127.0.0.1:8080")
    if err != nil {
        t.Fatalf("listening: %v", err)
    }
    defer listener.Close()

    go func() {
        conn, _ := listener.Accept()
        if conn != nil {
            defer conn.Close()
            io.ReadAll(conn)
        }
    }()

    // Setup CNF...

    // Send TCP traffic
    sendTCPTraffic(t, "127.0.0.1:8080", []byte("test data"))

    // Validate processing
}
```

### UDP Traffic

```go
func sendUDPPacket(t *testing.T, addr string, data []byte) {
    t.Helper()

    conn, err := net.Dial("udp", addr)
    if err != nil {
        t.Fatalf("dialing: %v", err)
    }
    defer conn.Close()

    if _, err := conn.Write(data); err != nil {
        t.Fatalf("writing: %v", err)
    }
}
```

## Packet Injection with gopacket

```go
import (
    "github.com/google/gopacket"
    "github.com/google/gopacket/layers"
    "github.com/google/gopacket/pcap"
)

func injectPacket(t *testing.T, iface string, packet []byte) {
    t.Helper()

    handle, err := pcap.OpenLive(iface, 1600, true, pcap.BlockForever)
    if err != nil {
        t.Fatalf("opening pcap: %v", err)
    }
    defer handle.Close()

    if err := handle.WritePacketData(packet); err != nil {
        t.Fatalf("writing packet: %v", err)
    }
}

func createTCPSYN(srcIP, dstIP string, srcPort, dstPort uint16) []byte {
    // Create Ethernet layer
    eth := layers.Ethernet{
        SrcMAC:       net.HardwareAddr{0x00, 0x00, 0x00, 0x00, 0x00, 0x01},
        DstMAC:       net.HardwareAddr{0x00, 0x00, 0x00, 0x00, 0x00, 0x02},
        EthernetType: layers.EthernetTypeIPv4,
    }

    // Create IP layer
    ip := layers.IPv4{
        Version:  4,
        TTL:      64,
        Protocol: layers.IPProtocolTCP,
        SrcIP:    net.ParseIP(srcIP),
        DstIP:    net.ParseIP(dstIP),
    }

    // Create TCP layer
    tcp := layers.TCP{
        SrcPort: layers.TCPPort(srcPort),
        DstPort: layers.TCPPort(dstPort),
        SYN:     true,
        Seq:     1000,
        Window:  65535,
    }
    tcp.SetNetworkLayerForChecksum(&ip)

    // Serialize
    buf := gopacket.NewSerializeBuffer()
    opts := gopacket.SerializeOptions{
        ComputeChecksums: true,
        FixLengths:       true,
    }

    gopacket.SerializeLayers(buf, opts, &eth, &ip, &tcp)
    return buf.Bytes()
}

func TestTCPSYNProcessing(t *testing.T) {
    // Setup...

    // Inject TCP SYN packet
    packet := createTCPSYN("10.0.0.1", "10.0.0.2", 12345, 80)
    injectPacket(t, "veth0", packet)

    // Validate...
}
```

## Map Validation

### Reading and Validating Counters

```go
func validateCounter(t *testing.T, m *ebpf.Map, expectedCount uint64) {
    t.Helper()

    var (
        key   uint32 = 0
        value uint64
    )

    if err := m.Lookup(&key, &value); err != nil {
        t.Fatalf("looking up counter: %v", err)
    }

    if value != expectedCount {
        t.Errorf("counter mismatch: got %d, want %d", value, expectedCount)
    }
}

func TestPacketCounting(t *testing.T) {
    // Load program
    spec, _ := LoadMyCNF()
    objs := &MyCNFObjects{}
    spec.LoadAndAssign(objs, nil)
    defer objs.Close()

    // Attach program...

    // Send 10 packets
    for i := 0; i < 10; i++ {
        sendPing(t, "10.0.0.2", 1)
    }

    time.Sleep(100 * time.Millisecond)

    // Validate counter
    validateCounter(t, objs.PacketCounter, 10)
}
```

### Validating Flow Table

```go
func validateFlowExists(t *testing.T, flowMap *ebpf.Map, key FlowKey) {
    t.Helper()

    var stats FlowStats
    if err := flowMap.Lookup(&key, &stats); err != nil {
        t.Fatalf("flow not found: %v", err)
    }

    if stats.Packets == 0 {
        t.Error("flow has zero packets")
    }

    t.Logf("Flow stats: packets=%d, bytes=%d", stats.Packets, stats.Bytes)
}
```

## Event Validation (Ringbuf)

```go
import (
    "github.com/cilium/ebpf/ringbuf"
)

func collectEvents(t *testing.T, eventsMap *ebpf.Map, expected int, timeout time.Duration) []PacketEvent {
    t.Helper()

    rd, err := ringbuf.NewReader(eventsMap)
    if err != nil {
        t.Fatalf("opening ringbuf: %v", err)
    }
    defer rd.Close()

    var events []PacketEvent
    deadline := time.After(timeout)

    for len(events) < expected {
        select {
        case <-deadline:
            t.Fatalf("timeout waiting for events: got %d, want %d", len(events), expected)
        default:
            record, err := rd.Read()
            if err != nil {
                if errors.Is(err, ringbuf.ErrClosed) {
                    return events
                }
                continue
            }

            var event PacketEvent
            if err := binary.Read(bytes.NewReader(record.RawSample), binary.LittleEndian, &event); err != nil {
                t.Logf("parsing event: %v", err)
                continue
            }

            events = append(events, event)
        }
    }

    return events
}

func TestEventGeneration(t *testing.T) {
    // Setup...

    // Start event collection in background
    eventsChan := make(chan []PacketEvent)
    go func() {
        events := collectEvents(t, objs.Events, 5, 5*time.Second)
        eventsChan <- events
    }()

    // Generate traffic
    time.Sleep(100 * time.Millisecond) // Let reader start
    for i := 0; i < 5; i++ {
        sendPing(t, "10.0.0.2", 1)
    }

    // Wait for events
    events := <-eventsChan

    if len(events) != 5 {
        t.Errorf("event count mismatch: got %d, want 5", len(events))
    }
}
```

## Complete Integration Test Example

```go
package main

import (
    "testing"
    "time"
    "net"

    "github.com/vishvananda/netlink"
    "github.com/vishvananda/netns"
    "github.com/cilium/ebpf/link"
)

func TestCNFIntegration(t *testing.T) {
    // Skip if not root
    if os.Getuid() != 0 {
        t.Skip("test requires root")
    }

    // Create test namespaces
    ns1, err := netns.New()
    if err != nil {
        t.Fatalf("creating ns1: %v", err)
    }
    defer ns1.Close()

    ns2, err := netns.New()
    if err != nil {
        t.Fatalf("creating ns2: %v", err)
    }
    defer ns2.Close()

    // Get original namespace
    origNS, _ := netns.Get()
    defer origNS.Close()
    defer netns.Set(origNS)

    // Create veth pair in host namespace
    veth := &netlink.Veth{
        LinkAttrs: netlink.LinkAttrs{Name: "veth0"},
        PeerName:  "veth1",
    }
    if err := netlink.LinkAdd(veth); err != nil {
        t.Fatalf("creating veth: %v", err)
    }
    defer netlink.LinkDel(veth)

    // Move veth1 to ns1
    veth1, _ := netlink.LinkByName("veth1")
    if err := netlink.LinkSetNsFd(veth1, int(ns1)); err != nil {
        t.Fatalf("moving veth1 to ns1: %v", err)
    }

    // Configure veth0 in host
    veth0, _ := netlink.LinkByName("veth0")
    addr, _ := netlink.ParseAddr("10.0.0.1/24")
    netlink.AddrAdd(veth0, addr)
    netlink.LinkSetUp(veth0)

    // Configure veth1 in ns1
    netns.Set(ns1)
    veth1, _ = netlink.LinkByName("veth1")
    addr, _ = netlink.ParseAddr("10.0.0.2/24")
    netlink.AddrAdd(veth1, addr)
    netlink.LinkSetUp(veth1)
    netns.Set(origNS)

    // Load eBPF program
    spec, err := LoadMyCNF()
    if err != nil {
        t.Fatalf("loading spec: %v", err)
    }

    objs := &MyCNFObjects{}
    if err := spec.LoadAndAssign(objs, nil); err != nil {
        t.Fatalf("loading objects: %v", err)
    }
    defer objs.Close()

    // Attach to veth0
    l, err := link.AttachXDP(link.XDPOptions{
        Program:   objs.XdpCnf,
        Interface: veth0.Attrs().Index,
        Flags:     link.XDPGenericMode,
    })
    if err != nil {
        t.Fatalf("attaching XDP: %v", err)
    }
    defer l.Close()

    // Generate traffic from ns1
    netns.Set(ns1)
    sendPing(t, "10.0.0.1", 10)
    netns.Set(origNS)

    // Wait for processing
    time.Sleep(500 * time.Millisecond)

    // Validate results
    validateCounter(t, objs.PacketCounter, 10)
}
```

## Multi-Container Test Environments

For more realistic testing scenarios, use Docker Compose to create multi-container topologies with the CNF acting as a router or gateway between containers.

### Why Multi-Container Testing

**Benefits:**
- Tests real packet forwarding behavior
- Validates routing and redirection logic
- Simulates production network topologies
- Tests asymmetric routing scenarios
- Verifies end-to-end connectivity
- Isolates test environment from host

**Use Cases:**
- CNF routers between networks
- Service mesh sidecar testing
- Load balancer validation
- VPN/tunnel endpoint testing
- Multi-homing scenarios

### Example: 3-Tier Router Topology

**Scenario:** Test a CNF router that solves asymmetric routing

```
Client (10.0.2.2)
  ↓
Router (10.0.2.1 / 10.0.1.1) [CNF with eBPF]
  ↓
Server (10.0.1.2)
  - Virtual IP: 192.168.100.5 on lo
  - Problem: Return traffic would go wrong way
  - Solution: eBPF redirect based on source IP
```

### Docker Compose Setup

**docker-compose.yml:**
```yaml
version: '3'

services:
  server:
    image: ubuntu:22.04
    privileged: true  # Required for eBPF
    cap_add:
      - NET_ADMIN
      - SYS_ADMIN
    volumes:
      - ./:/app
    entrypoint: /app/scripts/server-entrypoint.sh
    networks:
      primary:
        ipv4_address: 10.111.220.11
      server_to_router:
        ipv4_address: 10.111.221.11

  router:
    image: ubuntu:22.04
    privileged: true
    cap_add:
      - NET_ADMIN
      - SYS_ADMIN
      - BPF
    volumes:
      - ./:/app
      - /sys/kernel/debug:/sys/kernel/debug:rw
    entrypoint: /app/scripts/router-entrypoint.sh
    networks:
      server_to_router:
        ipv4_address: 10.111.221.21
      router_to_client:
        ipv4_address: 10.111.222.21
    depends_on:
      - server

  client:
    image: ubuntu:22.04
    privileged: true
    cap_add:
      - NET_ADMIN
    volumes:
      - ./:/app
    entrypoint: /app/scripts/client-entrypoint.sh
    networks:
      router_to_client:
        ipv4_address: 10.111.222.22
    depends_on:
      - router

networks:
  primary:
    driver: bridge
    ipam:
      config:
        - subnet: 10.111.220.0/24
  server_to_router:
    driver: bridge
    ipam:
      config:
        - subnet: 10.111.221.0/24
  router_to_client:
    driver: bridge
    ipam:
      config:
        - subnet: 10.111.222.0/24
```

### Entrypoint Scripts

**scripts/server-entrypoint.sh:**
```bash
#!/bin/bash
set -e

# Add virtual IP to loopback
ip addr add 192.168.100.5/32 dev lo

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1

# Add route to reach client via router
ip route add 10.111.222.0/24 via 10.111.221.21

# Start listener
echo "Server ready - listening on port 8080"
nc -l -p 8080 -k &

# Keep container running
tail -f /dev/null
```

**scripts/router-entrypoint.sh:**
```bash
#!/bin/bash
set -e

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1

# Add routes
ip route add 192.168.100.0/24 via 10.111.221.11

echo "Router ready - starting CNF..."

# Build and run CNF with eBPF program
cd /app
go build -o cnf-router
./cnf-router &

# Keep container running
tail -f /dev/null
```

**scripts/client-entrypoint.sh:**
```bash
#!/bin/bash
set -e

# Add route to server via router
ip route add 192.168.100.0/24 via 10.111.222.21

echo "Client ready"

# Keep container running
tail -f /dev/null
```

### Running Tests

**Start environment:**
```bash
docker-compose up -d
```

**Test without eBPF (should fail):**
```bash
# From client container
docker-compose exec client nc -v 192.168.100.5 8080
# Expected: Connection timeout (asymmetric routing)
```

**Test with eBPF (should work):**
```bash
# Router is already running CNF with eBPF
# From client container
docker-compose exec client nc -v 192.168.100.5 8080
# Expected: Connection successful
```

**Manual validation:**
```bash
# Check eBPF program loaded
docker-compose exec router bpftool prog list

# Check packet counters
docker-compose exec router bpftool map dump name stats

# View trace logs
docker-compose exec router cat /sys/kernel/debug/tracing/trace_pipe
```

**Cleanup:**
```bash
docker-compose down -v
```

### Automated Test Integration

**Go test that uses Docker Compose:**

```go
package main_test

import (
    "fmt"
    "os"
    "os/exec"
    "testing"
    "time"
)

func TestCNFRouterWithDockerCompose(t *testing.T) {
    // Skip if Docker not available
    if _, err := exec.LookPath("docker-compose"); err != nil {
        t.Skip("docker-compose not available")
    }

    // Start containers
    cmd := exec.Command("docker-compose", "up", "-d")
    if err := cmd.Run(); err != nil {
        t.Fatalf("starting containers: %v", err)
    }

    // Cleanup
    defer func() {
        exec.Command("docker-compose", "down", "-v").Run()
    }()

    // Wait for containers to be ready
    time.Sleep(5 * time.Second)

    // Test: ping from client to server's virtual IP
    t.Run("ping_virtual_ip", func(t *testing.T) {
        cmd := exec.Command("docker-compose", "exec", "-T", "client",
            "ping", "-c", "3", "192.168.100.5")
        output, err := cmd.CombinedOutput()

        if err != nil {
            t.Errorf("ping failed: %v\nOutput: %s", err, output)
        }

        t.Logf("Ping output:\n%s", output)
    })

    // Test: TCP connection from client to server
    t.Run("tcp_connection", func(t *testing.T) {
        // Start server listener
        serverCmd := exec.Command("docker-compose", "exec", "-T", "server",
            "sh", "-c", "echo 'hello' | nc -l -p 9000 &")
        serverCmd.Run()

        time.Sleep(1 * time.Second)

        // Connect from client
        clientCmd := exec.Command("docker-compose", "exec", "-T", "client",
            "sh", "-c", "nc -w 2 192.168.100.5 9000")
        output, err := clientCmd.CombinedOutput()

        if err != nil {
            t.Errorf("TCP connection failed: %v", err)
        }

        if string(output) != "hello\n" {
            t.Errorf("unexpected response: got %q, want %q", output, "hello\n")
        }
    })

    // Test: verify eBPF statistics
    t.Run("ebpf_statistics", func(t *testing.T) {
        cmd := exec.Command("docker-compose", "exec", "-T", "router",
            "bpftool", "map", "dump", "name", "stats")
        output, err := cmd.CombinedOutput()

        if err != nil {
            t.Logf("Warning: could not read stats: %v", err)
            return  // Don't fail test
        }

        t.Logf("eBPF statistics:\n%s", output)

        // Could parse output and check counters here
    })
}
```

### Alternative: Makefile-Based Testing

**Makefile:**
```makefile
.PHONY: test-up test-validate test-down test-all

test-up:
	docker-compose up -d
	@echo "Waiting for containers..."
	@sleep 5

test-validate: test-up
	@echo "Testing connectivity..."
	docker-compose exec -T client ping -c 3 192.168.100.5
	docker-compose exec -T client nc -zv 192.168.100.5 8080

test-down:
	docker-compose down -v

test-all: test-validate test-down
```

Usage:
```bash
make test-all
```

### Advanced Multi-Container Patterns

#### Pattern 1: Chain of CNFs

```yaml
services:
  cnf1:
    # First CNF - packet classifier

  cnf2:
    # Second CNF - rate limiter
    depends_on: [cnf1]

  cnf3:
    # Third CNF - load balancer
    depends_on: [cnf2]
```

#### Pattern 2: Service Mesh Topology

```yaml
services:
  app:
    # Application container

  sidecar:
    # eBPF sidecar CNF
    network_mode: "service:app"  # Share network namespace
```

#### Pattern 3: Multi-Path Testing

```yaml
services:
  router:
    networks:
      - isp1
      - isp2
      - internal
    # Test multiple paths/ISPs
```

### Debugging Multi-Container Tests

**View logs:**
```bash
docker-compose logs -f router
docker-compose logs -f server
```

**Enter container:**
```bash
docker-compose exec router /bin/bash
```

**Check routing:**
```bash
docker-compose exec router ip route
docker-compose exec server ip route
docker-compose exec client ip route
```

**Capture packets:**
```bash
docker-compose exec router tcpdump -i eth0 -n
```

**View eBPF programs:**
```bash
docker-compose exec router bpftool prog list
docker-compose exec router bpftool map list
```

### Best Practices for Multi-Container Tests

1. **Use specific container images** with version tags (not `latest`)
2. **Set resource limits** to prevent test interference
3. **Add health checks** to wait for readiness
4. **Use named networks** for clarity
5. **Volume mount your CNF binary** for faster iteration
6. **Add cleanup in defer/trap** to avoid orphaned containers
7. **Check prerequisites** (Docker, docker-compose) in test setup
8. **Use meaningful container names** for debugging
9. **Log extensively** during setup and validation
10. **Test both success and failure** scenarios

### Common Issues

**Problem:** eBPF program won't load in container
**Solution:** Ensure `privileged: true` and correct capabilities

**Problem:** Asymmetric routing still occurs
**Solution:** Verify CNF attached to correct interface and direction (egress)

**Problem:** Containers can't resolve each other
**Solution:** Use IP addresses or configure DNS in docker-compose

**Problem:** tc/bpftool commands fail
**Solution:** Mount `/sys/kernel/debug` and ensure BPF capability

## Benchmarking

```go
func BenchmarkCNFThroughput(b *testing.B) {
    // Setup CNF...

    packet := createTCPSYN("10.0.0.1", "10.0.0.2", 12345, 80)

    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        injectPacket(b, "veth0", packet)
    }
}

func BenchmarkMapLookup(b *testing.B) {
    // Load program...

    var (
        key   uint32 = 0
        value uint64
    )

    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        objs.CounterMap.Lookup(&key, &value)
    }
}
```

## Best Practices

1. **Use t.Helper()**: Mark helper functions
2. **Use t.Cleanup()**: Automatic resource cleanup
3. **Skip non-root tests**: Check `os.Getuid()`
4. **Isolate with namespaces**: Avoid interfering with host
5. **Add timeouts**: Prevent hanging tests
6. **Validate incrementally**: Test small pieces first
7. **Use table-driven tests**: Test multiple scenarios
8. **Mock when possible**: Unit test eBPF logic separately
9. **Clean up resources**: Use defer or t.Cleanup()
10. **Log important info**: Use t.Logf() for debugging

## Common Test Patterns

```go
// Table-driven test
func TestPacketFiltering(t *testing.T) {
    tests := []struct {
        name     string
        srcIP    string
        dstIP    string
        wantDrop bool
    }{
        {"allow local", "10.0.0.1", "10.0.0.2", false},
        {"drop external", "1.1.1.1", "10.0.0.2", true},
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            // Test logic...
        })
    }
}
```