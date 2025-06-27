.MODEL SMALL
.STACK 100h

.DATA
    menu_title      DB 13,10,'==========================',13,10
                    DB 'TO-DO RPG SYSTEM',13,10
                    DB '1. Add Task',13,10
                    DB '2. Show Tasks',13,10
                    DB '3. Complete Task',13,10
                    DB '4. View Stats',13,10
                    DB '5. Upgrade Stats',13,10
                    DB '6. Exit',13,10,13,10
                    DB 'Enter choice: $'
    
    ; task management
    task_prompt     DB 13,10,'Enter new task (max 20 chars): $'
    task_added      DB 13,10,'Task added successfully.$'
    pending_header  DB 13,10,'--- Pending Tasks ---',13,10,'$'
    completed_header DB 13,10,'--- Completed Tasks ---',13,10,'$'
    no_tasks        DB 'No tasks found.$'
    complete_prompt DB 13,10,'Enter task number to complete: $'
    task_completed  DB 13,10,'Task marked as completed.',13,10
                   DB '+10 XP and +5 coins awarded!$'
    invalid_task    DB 13,10,'Invalid task number!$'
    
    ; stats display
    stats_header    DB 13,10,'--- Player Stats ---',13,10,'$'
    xp_label        DB 'XP: $'
    coins_label     DB 13,10,'Coins: $'
    stamina_label   DB 13,10,13,10,'Stamina: $'
    strength_label  DB 13,10,'Strength: $'
    health_label    DB 13,10,'Health: $'
    
    ; upgrade menu
    upgrade_header  DB 13,10,'Which stat to upgrade?',13,10,13,10
                    DB '1. Stamina (10 coins)',13,10
                    DB '2. Strength (15 coins)',13,10
                    DB '3. Health (10 coins)',13,10,13,10
                    DB 'Enter choice: $'
    upgrade_success DB 13,10,'Upgrade successful!$'
    insufficient    DB 13,10,'Insufficient coins!$'
    remaining_coins DB 13,10,'Remaining coins: $'
    
    ; general messages
    newline         DB 13,10,'$'
    press_key       DB 13,10,'Press any key to continue...$'
    goodbye         DB 13,10,'Thanks for playing! Goodbye!$'
    dot             DB '. ','$'
    
    ; game data
    max_tasks       EQU 10
    task_length     EQU 21          ; 20 chars + null terminator
    
    ; task storage (10 tasks * 21 bytes each)
    tasks           DB max_tasks * task_length DUP(0)
    task_status     DB max_tasks DUP(0)        ; 0 = empty, 1 = pending, 2 = completed
    task_count      DB 0
    
    ; initial player stats
    player_xp       DW 0
    player_coins    DW 0
    player_stamina  DB 40
    player_strength DB 10
    player_health   DB 50
    
    ; temp variables
    choice          DB 0
    temp_number     DW 0
    input_buffer    DB 25 DUP(0)


.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

main_loop:
    CALL show_menu
    CALL get_choice
    
    CMP AL, '1'
    JE add_task_handler
    CMP AL, '2'
    JE show_tasks_handler
    CMP AL, '3'
    JE complete_task_handler
    CMP AL, '4'
    JE view_stats_handler
    CMP AL, '5'
    JE upgrade_stats_handler
    CMP AL, '6'
    JE exit_program
    
    JMP main_loop

add_task_handler:
    CALL add_task
    JMP main_loop

show_tasks_handler:
    CALL show_tasks
    JMP main_loop

complete_task_handler:
    CALL complete_task
    JMP main_loop

view_stats_handler:
    CALL view_stats
    JMP main_loop

upgrade_stats_handler:
    CALL upgrade_stats
    JMP main_loop


exit_program:
    MOV AH, 4Ch
    INT 21h

MAIN ENDP