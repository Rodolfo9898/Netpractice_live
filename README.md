*This project has been created as part of the 42 curriculum by rperez-t.*

# Netpractice_live

## Description

The training interface of the NetPractice project, as provided by the intranet
(`net_practice.1.9.tgz`), kept so that it can be used as a git submodule. Nothing in the
site was modified: its pages and scripts are byte for byte those of the archive.

Git keeps the archive and the launcher, and none of the site. `run.sh` extracts the archive
at the root of the repository the first time it runs, and again whenever a file of the site
is missing, then serves it. A fresh clone is four files, and one `./run.sh` away from the
interface.

NetPractice is a set of ten small simulated networks, each one broken. For each level you
fix the IP addresses, masks, gateways and routes of the unshaded fields until every goal
at the top of the page turns `OK`. Nothing here is a real network: the simulator is
JavaScript that runs in the page.

What git keeps:

| File | What it is |
|---|---|
| `src/net_practice.1.9.tgz` | The archive from the intranet, untouched: the only copy of the site in git |
| `run.sh` | Extracts the archive when the site is not all at the root, then starts a local web server on a free port and opens the browser on it |
| `.gitignore` | Ignores everything at the root but these four files, so the extracted site is never committed |
| `README.md` | This file |

What `run.sh` extracts at the root (and git ignores):

| File | What it is |
|---|---|
| `index.html` | The start page: login for training, or the evaluation mode |
| `js/intro.js` | The start page's script: the two tabs, the login, the choice of the evaluation level |
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
- `tar`, to extract the archive.
- A web browser. Nothing to build or install.

The pages need a web server: browsers refuse to run them from a `file://` URL.

### Running

```sh
./run.sh
```

It works in the folder it is in, so it can be started from anywhere. In order:

1. It reads the archive, `src/net_practice*.tgz` (exactly one), and looks for each of its
   files at the root, without the archive's top folder: `net_practice/js/sim.js` is
   `js/sim.js`.
2. If they are all there, nothing is extracted. If not, it says so, unpacks the archive in
   a temporary folder (removed afterwards) and copies from it the files that are missing:
   `Netpractice: extracting the site from src/net_practice.1.9.tgz.` for a fresh clone,
   `Netpractice: 3 of the 33 files of the site are missing, restoring them from ...` for a
   site that lost a few. A file that is already there is never overwritten. The `run.sh`
   inside the archive is not extracted: this one replaces it.
3. It looks for a free port from 49152 up (with `ss`, when it exists, otherwise it uses
   49242), starts `python3 -m http.server` **in this folder**, and opens the browser with
   `xdg-open` (Linux) or `open` (macOS). Ctrl-C stops the server.

It stops before step 3, with a message, when there is no archive and no `index.html`, when
`src/` holds two archives, when the archive cannot be read, or when a name in it would leave
the folder.

`./run.sh --extract` does steps 1 and 2 only: no server, no browser, and nothing printed when
the site is complete. It is for a project that uses this repository as a submodule and needs
the files without the server (the checks of `netpractice` run the simulator of `js/`).

To get a file back as the archive has it, delete it and run `./run.sh` again. To start the
whole site over: `rm -rf css img js index.html end.html level*.html License`, then `./run.sh`.
To use another version of the archive, put the new `net_practice.X.Y.tgz` in `src/` in place
of the old one and start the site over the same way: the archive is only read for what is
missing.

Without `run.sh`:

```sh
mkdir site && tar -xzf src/net_practice.1.9.tgz -C site --strip-components=1
cd site && python3 -m http.server 49242    # then open http://localhost:49242
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
  to be duplicated, modified or used in any other context. It comes with the archive, and
  `run.sh` extracts it next to the pages.
- `man python3` (`-m http.server`), `man ss`, `man tar`
- Networking concepts the levels are about:
  - TCP/IP addressing - https://datatracker.ietf.org/doc/html/rfc791
  - Subnet masks and CIDR notation - https://datatracker.ietf.org/doc/html/rfc4632
  - Private addresses - https://datatracker.ietf.org/doc/html/rfc1918
  - Default gateway - https://en.wikipedia.org/wiki/Default_gateway
  - Routing tables - https://en.wikipedia.org/wiki/Routing_table
  - Routers and switches - https://en.wikipedia.org/wiki/Network_switch
  - The OSI model - https://en.wikipedia.org/wiki/OSI_model
