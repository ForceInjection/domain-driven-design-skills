---
name: mixmi-user-flows
description: Step-by-step user journeys through the mixmi platform including onboarding, upload, remix creation, purchasing, and discovery
metadata:
  status: Active
  implementation: Stacks Auth - Alpha
  last_updated: 2025-10-26
---

# mixmi User Flows

> Complete step-by-step journeys showing how users interact with the mixmi platform.

## Table of Contents

1. [Flow 1: Alpha User Onboarding](#flow-1-alpha-user-onboarding)
2. [Flow 2: Quick Upload (Minimal)](#flow-2-quick-upload-minimal)
3. [Flow 3: Advanced Upload (Full Metadata)](#flow-3-advanced-upload-full-metadata)
4. [Flow 4: Creating a Remix (Planned)](#flow-4-creating-a-remix-planned)
5. [Flow 5: Purchasing Content](#flow-5-purchasing-content)
6. [Flow 6: Discovery via Globe](#flow-6-discovery-via-globe)
7. [Flow 7: Discovery via Search](#flow-7-discovery-via-search)
8. [Flow 8: Browsing Creator Stores](#flow-8-browsing-creator-stores)
9. [Flow 9: Exploring Artist Profiles](#flow-9-exploring-artist-profiles)
10. [Flow 10: Editing Your Profile](#flow-10-editing-your-profile)

## Flow 1: Alpha User Onboarding

**Goal:** Authenticate and gain upload access
**Duration:** 1-2 minutes
**Authentication Methods:** Stacks Wallet OR Alpha Invite Code

### Path A: Stacks Wallet Authentication (Preferred)

#### Step 1: Navigate to Platform

**URL:** `https://mixmi-alpha.vercel.app/` (or localhost)
**Page:** Globe homepage (`app/page.tsx`)
**State:** User not authenticated

**UI:**
- Header shows "Sign In" button (top-right)
- Globe visible with existing content
- No upload button visible

#### Step 2: Click "Sign In"

**Action:** User clicks "Sign In" in header
**Component:** `Header.tsx` → opens `SignInModal.tsx`

**Modal Displays:**
- "Welcome to mixmi Alpha" header
- Two options:
  1. **"Connect Wallet"** button (cyan, primary)
  2. **"Use Alpha Code"** link (secondary, text link below)

#### Step 3: Click "Connect Wallet"

**Action:** User clicks "Connect Wallet"
**Library:** `@stacks/connect` (Stacks blockchain wallet integration)

**What Happens:**
```javascript
import { showConnect } from '@stacks/connect';

showConnect({
  appDetails: {
    name: 'mixmi Alpha',
    icon: window.location.origin + '/logo.png'
  },
  onFinish: (data) => {
    // Wallet connection successful
    const walletAddress = data.userSession.loadUserData().profile.stxAddress.mainnet;
    // Store in AuthContext
  },
  onCancel: () => {
    // User closed wallet popup
  }
});
```

**Wallet Popup Appears:**
- Shows available wallets (Hiro, Xverse, Leather, etc.)
- User selects their wallet
- Wallet asks to approve connection
- User signs authentication message

#### Step 4: Alpha Whitelist Verification

**Backend Call:**
```javascript
const response = await fetch('/api/auth/alpha-check', {
  method: 'POST',
  body: JSON.stringify({ walletAddress })
});

const { isApproved, alphaCode } = await response.json();
```

**Database Query:**
```sql
SELECT alpha_code, is_active
FROM alpha_users
WHERE wallet_address = 'SP...'
  AND is_active = true;
```

**Two Outcomes:**

**✅ If Approved:**
- `AuthContext` sets `isAuthenticated = true`
- `walletAddress` stored in context
- Modal closes automatically
- Header now shows:
  - "Upload" button appears
  - Wallet address (truncated): "SP1ABC...XYZ"
  - Cart icon

**❌ If Not Approved:**
- Error message: "Wallet not approved for alpha access"
- Option to request access (future)
- User must use alpha code instead

### Path B: Alpha Code Authentication (Fallback)

#### Step 1-2: Same as Path A

#### Step 3: Click "Use Alpha Code"

**UI Changes:**
- "Connect Wallet" button dims/hides
- Text input appears: "Enter your alpha invite code"
- Placeholder: "mixmi-ABC123"
- "Submit" button

#### Step 4: Enter Alpha Code

**User Types:** `mixmi-ABC123`
**Action:** Clicks "Submit"

**Validation (Frontend):**
```javascript
const isAlphaCode = (code) => {
  return /^mixmi-[A-Z0-9]{6}$/.test(code);
};
```

**Backend Conversion:**
```javascript
// User entered: mixmi-ABC123
// Backend resolves to actual wallet

const response = await fetch('/api/auth/resolve-wallet', {
  method: 'POST',
  body: JSON.stringify({ authIdentity: 'mixmi-ABC123' })
});

const { walletAddress } = await response.json();
// Returns: SP1ABC...XYZ
```

**Why This Works:**
- UI never shows "wallet address" (prevents security scanner warnings)
- Backend transparently converts alpha code → wallet
- Blockchain operations use real wallet address
- User-friendly authentication

#### Step 5: Authenticated State

**AuthContext State:**
```javascript
{
  isAuthenticated: true,
  walletAddress: 'SP1ABC...',
  alphaCode: 'mixmi-ABC123', // For display
  authMethod: 'alpha_code' // or 'wallet'
}
```

**UI Changes:**
- Modal closes
- Header shows upload button
- User can now upload content

### First Upload Incentive

**After Authentication:**
- Toast notification: "You're in! Ready to upload your first track?"
- Welcome page: "Sign In and Upload" button now says "Upload Your First Track"

## Flow 2: Quick Upload (Minimal)

**Goal:** Upload a loop or song in ~60 seconds
**Prerequisites:** User authenticated
**Duration:** 1-2 minutes

### Step 1: Open Upload Modal

**Triggers:**
- Click "Upload" in header
- Click "Sign In and Upload" on Welcome page (if authenticated)
- Click "+" in own store

**Component:** `IPTrackModal` opens
**Mode:** Quick Upload (default, toggle enabled)

### Step 2: Select Content Type

**UI:** 5 large buttons with icons

```
┌─────────┬─────────┬─────────┬─────────┬─────────┐
│ 🎵 Song │ 🔁 Loop │📦 Pack │ 💿 EP  │ 🎚️ Mix │
└─────────┴─────────┴─────────┴─────────┴─────────┘
```

**User Clicks:** "🔁 Loop"

**State Change:**
```javascript
setFormData({ ...formData, content_type: 'loop' });
```

**UI Updates:**
- BPM field becomes required (red asterisk)
- Loop category dropdown appears

### Step 3: Upload Audio File

**UI:** File picker or drag zone (drag-and-drop for audio not yet implemented)

**User Actions:**
- Clicks "Choose Audio File"
- Selects `trap-beat-140.wav` (8MB)

**File Validation:**
```javascript
// Check format
const validFormats = ['audio/wav', 'audio/mpeg', 'audio/mp4', 'audio/flac'];
if (!validFormats.includes(file.type)) {
  throw new Error('Invalid audio format');
}

// Check size
if (file.size > 10 * 1024 * 1024) {
  throw new Error('File too large (max 10MB)');
}
```

**Auto-Detection Starts:**
```javascript
// BPM detection
setIsDetectingBPM(true);
const detectedBPM = await detectBPM(file);
// Result: 140 BPM

// Duration detection
const duration = await detectDuration(file);
// Result: 32 seconds
```

**UI Updates:**
- Progress bar shows during detection
- "BPM: 140 (auto-detected)" appears
- User MUST verify/override this value

### Step 4: Fill Basic Metadata

**Required Fields (Quick Mode):**

```
Title: [Trap Beat 140      ]  *
Artist: [DJ Example        ]  *
BPM: [140                  ]  * (pre-filled, editable)
Loop Category: [▼ Beats    ]  * (dropdown)
Location: [Los Angeles, CA ]  * (autocomplete)
```

**BPM Verification:**
```
⚠️ User clicks BPM field
Modal: "Auto-detected 140 BPM. Is this correct?"
[Yes, 140 is correct] [No, let me change it]

If user changes to 142:
✓ BPM updated to 142 (whole number only)
```

**Location Autocomplete:**
```
User types: "Los"

Suggestions appear:
┌──────────────────────────┐
│ 🏙️ Los Angeles, CA, USA  │
│ 🏙️ Los Alamos, NM, USA   │
│ 🏙️ Louisiana, USA        │
│ 🏔️ Louisiana Nation      │
└──────────────────────────┘

User selects: Los Angeles, CA, USA
```

**Coordinates Stored:**
```javascript
{
  location_name: "Los Angeles, CA, USA",
  location_lat: 34.052234,
  location_lng: -118.243685
}
```

### Step 5: Upload Cover Image

**UI:** File picker or drag zone

**Auto-Generation Option:**
```
┌────────────────────────────┐
│  📷 Upload Cover Image      │
│                            │
│  [Choose File]             │
│       or                   │
│  [🎨 Auto-Generate]        │
└────────────────────────────┘
```

**If Auto-Generate:**
```javascript
// Creates visual from audio waveform
const generateCover = async (audioFile) => {
  const waveformCanvas = await createWaveformCanvas(audioFile);
  const blob = await canvasToBlob(waveformCanvas);
  return blob;
};
```

**Manual Upload Validation:**
```javascript
// Check image dimensions
const img = new Image();
img.src = URL.createObjectURL(file);
if (img.width < 500 || img.height < 500) {
  alert('Image too small (min 500x500)');
}
if (img.width !== img.height) {
  alert('Image should be square');
}
```

### Step 6: Review and Submit

**Pre-Submit Summary:**
```
┌──────────────────────────────┐
│  Ready to Upload?            │
├──────────────────────────────┤
│  Type: Loop                  │
│  Title: Trap Beat 140        │
│  Artist: DJ Example          │
│  BPM: 140                    │
│  Location: Los Angeles, CA   │
│  Files: ✅ Audio ✅ Cover     │
│                              │
│  [← Back]  [Upload Track →]  │
└──────────────────────────────┘
```

**Upload Process:**
```javascript
// 1. Upload audio to Supabase Storage
const audioPath = `${walletAddress}/${Date.now()}_audio.wav`;
await supabase.storage
  .from('user-content')
  .upload(audioPath, audioFile);

// 2. Upload cover image
const imagePath = `${walletAddress}/${Date.now()}_cover.jpg`;
await supabase.storage
  .from('user-content')
  .upload(imagePath, imageFile);

// 3. Create database record
const { data: track } = await supabase
  .from('ip_tracks')
  .insert({
    title: formData.title,
    artist: formData.artist,
    content_type: 'loop',
    bpm: formData.bpm,
    audio_url: audioPath,
    cover_image_url: imagePath,
    location_name: formData.location_name,
    location_lat: formData.location_lat,
    location_lng: formData.location_lng,
    primary_uploader_wallet: walletAddress,
    created_at: new Date().toISOString()
  })
  .select()
  .single();

// 4. Success!
return track;
```

### Step 7: Success State

**Modal Updates:**
```
┌──────────────────────────────┐
│  ✅ Upload Complete!         │
├──────────────────────────────┤
│                              │
│  Your track "Trap Beat 140"  │
│  is now live on mixmi!       │
│                              │
│  [View Track] [Upload Another]│
└──────────────────────────────┘
```

**Actions:**
- "View Track" → Opens TrackDetailsModal
- "Upload Another" → Resets form
- Close modal → Returns to previous page

## Flow 3: Advanced Upload (Full Metadata)

**Goal:** Upload with complete IP attribution
**Prerequisites:** User authenticated
**Duration:** 3-5 minutes

### Toggle to Advanced Mode

**Location:** Top of IPTrackModal

```
Quick Upload ○━━━━━● Advanced Upload
               ↑ User slides toggle
```

**What Changes:**
- Additional metadata fields appear
- IP splitting interface shows
- Referrer section enabled
- Full credits section available

### Additional Fields in Advanced Mode

#### IP Splitting Configuration

**UI:**
```
┌──────────────────────────────┐
│  IP Splits                   │
├──────────────────────────────┤
│  Producer: [You      ] [60%] │
│  + Add Collaborator          │
│                              │
│  Platform Fee:         15%   │
│  Available:            25%   │
│                              │
│  [+ Add Split Recipient]     │
└──────────────────────────────┘
```

**Adding Collaborator:**
```javascript
// User clicks "+ Add Collaborator"
// New row appears:
{
  role: "Vocalist",        // Dropdown
  wallet: "SP2ABC...",    // Text input
  percentage: 25          // Number input
}

// Validation
if (totalPercentage > 85) {
  error: "Total cannot exceed 85% (15% platform fee)"
}
```

#### Credits Section

**Fields:**
```
Credits (Optional)
├─ Vocalist: [Jane Doe        ]
├─ Mixing Engineer: [John Mix ]
├─ Mastering: [Master Studios ]
└─ + Add Credit Field
```

#### Referrer Attribution

**Field:**
```
Referred By (Optional)
[SP2DEF...] or [mixmi-XYZ789]
Help: Who told you about mixmi?
```

**Validation:**
```javascript
// Check if valid wallet or alpha code
const isValidReferrer = (input) => {
  return isWalletAddress(input) || isAlphaCode(input);
};
```

### Complete Upload Flow

All steps from Quick Upload, plus:
- IP splits configuration
- Credits attribution
- Referrer tracking
- Extended metadata

## Flow 4: Creating a Remix (Planned)

**Goal:** Create and save a remix using the mixer
**Prerequisites:** Authenticated, tracks loaded in mixer
**Status:** Coming in Generation 1

### Planned Implementation

#### Step 1: Load Tracks to Mixer

- Drag loops from Crate to Deck A/B
- Or click "Load to Mixer" from track card

#### Step 2: Create Mix

- Adjust BPM, apply FX
- Record live mixing session
- Mix auto-saves as WebM/Opus

#### Step 3: Save Recording

**Planned Modal:**
```
┌──────────────────────────────┐
│  Save Your Remix             │
├──────────────────────────────┤
│  Title: [Summer Mix 2025   ] │
│  Duration: 3:42              │
│                              │
│  Source Tracks:              │
│  • Loop 1 by Artist A (30%)  │
│  • Loop 2 by Artist B (30%)  │
│  Platform Fee: 15%           │
│  Your Share: 25%             │
│                              │
│  [Cancel] [Save & Upload]    │
└──────────────────────────────┘
```

#### Step 4: Auto-Calculate IP Splits

```javascript
// Automatic attribution based on source loops
const calculateRemixSplits = (sourceTracks) => {
  const remixerShare = 25;  // Fixed for remixer
  const platformFee = 15;   // Fixed platform fee
  const sourceShare = 60;   // Divided among sources
  
  const perSource = sourceShare / sourceTracks.length;
  
  return sourceTracks.map(track => ({
    recipient: track.primary_uploader_wallet,
    percentage: perSource,
    role: 'Original Creator'
  }));
};
```

## Flow 5: Purchasing Content

**Goal:** Purchase and download a track
**Prerequisites:** None (can purchase without auth)
**Duration:** 30 seconds - 2 minutes

### Step 1: Find Track to Purchase

**Entry Points:**
- Globe page card hover → price badge
- Store page → track cards
- Search results → price badges
- Track details modal → purchase button

### Step 2: Click Price Badge

**UI Example:**
```
Track card hover state:
┌─────────────┐
│   Cover     │
│   Image     │
│ [$2.99 STX] │ ← Click this
└─────────────┘
```

### Step 3: Add to Cart

**Action:** Click price badge
**Result:** Track added to cart

**Cart Updates:**
- Cart icon shows item count: 🛒 (1)
- Toast notification: "Added to cart!"
- Price badge changes to "✓ In Cart"

### Step 4: Open Cart

**Click:** Cart icon in header
**Modal:** Shopping cart opens

```
┌──────────────────────────────┐
│  Shopping Cart          [×]  │
├──────────────────────────────┤
│                              │
│  1. Trap Beat 140            │
│     by DJ Example            │
│     Type: Loop               │
│     $2.99 STX         [🗑️]   │
│                              │
│  ─────────────────────────   │
│  Total: $2.99 STX            │
│                              │
│  [Continue Shopping]         │
│  [Proceed to Checkout →]     │
└──────────────────────────────┘
```

### Step 5: Checkout Process

**If Not Authenticated:**
```
┌──────────────────────────────┐
│  Sign In to Purchase         │
├──────────────────────────────┤
│  Connect your wallet to       │
│  complete this purchase       │
│                              │
│  [Connect Wallet]            │
│  [Use Alpha Code]            │
└──────────────────────────────┘
```

**If Authenticated:**
```
┌──────────────────────────────┐
│  Confirm Purchase            │
├──────────────────────────────┤
│  Track: Trap Beat 140        │
│  Price: $2.99 STX            │
│  From: Your Wallet           │
│  To: Creator Wallet          │
│                              │
│  IP Splits:                  │
│  • Creator: 60% ($1.79)      │
│  • Platform: 15% ($0.45)     │
│  • Referrer: 10% ($0.30)     │
│  • Other: 15% ($0.45)        │
│                              │
│  [Cancel] [Confirm Purchase] │
└──────────────────────────────┘
```

### Step 6: Blockchain Transaction

**Process:**
```javascript
// 1. Initialize Stacks transaction
const transaction = {
  contractAddress: 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM',
  contractName: 'mixmi-payments',
  functionName: 'purchase-track',
  functionArgs: [
    trackId,
    priceInMicroSTX,
    ipSplits
  ]
};

// 2. User approves in wallet
await openContractCall(transaction);

// 3. Wait for confirmation
// Shows loading state: "Processing payment..."

// 4. Transaction confirmed
```

### Step 7: Download Access

**Success Modal:**
```
┌──────────────────────────────┐
│  ✅ Purchase Complete!       │
├──────────────────────────────┤
│                              │
│  Thank you for supporting    │
│  DJ Example!                 │
│                              │
│  [Download Track]            │
│  [View in Library]           │
│  [Continue Shopping]         │
└──────────────────────────────┘
```

**Download Process:**
```javascript
// Generate temporary download URL
const { data: downloadUrl } = await supabase
  .from('purchases')
  .insert({
    buyer_wallet: walletAddress,
    track_id: track.id,
    transaction_hash: txHash,
    purchased_at: new Date()
  })
  .select('download_token')
  .single();

// Trigger download
window.open(`/api/download/${downloadUrl.download_token}`);
```

## Flow 6: Discovery via Globe

**Goal:** Discover new music through map interface
**Prerequisites:** None
**Duration:** Ongoing browsing

### Globe Interaction

**Default View:**
- 3D rotating globe
- Glowing dots for track locations
- Auto-rotation at 0.001 radians/frame

### Hover on Location Dot

**Visual Feedback:**
- Dot grows (1.5x scale)
- Glow intensifies
- Tooltip appears with city name

### Click on Location

**Action:** Click glowing dot
**Result:** Track cards appear

```
┌─────────────────────────────┐
│  Los Angeles, CA            │
│  12 tracks                  │
├─────────────────────────────┤
│ [Track] [Track] [Track]     │
│ [Track] [Track] [Track]     │
│         Load More...         │
└─────────────────────────────┘
```

### Track Card Interactions

**Hover State:**
- Card scales to 1.05x
- Overlay with track details
- Action buttons appear

**Available Actions:**
- Play preview (▶️)
- Add to cart ($)
- View details (ℹ️)
- Load to mixer (🎛️) - if loop

## Flow 7: Discovery via Search

**Goal:** Find specific tracks or artists
**Prerequisites:** None
**Duration:** 10-30 seconds

### Access Search

**Trigger:** Click search icon in header
**Modal:** Search interface opens

### Enter Search Query

**Search Input:**
```
┌──────────────────────────────┐
│  🔍 Search mixmi             │
├──────────────────────────────┤
│  [trap beats 140 bpm_____]   │
│                              │
│  Filter by:                  │
│  ○ All  ● Tracks  ○ Artists  │
│  ○ Loops  ○ Songs           │
└──────────────────────────────┘
```

### Real-time Results

**As User Types:**
```javascript
// Debounced search (300ms)
const debouncedSearch = debounce(async (query) => {
  const { data: results } = await supabase
    .from('ip_tracks')
    .select('*')
    .or(`title.ilike.%${query}%,artist.ilike.%${query}%`)
    .limit(20);
  
  setSearchResults(results);
}, 300);
```

### Results Display

**Search Results:**
```
┌──────────────────────────────┐
│  Results for "trap beats"    │
├──────────────────────────────┤
│                              │
│  Tracks (8)                  │
│  ├─ Trap Beat 140           │
│  │  by DJ Example • Loop     │
│  ├─ Dark Trap 150           │
│  │  by Producer X • Loop     │
│  └─ ...                      │
│                              │
│  Artists (3)                 │
│  ├─ Trap Lord               │
│  ├─ Trap Queen              │
│  └─ ...                      │
└──────────────────────────────┘
```

### Select Result

**Click Action:**
- Track → Opens TrackDetailsModal
- Artist → Navigate to artist profile

## Flow 8: Browsing Creator Stores

**Goal:** Explore a creator's catalog
**Prerequisites:** None
**Duration:** 2-5 minutes browsing

### Navigate to Store

**Entry Points:**
- Click artist name on track card
- Click "View Store" in profile
- URL: `/store/[identifier]`

### Store Layout

**Header Section:**
```
┌──────────────────────────────┐
│  DJ Example's Store          │
│  12 tracks • Member since Oct│
│                              │
│  [Follow] [Share] [Tip]      │
└──────────────────────────────┘
```

**Track Grid:**
```
Filters: [All] [Loops] [Songs] [Packs]
Sort: [Newest ▼]

┌────┬────┬────┬────┐
│Loop│Loop│Song│Pack│
├────┼────┼────┼────┤
│Loop│EP  │Loop│Song│
├────┼────┼────┼────┤
│... │... │... │... │
└────┴────┴────┴────┘
```

### Filter and Sort

**Filter Options:**
```javascript
const filters = {
  all: null,
  loops: "content_type = 'loop'",
  songs: "content_type = 'full_song'",
  packs: "content_type IN ('loop_pack', 'ep')"
};
```

**Sort Options:**
- Newest First (default)
- Oldest First
- Price: Low to High
- Price: High to Low
- Most Downloaded (future)

## Flow 9: Exploring Artist Profiles

**Goal:** Learn about an artist
**Prerequisites:** None
**Duration:** 1-2 minutes

### Navigate to Profile

**Entry Points:**
- Click artist avatar
- Click artist name (when underlined)
- URL: `/profile/[identifier]`

### Profile Sections

**Header:**
```
┌──────────────────────────────┐
│    [Avatar]                  │
│    DJ Example                │
│    "Making beats daily"      │
│                              │
│  📍 Los Angeles, CA          │
│  🎵 12 tracks                │
│  👥 234 followers (future)   │
└──────────────────────────────┘
```

**Bio Section:**
```
About
─────
Producer and DJ from LA, specializing 
in trap and hip-hop beats. Available 
for custom work and collaborations.

[Instagram] [SoundCloud] [Twitter]
```

**Recent Tracks:**
```
Recent Uploads
──────────────
[Track] [Track] [Track] [Track]
        View All →
```

### Social Actions (Future)

**Planned Features:**
- Follow artist
- Send message
- Book for collaboration
- Tip directly (STX/BTC)

## Flow 10: Editing Your Profile

**Goal:** Update profile information
**Prerequisites:** Authenticated
**Duration:** 2-3 minutes

### Navigate to Own Profile

**Access:**
- Click avatar in header → "My Profile"
- URL: `/profile/me` redirects to `/profile/[wallet]`

### Edit Profile Button

**Location:** Top-right of profile when viewing own
**Button:** "Edit Profile" (pencil icon)

### Profile Edit Modal

**Sections:**

#### Basic Information

```
Display Name*
[DJ Example_______________]

Tagline (40 chars)
[Making beats daily_______]

Bio (350 chars)
[Producer and DJ from LA,
specializing in trap and
hip-hop beats...]

[Save Changes]
```

#### Avatar Upload

```
Profile Image
┌──────────┐
│  Current │ [Change Photo]
│  Avatar  │
└──────────┘

Drag & drop or choose file
Max 5MB • Square recommended
```

#### Social Links (Future)

```
Social Links
├─ Instagram: [@djexample____]
├─ SoundCloud: [/djexample___]
├─ Twitter: [@djexample_____]
└─ + Add Link
```

### Save Changes

**Process:**
```javascript
// Update profile in database
await supabase
  .from('user_profiles')
  .upsert({
    wallet_address: walletAddress,
    display_name: formData.name,
    tagline: formData.tagline,
    bio: formData.bio,
    avatar_url: uploadedImageUrl,
    social_links: formData.socialLinks,
    updated_at: new Date()
  });

// Update local ProfileContext
updateProfile(newProfileData);

// Close modal
onClose();
```

**Success:**
- Changes reflect immediately
- No page refresh needed
- Toast: "Profile updated!"

## Related Skills

- **mixmi-component-library** - UI components used in flows
- **mixmi-design-patterns** - Visual patterns for extending flows
- **mixmi-payment-flow** - Detailed payment implementation
- **mixmi-database-schema** - Data structures behind flows