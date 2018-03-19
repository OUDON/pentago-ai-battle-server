# Pentago AI Battle Server

## Overview
[Pentago](https://en.wikipedia.org/wiki/Pentago) is a two-player perfect information game.
Pentago AI Battle Server is a tool for running AI battle of Pentago.
The tool communicates with the AI agents via stdin and stdout.

## Usage
### Write your AI client
Write your AI client and make the executable.

For example, use sample AI clinet `sample_ai/random.cpp` and compile it:

``` sh
g++ ./sample_ai/randome.cpp -o ai_sample.out
```

### Run the server program
To execute AI battle, use the following command:

```
ruby pentago_battle.rb NAME1 CMD1 NAME2 CMD2
```

`NAME1` is the first player's name, `CMD1` is the command to execute the first player's AI client,
`NAME2` is the second player's name and `CMD2` is the command to execute the second player's AI client.

For example,

```
ruby pentago_battle.rb Alice ./ai_sample.out Bob ./ai_sample.out
```

## Rules of the Game
Pentago is played on a 6x6 board composed of four 3x3 sub-boards.
Two players alternate turns.
Each turn, the player places a stone in an empty cell and rotate one of the sub-boards by 90 degrees clockwise or counterclockwise.
The goal of each player is to get five stones in a row horizontally, vertically, or diagonally.

### Input and Output
#### Initialize Input
When the game is beginning, you will be given an input in the following format:

```
[ W ]
[ H ]
[ id ]
```

where `W` is the width of the board (always 6), `H` is the height of the board (always 6)
and `id` is your id in the game (0 is for the first player, 1 is for the second player).

#### Input for one game turn
Each your game turn, you will be given an input:

```
[ turn ]
[ time ]
[ cell(0, 0) ][ cell(1, 0) ] ... [ cell(5, 0) ]
[ cell(0, 1) ][ cell(1, 1) ] ... [ cell(5, 1) ]
...
[ cell(0, 5) ][ cell(1, 5) ] ... [ cell(5, 5) ]
```

where `turn` is the turn number (one-based) and `time` is the remaining computation time in milliseconds.
The state of the game board is given as a matrix of letters `cell(x, y)`.
If `cell(x, y)` is '-', it means that the cell is empty.
If `cell(x, y)` is 'o', it means that the first player's stone is placed on the cell.
And if `cell(x, y)` is 'x', it means that the second player's stone is placed on the cell.

#### Output for one game turn
```
[ put_x ] [ put_y ] [ rotate_idx ] [ rotate_direction ]
```

## License
This software is released under the MIT License.
