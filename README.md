# 3D Mutable *Cellular Automata*
This repository shows a simple implementation of a mutable *cellular automaton* inside a three-dimensional environment running in the Godot engine. The main objective of the simulation is to show how a simple mutation mechanism can affect the overall growth of a population.

## Context
This code was built for the METEP ("Metodologias de Pesquisa" or "Research Methodologies") course at my university. Also, it was built over a span of 2 months, so it may still have some rough edges.

## How to run
Actually, it is pretty easy to run the project. You just need to do two things:
1. Add the `cube.tscn` into the the `root.tscn`
2. Add the ruleset (in this example, `conways-rule.gd`) to the `root.tscn`

## Results
Even though the mutation code is simple, the outcome can be very surprising. We could consistently get populations with 20 generations when using mutation (without it, the average was 7–8 generations).

> **IMPORTANT:** I did not have time to collect relevant quantitative data, so I recommend running tests yourself and capturing some numbers before trusting this README. 

### Visual result
![mutation](assets/mutation.GIF)

## Conclusion
If you want to know more about it, take a look at my research in `./docs/final-docs.pdf` to better understand how the code works. 

Also, feel free to change the code (especially to solve optimization issues that come from using the CPU instead of the GPU to process the generations).
