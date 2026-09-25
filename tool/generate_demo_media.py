"""Generates the bundled demo media (royalty-free by construction).

Creates short silent H.264 clips with a big running timer (handy for checking
"resume from last position"), two course thumbnails, and one intentionally
corrupt video used to demo the player's error state.

Usage (from the project root):  python3 tool/generate_demo_media.py
Requires: opencv-python + numpy. On macOS the AVFoundation writer produces
H.264 directly; otherwise it falls back to mp4v + `avconvert`.
"""

import os
import random
import shutil
import subprocess
import tempfile

import cv2
import numpy as np

W, H, FPS = 640, 360, 24
VIDEOS = [
    # (file name, seconds, background BGR, accent BGR)
    ("lesson_1.mp4", 20, (96, 110, 14), (180, 230, 120)),
    ("lesson_2.mp4", 30, (120, 60, 50), (240, 190, 160)),
    ("lesson_3.mp4", 40, (40, 90, 150), (140, 210, 250)),
]
ROOT = os.path.join(os.path.dirname(__file__), "..", "assets")


def draw_frame(index, total_frames, seconds, bg, accent, clip_no):
    frame = np.zeros((H, W, 3), np.uint8)
    frame[:] = bg
    t = index / FPS
    # Moving dot so motion is visible.
    x = int((index % (FPS * 4)) / (FPS * 4) * (W - 80)) + 40
    cv2.circle(frame, (x, 70), 14, accent, -1, cv2.LINE_AA)
    cv2.putText(frame, f"Thaheen demo clip {clip_no}", (40, 140),
                cv2.FONT_HERSHEY_SIMPLEX, 0.9, (255, 255, 255), 2, cv2.LINE_AA)
    timer = f"{int(t) // 60}:{int(t) % 60:02d} / {seconds // 60}:{seconds % 60:02d}"
    cv2.putText(frame, timer, (40, 250), cv2.FONT_HERSHEY_DUPLEX, 2.2,
                (255, 255, 255), 3, cv2.LINE_AA)
    # Progress line along the bottom.
    cv2.rectangle(frame, (0, H - 12), (W, H), (0, 0, 0), -1)
    cv2.rectangle(frame, (0, H - 12), (int(W * index / total_frames), H), accent, -1)
    return frame


def open_writer(path):
    fourcc = cv2.VideoWriter_fourcc(*"avc1")
    writer = cv2.VideoWriter(path, cv2.CAP_AVFOUNDATION, fourcc, FPS, (W, H))
    if writer.isOpened():
        return writer, False
    fallback = cv2.VideoWriter(path, cv2.VideoWriter_fourcc(*"mp4v"), FPS, (W, H))
    return fallback, True


def make_video(name, seconds, bg, accent, clip_no):
    out = os.path.join(ROOT, "videos", name)
    tmp = os.path.join(tempfile.mkdtemp(), name)
    writer, needs_transcode = open_writer(tmp)
    total = seconds * FPS
    for i in range(total):
        writer.write(draw_frame(i, total, seconds, bg, accent, clip_no))
    writer.release()
    if needs_transcode:
        subprocess.run(["avconvert", "-s", tmp, "-p", "Preset640x480",
                        "-o", out, "--replace"], check=True)
    else:
        shutil.move(tmp, out)
    print(f"{name}: {os.path.getsize(out) / 1024:.0f} KB")


def make_thumbnail(name, top, bottom, shape):
    img = np.zeros((360, 640, 3), np.uint8)
    for y in range(360):
        a = y / 359
        img[y, :] = [int(top[c] * (1 - a) + bottom[c] * a) for c in range(3)]
    white = (255, 255, 255)
    if shape == "bones":
        for cx, cy in [(200, 180), (440, 180)]:
            cv2.line(img, (cx - 70, cy), (cx + 70, cy), white, 18, cv2.LINE_AA)
            for dx in (-70, 70):
                cv2.circle(img, (cx + dx, cy - 14), 16, white, -1, cv2.LINE_AA)
                cv2.circle(img, (cx + dx, cy + 14), 16, white, -1, cv2.LINE_AA)
    else:
        for cx, cy, angle in [(220, 170, 30), (420, 200, -25)]:
            box = cv2.boxPoints(((cx, cy), (150, 56), angle)).astype(np.int32)
            cv2.fillPoly(img, [box], white, cv2.LINE_AA)
            cv2.circle(img, (cx, cy), 6, bottom, -1, cv2.LINE_AA)
    cv2.imwrite(os.path.join(ROOT, "images", name), img)
    print(f"{name} written")


def make_corrupt_video():
    random.seed(42)  # deterministic, and not a media container at all
    path = os.path.join(ROOT, "videos", "corrupt_lesson.mp4")
    with open(path, "wb") as f:
        f.write(bytes(random.getrandbits(8) for _ in range(32 * 1024)))
    print("corrupt_lesson.mp4 written")


if __name__ == "__main__":
    os.makedirs(os.path.join(ROOT, "videos"), exist_ok=True)
    os.makedirs(os.path.join(ROOT, "images"), exist_ok=True)
    for n, (name, secs, bg, accent) in enumerate(VIDEOS, start=1):
        make_video(name, secs, bg, accent, n)
    make_thumbnail("anatomy.png", (120, 130, 20), (60, 70, 10), "bones")
    make_thumbnail("pharmacology.png", (150, 80, 90), (90, 40, 60), "capsules")
    make_corrupt_video()
