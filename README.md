dwc_network_server_emulator
===========================

A Nintendo DS and Wii online multiplayer server emulator.

> **This is a fork of [polaris-/dwc_network_server_emulator](https://github.com/polaris-/dwc_network_server_emulator), specifically set up to retrieve Pokémon Ranger WiFi events. Retrieving events with a Nintendo DS has been confirmed to work successfully.**

[Usage Instructions](https://github.com/polaris-/dwc_network_server_emulator/wiki) | [Partial Compatibility List](https://github.com/polaris-/dwc_network_server_emulator/wiki/Compatibility) | [Available Content](https://github.com/polaris-/dwc_network_server_emulator/wiki/Nintendo-DS-Download-Content)

Running with Docker
-------------------

This fork uses Docker Compose to run both the backend and the nginx reverse proxy. No manual Python environment setup is needed.

```bash
docker compose up --build
```

The `docker-compose.yaml` defines two services:
- `dwc_backend` — the emulator backend (ports 8000, 9000, 9002, 9003, 9009)
- `nginx_proxy` — an nginx reverse proxy built with OpenSSL 1.0.2 to support SSLv2/SSLv3 as required by the Nintendo DS (ports 80, 443)

The required TLS certificate is included in the repository and has a lifespan of 10 years. No ROM patching was needed for the Pokémon Ranger games.

Setup Requirements
------------------

### 1. WEP or open WiFi network

The Nintendo DS only supports WEP or open (no password) WiFi networks. You need to provide such a hotspot on the machine or router connecting your DS to the network. On Linux, tools like [linux-wifi-hotspot](https://github.com/lakinduakash/linux-wifi-hotspot) or `hostapd` can be used to create a compatible access point.

### 2. DNS redirection

All DNS queries for `*.nintendowifi.net` must resolve to the host running `docker compose`. On Linux, `dnsmasq` is a straightforward option:

Add the following line to your `dnsmasq` configuration (e.g. `/etc/dnsmasq.conf`):

```
address=/nintendowifi.net/192.x.x.x
```

Replace `192.x.x.x` with the IP address of the host running Docker. Then configure your WiFi hotspot or DHCP server to hand out that machine as the DNS server for connecting clients.

---

Open source projects referenced during the creation of the original project: [OpenSpy Core](https://github.com/sfcspanky/Openspy-Core/) | [Luigi Auriemma's Gslist and enctypex_decoder](http://aluigi.altervista.org/papers.htm)
