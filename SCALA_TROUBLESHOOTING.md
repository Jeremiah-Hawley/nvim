# Scala/Metals troubleshooting log

Bugs hit and fixed while setting up `lua/jer/plugins/scala.lua` (nvim-metals) on this machine (Ubuntu 24.04 aarch64, WSL2).

## 1. "Coursier not installed" warning on opening a `.scala` file

**Cause:** Coursier (`cs`), the tool nvim-metals uses to install Metals, wasn't present.

**Fix:** Installed the JVM-based `cs` launcher (no native aarch64 Linux binary exists upstream, only the darwin/x86_64 builds — the cross-platform jar launcher works fine since a JDK is already installed):
```bash
curl -fL "https://github.com/coursier/coursier/releases/latest/download/coursier" -o ~/.local/bin/cs
chmod +x ~/.local/bin/cs
```
Then ran `:MetalsInstall` in nvim to pull the Metals server itself.

## 2. `javax.tools.DiagnosticListener` ClassNotFoundException running `scala file.scala`

**Cause:** `/usr/bin/scala` is version 2.11.12 (2017), which predates the JDK 9+ module system. Its classpath resolver scans for the old monolithic `rt.jar`, which doesn't exist under JDK 21 — so it can't find `javax.tools`, even though it's present as a module.

**Fix:** Installed a current toolchain via coursier instead of relying on the system package:
```bash
cs setup -y
```
This installs `scala`/`scalac`/`scala-cli` (JDK-21-compatible) under `~/.local/share/coursier/bin`.

## 3. New `scala` still resolving to the broken 2.11 binary

**Cause:** Two PATH bugs from `cs setup -y`:
- It appended `~/.local/share/coursier/bin` to the *end* of `PATH` in `~/.profile`, after `/usr/bin` — so `/usr/bin/scala` still won.
- It only touched `~/.profile` (login shells). `~/.bashrc` — what nvim's `:terminal` and most terminal emulators actually source for interactive non-login shells — never got the entry at all.

**Fix:** Prepended the coursier bin dir in both files:
```bash
export PATH="/root/.local/share/coursier/bin:$PATH"
```
Requires a fresh shell (or a full nvim restart) to take effect — running processes keep their old inherited PATH.

## 4. `:MetalsImportBuild` / `:MetalsRestartMetals` → `E492: Not an editor command`

**Cause two-fold:**
- I initially gave the wrong command name (`:MetalsRestartServer` doesn't exist — it's `:MetalsRestartMetals`).
- nvim-metals only registers its `:Metals*` user commands the first time it successfully attaches to a real `.scala`/`.sbt` buffer *in the current nvim session* (`add_commands()` runs inside `initialize_or_attach`). Running them before opening a real Scala file that session means the commands genuinely don't exist yet.

**Fix:** Open the actual `.scala` file first and let Metals attach (watch for the `[nvim-metals]` attach messages), *then* the `Metals*` commands exist. Tab-complete after `:Metals` to confirm before running one.

## 5. `AssertionError: asTerm called on not-a-Term val <none>` during compile

```
Error: Unexpected error when compiling ScalaPlaybox_...: java.lang.AssertionError: ...
  at dotty.tools.dotc.core.Definitions.init(Definitions.scala:2236)
```

**Cause:** Corrupted in-memory state in the long-running Bloop compile daemon (shared by scala-cli and Metals), most likely from repeated/cancelled compiles in the same session — a known flaky Bloop/Dotty daemon issue, not a project config problem. Reproduced identically outside nvim by hitting an old daemon, and confirmed a *fresh* daemon compiles the same project fine.

**Fix:** Kill the daemon and let it restart clean:
```bash
pkill -f bloop.BloopServer
```
No cache clearing needed if this recurs — just the daemon restart.
