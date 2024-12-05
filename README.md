# logic-sim
This will be a logic simulation program in Godot 4 inspired by Sebastian Lague's project. The project is currently in pre-alpha state. The main goal is to create a software that is both easy to use but also has less limitions than either Sebastian's original project or any of the forks. For now the main focus is to get the basic functionality down and with that to make the program useable. Afterwards I woul like to implement the following:
- [ ] HDD: A permanent storage device, with more storage than DSL-CE (128 bits)
- [ ] BUS: A bus and tri-state logic system similar to the one Sebastian showcased in his last video. 
- [ ] Display: A modular display module with multiple colors.
- [ ] 7 Segment display: For showcasing different numbers or at some point maybe even letters
- [ ] Clock: A chip which provides a constant pulsing
- [ ] Input: I would like to have something where the user can input stuff on runtime. I will probably be a LineEdit which will take an input, and any time that goes from low to high it will output the next character in a binary format. If the last character has been reached it will just loop around. Another output will tell the number of characters. 
- [ ] Persistent Terminal Groups: The way Sebastian implemented terminal groups is nice but it also means that if you then try to edit the chip the terminal groups will not be displayed any more. 

## Roadmap
- [x] Four sided Chips: Chips can now have input and output terminals on all sides.
- [ ] Better identification system for blocks and wires
- [ ] Save wires completely, with their additional points. 
- [ ] Possibility to view and edit blocks after they have been saved.
- [ ] Directories for blocks
- [ ] Block path validation
- [ ] More advanced blocks. See above.
