# docker-freetdm

Docker image for building [FreeTDM] and the `mod_freetdm` module for use
with FreeSWITCH.

The ZapTel/DAHDI I/O module (`ftmod_zt`) along with the analog signaling
modules (`ftmod_analog` and `ftmod_analog_em`) are compiled as well. So
it should be able to work with DAHDI-compatible telephony cards offering
integration with FXO/FXS or E&M lines.

## Usage

The `ericyan/freetdm` image works as a builder only and is not awfully
useful on its own. Another container (based on `ericyan/freeswitch` in
this example) that actually do all the hard work can then copy and use
the compiled modules from the builder like this:

```
FROM ericyan/freetdm as builder

FROM ericyan/freeswitch

# FreeTDM
COPY --from=builder /usr/local/freeswitch/lib/libfreetdm.so.1.0.0 /usr/lib/
RUN chmod 644 /usr/lib/libfreetdm.so.1.0.0 \
    && ln -s /usr/lib/libfreetdm.so.1.0.0 /usr/lib/libfreetdm.so.1 \
    && ln -s /usr/lib/libfreetdm.so.1.0.0 /usr/lib/libfreetdm.so
COPY --from=builder /usr/local/freeswitch/mod/*.so /usr/lib/freeswitch/mod/
RUN chmod 644 /usr/lib/freeswitch/mod/*.so
```

Make sure the drivers are properly installed on the host. Then, use the
`--device` option to add host device to the container when starting the
container with `docker run`.

[FreeTDM]: https://freeswitch.org/confluence/display/FREESWITCH/FreeTDM
