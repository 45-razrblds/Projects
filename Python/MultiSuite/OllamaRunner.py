#!/usr/bin/env python3
import subprocess
import sys
import shutil
import curses
import datetime
import time
from typing import List

VERSION = "1.1.0"

LOADING_ANIMATION = [",", "\u25FC\u25FB"]

def check_ollama_installed() -> None:
    if shutil.which("ollama") is None:
        print("Error: 'ollama' command not found. Please install Ollama and ensure it's in your PATH.")
        sys.exit(1)

def draw_header(stdscr):
    stdscr.addstr(1, 2, "   ___  __  ___  ___  _________ ")
    stdscr.addstr(2, 2, r"  / _ \/ / / / |/ / |/ / __/ _ \ ")
    stdscr.addstr(3, 2, r" / , _/ /_/ /    /    / _// , _/ ")
    stdscr.addstr(4, 2, r"/_/|_|\____/_/|_/_/|_/___/_/|_| ")

def list_installed_models(stdscr) -> List[str]:
    stdscr.clear()
    draw_header(stdscr)
    stdscr.addstr(8, 2, "Fetching installed models... Please wait.\n", curses.A_DIM)
    stdscr.refresh()

    try:
        process = subprocess.Popen(
            ["ollama", "list"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )

        animation_index = 0
        while process.poll() is None:
            stdscr.addstr(9, 4, f"Loading {LOADING_ANIMATION[animation_index % len(LOADING_ANIMATION)]}")
            stdscr.refresh()
            animation_index += 1
            time.sleep(0.1)

        stdout, stderr = process.communicate()
        if process.returncode != 0:
            stdscr.addstr(10, 2, "Error fetching installed models.", curses.A_BOLD)
            stdscr.refresh()
            time.sleep(2)
            sys.exit(1)
    except Exception as e:
        stdscr.addstr(10, 2, f"Unexpected error: {str(e)}", curses.A_BOLD)
        stdscr.refresh()
        time.sleep(2)
        sys.exit(1)

    lines = stdout.strip().splitlines()
    if not lines:
        stdscr.addstr(10, 2, "No output from 'ollama list'.", curses.A_BOLD)
        stdscr.refresh()
        time.sleep(2)
        sys.exit(1)

    models = [line.split()[0] for line in lines[1:] if line.split()]
    return models

def start_model(model_name: str) -> None:
    curses.endwin()
    print(f"\nStarting model: {model_name}\n")
    subprocess.run(["ollama", "run", model_name])

def menu(stdscr, models: List[str]) -> str:
    curses.curs_set(0)
    selected = 0
    while True:
        stdscr.clear()
        draw_header(stdscr)
        max_y, max_x = stdscr.getmaxyx()

        for i, model in enumerate(models):
            y = i + 8
            if y >= max_y:
                continue

            display_text = model[:max_x - 4] if len(model) > max_x - 4 else model

            try:
                if i == selected:
                    stdscr.attron(curses.color_pair(1))
                    stdscr.addstr(y, 4, display_text)
                    stdscr.attroff(curses.color_pair(1))
                else:
                    stdscr.addstr(y, 4, display_text)
            except curses.error:
                pass

        stdscr.refresh()
        key = stdscr.getch()

        if key == curses.KEY_UP and selected > 0:
            selected -= 1
        elif key == curses.KEY_DOWN and selected < len(models) - 1:
            selected += 1
        elif key in [10, 13]:
            return models[selected]
        elif key in [ord('q'), ord('Q')]:
            curses.endwin()
            sys.exit(0)

def main(stdscr) -> None:
    check_ollama_installed()
    models = list_installed_models(stdscr)
    if not models:
        curses.endwin()
        print("No models installed.")
        sys.exit(1)

    curses.start_color()
    curses.init_pair(1, curses.COLOR_BLACK, curses.COLOR_CYAN)

    selected_model = menu(stdscr, models)
    start_model(selected_model)

if __name__ == '__main__':
    curses.wrapper(main)
