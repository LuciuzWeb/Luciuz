# Timeouts

Les timeouts protègent contre les clients lents et les handlers défectueux.

## Timeout handler
`timeouts.handler_secs` limite le temps maximal accordé au handler pour répondre.

```toml
[timeouts]
handler_secs = 30
```

Si le timeout se déclenche, Luciuz renvoie `504 Gateway Timeout`.

## Roadmap
D’autres timeouts (lecture headers, connect/read upstream, idle) sont prévus pour la v1.
