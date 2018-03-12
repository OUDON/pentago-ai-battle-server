# PENTAGO AI Battle Server

## Detail of the Game
### Rules

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

#### Example

