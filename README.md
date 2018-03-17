# Pentago AI Battle Server

## Overview
[Pentago](https://en.wikipedia.org/wiki/Pentago) is a two-player perfect information game.
Pentago AI Battle Server is a tool for running AI battle of Pentago.
The tool communicates with the AI agents via stdin and stdout.

## Rules of the Game
Pentago is played on a 6x6 board composed of four 3x3 sub-boards.
Two players alternate turns.
Each turn, the player places a stone in an empty cell and rotate one of the sub-boards by 90 degrees clockwise or counter clockwise.
The goal of each player is to get five stones in a row horizontally, vertically, or diagonally.

### Input and Output
#### Initialize Input
When the game is beginning, you will be given an input in the follwoing format.

```
[ W ]
[ H ]
[ id ]
```

where `W` is the width of the board (always 6), `H` is the height of the board (always 6)
and `id` is your id in the game (0 is for first player, 1 is for second player).

#### Input for one game turn
```
[ time ]
[ turn ]
[ cell(0, 0) ][ cell(1, 0) ] ... [ cell(5, 0) ]
[ cell(0, 1) ][ cell(1, 1) ] ... [ cell(5, 1) ]
...
[ cell(0, 5) ][ cell(1, 5) ] ... [ cell(5, 5) ]
```

#### Output for one game turn
```
[ put_x ] [ put_y ] [ rotate_idx ] [ rotate_direction ]
```

## License
This software is released under the MIT License.
