# 8086 Assembly To-Do RPG

A text-based reward-based To-Do List game built in 8086 16-bit Assembly.  
Complete real-life tasks to earn XP and coins, then use those rewards to upgrade your character’s **Stamina**, **Strength**, and **Health**.

## 📌 Team
1. [Junaid Sultan](https://github.com/junaidsultanxyz)
2. [Messam Shahzad](https://github.com/Misu06)

---

## Functional Requirements

### Task Management
- [x] Add a task (fixed-length string, e.g., 20 characters)
- [x] View all pending tasks
- [x] Mark a task as completed
- [ ] Limit: 10 tasks max

### Character System
- [x] Character has 3 upgradable stats:
  - Stamina (starts at 40)
  - Strength (starts at 1)
  - Health (starts at 50)

### Reward System
- [x] Completing a task gives:
  - +10 XP
  - +5 Coins
- [x] XP and coins are tracked separately

### Stat Upgrades
- [x] Spend coins to increase stats:
  - Stamina: +1 → 10 coins
  - Strength: +1 → 15 coins
  - Health: +1 → 10 coins
- [x] Show an error if coins are insufficient

### Display & Menus
- [x] Show all stats
- [x] Show current XP and coins
- [x] Show completed and pending tasks

### Optional Features (Future Work)
- [ ] Save/load progress using DOS interrupt 21h
- [ ] Add task difficulty and scaling rewards
- [ ] Add scrollable task list if >10 tasks
- [ ] Use BIOS to draw colored text or bordered UI

---

## 🖥️ Text-Based UI Structure

==========================
TO-DO RPG SYSTEM
1. Add Task
2. Show Tasks
3. Complete Task
4. View Stats
5. Upgrade Stats
6. Exit

Enter choice: _


### Add Task
Enter new task (max 20 chars): Read textbook
Task added successfully.


### Show Tasks
--- Pending Tasks ---
1. Read textbook
2. Drink water
3. Practice coding


### Complete Task
Enter task number to complete: 2
Task marked as completed.
+10 XP and +5 coins awarded!


### View Stats
--- Player Stats ---
XP: 45
Coins: 20

Stamina: 11
Strength: 5
Health: 10


### Upgrade Stats
Which stat to upgrade?

1. Stamina (10 coins)
2. Strength (15 coins)
3. Health (10 coins)

Enter choice: 1

Upgraded Stamina! New value: 12
Remaining coins: 10



---

## Built With
- 8086 Assembly Language
- EMU8086 / MASM / TASM
- DOSBox (for execution/testing)

---

## Recommended Tools
- [EMU8086 IDE](https://emu8086-microprocessor-emulator.en.softonic.com/)
- [VS Code + MASM/TASM Extension](https://code.visualstudio.com/download)

After installing VS Code, Quick Open (Ctrl + P) and paste (ext install xsro.masm-tasm) to install MASM/TASM extension. Right click the .asm file and click on "Run ASM Code"
