"""Mango title stream and a confirmation-based Fuzzel power menu for Waybar."""

import json
import subprocess
import sys


def window():
    # Mango sends the current client immediately, then updates on focus/title changes.
    process = subprocess.Popen(
        ["mmsg", "watch", "focusing-client"], stdout=subprocess.PIPE, text=True
    )
    try:
        for line in process.stdout:
            try:
                client = json.loads(line)
                title = (client or {}).get("title", "")
                print(json.dumps({"text": title, "class": "" if title else "empty"}), flush=True)
            except (ValueError, AttributeError):
                continue
    finally:
        process.terminate()
        process.wait()


def choose(prompt, options):
    result = subprocess.run(
        ["fuzzel", "--dmenu", "--prompt", prompt],
        input="\n".join(options), text=True, capture_output=True
    )
    return result.stdout.strip() if result.returncode == 0 else ""


def power():
    actions = {
        "Suspend": ["systemctl", "suspend"],
        "Log out": ["mmsg", "dispatch", "quit"],
        "Reboot": ["systemctl", "reboot"],
        "Shut down": ["systemctl", "poweroff"],
    }
    action = choose("Power: ", actions)
    if action in actions and choose(f"{action}? ", ["Cancel", "Confirm"]) == "Confirm":
        subprocess.run(actions[action], check=True)


if __name__ == "__main__":
    {"window": window, "power": power}[sys.argv[1]]()
