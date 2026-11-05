*This project has been created as part of the 42 curriculum by rperez-t.*

# Netpractice_live

## Description

The training interface of the NetPractice project, as provided by the intranet
(`net_practice.1.9.tgz`), extracted at the root of this repository so that it can be
used as a git submodule. Nothing in it was modified: the pages, scripts and `run.sh` are
byte for byte those of the archive.

NetPractice is a set of ten small simulated networks, each one broken. For each level you
fix the IP addresses, masks, gateways and routes of the unshaded fields until every goal
at the top of the page turns `OK`. Nothing here is a real network: the simulator is
JavaScript that runs in the page.

| File | What it is |
|---|---|
| `run.sh` | Starts a local web server on a free port and opens the browser on it |
| `index.html` | The start page: login for training, or the evaluation mode |
| `level1.html` ... `level10.html` | One page per level; each loads `js/levelN.js`, `js/show.js` and `js/sim.js` |
| `end.html` | The page after level 10 |
| `js/levelN.js` | The network of level N: hosts, routers, interfaces, links, routes and goals |
| `js/show.js` | Draws the board, seeds the random addresses with the login, exports the config |
| `js/sim.js` | The simulator: how a packet is routed, and what makes a goal `OK` |
| `css/`, `img/` | Style and pictures |
| `License` | The terms under which 42 provides it |

## Instructions

### Requirements

- `python3`, which `run.sh` uses as the web server.
- A web browser. Nothing to build or install.

The pages need a web server: browsers refuse to run them from a `file://` URL.

### Running

```sh
./run.sh
```

It looks for a free port from 49152 up (with `ss`, when it exists, otherwise it uses
49242), starts `python3 -m http.server` **in the current directory**, and opens the
browser with `xdg-open` (Linux) or `open` (macOS). Ctrl-C stops the server. Run it from
this folder: the server serves the folder it is started in.

Without `run.sh`:

```sh
python3 -m http.server 49242    # then open http://localhost:49242
```

### Using the interface

1. **Training**: enter your intranet login and press *Start!*. Each level is generated
   from the login, so the addresses are always the same for the same login, and the
   moulinette can find them again.
2. **Evaluation**: three random levels from 6 to 10, to solve in 15 minutes, with random
   addresses. This is the mode of the defense.
3. Change the unshaded fields, then *Check again*. The logs at the bottom tell, hop by
   hop, why a goal fails (invalid IP, loop, no route, wrong gateway...).
4. When every goal is `OK`, press *Get my config*: the browser downloads `levelN.json`
   with the values of the editable fields. Then go to the next level.

The level files are the work to hand in: ten of them, one per level, at the root of the
project's repository.

## Resources

- The NetPractice subject, version 6.3.
- `License`: the content is provided by 42 for the curriculum, and it is not authorized
  to be duplicated, modified or used in any other context.
- `man python3` (`-m http.server`), `man ss`
- Networking concepts the levels are about:
  - TCP/IP addressing - https://datatracker.ietf.org/doc/html/rfc791
  - Subnet masks and CIDR notation - https://datatracker.ietf.org/doc/html/rfc4632
  - Private addresses - https://datatracker.ietf.org/doc/html/rfc1918
  - Default gateway - https://en.wikipedia.org/wiki/Default_gateway
  - Routing tables - https://en.wikipedia.org/wiki/Routing_table
  - Routers and switches - https://en.wikipedia.org/wiki/Network_switch
  - The OSI model - https://en.wikipedia.org/wiki/OSI_model
