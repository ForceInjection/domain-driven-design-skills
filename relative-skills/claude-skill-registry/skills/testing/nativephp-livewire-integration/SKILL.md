---
name: NativePHP Livewire Integration
description: This skill should be used when the user asks about "livewire nativephp", "livewire native event", "#[OnNative]", "livewire camera", "livewire component native", "livewire geolocation", "livewire biometrics", "handle native event in livewire", "livewire photo upload", "livewire scanner", or needs to integrate NativePHP native functionality into Livewire components.
version: 0.1.0
---

# NativePHP Livewire Integration

This skill provides guidance for integrating NativePHP native functionality into Livewire components, including event handling, API usage, and best practices.

## Overview

Livewire components are the primary way to build interactive NativePHP Mobile apps. Native events are dispatched via JavaScript injection and can be listened to using Livewire attributes.

## Event Listening Pattern

### Using #[OnNative] Attribute (REQUIRED)

NativePHP provides a custom `#[OnNative]` attribute that MUST be used for listening to native events. This is cleaner and more reliable than the raw Livewire `#[On]` attribute.

```php
use Livewire\Component;
use Native\Mobile\Attributes\OnNative;
use Native\Mobile\Events\Camera\PhotoTaken;
use Native\Mobile\Events\Camera\PhotoCancelled;

class PhotoUploader extends Component
{
    public ?string $photoPath = null;

    #[OnNative(PhotoTaken::class)]
    public function handlePhotoTaken(string $path, string $mimeType = 'image/jpeg', ?string $id = null)
    {
        $this->photoPath = $path;
        // Process the photo
    }

    #[OnNative(PhotoCancelled::class)]
    public function handlePhotoCancelled(bool $cancelled = true, ?string $id = null)
    {
        session()->flash('info', 'Photo capture was cancelled');
    }
}
```

**IMPORTANT**: Always use `#[OnNative(EventClass::class)]` - NEVER use the raw `#[On('native:...')]` syntax. The `OnNative` attribute automatically handles the `native:` prefix and event class resolution.

## Complete Camera Example

```php
namespace App\Livewire;

use Livewire\Component;
use Native\Mobile\Attributes\OnNative;
use Native\Mobile\Events\Camera\PhotoTaken;
use Native\Mobile\Events\Camera\PhotoCancelled;
use Native\Mobile\Events\Gallery\MediaSelected;
use Native\Mobile\Facades\Camera;

class AvatarUploader extends Component
{
    public ?string $avatarPath = null;
    public ?string $avatarUrl = null;

    public function takePhoto()
    {
        Camera::getPhoto()
            ->id('avatar-' . auth()->id())
            ->remember()
            ->start();
    }

    public function pickFromGallery()
    {
        Camera::pickImages()
            ->images()
            ->single()
            ->id('avatar-gallery')
            ->remember()
            ->start();
    }

    #[OnNative(PhotoTaken::class)]
    public function handlePhotoTaken(string $path, string $mimeType, ?string $id)
    {
        if (str_starts_with($id, 'avatar-')) {
            $this->processAvatar($path);
        }
    }

    #[OnNative(MediaSelected::class)]
    public function handleMediaSelected(bool $success, array $files, int $count, ?string $error, bool $cancelled, ?string $id)
    {
        if ($success && $count > 0) {
            $this->processAvatar($files[0]['path']);
        }
    }

    #[OnNative(PhotoCancelled::class)]
    public function handlePhotoCancelled()
    {
        // User cancelled - no action needed
    }

    private function processAvatar(string $path)
    {
        // Move to permanent storage
        $filename = 'avatars/' . auth()->id() . '_' . time() . '.jpg';
        Storage::disk('public')->put($filename, file_get_contents($path));

        $this->avatarPath = $filename;
        $this->avatarUrl = Storage::disk('public')->url($filename);

        // Update user record
        auth()->user()->update(['avatar' => $filename]);
    }

    public function render()
    {
        return view('livewire.avatar-uploader');
    }
}
```

Blade template:

```blade
<div>
    <div class="avatar-container">
        @if($avatarUrl)
            <img src="{{ $avatarUrl }}" alt="Avatar" class="avatar">
        @else
            <div class="avatar-placeholder">No Photo</div>
        @endif
    </div>

    <div class="button-group">
        <button wire:click="takePhoto" type="button">
            Take Photo
        </button>
        <button wire:click="pickFromGallery" type="button">
            Choose from Gallery
        </button>
    </div>
</div>
```

## QR Scanner Example

```php
namespace App\Livewire;

use Livewire\Component;
use Native\Mobile\Attributes\OnNative;
use Native\Mobile\Events\Scanner\CodeScanned;
use Native\Mobile\Facades\Scanner;

class ProductScanner extends Component
{
    public array $scannedProducts = [];

    public function startScanning()
    {
        Scanner::scan()
            ->prompt('Scan product barcode')
            ->formats(['ean13', 'qr', 'code128'])
            ->continuous(true)
            ->id('product-scanner')
            ->scan();
    }

    #[OnNative(CodeScanned::class)]
    public function handleCodeScanned(string $data, string $format, ?string $id)
    {
        // Look up product
        $product = Product::where('barcode', $data)->first();

        if ($product) {
            $this->scannedProducts[] = [
                'barcode' => $data,
                'name' => $product->name,
                'price' => $product->price,
            ];
        } else {
            session()->flash('warning', "Unknown barcode: {$data}");
        }
    }

    public function render()
    {
        return view('livewire.product-scanner');
    }
}
```

## Biometric Authentication Example

```php
namespace App\Livewire;

use Livewire\Component;
use Native\Mobile\Attributes\OnNative;
use Native\Mobile\Events\Biometric\Completed;
use Native\Mobile\Facades\Biometrics;

class SecureAction extends Component
{
    public bool $authenticated = false;
    public string $pendingAction = '';

    public function performSecureAction(string $action)
    {
        $this->pendingAction = $action;

        Biometrics::prompt()
            ->id('secure-' . $action)
            ->prompt();
    }

    #[OnNative(Completed::class)]
    public function handleBiometricResult(bool $success, ?string $id)
    {
        if ($success) {
            $this->authenticated = true;

            // Execute the pending action
            match($this->pendingAction) {
                'delete-account' => $this->deleteAccount(),
                'export-data' => $this->exportData(),
                'change-password' => $this->showPasswordForm(),
                default => null,
            };
        } else {
            session()->flash('error', 'Authentication failed');
        }

        $this->pendingAction = '';
    }

    // ... action methods
}
```

## Geolocation Example

```php
namespace App\Livewire;

use Livewire\Component;
use Native\Mobile\Attributes\OnNative;
use Native\Mobile\Events\Geolocation\LocationReceived;
use Native\Mobile\Events\Geolocation\PermissionStatusReceived;
use Native\Mobile\Facades\Geolocation;

class LocationTracker extends Component
{
    public ?float $latitude = null;
    public ?float $longitude = null;
    public bool $hasPermission = false;

    public function mount()
    {
        Geolocation::checkPermissions()->get();
    }

    public function requestLocation()
    {
        if (!$this->hasPermission) {
            Geolocation::requestPermissions()->get();
            return;
        }

        Geolocation::getCurrentPosition()
            ->fineAccuracy(true)
            ->id('current-location')
            ->get();
    }

    #[OnNative(PermissionStatusReceived::class)]
    public function handlePermissionStatus(string $location, string $coarseLocation, string $fineLocation)
    {
        $this->hasPermission = in_array($fineLocation, ['granted', 'limited']);
    }

    #[OnNative(LocationReceived::class)]
    public function handleLocationReceived(
        bool $success,
        ?float $latitude,
        ?float $longitude,
        ?float $accuracy,
        ?int $timestamp,
        ?string $provider,
        ?string $error
    ) {
        if ($success) {
            $this->latitude = $latitude;
            $this->longitude = $longitude;
        } else {
            session()->flash('error', $error ?? 'Failed to get location');
        }
    }
}
```

## Dialog Example

```php
namespace App\Livewire;

use Livewire\Component;
use Native\Mobile\Attributes\OnNative;
use Native\Mobile\Events\Alert\ButtonPressed;
use Native\Mobile\Facades\Dialog;

class ItemManager extends Component
{
    public ?int $pendingDeleteId = null;

    public function confirmDelete(int $id)
    {
        $this->pendingDeleteId = $id;

        Dialog::alert(
            'Confirm Delete',
            'Are you sure you want to delete this item?',
            ['Cancel', 'Delete']
        )
            ->id('delete-' . $id)
            ->show();
    }

    #[OnNative(ButtonPressed::class)]
    public function handleDialogResponse(int $index, string $label, ?string $id)
    {
        if (str_starts_with($id, 'delete-') && $label === 'Delete') {
            $itemId = (int) str_replace('delete-', '', $id);
            Item::find($itemId)?->delete();
            session()->flash('success', 'Item deleted');
        }

        $this->pendingDeleteId = null;
    }
}
```

## Audio Recording Example

```php
namespace App\Livewire;

use Livewire\Component;
use Native\Mobile\Attributes\OnNative;
use Native\Mobile\Events\Microphone\MicrophoneRecorded;
use Native\Mobile\Events\Microphone\MicrophoneCancelled;
use Native\Mobile\Facades\Microphone;

class VoiceNote extends Component
{
    public bool $isRecording = false;
    public ?string $recordingPath = null;

    public function startRecording()
    {
        Microphone::record()
            ->id('voice-note')
            ->remember()
            ->start();

        $this->isRecording = true;
    }

    public function stopRecording()
    {
        Microphone::stop();
        $this->isRecording = false;
    }

    #[OnNative(MicrophoneRecorded::class)]
    public function handleRecordingComplete(string $path, string $mimeType, ?string $id)
    {
        $this->recordingPath = $path;
        $this->isRecording = false;

        // Save to storage
        $filename = 'recordings/' . auth()->id() . '_' . time() . '.m4a';
        Storage::put($filename, file_get_contents($path));
    }

    #[OnNative(MicrophoneCancelled::class)]
    public function handleRecordingCancelled()
    {
        $this->isRecording = false;
    }
}
```

## Push Notification Enrollment

```php
namespace App\Livewire;

use Livewire\Component;
use Native\Mobile\Attributes\OnNative;
use Native\Mobile\Events\PushNotification\TokenGenerated;
use Native\Mobile\Facades\PushNotifications;

class NotificationSettings extends Component
{
    public bool $enrolled = false;

    public function enrollForNotifications()
    {
        PushNotifications::enroll()
            ->id('main')
            ->enroll();
    }

    #[OnNative(TokenGenerated::class)]
    public function handleTokenGenerated(string $token, ?string $id)
    {
        // Store token on your server
        auth()->user()->update(['push_token' => $token]);

        $this->enrolled = true;
        session()->flash('success', 'Push notifications enabled');
    }
}
```

## Safe Area in Livewire Layouts

Apply safe area handling in your Livewire layout:

```blade
<!DOCTYPE html>
<html>
<head>
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
    @livewireStyles
</head>
<body class="nativephp-safe-area">
    {{ $slot }}

    @livewireScripts
</body>
</html>
```

## Best Practices

1. **ALWAYS use #[OnNative(EventClass::class)]** - This is the required pattern, not `#[On('native:...')]`. The `OnNative` attribute from `Native\Mobile\Attributes\OnNative` automatically handles the `native:` prefix.

2. **Track requests with IDs** - Correlate async requests with responses:
   ```php
   Camera::getPhoto()->id('unique-id')->remember()->start();
   ```

3. **Handle cancellations** - Always handle cancelled events gracefully

4. **Check permissions first** - For location, camera, etc., check/request permissions before use

5. **Use session flashing** - For user feedback on native operations

6. **Clean up temporary files** - Move captured media to permanent storage

## Available Facades

All NativePHP Facades are in `Native\Mobile\Facades\`:

| Facade | Description |
|--------|-------------|
| `Biometrics` | Face ID / fingerprint authentication |
| `Browser` | Open URLs, in-app browser, OAuth |
| `Camera` | Photo capture, video recording, gallery picker |
| `Device` | Device info, vibration, flashlight |
| `Dialog` | Native alerts and toasts |
| `File` | File operations |
| `Geolocation` | GPS location, permissions |
| `Haptics` | Haptic feedback |
| `Microphone` | Audio recording |
| `Network` | Network status |
| `PushNotifications` | Push notification enrollment |
| `Scanner` | QR/barcode scanning |
| `SecureStorage` | Encrypted key-value storage |
| `Share` | Native share sheet |
| `System` | Platform detection, app settings |

## Available Events

All events are in `Native\Mobile\Events\`:

| Event | Parameters |
|-------|------------|
| `Camera\PhotoTaken` | `string $path`, `string $mimeType`, `?string $id` |
| `Camera\PhotoCancelled` | `bool $cancelled`, `?string $id` |
| `Camera\VideoRecorded` | `string $path`, `string $mimeType`, `?string $id` |
| `Camera\VideoCancelled` | `bool $cancelled`, `?string $id` |
| `Gallery\MediaSelected` | `bool $success`, `array $files`, `int $count`, `?string $error`, `bool $cancelled`, `?string $id` |
| `Scanner\CodeScanned` | `string $data`, `string $format`, `?string $id` |
| `Biometric\Completed` | `bool $success`, `?string $id` |
| `Alert\ButtonPressed` | `int $index`, `string $label`, `?string $id` |
| `Geolocation\LocationReceived` | `bool $success`, `?float $latitude`, `?float $longitude`, `?float $accuracy`, `?int $timestamp`, `?string $provider`, `?string $error`, `?string $id` |
| `Geolocation\PermissionStatusReceived` | `string $location`, `string $coarseLocation`, `string $fineLocation`, `?string $id` |
| `Geolocation\PermissionRequestResult` | (varies) |
| `Microphone\MicrophoneRecorded` | `string $path`, `string $mimeType`, `?string $id` |
| `Microphone\MicrophoneCancelled` | `bool $cancelled`, `?string $id` |
| `PushNotification\TokenGenerated` | `string $token`, `?string $id` |
| `App\UpdateInstalled` | (varies) |

## Fetching Live Documentation

For detailed Livewire integration:

- **Events**: `https://nativephp.com/docs/mobile/2/the-basics/events`
- **APIs**: `https://nativephp.com/docs/mobile/2/apis/overview`

Use WebFetch to retrieve the latest patterns and examples.
