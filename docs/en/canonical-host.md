# Canonical host (www → apex)

When `server.canonical_host` is set, Luciuz enforces a single official host.

## What you get
- Requests to `www.<canonical>` are redirected to `<canonical>`.
- Unknown hosts are rejected (no open redirect behavior).

## Example
```toml
[server]
canonical_host = "luciuz.com"
```

## Certificate considerations
If you redirect `www` to apex over HTTPS, `www` must still present a valid certificate.
In practice, include both in `acme.domains`:

```toml
[acme]
domains = ["luciuz.com","www.luciuz.com"]
```

## HTTP port 80
If you enforce canonical host on HTTP, Luciuz can also guard port 80 to reduce abuse before redirection.
