---
name: arduino-code-generator
description: Generate Arduino/embedded C++ code snippets and patterns on demand for UNO/ESP32/RP2040. Use when users request Arduino code for sensors, actuators, communication protocols, state machines, non-blocking timers, data logging, or hardware abstraction. Generates production-ready code with proper memory management, timing patterns, and board-specific optimization. Supports DHT22, BME280, buttons, I2C/SPI, EEPROM, SD cards, WiFi, and common peripherals.
---

# Arduino Code Generator

Generate production-quality Arduino code snippets for sensors, actuators, communication, and embedded patterns.

## Quick Start

**Browse example sketches:**
```bash
# See 9 production-ready examples in examples/ folder
ls examples/
# config-example.ino, filtering-example.ino, buttons-example.ino,
# i2c-example.ino, csv-example.ino, scheduler-example.ino,
# state-machine-example.ino, hardware-detection-example.ino,
# data-logging-example.ino
```

**List available patterns:**
```bash
uv run scripts/generate_snippet.py --list
```

**Generate code for specific pattern and board:**
```bash
uv run scripts/generate_snippet.py --pattern i2c --board esp32
uv run scripts/generate_snippet.py --pattern buttons --board uno --output button.ino
```

**Interactive mode:**
```bash
uv run scripts/generate_snippet.py --interactive
```

## Resources

- **examples/** - 9 production-ready example sketches (one per pattern category)
- **examples/README.md** - Detailed documentation for each example with wiring diagrams
- **scripts/generate_snippet.py** - CLI tool for code generation with 9 pattern templates
- **assets/workflow.mmd** - Mermaid diagram of code generation workflow

## Supported Patterns

### Hardware Abstraction
- Multi-board config.h with conditional compilation
- Pin definitions for UNO/ESP32/RP2040
- Memory budget tracking

See [patterns-config.md](references/patterns-config.md) | Example: [config-example.ino](examples/config-example.ino)

### Sensor Reading & Filtering
- ADC noise reduction (moving average, median, Kalman)
- DHT22, BME280, analog sensors
- Data validation and calibration

See [patterns-filtering.md](references/patterns-filtering.md) | Example: [filtering-example.ino](examples/filtering-example.ino)

### Input Handling
- Software button debouncing
- Edge detection (PRESSED/RELEASED/LONG_PRESS)
- Multi-button management

See [patterns-buttons.md](references/patterns-buttons.md) | Example: [buttons-example.ino](examples/buttons-example.ino)

### Communication
- I2C device scanning and diagnostics
- SPI configuration
- UART/Serial protocols
- CSV data output

See [patterns-i2c.md](references/patterns-i2c.md) and [patterns-csv.md](references/patterns-csv.md) | Examples: [i2c-example.ino](examples/i2c-example.ino), [csv-example.ino](examples/csv-example.ino)

### Timing & Concurrency
- Non-blocking millis() patterns
- Task scheduling without delay()
- Priority-based schedulers
- State machines

See [patterns-scheduler.md](references/patterns-scheduler.md) and [patterns-state-machine.md](references/patterns-state-machine.md) | Examples: [scheduler-example.ino](examples/scheduler-example.ino), [state-machine-example.ino](examples/state-machine-example.ino)

### Hardware Detection
- Auto-detect boards (UNO/ESP32/RP2040)
- SRAM usage monitoring
- Sensor fallback strategies
- Adaptive configuration

See [patterns-hardware-detection.md](references/patterns-hardware-detection.md) | Example: [hardware-detection-example.ino](examples/hardware-detection-example.ino)

### Data Persistence
- EEPROM with CRC validation
- SD card FAT32 logging
- Wear leveling for EEPROM
- Buffered writes

See [patterns-data-logging.md](references/patterns-data-logging.md) | Example: [data-logging-example.ino](examples/data-logging-example.ino)

## Code Generation Workflow

When user requests Arduino code:

1. **Identify pattern type** from the request
2. **Read relevant reference file** for that pattern
3. **Generate code** following these rules:
   - Include necessary `#include` statements
   - Define pins in config.h style
   - Use `millis()` instead of `delay()` for timing
   - Add F() macro for strings on memory-constrained boards
   - Include error handling
   - Add Serial output for debugging
   - Comment "why" not "what"
4. **Provide usage instructions** with wiring and expected output
5. **Mention integration** with other patterns when relevant

## Quality Standards

All generated code must:
- ✅ Compile without warnings on Arduino IDE
- ✅ Use unsigned long for millis() timing
- ✅ Handle overflow conditions (millis() wraps every 49 days)
- ✅ Include bounds checking for arrays
- ✅ Use const for read-only data
- ✅ Define magic numbers as constants
- ✅ Be memory-safe (no buffer overflows)

## Example Usage Patterns

**User:** "Generate code to read a DHT22 sensor without blocking"
→ Read patterns-filtering.md → Generate DHT22 + EveryMs pattern

**User:** "Create a button handler with long press detection"
→ Read patterns-buttons.md → Generate DebouncedButton with events

**User:** "Make an I2C scanner for my Arduino"
→ Read patterns-i2c.md → Generate scanner with diagnostics

**User:** "Log data to SD card every 10 seconds"
→ Read patterns-data-logging.md → Generate buffered CSV logger

## Board-Specific Optimization

### Arduino UNO (2KB SRAM)
- Use F() macro for strings
- Minimize buffer sizes
- Prefer circular buffers
- Avoid String class

### ESP32 (520KB SRAM)
- Enable WiFi/BLE patterns
- Use FreeRTOS tasks
- Leverage dual-core
- Support larger buffers

### RP2040 (264KB SRAM)
- Use PIO for timing-critical tasks
- Support USB host mode
- Multicore patterns available

## Common Pitfalls to Avoid

❌ Never use `delay()` for timing (blocks execution)
❌ Never use signed types for millis() comparisons
❌ Never forget to call `begin()` on peripherals
❌ Never assume hardware is present without checking
❌ Never mix polling and interrupt-based input

✅ Use millis() for non-blocking timing
✅ Use unsigned long for time variables
✅ Check return values from peripheral init
✅ Provide fallback for missing hardware
✅ Choose one input strategy per button

## Integration Patterns

Combine multiple patterns for complex projects:
- **Environmental Monitor:** Filtering + Scheduler + CSV + Data Logging
- **Button-Controlled Robot:** Buttons + State Machine + Scheduler
- **IoT Data Logger:** Hardware Detection + WiFi + Data Logging + CSV
- **Sensor Hub:** I2C + Filtering + Scheduler + Hardware Detection
