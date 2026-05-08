---
name: spring-security
description: Secure Spring Boot applications - authentication, authorization, OAuth2, JWT, CORS/CSRF protection
sasmp_version: "1.3.0"
bonded_agent: 04-spring-security
bond_type: PRIMARY_BOND
version: "2.0.0"
updated: "2024-12-30"
---

# Spring Security Skill

Master Spring Security for authentication, authorization, OAuth2/OIDC, JWT, and security best practices.

## Overview

This skill covers everything needed to build secure Spring Boot applications following OWASP guidelines.

## Parameters

| Name | Type | Required | Default | Validation |
|------|------|----------|---------|------------|
| `auth_type` | enum | ✗ | jwt | jwt \| session \| oauth2 |
| `oauth_provider` | enum | ✗ | - | google \| github \| keycloak |
| `rbac_model` | enum | ✗ | role | role \| permission |

## Topics Covered

### Core (Must Know)
- **Authentication**: Form login, HTTP Basic, JWT
- **Authorization**: Role-based access control, URL patterns
- **SecurityFilterChain**: Modern Spring Security configuration

### Intermediate
- **OAuth2**: Social login, resource server
- **JWT**: Token generation, validation, refresh
- **Method Security**: `@PreAuthorize`, `@PostAuthorize`

### Advanced
- **Custom Providers**: Custom `AuthenticationProvider`
- **MFA**: Multi-factor authentication
- **Security Headers**: CSP, HSTS, X-Frame-Options

## Code Examples

### JWT Security Configuration (Spring Boot 3.x)
```java
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        return http
            .csrf(csrf -> csrf.disable())
            .cors(cors -> cors.configurationSource(corsConfig()))
            .sessionManagement(session ->
                session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .authorizeHttpRequests(auth -> auth
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers("/api/public/**").permitAll()
                .requestMatchers("/api/admin/**").hasRole("ADMIN")
                .anyRequest().authenticated()
            )
            .oauth2ResourceServer(oauth2 -> oauth2.jwt(Customizer.withDefaults()))
            .build();
    }

    @Bean
    CorsConfigurationSource corsConfig() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOrigins(List.of("http://localhost:3000"));
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE"));
        config.setAllowedHeaders(List.of("*"));
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/api/**", config);
        return source;
    }
}
```

### JWT Token Service
```java
@Service
@RequiredArgsConstructor
public class JwtTokenService {

    private final JwtEncoder jwtEncoder;

    public String generateToken(UserDetails user) {
        Instant now = Instant.now();
        String roles = user.getAuthorities().stream()
            .map(GrantedAuthority::getAuthority)
            .collect(Collectors.joining(" "));

        JwtClaimsSet claims = JwtClaimsSet.builder()
            .issuer("self")
            .issuedAt(now)
            .expiresAt(now.plusSeconds(3600))
            .subject(user.getUsername())
            .claim("roles", roles)
            .build();

        return jwtEncoder.encode(JwtEncoderParameters.from(claims)).getTokenValue();
    }
}
```

### Method Security
```java
@Service
public class OrderService {

    @PreAuthorize("hasRole('ADMIN') or @orderSecurity.isOwner(#orderId, principal)")
    public Order getOrder(Long orderId) {
        return orderRepository.findById(orderId)
            .orElseThrow(() -> new OrderNotFoundException(orderId));
    }

    @PreAuthorize("hasRole('ADMIN')")
    public void deleteOrder(Long orderId) {
        orderRepository.deleteById(orderId);
    }
}
```

## Troubleshooting

### Failure Modes

| Issue | Diagnosis | Fix |
|-------|-----------|-----|
| 401 on all requests | Missing auth | Check filter chain order |
| 403 after login | Wrong role | Use `ROLE_` prefix |
| CORS blocked | Wrong config | Configure CorsConfigurationSource |
| CSRF error | Missing token | Disable for APIs or add token |

### Debug Checklist

```
□ Enable security debug logging
□ Check SecurityFilterChain bean is loaded
□ Verify filter chain order
□ Confirm JWT secret/key configuration
□ Test with curl including headers
```

## Unit Test Template

```java
@WebMvcTest(SecureController.class)
@Import(SecurityConfig.class)
class SecureControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Test
    void shouldReturn401WhenNotAuthenticated() throws Exception {
        mockMvc.perform(get("/api/protected"))
            .andExpect(status().isUnauthorized());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void shouldAllowAdminAccess() throws Exception {
        mockMvc.perform(get("/api/admin/users"))
            .andExpect(status().isOk());
    }
}
```

## Usage

```
Skill("spring-security")
```

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.0.0 | 2024-12-30 | Spring Boot 3.x patterns, JWT, method security |
| 1.0.0 | 2024-01-01 | Initial release |
