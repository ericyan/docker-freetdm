# docker-freetdm

Docker image for building [FreeTDM] and the `mod_freetdm` module for use
with FreeSWITCH.

The ZapTel/DAHDI I/O module (`ftmod_zt`) along with the analog signaling
modules (`ftmod_analog` and `ftmod_analog_em`) are compiled as well. So
it should be able to work with DAHDI-compatible telephony cards offering
integration with FXO/FXS or E&M lines.

[FreeTDM]: https://freeswitch.org/confluence/display/FREESWITCH/FreeTDM
