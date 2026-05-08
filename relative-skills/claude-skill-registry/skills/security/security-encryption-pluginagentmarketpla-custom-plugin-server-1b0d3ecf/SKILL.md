---
name: security-encryption
description: Game server security including encryption, anti-cheat, and secure communication
sasmp_version: "1.3.0"
version: "2.0.0"
bonded_agent: 01-game-server-architect
bond_type: SECONDARY_BOND

# Parameters
parameters:
  required:
    - security_layer
  optional:
    - encryption_algorithm
    - key_rotation_hours
  validation:
    security_layer:
      type: string
      enum: [transport, application, data_at_rest]
    encryption_algorithm:
      type: string
      enum: [aes_256_gcm, chacha20_poly1305, rsa_4096]
      default: aes_256_gcm
    key_rotation_hours:
      type: integer
      min: 1
      max: 720
      default: 24

# Retry Configuration
retry_config:
  max_attempts: 1
  fallback: reject_connection

# Observability
observability:
  logging:
    level: warn
    fields: [event_type, source_ip, threat_level]
  metrics:
    - name: security_violations_total
      type: counter
    - name: encryption_operations_duration_us
      type: histogram
    - name: blocked_connections_total
      type: counter
    - name: rate_limit_hits
      type: counter
---

# Security & Encryption for Game Servers

Implement **secure game server architecture** with encryption and anti-cheat measures.

## Security Layers

```
[Client] ← TLS 1.3 → [Load Balancer] ← mTLS → [Game Server]
                                                    ↓
                                          [Encrypted State]
```

## Transport Security

### TLS/SSL Configuration

```cpp
#include <openssl/ssl.h>

SSL_CTX* createSecureContext() {
    SSL_CTX* ctx = SSL_CTX_new(TLS_server_method());

    // TLS 1.3 only
    SSL_CTX_set_min_proto_version(ctx, TLS1_3_VERSION);
    SSL_CTX_set_max_proto_version(ctx, TLS1_3_VERSION);

    // Load certificates
    SSL_CTX_use_certificate_file(ctx, "server.crt", SSL_FILETYPE_PEM);
    SSL_CTX_use_PrivateKey_file(ctx, "server.key", SSL_FILETYPE_PEM);

    // Secure cipher suites only
    SSL_CTX_set_ciphersuites(ctx,
        "TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256");

    // Enable session tickets
    SSL_CTX_set_session_cache_mode(ctx, SSL_SESS_CACHE_SERVER);

    return ctx;
}
```

### DTLS for UDP Game Traffic

```cpp
SSL_CTX* createDTLSContext() {
    SSL_CTX* ctx = SSL_CTX_new(DTLS_server_method());
    SSL_CTX_set_min_proto_version(ctx, DTLS1_2_VERSION);

    // Cookie verification to prevent DoS
    SSL_CTX_set_cookie_generate_cb(ctx, generateCookie);
    SSL_CTX_set_cookie_verify_cb(ctx, verifyCookie);

    return ctx;
}
```

## Server Authority Model

```cpp
// NEVER trust client data - validate everything server-side
class AuthoritativeServer {
public:
    bool onMoveCommand(uint32_t playerId, Vector3 targetPos) {
        auto& player = players[playerId];
        Vector3 currentPos = player.position;

        // Validate movement speed
        float distance = (targetPos - currentPos).length();
        float maxDistance = player.speed * deltaTime * 1.1f; // 10% tolerance

        if (distance > maxDistance) {
            logSuspicious(playerId, "SPEED_HACK", {
                {"distance", distance},
                {"max_allowed", maxDistance}
            });
            return false;
        }

        // Validate path (no teleporting through walls)
        if (!isPathClear(currentPos, targetPos)) {
            logSuspicious(playerId, "WALL_HACK", {});
            return false;
        }

        // Apply validated movement
        player.position = targetPos;
        return true;
    }

    bool onFireCommand(uint32_t playerId, Vector3 aimDir) {
        auto& player = players[playerId];

        // Validate fire rate
        auto now = Clock::now();
        auto timeSinceLastShot = now - player.lastFireTime;

        if (timeSinceLastShot < player.weapon.fireRate) {
            logSuspicious(playerId, "FIRE_RATE_HACK", {});
            return false;
        }

        // Server performs hit detection
        auto hit = raycast(player.position, aimDir);
        if (hit.entity) {
            applyDamage(hit.entity, player.weapon.damage);
        }

        player.lastFireTime = now;
        return true;
    }
};
```

## Anti-Cheat Detection

```cpp
class AntiCheatSystem {
    struct PlayerStats {
        float avgAccuracy;
        float avgReactionTime;
        int suspicionScore;
        std::vector<SuspiciousEvent> events;
    };

    std::unordered_map<uint32_t, PlayerStats> stats;

public:
    void onHit(uint32_t shooter, uint32_t target, const HitInfo& info) {
        auto& s = stats[shooter];

        // Statistical aimbot detection
        updateAccuracy(s, info);
        if (s.avgAccuracy > 0.95f && s.shots > 100) {
            s.suspicionScore += 10;
            flagForReview(shooter, "STATISTICAL_AIMBOT");
        }

        // Inhuman reaction time detection
        if (info.reactionTime < 0.1f) { // 100ms
            s.suspicionScore += 5;
            s.events.push_back({
                "INHUMAN_REACTION",
                info.reactionTime,
                Clock::now()
            });
        }

        // Trigger ban review if threshold exceeded
        if (s.suspicionScore > 100) {
            triggerBanReview(shooter, s);
        }
    }

    void validatePacket(uint32_t playerId, const Packet& pkt) {
        // Check sequence numbers for replay attacks
        if (pkt.sequence <= lastSequence[playerId]) {
            logSuspicious(playerId, "REPLAY_ATTACK", {});
            return;
        }

        // Verify packet checksum
        if (!verifyChecksum(pkt)) {
            logSuspicious(playerId, "PACKET_TAMPERING", {});
            disconnectPlayer(playerId);
        }
    }
};
```

## Authentication

```cpp
#include <jwt-cpp/jwt.h>

class AuthService {
    std::string secret;

public:
    std::string generateToken(const Player& player) {
        return jwt::create()
            .set_issuer("game-auth-server")
            .set_type("JWS")
            .set_payload_claim("player_id", jwt::claim(player.id))
            .set_payload_claim("username", jwt::claim(player.username))
            .set_issued_at(std::chrono::system_clock::now())
            .set_expires_at(std::chrono::system_clock::now() +
                           std::chrono::hours(24))
            .sign(jwt::algorithm::hs256{secret});
    }

    std::optional<PlayerClaims> validateToken(const std::string& token) {
        try {
            auto verifier = jwt::verify()
                .allow_algorithm(jwt::algorithm::hs256{secret})
                .with_issuer("game-auth-server");

            auto decoded = jwt::decode(token);
            verifier.verify(decoded);

            return PlayerClaims{
                decoded.get_payload_claim("player_id").as_string(),
                decoded.get_payload_claim("username").as_string()
            };
        } catch (const std::exception& e) {
            return std::nullopt;
        }
    }
};
```

## Rate Limiting

```cpp
class RateLimiter {
    struct Bucket {
        int tokens;
        std::chrono::steady_clock::time_point lastRefill;
    };

    std::unordered_map<std::string, Bucket> buckets;
    std::shared_mutex mutex;

public:
    bool allow(const std::string& key, int cost = 1) {
        std::unique_lock lock(mutex);

        auto& bucket = buckets[key];
        refill(bucket);

        if (bucket.tokens >= cost) {
            bucket.tokens -= cost;
            return true;
        }
        return false;
    }

private:
    void refill(Bucket& bucket) {
        auto now = std::chrono::steady_clock::now();
        auto elapsed = now - bucket.lastRefill;
        auto refillAmount = elapsed.count() * refillRate;
        bucket.tokens = std::min(maxTokens, bucket.tokens + refillAmount);
        bucket.lastRefill = now;
    }
};

// Usage
RateLimiter limiter;

void onClientMessage(Connection* conn, Message& msg) {
    if (!limiter.allow(conn->ip, 1)) {
        // Rate limited
        conn->send(RateLimitedResponse{});
        return;
    }
    processMessage(conn, msg);
}
```

## Rate Limit Thresholds

| Action | Limit | Window |
|--------|-------|--------|
| Login attempts | 5 | 1 min |
| Commands/sec | 60 | 1 sec |
| Chat messages | 10 | 10 sec |
| API requests | 100 | 1 min |

## Troubleshooting

### Common Failure Modes

| Error | Root Cause | Solution |
|-------|------------|----------|
| TLS handshake fail | Cert expired | Auto-renew certs |
| Token rejected | Clock drift | NTP sync |
| False positives | Strict thresholds | Tune detection |
| DoS vulnerability | No rate limit | Add rate limiting |

### Debug Checklist

```bash
# Verify TLS configuration
openssl s_client -connect game.example.com:443 -tls1_3

# Check certificate validity
openssl x509 -in server.crt -noout -dates

# Monitor security events
journalctl -u game-server | grep -E "(SUSPICIOUS|BLOCKED|VIOLATION)"

# Test rate limiter
for i in {1..100}; do curl -s game.example.com/api; done
```

## Unit Test Template

```cpp
#include <gtest/gtest.h>

TEST(Security, RejectsInvalidToken) {
    AuthService auth;
    auto result = auth.validateToken("invalid.token.here");
    EXPECT_FALSE(result.has_value());
}

TEST(Security, DetectsSpeedHack) {
    AuthoritativeServer server;
    Player player{.position = {0, 0, 0}, .speed = 10.0f};

    // Normal movement
    EXPECT_TRUE(server.onMoveCommand(1, {5, 0, 0}));

    // Teleport attempt
    EXPECT_FALSE(server.onMoveCommand(1, {1000, 0, 0}));
}

TEST(Security, RateLimiterWorks) {
    RateLimiter limiter;

    // First 10 requests pass
    for (int i = 0; i < 10; ++i) {
        EXPECT_TRUE(limiter.allow("test_ip"));
    }

    // 11th request blocked
    EXPECT_FALSE(limiter.allow("test_ip"));
}

TEST(Security, AESEncryptDecrypt) {
    std::string plaintext = "game state data";
    auto [ciphertext, iv] = encrypt_aes_gcm(plaintext, key);
    auto decrypted = decrypt_aes_gcm(ciphertext, key, iv);
    EXPECT_EQ(plaintext, decrypted);
}
```

## Resources

- `assets/` - Security checklists
- `references/` - Encryption guides
