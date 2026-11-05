*This project has been created as part of the 42 curriculum by rperez-t.*

# Netpractice_live

## Description

The training interface of the NetPractice project, as provided by the intranet
(`net_practice.1.9.tgz`), kept so that it can be used as a git submodule. Nothing in the
site was modified: its pages and scripts are byte for byte those of the archive.

Git keeps the archive and the launcher (`run.sh` and its modules), and none of the site.
`run.sh` extracts the archive at the root of the repository the first time it runs, and again
whenever a file of the site is missing, serves it, and removes it again when the server stops:
the site only exists while it is being used, and the folder is back to what git keeps. A
fresh clone is one `./run.sh` away from the interface.

NetPractice is a set of ten small simulated networks, each one broken. For each level you
fix the IP addresses, masks, gateways and routes of the unshaded fields until every goal
at the top of the page turns `OK`. Nothing here is a real network: the simulator is
JavaScript that runs in the page.

What git keeps:

| File | What it is |
|---|---|
| `src/net_practice.1.9.tgz` | The archive from the intranet, untouched: the only copy of the site in git |
| `run.sh` | The main: loads the modules, makes sure the site is all at the root (extracting what is missing), starts a local web server on a free port and opens the browser on it, and removes the site when the server stops |
| `src/sh/log.sh` | The messages, and the errors that stop everything |
| `src/sh/archive.sh` | Finds the archive in `src/`, reads and checks its list of files, says where each one goes, and unpacks it to read from |
| `src/sh/site.sh` | Checks that the site is all at the root, and extracts from the archive what is missing |
| `src/sh/destroy.sh` | The opposite: removes the site from the root, so that only what git keeps is left |
| `src/sh/server.sh` | Finds a free port, starts the web server and opens the browser: what the `run.sh` of the intranet does |
| `.gitignore` | Ignores everything at the root but `run.sh`, `src/` and the README, so the extracted site is never committed |
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
4. When the server stops, however it stops (Ctrl-C, the terminal closed, the server failing to
   start), the site is removed: every file of the site that is still the archive's own
   (compared byte for byte), then the folders that leaves empty (a `.DS_Store` of the Finder
   in them does not count). It says `Netpractice: removed the site (33 files).`

Nothing that somebody wrote is ever removed. A file of the site that was changed is kept and
named (`Netpractice: kept 1 file(s) of the site that differ from the archive ...`), and so is
everything the archive does not have: your own files, a `level1.json` you put here. Without an
archive nothing says what the site is made of, and nothing is removed. Keep one `run.sh` per
folder: when one stops, it removes the site the other one is serving.

It stops before step 3, with a message, when there is no archive and no `index.html`, when
`src/` holds two archives, when the archive cannot be read, or when a file in it would leave
the folder or go into `src/` or `.git` (so an archive can never replace the modules).

`./run.sh --extract` does steps 1 and 2 only: no server, no browser, nothing printed when
the site is complete, and nothing removed afterwards. It is for a project that uses this
repository as a submodule and needs the files without the server (the checks of `netpractice`
run the simulator of `js/`). A `run.sh` started later removes them when its server stops.

`./run.sh --destroy` does step 4 only: it removes what `--extract` left, or what a run that
was killed (`kill -9`, a power cut) had no time to remove. It says `no file of the site is
here.` when there is nothing to remove.

### How `run.sh` is organized

`run.sh` is only the main. It moves to its own folder, loads the modules of `src/sh/` in this
order (`log`, `archive`, `site`, `destroy`, `server`), and its `main` function does the work:
`site_ensure` (steps 1 and 2), then `server_run` (step 3). `main` also decides what happens
when the script ends: it always removes the temporary folder, and when the server was started
it also calls `destroy_site` (step 4), by an `EXIT` trap, which is why Ctrl-C and the like
clean up too. `--extract` and `--destroy` only run their part.

The modules only define functions, so nothing happens when one is loaded. The functions start
with the name of their module: `log_say`, `log_warn`, `log_fail`, `archive_find`,
`archive_list`, `archive_path`, `archive_dir`, `archive_unpack`, `archive_forget`, `site_look`,
`site_extract`, `site_ensure`, `destroy_site`, `server_port`, `server_browser`, `server_run`.
The few variables they share are in capitals (`ARCHIVE`, `LISTING`, `REL`, `WORK`, `MISSING`,
`TOTAL`, `REMOVED`, `KEPT`, `SERVER_PORT`) and are listed at the top of the module that sets
them. To add a module, put the file in `src/sh/` and its name in the `for module in ...` line
of `run.sh`.

### Starting over

To get a file back as the archive has it, delete it and run `./run.sh` again. A file you
changed is kept by step 4, so delete it by hand too to be rid of the change. To use another
version of the archive, put the new `net_practice.X.Y.tgz` in `src/` in place of the old one:
the site is not there between two runs, so the next `./run.sh` extracts the new one (after a
`./run.sh --extract` that left the old one, do `./run.sh --destroy` first).

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
