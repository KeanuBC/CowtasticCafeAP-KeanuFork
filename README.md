# AP Cowtastic Open Café — Keanu Fork

An unofficial Archipelago randomizer implementation for Cowtastic Open Café.

This repository contains a modified version of the original AP Cowtastic Open Café project, with additional changes and improvements maintained independently.

> **Content Warning:** This project contains NSFW content, including suggestive themes and audio dialogue. Please keep this in mind before downloading or playing.

---

## 📌 Table of Contents

1. [About](#about)
2. [Project Status](#project-status)
3. [Requirements](#requirements)
4. [Installation](#installation)
5. [Features](#features)
6. [Voice Assets & Credits](#voice-assets--credits)
7. [AI Usage & Development Disclaimer](#ai-usage--development-disclaimer)
8. [Legal Disclaimer](#legal-disclaimer)
9. [Support & Community](#support--community)
10. [Acknowledgments](#acknowledgments)
11. [License](#license)

---

## About

AP Cowtastic Open Café brings Archipelago multiworld randomization to Cowtastic Open Café, allowing players to experience the café's gameplay alongside other Archipelago players.

The randomizer integrates directly with the Unity game, connecting to an Archipelago server to receive items, complete checks, and participate in multiworld progression.

This is an unofficial fork. It is not affiliated with or endorsed by the original game's developers or the Archipelago team.

### What does this fork contain?

- An Archipelago world (`.apworld`) for generating randomized seeds.
- A modified Unity game client that communicates with Archipelago servers.
- Item and location randomization.
- Café upgrades and progression mechanics.
- Cosmetic unlocks and additional gameplay features.
- Support for optional Archipelago features such as DeathLink.

---

## Project Status

This project is independently maintained as a fork of the original AP Cowtastic Open Café implementation.

Development and improvements may continue independently of the original repository.

Contributions, bug reports, and suggestions are welcome, provided they are relevant to this fork.

---

## Requirements

Before playing, you will need:

- An installation of [Archipelago](https://archipelago.gg/).
- The Cowtastic Open Café game files included with the release.
- A compatible operating system (Windows, Linux, or macOS).
- An Archipelago multiworld seed and its corresponding player YAML.

---

## Installation

### 1. Download the files

Visit the repository's [Releases](../../releases/latest) page and download the latest available release.

The release should include:
- The Archipelago world file (`.apworld`).
- The game package (`.zip`).

### 2. Install the Archipelago world

1. Locate the downloaded `.apworld` file.
2. Double-click it to install it into your Archipelago installation.
3. Open Archipelago and select the option to generate templates.

### 3. Generate your YAML

1. Locate the generated Cowtastic Open Café YAML template.
2. Configure your desired randomizer settings.
3. Place the YAML file in your Archipelago `Players` directory.
4. Generate your multiworld game.

### 4. Launch the game

1. Extract the downloaded game ZIP somewhere convenient.
2. Open the extracted folder.
3. Launch `CowtasticCafeKeanuFork.exe` (or the equivalent executable for your platform).
4. You should be greeted with the Archipelago connection screen.

### 5. Connect to your multiworld

Enter the connection information for your Archipelago session:

- **Server:** The address of your Archipelago server.
- **Port:** The server's connection port.
- **Slot:** Your player slot name.
- **Password:** Your server password, if one is required.

Once connected, you can begin playing!

---

## Features

The randomizer includes several mechanics and optional settings.

- **Ingredient Progression:** Unlock ingredients through randomized item collection.
- **Serve Checks:** Earn location checks by fulfilling customer orders.
- **Shop Locations:** Purchase randomized upgrades using in-game currency.
- **Cosmetics:** Receive cosmetic unlocks through the item pool.
- **Stretchy Candy:** Increase milk capacity and work toward the game's victory condition.
- **DeathLink:** Optionally interact with other players through Archipelago's DeathLink system.
- **Censorship Mode:** Provides alternate names for certain items and locations.
- **Milk Flow Adjustments:** An optional setting for controlling milk production rate.

Some features are configurable through the player's YAML settings.

---

## Voice Assets & Credits

The project uses voice content originally provided by its respective creators.

The voice sample included in the original project was generously provided by **Lewdheart**. All rights to that specific voice recording remain with its original creator.

Additional acknowledgments:

- **Noa3** — Original Cowtastic Open Café project and source material.
- **Original AP Cowtastic Café contributors** — Development of the original Archipelago implementation.
- **Archipelago** — Multiworld randomizer framework.

Please respect the rights of the original creators when redistributing or modifying their work.

---

## AI Usage & Development Disclaimer

Transparency regarding AI usage is important to this project.

The original upstream project used **Claude AI (Anthropic)** during its development.

However, the modifications and changes I have personally made to this fork were written and implemented by me without AI assistance.

The use of AI in the upstream project's development should not be interpreted as meaning that all work in this repository was AI-generated.

Credit for original work remains with its respective authors and contributors.

[Read the full AI Usage Disclosure](AIUsageDisclosure.md).

---

## Legal Disclaimer

This is an unofficial, non-commercial community project.

- This project is not affiliated with the original game's developers or Archipelago.
- Original game content, voice recordings, and other third-party materials remain the property of their respective owners.
- Please do not redistribute third-party content outside the permissions granted by its respective creator.
- This fork does not claim ownership of the original project or its assets.

### Licensing

The original repository includes an MIT license for its licensed software.

Please refer to the included `LICENSE.txt` for the applicable license terms. Third-party assets, voice recordings, and other materials may have separate licensing requirements.

---

## Support & Community

For help with Archipelago-related questions, multiworld setup, or gameplay issues, you can visit the AP After Dark Discord server and look for the Cowtastic Café community.

Bug reports and suggestions specific to this fork should be submitted through this repository's [Issues](../../issues) page.

---

## Acknowledgments

Special thanks to everyone involved in the original Cowtastic Open Café project, the original Archipelago implementation, and the Archipelago community.

This fork would not exist without their previous work.

---

## License
Split license:

| Component       | License           | Commercial Use | ShareAlike |
|----------------|-------------------|----------------|------------|
| Code (C#)       | MIT / Apache 2.0  | ✅ Allowed      | ❌          |
| Assets / Audio  | CC BY-NC-SA 4.0   | ❌ Forbidden    | ✅ Required |

This means:
- Your code is open and usable by others
- Media/voices can be remixed or reused, **but not sold**
- Derivative projects must use the same license for media
