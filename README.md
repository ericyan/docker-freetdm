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

## Configuration

In order to interface with FreeTDM from FreeSWITCH you must configure
several different components:

 * Hardware drivers (eg. DAHDI)
 * The FreeTDM library
 * FreeSWITCH module `mod_freetdm`

Sample configs is available at https://freeswitch.org/stash/projects/FS/repos/freeswitch/browse/libs/freetdm/conf

### Driver configuration

On the host, the driver needs to be installed and properly configurated.
For DAHDI devices, the config file is `/etc/dahdi/system.conf`. The user
manual of the telephony card should have a chapter on how to configure
the driver.

In the container, you need to make sure the `freeswitch` user has the
permission to access the mounted device. For DAHDI devices, you may need
to do something like this:

```
chown -R freeswitch:freeswitch /dev/dahdi
```

### FreeTDM library configuration

The `/etc/freeswitch/freetdm.conf` file follows an INI-like format. This
is where you declare your spans. For each span, you must specify the I/O
module that will control that span and the span name, for example:

```
[span zt dahdi-1]
trunk_type => FXO
fxo-channel => 1:1-8
```

This specifies a span named `dahdi-1` that will be controlled by the zt
I/O module. Consult the FreeTDM documentation for details.

The I/O modules also have their own config files (for `ftmod_zt`, it is
`/etc/freeswitch/zt.conf`), but you normally do not need them as the
defaults are sensible.

The `ftmod_analog` module requires `/etc/freeswitch/tones.conf` for tone
generation and detection. If you use analog interfaces and you want to
dial out you must make sure the tone configuration is correct for your
country.

### FreeSWITCH configuration

Once the library is configured, we then tell FreeSWITCH which signaling
settings to use and where to send the incoming calls to. This is done
through `/etc/freeswitch/autload_configs/freetdm.conf.xml`.

Most of the time the span definitions will match those in the library
config. However, you can have some spans defined in `freetdm.conf` but
not in use in `freetdm.conf.xml`, but not the other way around.

Span definitions are declared inside an section for each signaling type.
Inside each section, you can declare individual spans. The name of the
span must match one of the names you used in the `freetdm.conf` file.

Please refer to the sample configuration file for documentation in all
the span types and their respective XML sections.

[FreeTDM]: https://freeswitch.org/confluence/display/FREESWITCH/FreeTDM
