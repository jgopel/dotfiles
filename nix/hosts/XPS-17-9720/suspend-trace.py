"""Drain a dedicated ftrace instance into durable, size-bounded text segments."""

import fcntl
import json
import os
from pathlib import Path
import select
import signal
import sys
import tempfile
import time


EVENTS = (
    "power/suspend_resume",
    "power/device_pm_callback_start",
    "power/device_pm_callback_end",
)
LIMIT = 10_000_000_000  # Decimal GB, across boots and service restarts.
SEGMENT = 100_000_000
METADATA_MARGIN = 1_000_000


def sync_directory(path):
    fd = os.open(path, os.O_RDONLY | os.O_DIRECTORY)
    try:
        os.fsync(fd)
    finally:
        os.close(fd)


def save_json(path, value):
    temporary = path.with_suffix(".tmp")
    with temporary.open("w") as output:
        json.dump(value, output, indent=2)
        output.write("\n")
        output.flush()
        os.fdatasync(output.fileno())
    temporary.replace(path)
    sync_directory(path.parent)


def clocks():
    return {
        "wall_ns": time.time_ns(),
        "monotonic_ns": time.monotonic_ns(),
        "boottime_ns": time.clock_gettime_ns(time.CLOCK_BOOTTIME),
    }


def configure(instance):
    # Validate support before enabling anything. Never reset a pre-existing
    # instance: it may contain records from a stopped/crashed reader.
    fresh = not instance.exists()
    instance.mkdir(exist_ok=True)
    for event in EVENTS:
        (instance / "events" / event / "format").read_text()
    if fresh:
        (instance / "current_tracer").write_text("nop")
        (instance / "buffer_size_kb").write_text("4096")
        (instance / "trace_clock").write_text("boot")
    elif (
        (instance / "current_tracer").read_text().strip() != "nop"
        or "[boot]" not in (instance / "trace_clock").read_text()
    ):
        raise RuntimeError("Unexpected trace instance configuration; preserving it")
    (instance / "options/overwrite").write_text("1")
    # Flush sparse PM events promptly instead of waiting for a half-full buffer.
    (instance / "buffer_percent").write_text("0")
    for event in EVENTS:
        (instance / "events" / event / "enable").write_text("1")
    (instance / "tracing_on").write_text("1")


class Recording:
    def __init__(self, root, metadata):
        self.root = root
        self.session = Path(tempfile.mkdtemp(prefix=f"{time.time_ns()}-", dir=root))
        self.output = None
        self.size = 0
        self.sequence = 0
        save_json(self.session / "metadata.json", metadata)
        sync_directory(root)
        self.rotate()

    def rotate(self):
        self.close()
        # Reserve the entire next segment, plus room for statistics updates.
        # Delete oldest trace segments first, keeping their decoding metadata
        # until the session's last trace segment has been removed.
        total = sum(p.stat().st_size for p in self.root.glob("*/*") if p.is_file())
        for old in sorted(self.root.glob("*/*.trace")):
            if total + SEGMENT + METADATA_MARGIN <= LIMIT:
                break
            total -= old.stat().st_size
            old.unlink()
            if old.parent != self.session and not list(old.parent.glob("*.trace")):
                for metadata in old.parent.iterdir():
                    total -= metadata.stat().st_size
                    metadata.unlink()
                old.parent.rmdir()
        if total + SEGMENT + METADATA_MARGIN > LIMIT:
            raise RuntimeError("Trace metadata exceeds retention budget")
        self.output = (self.session / f"{self.sequence:08d}.trace").open("xb", buffering=0)
        self.sequence += 1
        self.size = 0
        sync_directory(self.session)
        sync_directory(self.root)

    def write(self, data):
        while data:
            if self.size == SEGMENT:
                self.rotate()
            count = self.output.write(data[: SEGMENT - self.size])
            self.size += count
            data = data[count:]

    def flush(self):
        if self.output is not None:
            os.fdatasync(self.output.fileno())

    def close(self):
        if self.output is not None:
            self.flush()
            self.output.close()
            self.output = None


def save_stats(instance, session):
    save_json(
        session / "status.json",
        {
            **clocks(),
            "per_cpu": {
                path.parent.name: path.read_text()
                for path in sorted(instance.glob("per_cpu/cpu*/stats"))
            },
        },
    )


def main(instance, root):
    root.mkdir(mode=0o700, parents=True, exist_ok=True)
    # Avoid a second consumer silently splitting the evidence stream.
    with (root / "recorder.lock").open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        configure(instance)
        recording = Recording(
            root,
            {
                **clocks(),
                "boot_id": Path("/proc/sys/kernel/random/boot_id").read_text().strip(),
                "uname": list(os.uname()),
                "cmdline": Path("/proc/cmdline").read_text(),
                "modules": Path("/proc/modules").read_text(),
                "trace_clock": (instance / "trace_clock").read_text(),
                "buffer_total_size_kb": (instance / "buffer_total_size_kb").read_text(),
                "event_formats": {
                    event: (instance / "events" / event / "format").read_text()
                    for event in EVENTS
                },
            },
        )
        stopping = False

        def stop(_signum, _frame):
            nonlocal stopping
            stopping = True

        signal.signal(signal.SIGTERM, stop)
        signal.signal(signal.SIGINT, stop)
        fd = os.open(instance / "trace_pipe", os.O_RDONLY | os.O_NONBLOCK)
        try:
            save_stats(instance, recording.session)
            print(f"Recording to {recording.session}; retention {LIMIT} bytes", flush=True)
            next_flush = time.monotonic() + 1
            next_stats = time.monotonic() + 60
            while not stopping:
                ready, _, _ = select.select([fd], [], [], max(0, next_flush - time.monotonic()))
                if ready:
                    try:
                        data = os.read(fd, 65536)
                    except BlockingIOError:
                        continue
                    if not data:
                        raise RuntimeError("Unexpected end of trace_pipe")
                    recording.write(data)
                now = time.monotonic()
                if now >= next_flush:
                    recording.flush()
                    next_flush = now + 1
                if now >= next_stats:
                    save_stats(instance, recording.session)
                    next_stats = now + 60
        finally:
            os.close(fd)
            recording.close()
            save_stats(instance, recording.session)
            # Leave tracing enabled: a restarting reader can drain the backlog.


if __name__ == "__main__":
    main(Path(sys.argv[1]), Path(sys.argv[2]))
