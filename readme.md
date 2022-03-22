# Lego based lets encrypt integration for homeassistant
[Homeassistant](https://www.home-assistant.io/) add-on which utilizes [lego](https://go-acme.github.io/lego/) to obtain and renew SSL-Certificates from [Let's Encrypt](https://letsencrypt.org/docs/) via [DNS-01 challange](https://letsencrypt.org/docs/challenge-types/#dns-01-challenge)  of a [scaleway DNS](https://www.scaleway.com/en/dns/). This allowes me to use a custom domain with homeassistant managed by scaleway dns, without exposing my homeassistant installation to the internet.

It is tested with Homeassistant Core Version `2022.3.6`.

(!) Discalmer: This is mainly a personal setup which I want to share, in case some also needs this. Read and understand the (very little) code before you use it!

## How to use

### Install the Add-on
This Add-on isn't currently published. 
Therefore you have copy all the files of this into `/addons` directory of youre home-assistant installation and install it along the [y"Tutorial: Making your first add-on
"](https://developers.home-assistant.io/docs/add-ons/tutorial#step-2-installing-and-testing-your-add-on)

### Configure the add-on
```yaml
lego_opts: ' ' #Allows you to add e.g. the debugging 
email: your-email@gmail.com #E-Mail used for lets encrypt registration
domain: your-domain.com #Domain used for the lets encrypt certificate
scaleway_api_token: abc-def # Scaleway API-Key see: https://go-acme.github.io/lego/dns/scaleway/
sys_certfile: fullchain.pem
sys_keyfile: privkey.pem
poll_interval: 3600
```

### Install nginx proxy add-on

Install the official [Nginx Proxy Add-on](https://github.com/home-assistant/addons/tree/master/nginx_proxy) and [ensure that 
home assistant webserver trusts the nginx proxy](https://www.home-assistant.io/integrations/http/#reverse-proxies).

```yaml
http:
  use_x_forwarded_for: true
  trusted_proxies:
    - 172.30.33.0/24
```

Configure the the nginx proxy add-on 
```yaml
certfile: fullchain.pem
cloudflare: false
customize:
  active: false
  default: nginx_proxy_default*.conf
  servers: nginx_proxy/*.conf
domain: your-domain.com
hsts: '' # Is disabled in this configuration
keyfile: privkey.pem
```

### Setup nginx-add-on restart
As the certifcates are changed by the lego add-on at every certifcate renew, 
the nginx server has to be restarted, to ensure the newest certificates are used.

(!) Attention: This will to lead to a short downtime of the nginx service.

```yaml

-  alias: Nginx daily restart
  trigger:
  - platform: time
    at: 03:00:00
  condition: []
  action:
  - service: hassio.addon_restart
    data:
      addon: core_nginx_proxy
  mode: single
```