---
name: nostr-wallet-connect
description: Use when implementing Nostr Wallet Connect (NIP-47) wallet service - provides complete patterns for generating NWC connection strings, publishing info events, listening for requests, processing wallet commands, and sending encrypted responses. Client-side patterns included for reference.
when_to_use: When building wallet services that expose Lightning functionality via NWC, generating NWC connection URIs for clients, implementing NIP-47 wallet service functionality, or handling encrypted wallet communication over Nostr relays
---

# Nostr Wallet Connect (NIP-47) - Wallet Service Implementation

## Overview

Complete implementation guide for Nostr Wallet Connect (NWC) following NIP-47, **focused on wallet service implementation** (the wallet that exposes functionality to clients). This guide provides production-ready patterns based on real-world implementations.

**Core Capabilities (Wallet Service):**
- Generate NWC connection strings for clients to connect
- Publish info events (kind 13194) with wallet capabilities
- Listen for request events (kind 23194) from clients
- Handle encrypted request decryption (NIP-04/NIP-44)
- Process wallet commands (pay_invoice, get_balance, make_invoice, etc.)
- Send encrypted responses (kind 23195)
- Manage connection allowances and quotas
- Prevent duplicate command processing

**Note:** Client-side patterns are included for reference only. The primary focus is implementing the wallet service.

## Prerequisites

**IMPORTANT:** Before adding dependencies, review your project's `package.json` to check if any of these packages already exist. If they do, verify the versions are compatible with the requirements below. Only add packages that are missing or need version updates.

**Required packages:**
- `nostr-tools` - Nostr protocol operations and encryption
- Nostr client library (e.g., `@nostr-dev-kit/ndk`, `@nostrify/nostrify`, or `@nostrify/react`)
- Lightning node integration or wallet backend

**Optional:**
- `@getalby/sdk` - For client-side implementations (reference only)

## Implementation Checklist

### Wallet Service Implementation (Primary Focus)
- [ ] Generate NWC connection strings with unique keypairs
- [ ] Store connection data securely (wallet pubkey, connection secret, allowance)
- [ ] Publish info events (kind 13194) with supported methods
- [ ] Listen for request events (kind 23194) on specific relays
- [ ] Handle encrypted request decryption (NIP-04 or NIP-44)
- [ ] Implement command handlers (pay_invoice, get_balance, make_invoice, etc.)
- [ ] Send encrypted responses (kind 23195) with proper error handling
- [ ] Track processed commands to prevent duplicates
- [ ] Implement allowance/quota management
- [ ] Add UI for displaying connection strings (QR codes)

### Client Implementation (Reference Only)
- [ ] Parse NWC connection strings
- [ ] Connect to wallet services
- [ ] Send payment requests
- [ ] Handle responses and errors

## Part 1: Understanding NWC Architecture

### NWC Connection String Format

NWC connection strings follow this format:
```
nostr+walletconnect://[pubkey]?relay=[relay_url]&secret=[32-byte_hex_secret]&lud16=[lightning_address]
```

**Components:**
- `pubkey`: 32-byte hex-encoded public key of the wallet service (unique per connection)
- `relay`: WebSocket URL of the Nostr relay (may be multiple, space-separated)
- `secret`: 32-byte randomly generated hex-encoded secret key for encryption
- `lud16`: (Optional) Lightning address for profile setup

**Example:**
```
nostr+walletconnect://b889ff5b1513b641e2a139f661a661364979c5beee91842f8f0ef42ab558e9d4?relay=wss%3A%2F%2Frelay.damus.io&secret=71a8c14c1407c113601079c4302dab36460f0ccd0ad506f1f2dc73b5100e4f3c
```

### Event Kinds

- **13194**: Info event (replaceable) - Wallet service capabilities
- **23194**: Request event - Client requests to wallet service
- **23195**: Response event - Wallet service responses
- **23197**: Notification event (NIP-44) - Wallet service notifications
- **23196**: Notification event (NIP-04, legacy) - Wallet service notifications

### Encryption

- **NIP-04 (widely supported)**: Most common, use for maximum compatibility
- **NIP-44 (preferred)**: Modern encryption, use if both client and service support it
- Negotiation via `encryption` tag in info and request events

## Part 2: Wallet Service Implementation

### Connection Data Structure

**Store connection information securely:**

```typescript
// types/nwc.ts
export interface NWCConnection {
  walletPublicKey: string;      // Wallet service pubkey (64 hex chars)
  walletPrivateKey: string;      // Wallet service private key (64 hex chars)
  connectionSecret: string;      // Connection secret for encryption (64 hex chars)
  connectionPublicKey: string;   // Connection pubkey derived from secret
  allowanceLeft: number;         // Remaining spending allowance (in msats)
}

export interface NWCCommand {
  method: string;
  params: Record<string, unknown>;
}

export interface NWCResult {
  result_type: string;
  result: Record<string, unknown> | null;
}

export interface NWCError {
  result_type: string;
  error: {
    code: string;
    message: string;
  };
}

// Event kind constants
export const NWCKind = {
  NWCInfo: 13194,
  NWCRequest: 23194,
  NWCResponse: 23195,
} as const;
```

### Generating NWC Connection Strings

**Generate NWC connection strings for clients to connect:**

```typescript
// lib/nwcGenerator.ts
import { generateSecretKey, getPublicKey } from 'nostr-tools';
import { bytesToHex } from '@noble/hashes/utils'; // or equivalent

export interface NWCConnectionConfig {
  relay: string | string[];
  lud16?: string;
}

/**
 * Generate a new NWC connection with unique keypair
 * @param config - Connection configuration
 * @returns NWC connection data and connection string
 */
export function generateNWCConnection(config: NWCConnectionConfig): {
  connection: NWCConnection;
  connectionString: string;
} {
  // Generate wallet service keypair (unique per connection)
  const walletSecret = generateSecretKey(); // Uint8Array
  const walletPublicKey = getPublicKey(walletSecret); // hex string
  const walletPrivateKey = bytesToHex(walletSecret); // hex string

  // Generate connection secret (for encryption with clients)
  const connectionSecret = generateSecretKey();
  const connectionPublicKey = getPublicKey(connectionSecret);
  const connectionSecretHex = bytesToHex(connectionSecret);

  // Format relay(s) - can be space-separated
  const relays = Array.isArray(config.relay) 
    ? config.relay.join(' ') 
    : config.relay;

  // Build connection string
  const url = new URL(`nostr+walletconnect://${walletPublicKey}`);
  url.searchParams.set('relay', relays);
  url.searchParams.set('secret', connectionSecretHex);
  
  if (config.lud16) {
    url.searchParams.set('lud16', config.lud16);
  }

  const connection: NWCConnection = {
    walletPublicKey,
    walletPrivateKey,
    connectionSecret: connectionSecretHex,
    connectionPublicKey,
    allowanceLeft: 1000000, // Default 1M sats allowance (adjust as needed)
  };

  return {
    connection,
    connectionString: url.toString(),
  };
}
```

**Usage:**
```typescript
const { connection, connectionString } = generateNWCConnection({
  relay: ['wss://relay.damus.io', 'wss://relay.nostr.band'],
  lud16: 'user@getalby.com',
});

// Store connection securely
storeConnection(connection);

// Display connectionString to user (QR code, copy button, etc.)
console.log('NWC Connection String:', connectionString);
```

### Publishing Info Event

**Publish replaceable info event (kind 13194) with wallet capabilities:**

```typescript
// lib/nwcInfo.ts
import type { NostrEvent } from '@nostrify/nostrify'; // or your Nostr library

export interface WalletServiceCapabilities {
  methods: string[]; // e.g., ['pay_invoice', 'get_balance', 'make_invoice']
  notifications?: string[]; // e.g., ['payment_received', 'payment_sent']
  encryption?: string[]; // e.g., ['nip04', 'nip44_v2']
}

/**
 * Publish NWC info event (kind 13194)
 * This is a replaceable event - only the latest per pubkey is stored
 */
export async function publishNWCInfoEvent(
  walletPubkey: string,
  walletPrivateKey: string,
  capabilities: WalletServiceCapabilities,
  relays: string[],
  nostrClient: NostrClient // Your Nostr client instance
): Promise<void> {
  // Check if info event already exists
  const existingEvents = await nostrClient.query([
    {
      kinds: [13194],
      authors: [walletPubkey],
      limit: 1,
    }
  ], { relays });

  // Only publish if it doesn't exist or capabilities changed
  if (existingEvents.length > 0) {
    const existing = existingEvents[0];
    const existingMethods = existing.content.split(/\s+/).filter(Boolean);
    const methodsMatch = JSON.stringify(existingMethods.sort()) === 
                        JSON.stringify(capabilities.methods.sort());
    
    if (methodsMatch) {
      console.log('NWC info event already published with same capabilities');
      return;
    }
  }

  // Build event tags
  const tags: string[][] = [];

  // Add encryption tag (default to NIP-04 for compatibility)
  if (capabilities.encryption && capabilities.encryption.length > 0) {
    tags.push(['encryption', capabilities.encryption.join(' ')]);
  } else {
    tags.push(['encryption', 'nip04']);
  }

  // Add notifications tag if supported
  if (capabilities.notifications && capabilities.notifications.length > 0) {
    tags.push(['notifications', capabilities.notifications.join(' ')]);
  }

  // Content is space-separated list of supported methods
  const content = capabilities.methods.join(' ');

  // Create and publish event
  const event = await nostrClient.createEvent({
    kind: 13194,
    content,
    tags,
  }, walletPrivateKey);

  await nostrClient.publish(event, relays);
  console.log('Published NWC info event:', event.id);
}
```

**Usage:**
```typescript
await publishNWCInfoEvent(
  connection.walletPublicKey,
  connection.walletPrivateKey,
  {
    methods: [
      'pay_invoice',
      'get_balance',
      'make_invoice',
      'lookup_invoice',
      'list_transactions',
      'get_info',
    ],
    notifications: ['payment_received', 'payment_sent'],
    encryption: ['nip04'], // Use NIP-04 for maximum compatibility
  },
  ['wss://relay.damus.io'],
  nostrClient
);
```

### Listening for Request Events

**Listen for and process NWC request events (kind 23194):**

```typescript
// lib/nwcRequestHandler.ts
import { nip04 } from 'nostr-tools'; // or nip44 for NIP-44 support
import type { NostrEvent } from '@nostrify/nostrify';

export interface NWCRequest {
  method: string;
  params: Record<string, unknown>;
}

export interface NWCResponse {
  result_type: string;
  error?: {
    code: string;
    message: string;
  } | null;
  result?: Record<string, unknown> | null;
}

/**
 * Subscribe to NWC request events and handle them
 */
export function listenToNWCCommands(
  connection: NWCConnection,
  relays: string[],
  nostrClient: NostrClient,
  onCommand: (command: NWCCommand, event: NostrEvent) => Promise<NWCResponse | NWCError>,
  seenCommandsUntil: number = 0 // Track last processed command timestamp
): () => void {
  // Subscribe to request events
  // Filter: kind 23194, author is connectionPublicKey, p tag is walletPublicKey
  const subscription = nostrClient.subscribe([
    {
      kinds: [23194],
      authors: [connection.connectionPublicKey],
      '#p': [connection.walletPublicKey],
      since: seenCommandsUntil, // Only get new commands
    }
  ], { relays });

  subscription.on('event', async (event: NostrEvent) => {
    try {
      // Check if NWC is enabled
      if (!isNWCEnabled()) {
        console.log('Received NWC command but NWC is disabled');
        return;
      }

      // Check if we've already processed this command
      if (event.created_at <= seenCommandsUntil) {
        return;
      }

      // Update seen commands timestamp
      updateSeenCommandsUntil(event.created_at);

      console.log('NWC request received:', event.id);

      // Get client pubkey from p tag
      const clientPubkeyTag = event.tags.find(([name]) => name === 'p');
      if (!clientPubkeyTag?.[1]) {
        console.error('Request missing client pubkey');
        return;
      }
      const clientPubkey = clientPubkeyTag[1];

      // Determine encryption scheme (default to NIP-04)
      const encryptionTag = event.tags.find(([name]) => name === 'encryption');
      const encryption = encryptionTag?.[1] || 'nip04';

      // Decrypt request
      let command: NWCCommand;
      try {
        if (encryption === 'nip44_v2' || encryption === 'nip44') {
          // NIP-44 decryption (if supported)
          const { nip44 } = await import('nostr-tools');
          const decrypted = await nip44.v2.decrypt(
            event.content,
            connection.connectionSecret,
            clientPubkey
          );
          command = JSON.parse(decrypted);
        } else {
          // NIP-04 decryption (default)
          const decrypted = await nip04.decrypt(
            connection.connectionSecret,
            clientPubkey,
            event.content
          );
          command = JSON.parse(decrypted);
        }
      } catch (decryptError) {
        console.error('Failed to decrypt NWC request:', decryptError);
        await sendNWCResponse(
          event,
          clientPubkey,
          {
            result_type: command?.method || 'error',
            error: {
              code: 'UNSUPPORTED_ENCRYPTION',
              message: 'Failed to decrypt request',
            },
            result: null,
          },
          encryption,
          connection,
          nostrClient,
          relays
        );
        return;
      }

      console.log('NWC command:', command.method, command.params);

      // Process command
      const response = await onCommand(command, event);

      // Send response
      await sendNWCResponse(
        event,
        clientPubkey,
        response,
        encryption,
        connection,
        nostrClient,
        relays
      );
    } catch (error) {
      console.error('Error handling NWC request:', error);
      // Send error response
      const clientPubkeyTag = event.tags.find(([name]) => name === 'p');
      const clientPubkey = clientPubkeyTag?.[1] || event.pubkey;
      const encryptionTag = event.tags.find(([name]) => name === 'encryption');
      const encryption = encryptionTag?.[1] || 'nip04';

      await sendNWCResponse(
        event,
        clientPubkey,
        {
          result_type: 'error',
          error: {
            code: 'INTERNAL',
            message: error instanceof Error ? error.message : 'Unknown error',
          },
          result: null,
        },
        encryption,
        connection,
        nostrClient,
        relays
      );
    }
  });

  // Return unsubscribe function
  return () => {
    subscription.close();
  };
}

/**
 * Send encrypted NWC response (kind 23195)
 */
async function sendNWCResponse(
  requestEvent: NostrEvent,
  clientPubkey: string,
  response: NWCResponse | NWCError,
  encryption: string,
  connection: NWCConnection,
  nostrClient: NostrClient,
  relays: string[]
): Promise<void> {
  // Encrypt response
  let encryptedContent: string;
  try {
    if (encryption === 'nip44_v2' || encryption === 'nip44') {
      const { nip44 } = await import('nostr-tools');
      encryptedContent = await nip44.v2.encrypt(
        JSON.stringify(response),
        connection.connectionSecret,
        clientPubkey
      );
    } else {
      encryptedContent = await nip04.encrypt(
        connection.connectionSecret,
        clientPubkey,
        JSON.stringify(response)
      );
    }
  } catch (encryptError) {
    console.error('Failed to encrypt NWC response:', encryptError);
    throw encryptError;
  }

  // Create response event
  const responseEvent = await nostrClient.createEvent({
    kind: 23195,
    content: encryptedContent,
    tags: [
      ['p', clientPubkey],
      ['e', requestEvent.id],
    ],
  }, connection.walletPrivateKey);

  // Publish response
  await nostrClient.publish(responseEvent, relays);
  console.log('Sent NWC response:', responseEvent.id);
}
```

### Processing Wallet Commands

**Handle common NWC commands with real-world patterns:**

```typescript
// lib/nwcCommands.ts
import type { NWCCommand, NWCResponse, NWCError, NWCConnection } from './types';

export async function handleNWCCommand(
  command: NWCCommand,
  connection: NWCConnection,
  walletBackend: WalletBackend // Your wallet/lightning backend
): Promise<NWCResponse | NWCError> {
  switch (command.method) {
    case 'get_info': {
      return {
        result_type: 'get_info',
        result: {
          alias: 'My Wallet',
          color: '#FF0000',
          pubkey: connection.walletPublicKey,
          network: 'mainnet',
          block_height: await walletBackend.getBlockHeight(),
          block_hash: await walletBackend.getBlockHash(),
          methods: [
            'pay_invoice',
            'get_balance',
            'make_invoice',
            'lookup_invoice',
            'list_transactions',
            'get_info',
          ],
        },
        error: null,
      };
    }

    case 'get_balance': {
      try {
        const balance = await walletBackend.getBalance(); // Returns sats
        return {
          result_type: 'get_balance',
          result: {
            balance: balance * 1000, // Convert to msats
          },
          error: null,
        };
      } catch (error) {
        return {
          result_type: 'get_balance',
          error: {
            code: 'INTERNAL',
            message: error instanceof Error ? error.message : 'Failed to get balance',
          },
          result: null,
        };
      }
    }

    case 'pay_invoice': {
      const invoice = command.params.invoice as string;
      const amountMsat = command.params.amount as number | undefined;

      // Check allowance
      if (amountMsat && amountMsat > connection.allowanceLeft) {
        return {
          result_type: 'pay_invoice',
          error: {
            code: 'QUOTA_EXCEEDED',
            message: 'Spending quota exceeded',
          },
          result: null,
        };
      }

      try {
        // Decode and validate invoice
        const invoiceData = await walletBackend.decodeInvoice(invoice);
        
        // Calculate total amount (invoice amount + fees)
        const totalAmount = invoiceData.amount + invoiceData.feeReserve;
        
        // Check allowance again with fees
        if (totalAmount > connection.allowanceLeft) {
          return {
            result_type: 'pay_invoice',
            error: {
              code: 'QUOTA_EXCEEDED',
              message: 'Spending quota exceeded',
            },
            result: null,
          };
        }

        // Pay invoice
        const paymentResult = await walletBackend.payInvoice(invoice);
        
        // Deduct from allowance
        connection.allowanceLeft -= totalAmount;
        updateConnection(connection);

        return {
          result_type: 'pay_invoice',
          result: {
            preimage: paymentResult.preimage,
            // fees_paid can be included if available
          },
          error: null,
        };
      } catch (error) {
        return {
          result_type: 'pay_invoice',
          error: {
            code: 'PAYMENT_FAILED',
            message: error instanceof Error ? error.message : 'Payment failed',
          },
          result: null,
        };
      }
    }

    case 'make_invoice': {
      const amount = command.params.amount as number; // msats
      const description = command.params.description as string | undefined;
      const expiry = command.params.expiry as number | undefined; // seconds

      try {
        const invoice = await walletBackend.createInvoice({
          amount: amount / 1000, // Convert msats to sats
          description,
          expiry,
        });

        return {
          result_type: 'make_invoice',
          result: {
            type: 'incoming',
            invoice: invoice.bolt11,
            description: invoice.description,
            payment_hash: invoice.paymentHash,
            amount: amount,
            created_at: Math.floor(Date.now() / 1000),
            expires_at: expiry ? Math.floor(Date.now() / 1000) + expiry : null,
          },
          error: null,
        };
      } catch (error) {
        return {
          result_type: 'make_invoice',
          error: {
            code: 'INTERNAL',
            message: error instanceof Error ? error.message : 'Failed to create invoice',
          },
          result: null,
        };
      }
    }

    case 'list_transactions': {
      const from = command.params.from as number | undefined;
      const until = command.params.until as number | undefined;
      const limit = (command.params.limit as number) || 10;
      const offset = (command.params.offset as number) || 0;
      const unpaid = command.params.unpaid as boolean | undefined;
      const type = command.params.type as 'incoming' | 'outgoing' | undefined;

      try {
        const transactions = await walletBackend.listTransactions({
          from,
          until: until || Math.floor(Date.now() / 1000),
          limit,
          offset,
          unpaid,
          type,
        });

        // Transform to NWC format
        const nwcTransactions = transactions.map(tx => ({
          type: tx.amount > 0 ? 'incoming' : 'outgoing',
          invoice: tx.bolt11,
          description: tx.description,
          preimage: tx.preimage,
          payment_hash: tx.paymentHash,
          amount: Math.abs(tx.amount) * 1000, // Convert to msats
          fees_paid: tx.feesPaid || 0,
          created_at: tx.createdAt,
          settled_at: tx.settledAt,
          expires_at: tx.expiresAt,
        }));

        // Sort by created_at descending (newest first)
        nwcTransactions.sort((a, b) => b.created_at - a.created_at);

        return {
          result_type: 'list_transactions',
          result: {
            transactions: nwcTransactions,
          },
          error: null,
        };
      } catch (error) {
        return {
          result_type: 'list_transactions',
          error: {
            code: 'INTERNAL',
            message: error instanceof Error ? error.message : 'Failed to list transactions',
          },
          result: null,
        };
      }
    }

    case 'lookup_invoice': {
      const paymentHash = command.params.payment_hash as string | undefined;
      const invoice = command.params.invoice as string | undefined;

      if (!paymentHash && !invoice) {
        return {
          result_type: 'lookup_invoice',
          error: {
            code: 'OTHER',
            message: 'invoice or payment_hash required',
          },
          result: null,
        };
      }

      try {
        let hash = paymentHash;
        if (!hash && invoice) {
          const decoded = await walletBackend.decodeInvoice(invoice);
          hash = decoded.paymentHash;
        }

        const tx = await walletBackend.lookupTransaction(hash!);
        if (!tx) {
          return {
            result_type: 'lookup_invoice',
            error: {
              code: 'NOT_FOUND',
              message: 'invoice not found',
            },
            result: null,
          };
        }

        return {
          result_type: 'lookup_invoice',
          result: {
            type: tx.amount > 0 ? 'incoming' : 'outgoing',
            invoice: tx.bolt11,
            description: tx.description,
            preimage: tx.preimage,
            payment_hash: tx.paymentHash,
            amount: Math.abs(tx.amount) * 1000,
            fees_paid: tx.feesPaid || 0,
            created_at: tx.createdAt,
            settled_at: tx.settledAt,
            expires_at: tx.expiresAt,
          },
          error: null,
        };
      } catch (error) {
        return {
          result_type: 'lookup_invoice',
          error: {
            code: 'NOT_FOUND',
            message: 'invoice not found',
          },
          result: null,
        };
      }
    }

    default:
      return {
        result_type: command.method,
        error: {
          code: 'NOT_IMPLEMENTED',
          message: `Method ${command.method} is not implemented`,
        },
        result: null,
      };
  }
}
```

### Complete Wallet Service Integration

**Putting it all together:**

```typescript
// stores/nwcStore.ts (example using Pinia/Vue, adapt to your framework)
import { defineStore } from 'pinia';
import { generateNWCConnection } from '@/lib/nwcGenerator';
import { publishNWCInfoEvent } from '@/lib/nwcInfo';
import { listenToNWCCommands } from '@/lib/nwcRequestHandler';
import { handleNWCCommand } from '@/lib/nwcCommands';
import type { NWCConnection } from '@/types/nwc';

export const useNWCStore = defineStore('nwc', {
  state: () => ({
    nwcEnabled: false,
    connections: [] as NWCConnection[],
    seenCommandsUntil: 0,
    subscriptions: [] as Array<() => void>,
  }),

  actions: {
    async generateNWCConnection(relays: string[], lud16?: string) {
      // Generate new connection
      const { connection, connectionString } = generateNWCConnection({
        relay: relays,
        lud16,
      });

      // Store connection
      this.connections.push(connection);

      // Publish info event
      await publishNWCInfoEvent(
        connection.walletPublicKey,
        connection.walletPrivateKey,
        {
          methods: [
            'pay_invoice',
            'get_balance',
            'make_invoice',
            'lookup_invoice',
            'list_transactions',
            'get_info',
          ],
          encryption: ['nip04'],
        },
        relays,
        nostrClient
      );

      return { connection, connectionString };
    },

    async listenToNWCCommands() {
      if (!this.nwcEnabled || this.connections.length === 0) {
        return;
      }

      // Close existing subscriptions
      this.unsubscribeNWC();

      // For each connection, start listening
      for (const connection of this.connections) {
        const unsubscribe = listenToNWCCommands(
          connection,
          relays, // Your relay URLs
          nostrClient,
          async (command, event) => {
            // Handle blocking for pay_invoice to prevent concurrent payments
            if (command.method === 'pay_invoice' && this.blocking) {
              return {
                result_type: 'pay_invoice',
                error: {
                  code: 'INTERNAL',
                  message: 'Already processing a payment',
                },
                result: null,
              };
            }

            if (command.method === 'pay_invoice') {
              this.blocking = true;
            }

            try {
              const response = await handleNWCCommand(
                command,
                connection,
                walletBackend
              );
              return response;
            } finally {
              if (command.method === 'pay_invoice') {
                this.blocking = false;
              }
            }
          },
          this.seenCommandsUntil
        );

        this.subscriptions.push(unsubscribe);
      }
    },

    unsubscribeNWC() {
      for (const unsubscribe of this.subscriptions) {
        unsubscribe();
      }
      this.subscriptions = [];
    },

    getConnectionString(connection: NWCConnection, relays: string[]): string {
      const url = new URL(`nostr+walletconnect://${connection.walletPublicKey}`);
      url.searchParams.set('relay', relays.join(' '));
      url.searchParams.set('secret', connection.connectionSecret);
      return url.toString();
    },
  },
});
```

## Part 3: UI Components (Wallet Service)

### NWC Connection String Display

**Display connection string with QR code:**

```typescript
// components/NWCDialog.tsx
import { useState } from 'react';
import { QRCode } from '@/components/QRCode'; // From qr-code-generator skill
import { Button } from '@/components/ui/button';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { useNWCStore } from '@/stores/nwcStore';

export function NWCDialog({ 
  connection, 
  connectionString,
  open,
  onOpenChange 
}: { 
  connection: NWCConnection;
  connectionString: string;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}) {
  const handleCopy = async () => {
    await navigator.clipboard.writeText(connectionString);
    // Optional: User feedback - choose one:
    // Option 1: Console logging
    // console.log('Copied to clipboard');
    // Option 2: Toast notification (if toast is available)
    // toast({ title: 'Copied', description: 'Connection string copied to clipboard' });
    // Option 3: No notification (silent success)
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>NWC Connection String</DialogTitle>
        </DialogHeader>
        <div className="space-y-4">
          <div className="flex justify-center p-4 bg-white rounded">
            <QRCode value={connectionString} size={256} />
          </div>
          <div>
            <Input 
              value={connectionString} 
              readOnly 
              className="font-mono text-xs"
            />
          </div>
          <div className="flex gap-2">
            <Button onClick={handleCopy} className="flex-1">
              Copy
            </Button>
            <Button variant="outline" onClick={() => onOpenChange(false)}>
              Close
            </Button>
          </div>
          <div className="text-sm text-muted-foreground">
            <p>Allowance: {connection.allowanceLeft / 1000} sats</p>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
}
```

## Part 4: Error Handling

### NWC Error Codes

**Handle NWC error codes according to NIP-47:**

```typescript
// lib/nwcErrors.ts
export const NWC_ERROR_CODES = {
  RATE_LIMITED: 'RATE_LIMITED',
  NOT_IMPLEMENTED: 'NOT_IMPLEMENTED',
  INSUFFICIENT_BALANCE: 'INSUFFICIENT_BALANCE',
  QUOTA_EXCEEDED: 'QUOTA_EXCEEDED',
  RESTRICTED: 'RESTRICTED',
  UNAUTHORIZED: 'UNAUTHORIZED',
  INTERNAL: 'INTERNAL',
  UNSUPPORTED_ENCRYPTION: 'UNSUPPORTED_ENCRYPTION',
  PAYMENT_FAILED: 'PAYMENT_FAILED',
  NOT_FOUND: 'NOT_FOUND',
  OTHER: 'OTHER',
} as const;

export function getErrorMessage(code: string): string {
  const messages: Record<string, string> = {
    RATE_LIMITED: 'Too many requests. Please wait a moment and try again.',
    NOT_IMPLEMENTED: 'This feature is not supported by the wallet.',
    INSUFFICIENT_BALANCE: 'Insufficient balance in wallet.',
    QUOTA_EXCEEDED: 'Spending quota exceeded.',
    RESTRICTED: 'This operation is not allowed.',
    UNAUTHORIZED: 'Wallet connection not authorized.',
    INTERNAL: 'An internal error occurred.',
    UNSUPPORTED_ENCRYPTION: 'Encryption method not supported.',
    PAYMENT_FAILED: 'Payment failed. Please try again.',
    NOT_FOUND: 'Requested item not found.',
    OTHER: 'An unknown error occurred.',
  };
  return messages[code] || messages.OTHER;
}
```

## Part 5: Security Considerations

### Best Practices

1. **Never log secrets**: Connection strings contain private keys
2. **Validate all inputs**: Always validate NWC connection strings and command parameters
3. **Use NIP-04 for compatibility**: NIP-04 is widely supported; use NIP-44 only if both sides support it
4. **Unique keys per connection**: Generate unique keypairs for each connection
5. **Store securely**: Use secure storage for connection data (localStorage is acceptable for browser apps)
6. **Track processed commands**: Use `seenCommandsUntil` to prevent duplicate processing
7. **Implement blocking**: Prevent concurrent payment processing
8. **Allowance management**: Track and enforce spending limits per connection
9. **Error messages**: Don't expose sensitive information in error messages

### Connection String Security

```typescript
// Never log full connection strings
function logConnection(connection: NWCConnection) {
  // ❌ Bad
  console.log('Connection:', connection.connectionString);
  
  // ✅ Good
  console.log('Connection:', {
    pubkey: connection.walletPublicKey.substring(0, 8) + '...',
    allowanceLeft: connection.allowanceLeft,
  });
}
```

## Part 6: Client Implementation (Reference Only)

### NWC Connection String Parsing

**For reference - how clients parse connection strings:**

```typescript
// lib/nwcParser.ts (CLIENT SIDE - REFERENCE ONLY)
export interface ParsedNWC {
  pubkey: string;
  relay: string[];
  secret: string;
  lud16?: string;
}

export function parseNWCConnectionString(uri: string): ParsedNWC | null {
  try {
    const normalized = uri.replace(/^nostrwalletconnect:\/\//, 'nostr+walletconnect://');
    
    if (!normalized.startsWith('nostr+walletconnect://')) {
      return null;
    }

    const url = new URL(normalized);
    const pubkey = url.hostname;
    
    if (!/^[0-9a-f]{64}$/i.test(pubkey)) {
      return null;
    }

    const relay = url.searchParams.get('relay');
    const secret = url.searchParams.get('secret');
    const lud16 = url.searchParams.get('lud16') || undefined;

    if (!relay || !secret) {
      return null;
    }

    if (!/^[0-9a-f]{64}$/i.test(secret)) {
      return null;
    }

    const relays = relay.split(/\s+/).filter(Boolean);

    return { pubkey, relay: relays, secret, lud16 };
  } catch (error) {
    return null;
  }
}
```

## Part 7: Troubleshooting

### Common Issues

**Connection fails:**
- Verify relay URL is correct and accessible
- Check that connection string format is valid
- Ensure wallet service has published info event (kind 13194)

**Commands not received:**
- Verify subscription filter matches connection pubkeys
- Check that `since` parameter is not filtering out events
- Ensure relays are connected and receiving events

**Encryption errors:**
- Ensure both client and service support same encryption scheme
- Check that secret key is correct (64 hex characters)
- Verify pubkey matches between connection string and info event

**Duplicate command processing:**
- Implement `seenCommandsUntil` tracking
- Check event `created_at` before processing
- Update timestamp after successful processing

## References

- **NIP-47**: https://github.com/nostr-protocol/nips/blob/master/47.md
- **NIP-44**: https://github.com/nostr-protocol/nips/blob/master/44.md
- **NIP-04**: https://github.com/nostr-protocol/nips/blob/master/04.md
- **cashu.me NWC implementation**: Reference implementation in Vue/Pinia
