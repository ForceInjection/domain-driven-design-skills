---
name: zephyr-driver-development
description: Full development cycle for Zephyr RTOS C/C++ drivers using Zephyr’s device model best practices. Use for creating or updating drivers, including devicetree bindings, driver implementation, device API wiring, instantiation macros, Kconfig/CMake integration, and test strategy using native_sim and bus emulators.
---

# Zephyr Driver Development

Follow the full driver lifecycle in order. Keep edits small and testable.

## 1) Clarify scope, project structure and expectations

- Identify the Zephyr subsystem (sensor, flash, gpio, etc.).
- Confirm target bus (I2C, SPI, etc.) and required devicetree properties.
- Decide whether a custom public API is needed; prefer existing subsystem APIs (informed by step 2)
- Clarify the project structure, make sure $ZEPHYR_BASE is set and visible and the Zephyr Module root

> [!NOTE] Always look at the in-tree Zephyr drivers before doing any work
>
> - There might be already a driver that (best scenario at the top):
>   1. Is exactly the same part as the one you are working
>   2. Targets very similar part but not the exact one (can be assumed by how similar the names are) and your part vendor wrote
>   3. Is the same device subsystem as yours (most common)
> - If a reference driver is found, ALWAYS copy the source files, remove unecessary code and leave out the function definitions/declarations + Macro devicetree defines and start with that as a skeleton.
> - Re-use these files/folders whenever possible:
>   - Bindings
>   - C Source files for device-specific driver implementations
>   - Samples and test applications

- Here are the relevant folders to search for examples

```sh $ZEPHYR_BASE/
├── drivers # Device-specific sources. Search here first
├── dts/bindings
├── include # Device API and subsystem API headers
├── samples
└── tests
```

Use `references/zephyr_nav_search.md` for more info on navigating and searching the Zephyr repo

## 2) Layout the driver files that will be created and changed for the new driver

- Define the location of the folder for the source files, KConfig and CMake file for the driver and copy the reference driver to this location
- Similarly, define the location of the DTS binding and copy the reference DTS binding to this location
- Define any addition/changes to the `include/`, `samples` and `tests` folder but do not add them yet. This will need to be done after the implementation is drafted

> [!EXAMPLE] Example driver files layout

```sh $MODULE_ROOT: application module root
.
|-- CMakeLists.txt
|-- drivers
|   |-- CMakeLists.txt
|   |-- lock # Lock drivers folder
|       |-- CMakeLists.txt # Lock drivers CMake file
|       |-- Kconfig # Lock drivers Kconfig file
|       |-- Kconfig.servo # Kconfig for lock-servo
|       |-- servo.c # Driver for lock-servo
|-- dts
    |-- bindings
        |-- lock
            |-- lock-servo.yaml # Devicetree bindings for lock-servo
```

## 3) Create devicetree bindings (YAML)

- Place bindings under `<MODULE_ROOT>/dts/bindings/`.
- Ensure `compatible` is correct; it is the lookup key.
- Define required/optional properties and defaults.
- Use correct devicetree data types.

Key properties to support:

- `compatible`, `reg`, `status`
- Include bus-specific semantics for `reg` (e.g., I2C address, SPI CS index).

```yaml
description: Lock driven by a servo
compatible: "lock-servo"
include: base.yaml

properties:
  pwms:
    required: true
    type: phandle-array
    description: |
      PWM specifier driving the servo motor.

open-pulse-us:
  required: true
  type: int
  description: |
    Lock open position pulse width (microseconds).

closed-pulse-us:
  required: true
  type: int
  description: |
    Lock closed position pulse width (microseconds).
```

## 4) Create the C driver main source files

Implement the following 6 core pieces:

1. Add `DT_DRV_COMPAT` at the top of the file with same compatible string as the one from the main driver file
2. **Immutable config struct**: device properties derived from devicetree.
3. **Mutable data struct**: runtime state + kernel primitives.

```C ROOT/drivers/lock/lock_servo.c
//1
#define DT_DRV_COMPAT lock_servo

//2
/** @brief Servo config. */
struct lock_servo_config {
    /* PWM specifier for servo motor */
    struct pwm_dt_spec servo;
    ...
}
//3
/** @brief Servo data. */
struct lock_servo_data {
    /* Servo current position in degrees */
	uint16_t  pos_theta;
    /*Kernel semaphore with 1 as count. Acts as a lightweight lock*/
    struct k_sem sem;
    ...
}
```

> [!NOTE] Use macros only to define the config struct at **compile time** using `DT_INST_PROP()` to get properties from the devicetree.
> Use `<SPI|I2C|GPIO>_DT_SPEC_*` to get the bus peripheral instance.

4. **DEVICE_API**: Implement the device's class/subsystem API

```C

//4
static int lock_servo_open(const struct device *dev)
{
	const struct lock_servo_config *config = dev->config;

	return servo_set_pulse(dev, config->open_pulse_us);
}

static int lock_servo_close(const struct device *dev)
{
	const struct lock_servo_config *config = dev->config;

	return servo_set_pulse(dev, config->closed_pulse_us);
}

static DEVICE_API(lock, lock_servo_api) = {
	.open = lock_servo_open,
	.close = lock_servo_close,
};
```

> [!NOTE] If no device class exists that is compatible with the driver we need to define our own DEVICE_API

```C ROOT/include/app/drivers/lock.h
typedef int (*lock_open_t)(const struct device *dev);
typedef int (*lock_close_t)(const struct device *dev);

__subsystem struct lock_driver_api {
	lock_open_t open;
	lock_close_t close;
};
```

And include in the source file and define the Device API with it:

```C
static const struct lock_driver_api lock_servo_api = {
    .open = lock_servo_open,
    .close = lock_servo_close,
};
```

5. Implement the `init_fn`to do only device initialization and configuration

```C
//5
static int lock_servo_init(const struct device *dev)
{
	const struct lock_servo_config *config = dev->config;
	int ret;

	if (!pwm_is_ready_dt(&config->servo)) {
		LOG_ERR("Servo PWM controller not ready");
		return -ENODEV;
	}

	if (!adc_is_ready_dt(&config->adc)) {
		LOG_ERR("Servo feedback ADC device not ready");
		return -ENODEV;
	}

	ret = adc_channel_setup_dt(&config->adc);
	if (ret < 0) {
		LOG_ERR("Could not configure ADC cannel (%d)", ret);
		return ret;
	}

	return 0;
}
```

6. Define your device with `DEVICE_DT_INST_DEFINE()` macro. The macro takes in the following params:

```C <zephyr/device.h>
 * @param inst Instance number
 * @param init_fn Pointer to the device's initialization function, which will be
 * run by the kernel during system initialization. Can be `NULL`.
 * @param pm Pointer to the device's power management resources, a
 * @ref pm_device, which will be stored in @ref device.pm. Use `NULL` if the
 * device does not use PM.
 * @param data Pointer to the device's private mutable data, which will be
 * stored in @ref device.data.
 * @param config Pointer to the device's private constant data, which will be
 * stored in @ref device.config field.
 * @param level The device's initialization level (PRE_KERNEL_1, PRE_KERNEL_2 or
 * POST_KERNEL).
 * @param prio The device's priority within its initialization level. See
 * SYS_INIT() for details.
 * @param api Pointer to the device's API structure. Can be `NULL`.
 */
#define DEVICE_DT_INST_DEFINE(inst, init_fn, pm, data, config, \
				level, prio, api, ...)
```

> [!IMPORTANT] Always use the auto-generated instance number created by the macro `DT_INST_FOREACH_STATUS_OKAY()` for `inst`
> Additionally default to using:
>
> - init level = `POST_KERNEL`
> - priority = 90

```C lock_servo.c
//6
/* PWM specifier is initialized using PWM_DT_INST_SPEC_GET() */
#define LOCK_SERVO_DEFINE(i)
    static comst struct lock_servo_config lock_servo_config_##i = {
    .servo = PWM_DT_INST_SPEC_GET(i),
    ...
	};                                                                     \
                                                                               \
	DEVICE_DT_INST_DEFINE(i, lock_servo_init, NULL, NULL,                  \
			      &lock_servo_config_##i, POST_KERNEL,             \
			      CONFIG_LOCK_INIT_PRIORITY, &lock_servo_api);

DT_INST_FOREACH_STATUS_OKAY(LOCK_SERVO_DEFINE)

```

7. Optional:

- Include PM hooks if needed (`PM_DEVICE_DT_INST_DEFINE`).

## Tips

- Use the macro utilities in `ZEPHYR_BASE/include/zephyr/sys/` and to generate masks, set and get fields in registers and any other bitwise operation. Here's the ones to definitely use:

```C zephyr/sys/util.h
/**
 * @brief Create a contiguous bitmask starting at bit position @p l
 *        and ending at position @p h.
 */
#define GENMASK(h, l) (((~0UL) - (1UL << (l)) + 1) & (~0UL >> (BITS_PER_LONG - 1 - (h))))
```

```C zephyr/sys/util_macro.h
/**
* @brief Extract a bitfield element from @p value corresponding to
*      the field mask @p mask.
*/
#define FIELD_GET(mask, value)  (((value) & (mask)) / LSB_GET(mask))

/**
* @brief Prepare a bitfield element using @p value with @p mask representing
*      its field position and width. The result should be combined
*      with other fields using a logical OR.
*/
#define FIELD_PREP(mask, value) (((value) * LSB_GET(mask)) & (mask))
```

> [!INFO] DT_INST_PROP has many variants and for specific data types or use case so be mindful of what data type are the properties as defined in the bindings yaml file.
> Search the zephyr/devicetree.h in ZEPHYR_BASE/include/zephyr for the entire API

```C zephyr/devicetree.h
/**
* @brief Get a devicetree property value
*
* For properties whose bindings have the following types, this macro
* expands to:
*
* - string: a string literal
* - boolean: `0` if the property is false, or `1` if it is true
* - int: the property's value as an integer literal
* - array, uint8-array, string-array: an initializer expression in braces,
*   whose elements are integer or string literals (like `{0, 1, 2}`,
*   `{"hello", "world"}`, etc.)
* - phandle: a node identifier for the node with that phandle
*
* A property's type is usually defined by its binding. In some
* special cases, it has an assumed type defined by the devicetree
* specification even when no binding is available: `compatible` has
* type string-array, `status` has type string, and
* `interrupt-controller` has type boolean.
*
* For other properties or properties with unknown type due to a
* missing binding, behavior is undefined.
*
* For usage examples, see DT_PATH(), DT_ALIAS(), DT_NODELABEL(),
* and DT_INST() above.
*
* @param node_id node identifier
* @param prop lowercase-and-underscores property name
* @return a representation of the property's value
*/
#define DT_PROP(node_id, prop) DT_CAT3(node_id, _P_, prop)
```

## 6) Create a driver emulator for testing

- Emulators typically consist of a single C source.
- Similar to defining a device driver

```C
DEVICE_DT_DEFINE(node_id, init_fn, pm, data, config, level, prio, api)
EMUL_DT_DEFINE(node_id, init_fn, data, cfg, bus_api, backend_api)
```

- Parameters specific to emulators
  - `bus_api` - bus messaging (required)
  - `backend_api` - test scenario setup (optional but useful)
- Create a new file called `<PART>_emul.c` and add the following:
  - Add `DT_DRV_COMPAT` at the top of the file with same compatible string as the one from the main driver file
  - `EMUL_DT_INST_DEFINE` at the bottom

> [!EXAMPLE] Creating an emulator - 12C bus_api example

```C
akm@9918c_emul_transfer_i2c(const struct emul *target, struct i2c_msg *msgs, int num_msgs, int addr){

    if (is_read) {

    /* handle register read */
    } else if (is_write) {

    /* handle register write */

    else {
    /* handle unknown case */
    }
}
```

## 6) Kconfig

- Add a `config` entry with:
  - `depends on DT_HAS_<COMPAT>_ENABLED`
  - `select` required subsystems (GPIO, SPI, etc.).
  - Provide helpful `help` text.

```kconfig $ROOT/drivers/lock/Kconfig
menuconfig LOCK
bool "Locks"

if LOCK
# define lock logging module
module = LOCK
module-str = lock
source "subsys/logging/Kconfig.template.log_config" # define lock drivers init priority

config LOCK_INIT_PRIORITY
    int "Lock init priority"
    default 90
    help Lock initialization priority.

# include each implementation's Kconfig
rsource "Kconfig.servo"
endif # LOCK
```

```kconfig $ROOT/drivers/lock/Kconfig.servo

config LOCK_SERVO
    bool "Servo-controlled lock"
    default y
    depends on DT_HAS_LOCK_SERVO_ENABLED
    select PWM
    select ADC
    help
        Enables a servo-controlled lock driver
```

## 7) CMake integration

- Add driver folder to parent CMake:
  - `add_subdirectory_ifdef(CONFIG_<DRIVER> <driver-dir>)`
- In driver CMake:
  - `zephyr_library()`
  - `zephyr_library_sources(<driver>.c)`
- If driver class uses a single library, prefer `zephyr_library_amend`.

## 8) Testing strategy (native_sim + emulators)

Use `references/testing.md` for emulator + native_sim guidance:

- Use `references/app-development.md` to create a minimal test/sample app for the driver.
- Use `native_sim` to run tests in a deterministic POSIX executable.
- Use bus emulators (I2C/SPI/eSPI/MSPI) for driver-level testing without HW.
- Reuse the same devicetree nodes as the real driver (`DT_DRV_COMPAT` must match).
- Add emulator backend APIs for test control where needed.

## 9) Final checks

- Ensure all devicetree bindings are valid and referenced.
- Ensure Kconfig and CMake are wired into the build.
- Ensure `DT_INST_FOREACH_STATUS_OKAY` instantiates devices.
- Ensure tests run on `native_sim` and emulate failure cases.

```cmake $ROOT/CMakeLists.txt
add_subdirectory(drivers)

zephyr_include_directories(include)
# optional, only needed for userspace support
zephyr_syscall_include_directories(include)
```

```cmake $ROOT/drivers/CMakeLists.txt
add_subdirectory_ifdef(CONFIG_LOCK lock)
```

```cmake $ROOT/drivers/lock/CMakeLists.txt
zephyr_library()
zephyr_library_sources_ifdef (CONFIG_LOCK_SERVO servo.c)
```

## References

- `references/testing.md` — native_sim and bus emulator testing patterns
- `references/app-development.md` — minimal app structure for driver samples/tests
- `references/zephyr_nav_search.md` — List of Zephyr in-tree driver subfolders for source, samples and test search
