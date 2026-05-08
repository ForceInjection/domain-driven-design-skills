---
name: ha-emby-media-player
description: Use when implementing Emby MediaPlayerEntity - covers all supported features, state management, playback control, media browsing, image handling, and Emby-specific API mappings for Home Assistant media player integration.
---

# Home Assistant Emby Media Player Entity

## Overview

**Implement MediaPlayerEntity following HA patterns with Emby API mappings.**

This covers supported features, state machine, properties, async methods, and Emby-specific implementation details.

## Entity Structure

```python
"""Emby media player entity."""
from __future__ import annotations

from homeassistant.components.media_player import (
    BrowseMedia,
    MediaPlayerEntity,
    MediaPlayerEntityFeature,
    MediaPlayerState,
    MediaType,
)

from .coordinator import EmbyDataUpdateCoordinator
from .entity import EmbyEntity
from .models import EmbySession


class EmbyMediaPlayer(EmbyEntity, MediaPlayerEntity):
    """Representation of an Emby media player."""

    _attr_device_class = MediaPlayerDeviceClass.TV  # or SPEAKER/RECEIVER
    _attr_supported_features = (
        MediaPlayerEntityFeature.PAUSE
        | MediaPlayerEntityFeature.PLAY
        | MediaPlayerEntityFeature.STOP
        | MediaPlayerEntityFeature.VOLUME_SET
        | MediaPlayerEntityFeature.VOLUME_MUTE
        | MediaPlayerEntityFeature.PREVIOUS_TRACK
        | MediaPlayerEntityFeature.NEXT_TRACK
        | MediaPlayerEntityFeature.SEEK
        | MediaPlayerEntityFeature.PLAY_MEDIA
        | MediaPlayerEntityFeature.BROWSE_MEDIA
    )

    def __init__(
        self,
        coordinator: EmbyDataUpdateCoordinator,
        session: EmbySession,
    ) -> None:
        """Initialize the media player."""
        super().__init__(coordinator, session.device_id)
        self._session_id = session.session_id
```

## Supported Features

Map Emby capabilities to HA features:

| HA Feature | Emby API | Notes |
|------------|----------|-------|
| PLAY | PlayState/Unpause | Resume playback |
| PAUSE | PlayState/Pause | Pause playback |
| STOP | PlayState/Stop | Stop playback |
| SEEK | PlayState/Seek | PositionTicks |
| VOLUME_SET | SetVolume | 0-100 scale |
| VOLUME_MUTE | ToggleMute | Boolean toggle |
| NEXT_TRACK | PlayState/NextTrack | Next in queue |
| PREVIOUS_TRACK | PlayState/PreviousTrack | Previous in queue |
| PLAY_MEDIA | Play items | By item ID |
| BROWSE_MEDIA | Items endpoint | Library browsing |

## State Machine

```python
@property
def state(self) -> MediaPlayerState | None:
    """Return current state."""
    session = self._get_session()
    if session is None:
        return MediaPlayerState.OFF

    if session.now_playing is None:
        return MediaPlayerState.IDLE

    if session.play_state.is_paused:
        return MediaPlayerState.PAUSED

    return MediaPlayerState.PLAYING
```

**State mapping:**
- No session → OFF
- Session but nothing playing → IDLE
- Playing and paused → PAUSED
- Playing and not paused → PLAYING
- Buffering (if detectable) → BUFFERING

## Properties (Return Cached Data Only)

```python
@property
def media_title(self) -> str | None:
    """Return the title of current media."""
    if (item := self._now_playing) is None:
        return None
    return item.name

@property
def media_artist(self) -> str | None:
    """Return the artist of current media."""
    if (item := self._now_playing) is None:
        return None
    # For music: artist, for TV: series name
    if item.media_type == "Audio":
        return item.album_artist or item.artists[0] if item.artists else None
    if item.media_type == "Episode":
        return item.series_name
    return None

@property
def media_album_name(self) -> str | None:
    """Return the album name of current media."""
    if (item := self._now_playing) is None:
        return None
    return item.album

@property
def media_duration(self) -> int | None:
    """Return the duration of current media in seconds."""
    if (item := self._now_playing) is None:
        return None
    # Emby uses ticks (100ns units)
    return item.run_time_ticks // 10_000_000

@property
def media_position(self) -> int | None:
    """Return the position of current media in seconds."""
    if (state := self._play_state) is None:
        return None
    return state.position_ticks // 10_000_000

@property
def media_position_updated_at(self) -> datetime | None:
    """Return when position was last updated."""
    return self._position_updated_at

@property
def volume_level(self) -> float | None:
    """Return the volume level (0.0 to 1.0)."""
    if (state := self._play_state) is None:
        return None
    # Emby uses 0-100 scale
    return state.volume_level / 100

@property
def is_volume_muted(self) -> bool | None:
    """Return true if volume is muted."""
    if (state := self._play_state) is None:
        return None
    return state.is_muted

@property
def media_content_type(self) -> MediaType | None:
    """Return the content type of current media."""
    if (item := self._now_playing) is None:
        return None
    return self._map_media_type(item.media_type)

@property
def media_content_id(self) -> str | None:
    """Return the content ID of current media."""
    if (item := self._now_playing) is None:
        return None
    return item.item_id

@property
def media_image_url(self) -> str | None:
    """Return the image URL of current media."""
    if (item := self._now_playing) is None:
        return None
    return self._build_image_url(item.item_id, "Primary")

@property
def media_image_remotely_accessible(self) -> bool:
    """Return if image is accessible outside local network."""
    # Emby images require authentication
    return False
```

## Helper Property

```python
@property
def _now_playing(self) -> EmbyNowPlayingItem | None:
    """Get the currently playing item from coordinator."""
    session = self._get_session()
    if session is None:
        return None
    return session.now_playing

@property
def _play_state(self) -> EmbyPlayState | None:
    """Get the play state from coordinator."""
    session = self._get_session()
    if session is None:
        return None
    return session.play_state

def _get_session(self) -> EmbySession | None:
    """Get this player's session from coordinator data."""
    return self.coordinator.data.sessions.get(self._session_id)
```

## Async Action Methods

```python
async def async_play_media(
    self,
    media_type: MediaType,
    media_id: str,
    enqueue: MediaPlayerEnqueue | None = None,
    announce: bool | None = None,
    **kwargs: Any,  # Required by interface
) -> None:
    """Play a piece of media."""
    play_command = "PlayNow"
    if enqueue == MediaPlayerEnqueue.ADD:
        play_command = "PlayLast"
    elif enqueue == MediaPlayerEnqueue.NEXT:
        play_command = "PlayNext"

    await self.coordinator.client.async_play(
        session_id=self._session_id,
        item_ids=[media_id],
        play_command=play_command,
    )

async def async_media_play(self) -> None:
    """Send play command."""
    await self.coordinator.client.async_send_play_command(
        session_id=self._session_id,
        command="Unpause",
    )

async def async_media_pause(self) -> None:
    """Send pause command."""
    await self.coordinator.client.async_send_play_command(
        session_id=self._session_id,
        command="Pause",
    )

async def async_media_stop(self) -> None:
    """Send stop command."""
    await self.coordinator.client.async_send_play_command(
        session_id=self._session_id,
        command="Stop",
    )

async def async_media_next_track(self) -> None:
    """Send next track command."""
    await self.coordinator.client.async_send_play_command(
        session_id=self._session_id,
        command="NextTrack",
    )

async def async_media_previous_track(self) -> None:
    """Send previous track command."""
    await self.coordinator.client.async_send_play_command(
        session_id=self._session_id,
        command="PreviousTrack",
    )

async def async_media_seek(self, position: float) -> None:
    """Seek to position in seconds."""
    position_ticks = int(position * 10_000_000)
    await self.coordinator.client.async_seek(
        session_id=self._session_id,
        position_ticks=position_ticks,
    )

async def async_set_volume_level(self, volume: float) -> None:
    """Set volume level (0.0 to 1.0)."""
    volume_percent = int(volume * 100)
    await self.coordinator.client.async_set_volume(
        session_id=self._session_id,
        volume=volume_percent,
    )

async def async_mute_volume(self, mute: bool) -> None:
    """Mute or unmute volume."""
    await self.coordinator.client.async_set_mute(
        session_id=self._session_id,
        mute=mute,
    )
```

## Media Browsing

```python
async def async_browse_media(
    self,
    media_content_type: MediaType | str | None = None,
    media_content_id: str | None = None,
) -> BrowseMedia:
    """Implement the media browsing capability."""
    if media_content_id is None:
        # Return root level
        return await self._build_root_browse()

    return await self._build_item_browse(media_content_id)

async def _build_root_browse(self) -> BrowseMedia:
    """Build root level browse menu."""
    views = await self.coordinator.client.async_get_views()

    children = [
        BrowseMedia(
            title=view.name,
            media_class=self._map_collection_type(view.collection_type),
            media_content_id=view.item_id,
            media_content_type=view.collection_type,
            can_play=False,
            can_expand=True,
        )
        for view in views
    ]

    return BrowseMedia(
        title="Emby",
        media_class=MediaClass.DIRECTORY,
        media_content_id="",
        media_content_type="root",
        can_play=False,
        can_expand=True,
        children=children,
    )

async def _build_item_browse(self, item_id: str) -> BrowseMedia:
    """Build browse for a specific item."""
    items = await self.coordinator.client.async_get_items(
        parent_id=item_id,
    )

    children = [
        BrowseMedia(
            title=item.name,
            media_class=self._map_media_class(item.media_type),
            media_content_id=item.item_id,
            media_content_type=item.media_type,
            can_play=item.is_playable,
            can_expand=item.is_folder,
            thumbnail=self._build_image_url(item.item_id, "Primary"),
        )
        for item in items
    ]

    return BrowseMedia(
        title="Browse",
        media_class=MediaClass.DIRECTORY,
        media_content_id=item_id,
        media_content_type="directory",
        can_play=False,
        can_expand=True,
        children=children,
    )
```

## Type Mapping Helpers

```python
def _map_media_type(self, emby_type: str) -> MediaType:
    """Map Emby media type to HA MediaType."""
    mapping: dict[str, MediaType] = {
        "Movie": MediaType.MOVIE,
        "Episode": MediaType.TVSHOW,
        "Audio": MediaType.MUSIC,
        "MusicVideo": MediaType.VIDEO,
        "Video": MediaType.VIDEO,
        "Photo": MediaType.IMAGE,
    }
    return mapping.get(emby_type, MediaType.VIDEO)

def _map_media_class(self, emby_type: str) -> MediaClass:
    """Map Emby type to HA MediaClass."""
    mapping: dict[str, MediaClass] = {
        "Movie": MediaClass.MOVIE,
        "Series": MediaClass.TV_SHOW,
        "Season": MediaClass.SEASON,
        "Episode": MediaClass.EPISODE,
        "Audio": MediaClass.TRACK,
        "MusicAlbum": MediaClass.ALBUM,
        "MusicArtist": MediaClass.ARTIST,
        "Playlist": MediaClass.PLAYLIST,
        "CollectionFolder": MediaClass.DIRECTORY,
    }
    return mapping.get(emby_type, MediaClass.DIRECTORY)
```

## Emby Tick Conversions

Emby uses "ticks" (100-nanosecond intervals):

```python
TICKS_PER_SECOND = 10_000_000
TICKS_PER_MS = 10_000

def ticks_to_seconds(ticks: int) -> int:
    """Convert Emby ticks to seconds."""
    return ticks // TICKS_PER_SECOND

def seconds_to_ticks(seconds: float) -> int:
    """Convert seconds to Emby ticks."""
    return int(seconds * TICKS_PER_SECOND)

def ticks_to_timedelta(ticks: int) -> timedelta:
    """Convert Emby ticks to timedelta."""
    return timedelta(microseconds=ticks // 10)
```

## Image URL Building

```python
def _build_image_url(
    self,
    item_id: str,
    image_type: str = "Primary",
    max_width: int = 500,
) -> str:
    """Build URL for Emby item image."""
    return (
        f"{self.coordinator.client.base_url}"
        f"/Items/{item_id}/Images/{image_type}"
        f"?maxWidth={max_width}"
        f"&api_key={self.coordinator.client.api_key}"
    )
```

**Security note:** Don't expose image URLs to `media_image_url` without auth context. Set `media_image_remotely_accessible = False` and let HA proxy the images.

## Platform Setup

```python
"""Platform setup for Emby media player."""
from homeassistant.config_entries import ConfigEntry
from homeassistant.core import HomeAssistant
from homeassistant.helpers.entity_platform import AddEntitiesCallback

from . import EmbyConfigEntry
from .media_player import EmbyMediaPlayer


async def async_setup_entry(
    hass: HomeAssistant,
    entry: EmbyConfigEntry,
    async_add_entities: AddEntitiesCallback,
) -> None:
    """Set up Emby media player entities."""
    coordinator = entry.runtime_data

    entities = [
        EmbyMediaPlayer(coordinator, session)
        for session in coordinator.data.sessions.values()
        if session.supports_media_control
    ]

    async_add_entities(entities)
```

## The Bottom Line

**Properties return cached data. Async methods do I/O. Map Emby concepts to HA correctly.**

- Use coordinator data for all state
- Convert ticks to seconds for HA
- Implement browse_media for library access
- Never block in properties
