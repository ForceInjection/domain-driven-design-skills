---
name: zephyr-driver-development
description: Full development cycle for Zephyr RTOS C/C++ drivers using Zephyr’s device model best practices. Use for creating or updating drivers, including devicetree bindings, driver implementation, device API wiring, instantiation macros, Kconfig/CMake integration, and test strategy using native_sim and bus emulators.
---

# Zephyr Driver Development

Follow the full driver lifecycle in order. Keep edits small and testable.

## Preparation

### 1) Clarify scope, project structure and expectations

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

### 2) Layout the driver files that will be created and changed for the new driver

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

## Implementation

> [!info] TLDR
>
> - Create new DTS bindings for hardware properties
> - Implement C Driver conforming to a existing subsystem device
> - Add Kconfig file for driver SW options
> - Integrate driver code with CMake
> - Optionally declare CUSTOM public API in header file

Example end-product file layout:
![[res/Driver_file_layout.jpeg]]

### Write DTS Bindings

Pretty straightforward and simple. The DTS bindings is a contract for you and other people to know how to define your device as a `dts` node.
The binding is written in `yaml` and **MUST** be inside `<ZEPHYR_MODULE>/dts/bindings/` folder to be recognized by Zephyr. The Zephyr module can be any repo that follows the structure expected by Zephyr.

The DTS bindings `yaml` file follows a somewhat loose specification defined mostly in the docs but also in code. The python script that parses the bindings expects **only** the `compatible` entry.

#### Important `Devicetree` properties

| Property   | Description                                                                                                                                                                       |
| ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| compatible | Name of the hardware a node represents, typically vendor,device. Used to find the bindings for the node.                                                                          |
| reg        | Information used to address the device (optional ONLY IF ONE DEVICE INSTANCE IS USED). Value meaning depends on the device. In general, it is a sequence of address-length pairs. |
| status     | Status of the device. okay (default if not specified) or disabled                                                                                                                 |

> [!info] The meaning of the `reg` property changes depending on the peripheral
>
> - In SPI this value is the index of the CS GPIO defined in **the phandle array of the cs-gpio property of the SPI instance**
> - In I2C this value is simply the I2C address of the device in the I2C bus
> - Etc,… look at the bindings for other peripherals that support multiple instances of devices

#### `Devicetree`data types

| Type            | Example                            |
| --------------- | ---------------------------------- |
| `string`        | `my-string = “hello,world”       ` |
| `int`           | `my-int = <1>                    ` |
| `boolean`       | `enable-my-feature;              ` |
| `array`         | `my-ints = <0xdeadbeef 1234 0>;  ` |
| `uint8-array`   | `my-bytes = [00 01 ab];          ` |
| `string-array`  | `my-strings = “str1”, “str2”;    ` |
| `phandle`       | `my-uart = <&uart0>;             ` |
| `phandles`      | `my-uarts = <&uart0 &uart1>;     ` |
| `phandle-array` | `io-channels = <&adc 0>, <&adc 1>` |

The entries string value will be used to match the device's `dts` node representation to the Driver C Implementation. A simple example below:

```yaml
title: Test binding

description: Property default value test

compatible: "defaults"

properties:
  int:
    type: int
    required: false
    default: 123

  array:
    type: array
    required: false
    default: [1, 2, 3]

  uint8-array:
    type: uint8-array
    required: false
    default: [0x89, 0xAB, 0xCD]

  string:
    type: string
    required: false
    default: "hello"

  string-array:
    type: string-array
    required: false
    default: ["hello", "there"]

  default-not-used:
    type: int
    required: false
    default: 123

examples:
  - |
    / {
        leds {
            compatible = "gpio-leds";

            uled: led {
                gpios = <&gpioe 12 GPIO_ACTIVE_HIGH>;
            };
        };

        aliases {
            led0 = &uled;
        };
    };
```

> [!info] The compatible field is the most important to get right, that will be used to match a driver to a binding. Usually the compatible string is going to have this format `“VENDOR,DEVICE”` in the YAML file and as a C macro it will become `”VENDOR_DEVICE”`

### Write a Driver C Implementation

> [!summary] 3 major things to write:
>
> - Immutable config structure
> - Mutable Data structure
> - Device API implementation

#### Configuration Structure

This structure is **immutable** and most of the values should be assigned in the devicetree as properties or derived from those values

```c


struct flash_at25xv021a_config {
	struct spi_dt_spec spi;
#if ANY_DEV_HAS_WP_GPIO
	struct gpio_dt_spec wp_gpio;
#endif /* ANY_DEV_HAS_WP_GPIO */
#if defined(CONFIG_FLASH_PAGE_LAYOUT)
	struct flash_pages_layout pages_layout;
#endif /* defined(CONFIG_FLASH_PAGE_LAYOUT) */
	struct flash_parameters parameters;
	uint8_t jedec_id[3];
	size_t size;
	k_timeout_t timeout;
	bool read_only;
	bool ultra_deep_sleep;
#if ANY_DEV_WRITEABLE
	size_t page_size;
	k_timeout_t timeout_erase;
#endif /* ANY_DEV_WRITEABLE */
};
```

#### Data Structure

This structure is mutable and should contain any necessary kernel primitives such as semaphores, mutex, etc

```c
struct flash_at25xv021a_data {
	struct k_mutex lock;
};

```

#### Device API

Depending on the driver, there will be API needed to interact with the IO-mapped peripherals. In this example it is SPI. Zephyr has a SPI API out-of-the-box but for other more niche peripherals it might not

```c
static int flash_at25xv021a_read_status(const struct device *dev, uint8_t *status)
{
	int err;
	uint8_t sr[2];
	uint8_t cmd[2] = {DEV_READ_SR, DEV_DUMMY_BYTE};
	const struct flash_at25xv021a_config *config = dev->config;
	const struct spi_buf tx_buf = {.buf = cmd, .len = ARRAY_SIZE(cmd)};
	const struct spi_buf_set tx = {.buffers = &tx_buf, .count = 1};
	const struct spi_buf rx_buf = {.buf = sr, .len = ARRAY_SIZE(sr)};
	const struct spi_buf_set rx = {.buffers = &rx_buf, .count = 1};

	err = spi_transceive_dt(&config->spi, &tx, &rx);
	if (err < 0) {
		LOG_ERR("unable to read status register from %s", dev->name);
		return err;
	}

	*status = sr[1];

	return err;
}
```

In most cases the driver can be categorized into a Zephyr supported device model such as "sensor", "flash" , etc. In that case the device can conform to that Device's API by providing the required function implementations
to the `DEVICE_API` macro and giving the device category name with it. In this example it is "flash"

```c
static int flash_at25xv021a_read(const struct device *dev, off_t offset, void *buf, size_t len)
{
	int err;
	struct flash_at25xv021a_data *data = dev->data;
	const struct flash_at25xv021a_config *config = dev->config;

	if (len == 0) {
		LOG_DBG("attempted to read 0 bytes from %s", dev->name);
		return 0;
	}

	if (len > config->size) {
		LOG_ERR("attempted to read more than device %s size: %u", dev->name, config->size);
		return -EINVAL;
	}

	k_mutex_lock(&data->lock, K_FOREVER);

	err = flash_at25xv021a_read_internal(dev, offset, buf, len);

	k_mutex_unlock(&data->lock);

	return err;
}


static int flash_at25xv021a_spi_write(const struct device *dev, const struct spi_dt_spec *spi,
				      const struct spi_buf_set *tx)
{
    ...
}

....

static DEVICE_API(flash, spi_flash_at25xv021a_api) = {
	.read = flash_at25xv021a_read,
	.write = flash_at25xv021a_write,
	.erase = flash_at25xv021a_erase,
	.get_size = flash_at25xv021a_get_size,
	.get_parameters = flash_at25xv021a_get_parameters,
#if defined(CONFIG_FLASH_PAGE_LAYOUT)
	.page_layout = flash_at25xv021a_pages_layout,
#endif
};

```

#### Device Instance Definition

Finally the device needs to be instantiated through the Zephyr 'macrobatics'. The macro below is going to instantiate this device driver **for each device node in the devicetree that has status "okay"**.
That's what `DT_INST_FOREACH_STATUS_OKAY` does. The `DEVICE_DT_INST_DEFINE` is then compiled and that is what instantiates the device.

```c
#define SPI_FLASH_AT25XV021A_DEFINE(inst)                                                          \
                                                                                                   \
	ASSERT_SIZE(DT_INST_PROP(inst, size));                                                     \
	ASSERT_PAGE_SIZE(DT_INST_PROP(inst, page_size));                                           \
	ASSERT_TIMEOUTS(DT_INST_PROP(inst, timeout), DT_INST_PROP(inst, timeout_erase));           \
                                                                                                   \
	static const struct flash_at25xv021a_config flash_at25xv021a_config_##inst = {             \
		.spi = SPI_DT_SPEC_INST_GET(inst, SPI_OP),                                         \
		.jedec_id = DT_INST_PROP(inst, jedec_id),                                          \
		.size = DT_INST_PROP(inst, size),                                                  \
		.timeout = K_MSEC(DT_INST_PROP(inst, timeout)),                                    \
		.read_only = DT_INST_PROP(inst, read_only),                                        \
		.ultra_deep_sleep = DT_INST_PROP(inst, ultra_deep_sleep),                          \
		.parameters =                                                                      \
			{                                                                          \
				.write_block_size = DT_INST_PROP(inst, page_size),                 \
				.erase_value = 0xff,                                               \
			},                                                                         \
		WP_GPIO_IF_PROVIDED(inst) PAGES_LAYOUT_IF_ENABLED(inst)                            \
			PAGE_SIZE_IF_WRITEABLE(inst) TIMEOUT_ERASE_IF_WRITEABLE(inst)};            \
                                                                                                   \
	static struct flash_at25xv021a_data flash_at25xv021a_data_##inst;                          \
                                                                                                   \
	PM_DEVICE_DT_INST_DEFINE(inst, flash_at25xv021a_pm_action);                                \
                                                                                                   \
	DEVICE_DT_INST_DEFINE(inst, flash_at25xv021a_init, PM_DEVICE_DT_INST_GET(inst),            \
			      &flash_at25xv021a_data_##inst, &flash_at25xv021a_config_##inst,      \
			      POST_KERNEL, CONFIG_FLASH_INIT_PRIORITY, &spi_flash_at25xv021a_api);

DT_INST_FOREACH_STATUS_OKAY(SPI_FLASH_AT25XV021A_DEFINE)


```

The following parameters taken by the device instantiation are explained in the comment below from `<zephyr/device.h>`

```c
 * @brief Create a device object from a devicetree node identifier and set it up
 * for boot time initialization.
 *
 * @param node_id The devicetree node identifier.

 * @param init_fn Pointer to the device's initialization function, which will be
 * run by the kernel during system initialization. Can be `NULL`.

 * @param deinit_fn Pointer to the device's de-initialization function. Can be
 * `NULL`. It must release any acquired resources (e.g. pins, bus, clock...) and
 * leave the device in its reset state.

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

```

### Kconfig

Example Kconfig file of a sensor driver:

```kconfig title=$ROOT/drivers/sensors/jm101/Kconfig
config JM101
	bool "JM-101 fingerprint sensor"
	default y
	# Depends on being enabled in DT
	depends on DT_HAS_ZEANTEC_JM101_ENABLED
	# Software Dependencies (selected)
	select GPIO
	select SERIAL
	select UART_INTERRUPT_DRIVEN
	help
		JM-101 fingerprint sensor.
```

If the device driver is of it own class then a little more work is needed including define a module and module-str for logging and defining a `INIT_PRIORITY` for the device class drivers

```kconfig title=$ROOT/drivers/lock/Kconfig
menuconfig LOCK
    bool "Locks"

if LOCK
# define lock logging module
module = LOCK
module-str = lock
source "subsys/logging/Kconfig.template.log_config"

# define lock drivers init priority
config LOCK_INIT_PRIORITY
    int "Lock init priority"
    default 90
    help
        Lock initialization priority.

# include each implementation's Kconfig
rsource "Kconfig.servo"

endif # LOCK

```

### CMake

Include driver folder if enabled

```CMake ROOT/drivers/sensor/CMakeLists.txt
add_subdirectory_ifdef(CONFIG_JM101 jm101)
```

create a new Zephyr library, add driver sources to it

```CMake ROOT/drivers/sensor/jm101/CMakeLists.txt
zephyr_library()
zephyr_library_sources (jm101.c)
```

> [!warning ] Beware on Single Library Devices
> Some driver classes have a single library, typically drivers where a single implementation is chosen. In such cases, `zephyr_library_amend` should be used instead.

## References

- `references/testing.md` — native_sim and bus emulator testing patterns
- `references/app-development.md` — minimal app structure for driver samples/tests
- `references/zephyr_nav_search.md` — List of Zephyr in-tree driver subfolders for source, samples and test search
