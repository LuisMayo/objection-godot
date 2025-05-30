# Objection Godot *(name pending)*

>[!WARNING]
> This is a work in progress, and is currently not suitable for general use.

This project reads an XML-like file (currently with a hard-coded name, but will be changed in the future) and plays it out as an *Ace Attorney* scene without any user input, then exits automatically.
For script examples, see the `test_*.xml` files.

This project currently uses Godot 4.4-beta.

## Usage

By default, the program will read from `script.xml` in the root of the project folder.

To make it read another script file, pass it as a command-line argument with the `--render-script` flag, like so:

```
-- --render-script="path/to/my/script.xml"
```

Note that the double hyphens (`--`) must be placed before the argument.

## Roadmap

See the [issues page](https://github.com/Meorge/objection-godot/issues) for planned features and fixes.

## Credits

Obviously, this project as a whole is based on the *Ace Attorney* games, especially the versions for the Nintendo DS.

This project is a continuation of the [Objection! rendering engine](https://github.com/LuisMayo/objection_engine), maintained by [LuisMayo](https://github.com/LuisMayo).

Many of the assets (including character animations and UI elements) were ripped by contributors to the [Court Records website](https://www.court-records.net).

The *Apollo Justice* "Perceive" background graphics were [ripped from the iOS version of the game by Reddit user u/JBoote1](https://www.reddit.com/r/AceAttorney/comments/mon8pi/comment/gu59ae0/).

The Mood Matrix graphics were extracted by [ChingKittyCat on Spriters Resource](https://www.spriters-resource.com/3ds/phoenixwrightaceattorneydualdestinies/sheet/151689/).

The Mood Matrix marker sound effects were recorded by [Discord user Jofe and posted on the Ace Attorney Case Developers Discord server](https://discord.com/channels/226527042240249866/226819687114211329/1243706139397455913), then trimmed by Meorge.

Other Mood Matrix sound effects were ripped by [user venser on the Court Records forums](https://www.forums.court-records.net/viewtopic.php?f=10&t=30410).

The math for the moon-style progress indicator was done by [Valérie/slartibartfass](https://github.com/vbettaque).

### Fonts

- Name tag font is [Ace Name by user guiguiba on FontStruct](https://fontstruct.com/fontstructions/show/1799842/ace-name)
- Text box body font is [Igiari Cyrillic by user trtrtrtr on FontStruct](https://fontstruct.com/fontstructions/show/1791074/igiari-4), forked from [Igiari by user caveras](https://fontstruct.com/fontstructions/show/1029846/igiari)
- Several fonts are from [RapBattleEditor0510's "Phoenix Wright: Ace Attorney Font Pack 2" on DeviantArt](https://www.deviantart.com/rapbattleeditor0510/art/Fonts-Phoenix-Wright-Ace-Attorney-Font-Pack-2-873499678):
  - Verdict label uses DFMincho StdN W12
  - "Witness Testimony" label uses DFP Gothic EB
  - Mood Matrix bootup percent-complete label uses DFPKaGei W6
- Flashing top-left "Testimony" label uses DIN Condensed (Bold)

- "New evidence" box title text font is [Ace Check by user guiguiba on FontStruct](https://fontstruct.com/fontstructions/show/1860020/ace-check)
- "New evidence" box body text font is [Court Records by user guiguiba on FontStruct](https://fontstruct.com/fontstructions/show/1847111/court-records)

## License

MIT

(Obviously, there's *Ace Attorney* assets in here, so take that into consideration if you're gonna do stuff with it)
