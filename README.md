![PolarSpirit](https://github.com/user-attachments/assets/bd190bb7-cf72-484b-bbb3-caa053c251dd)

Polar Spirit is a 2D Platformer Adventure made with Godot 4.2. It was developed in 10 weeks in the beginning of 2024 as a student project in the S4G School for Games. For version control, we used [Mercurial](https://www.mercurial-scm.org/).

Enjoy the game on [itch.io](https://s4g.itch.io/polar-spirit)!

## Responsibilities
Since I was the only programmer in the team, my main responsibilities were the technical aspect and project architecture. I also created the SFX, music, most of the game's VFX and implemented the following assets:
- all characters (movement/combat/dialogues)
- animations (characters/environment)
- a variety of interactive platforms
- tilemaps and level design tools

## Highlights
**[Player](https://github.com/wolfgangkatzensprung/PolarSpirit/blob/main/Scripts/Player.gd)**

The main character combining innovative mechanics (e.g. BubbleFly) with established features such as [riding spline slopes](https://github.com/wolfgangkatzensprung/PolarSpirit/blob/main/Scripts/IceSlide.gd), basic gamefeel improvements like coyote time, jump buffering, etc.

**[Bubbles](https://github.com/wolfgangkatzensprung/PolarSpirit/blob/main/Scripts/Bubbles.gd)**

The player can use bubbles are as projectiles, but also for flying. The can grow larger in size and thus become slower. See [Bubble](https://github.com/wolfgangkatzensprung/PolarSpirit/blob/main/Scripts/Bubble.gd) for the individual bubble node.

**[Enemy](https://github.com/wolfgangkatzensprung/PolarSpirit/blob/main/Scripts/Enemy.gd)**

A dangerous, classic platforming enemy the player can encase in his bubbles, using them as jump pads.

**[Wind](https://github.com/wolfgangkatzensprung/PolarSpirit/blob/main/Scripts/Wind.gd)**

As we all know, penguins are not capable of flying. That's because regular penguins don't have a magical bubble to carry them in the wind!
  
## Dependencies
- [Dialogue Manager](https://godotengine.org/asset-library/asset/1432)
- [Phantom Camera](https://godotengine.org/asset-library/asset/1822)
- [Save System](https://godotengine.org/asset-library/asset/2217)
