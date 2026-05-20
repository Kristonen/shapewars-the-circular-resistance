# Shapewars: The Circular Resistance

> 📢 **Project Notice:** This repository contains the public development of the official **Demo** for *Shapewars: The Circular Resistance*. The full version of the game is planned for a commercial release on **Steam** and **Itch.io**. 
> 
> 📄 **License:** All rights reserved. The source code is public solely for educational, portfolio, and personal evaluation purposes. Commercial redistribution, creating copycat versions, or selling the code is strictly prohibited. (See LICENSE for details).

## Introduction

This is a fast-paced rogue-lite shoot 'em up built with [Odin](https://odin-lang.org) and [Raylib](https://www.raylib.com). The game is inspired by [Vampire Survivors](https://store.steampowered.com/app/1794680/Vampire_Survivors), but instead of automatic attacking, the player has full control over shooting and unique abilities.

## Lore

This game is the first entry into the *Shapewars Saga*.

The tyrannical **Rectangle Empire** is expanding and seeking absolute world domination over the entire universe. In **The Circular Resistance**, you take control of a young circle fighting back against the overwhelming rectangular forces. Will you roll with the punches, or will you be cornered?

## Features

* **Active Combat:** Manual aiming and shooting.
* **Abilities:** Different abilities that can be unlocked while playing.
* **Progression:** Between runs you can upgrade your weapon or ability.
* **Horde Survival:** Face waves of enemies with different behaviors.
* **Bosses:** In addition to enemies, there are also different bosses.
* **Built from Scratch:** Leveraging Odin and Raylib the lightweight way.

## Goals

This repository marks two major milestones for me:
1. Developing my **very first video game** from scratch.
2. My introduction to **Odin** as my first systems programming language.

I am using this project to dive deep into game loops, collision detection, and memory management.

### Subgoals

* First touch with shader programming (GLSL).

## Architecture

The project is built around a classic **Core Game Loop**. To keep the codebase *modular* and *maintainable*, the gameplay logic is strictly separated into three main phases executed every frame:

1. **[Check Collisions:](https://github.com/Kristonen/shapewars-the-circular-resistance/blob/main/source/game_collision.odin)** Evaluates physics and interactions between entities (e.g., Circles and Rectangles, interaction with NPCs and UI elements, projectiles hitting walls or targets).
2. **[Update Game:](https://github.com/Kristonen/shapewars-the-circular-resistance/blob/main/source/game_update.odin)** Updates positions, timers, enemy behaviors, player inputs, and state changes based on delta time.
3. **[Draw Game:](https://github.com/Kristonen/shapewars-the-circular-resistance/blob/main/source/game_draw.odin)** Renders the current frame to the screen using Raylib's hardware-accelerated drawing functions.

## Current Project Status & Mindset

Please note that this is a **learning project**. My primary focus is understanding the core mechanics of game development, getting comfortable with the Odin programming language and ecosystem, and creating my first video game.

### Because of this:
* **Function over Perfection:** The priority is a working, fun game. The code is not always perfectly optimized or strictly elegant yet.
* **Expanding my Paradigm Horizon:** Coming from an Object-Oriented background (mainly C#), one of my main challenges and goals is learning how to think in a procedural, data-oriented way. Instead of forcing classic OOP design patterns (like the Strategy, Singleton, Decorator, etc.) where they don't fit, I want to expand my horizon and learn how to solve these architectural problems using idiomatic Odin features like composition and function pointers.

Feedback, tips, and constructive code reviews/advice are always highly appreciated!

## How to Run

Since the game is actively in development, there are **no pre-compiled releases yet**. If you want to try it out, you can easily run it from the source code.

### Prerequisites

* You need to have the [Odin Compiler](https://odin-lang.org/docs/install/) installed and added to your system's PATH.
    * *If you need help setting up Odin, check out this excellent [Video Guide by Karl Zylinski](https://www.youtube.com/watch?v=yq5VabsGz_4)*
* Raylib is bundled via Odin's vendor packages, so no extra setup is required.

### Installation & Launch
Clone this repository:
```bash
git clone https://github.com/Kristonen/shapewars-the-circular-resistance.git
```
Navigate to the source directory:
```bash
cd shapewars-the-circular-resistance/source
```
Run the game using the Odin compiler:
```bash
odin run .
```

### Controls

* Move: **W A S D**
* Aim: **Mouse**
* Shoot: **Left Mouse Button**
* Special Ability: **Spacebar**
* Interaction: **E**
* Pause: **Escape**