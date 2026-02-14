# Vector Descent
This is an example project you can use to learn developing your own games for the atom arcade machine. You are not allowed to use the projects assets in your own projects. They are only ment as learning resources.

No AI was used to create any of the games assets.

## Steup
There is no setup needed. Clone the repository and open it in the Godot Engine. This game is currently using Godot 4.5.1.stable.
The Arcade Connector Extension is already included in the example. If there are bugs, you should check if there is a newer verion of the connector available.

## Export
It is necessary for the game to be registered by the Atom Arcade launcher, that is includes in its gamedirectory a cover.jpg and a and an info.json.

Paste the exported games folder inside the games subdirectory of the Atom Arcade Launcher. After starting the launcher your game should be visible in the menu. Notice: After updating the games library, your game might be missing. The gmes folger gets reset after each update of your library.