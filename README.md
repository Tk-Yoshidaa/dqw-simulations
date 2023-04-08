# dqw-loot-sim

## Usage
### For single simulation

Run julia

```
julia -i main.jl
```

Call `run` function with the mode `0`

```
run(0, [n_D, n_C, n_B, n_A, n_S])
```

You can omit the second argument if you have no hearts
```
run(0)
```

### For multiple simulations

```
julia -i main.jl
```

Call `run` function with the mode `1`, and GUI window will open

```
run(1, [n_D, n_C, n_B, n_A, n_S])
```
