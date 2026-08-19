#!/usr/bin/env node

import { spawnSync } from "node:child_process";
import { resolve } from "node:path";
import { exit } from "node:process";

const checks = {
  "agent-docs": ["check-agent-docs"],
  "agent-behavior": ["check-agent-behavior"],
  "init-smoke": ["test-init"]
};

const [checkName, ...forwardedArgs] = process.argv.slice(2);
const entry = checks[checkName];

if (!entry) {
  console.error(`Unknown platform check: ${checkName ?? "(missing)"}`);
  console.error(`Expected one of: ${Object.keys(checks).join(", ")}`);
  exit(2);
}

const baseName = entry[0];
const onWindows = process.platform === "win32";
const command = onWindows ? "pwsh" : "bash";
const script = resolve("scripts", `${baseName}.${onWindows ? "ps1" : "sh"}`);
const args = onWindows
  ? ["-NoLogo", "-NoProfile", "-File", script, ...forwardedArgs]
  : [script, ...forwardedArgs];
const result = spawnSync(command, args, { stdio: "inherit", shell: false });

if (result.error) {
  console.error(`Unable to run ${checkName} with ${command}: ${result.error.message}`);
  exit(1);
}

exit(result.status ?? 1);
