# WebRTC-EZ for Godot 4

A Godot 4 plugin that simplifies establishing a WebRTC multiplayer connection. Built to be used with my WebRTC [signaling-server](https://github.com/jleininger/webrtc-ez-server) but easily customizable for any WebRTC project.

## Features

- Easy-to-use WebRTC multiplayer implementation
- Built-in player management system
- Automatic WebRTC connection handling
- Simple lobby system integration

## Installation

1. Download or clone this repository
2. Copy the `addons/webrtc-ez` folder into your Godot project's `addons` directory
3. Enable the plugin in Project Settings -> Plugins
4. You're ready to go!

## Usage

### Basic Setup

1. Add the Client node to your scene.
2. Set the url for your signaling server in the inspector pane.
3. Call `$Client.start()` when you're ready to start the connection.

### Player Management

The plugin includes a built-in player management system:

```gdscript
# Add a player
NetworkManager.add_player(id, player_name)

# Check if in single player mode
if network_manager.single_player:
    # Handle single player logic
```

## Configuration

The default configuration can be modified in the plugin settings:

- Default server URL: `ws://127.0.0.1:9080`

## Requirements

- Godot 4.x
- A WebRTC signaling server (recommended: [WebRTC EZ Server](https://github.com/jleininger/webrtc-ez-server))

## License

MIT

## Credits

Created by [Jadon Leininger](https://jadonl.com)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
