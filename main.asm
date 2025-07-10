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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; MAIN

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FR FUNCTIONS

; add a new task
add_task PROC
    ; check if we have space for more tasks
    CMP task_count, max_tasks
    JGE task_limit_reached
    
    LEA DX, task_prompt
    CALL print_string
    
    ; get task input
    LEA DX, input_buffer
    MOV AH, 0Ah
    MOV input_buffer[0], task_length - 1
    INT 21h
    
    ; find empty slot and copy task
    MOV AL, task_count
    MOV AH, 0
    MOV BL, task_length
    MUL BL                      ; aX = task_count * task_length
    
    MOV SI, AX
    ADD SI, OFFSET tasks        ; sI points to empty task slot
    
    ; copy task from input buffer
    MOV CL, input_buffer[1]
    MOV CH, 0
    LEA DI, input_buffer[2]
    
copy_task:
    MOV AL, [DI]
    MOV [SI], AL
    INC SI
    INC DI
    LOOP copy_task
    
    MOV BYTE PTR [SI], 0        ; null terminate

    ; mark task as pending
    MOV AL, task_count
    MOV AH, 0
    MOV SI, AX
    ADD SI, OFFSET task_status
    MOV BYTE PTR [SI], 1        ; 1 = pending
    
    INC task_count
    
    LEA DX, task_added
    CALL print_string
    CALL pause
    RET

task_limit_reached:
    LEA DX, newline
    CALL print_string
    RET
add_task ENDP


show_tasks PROC
    ; show pending tasks
    LEA DX, pending_header
    CALL print_string
    
    MOV CX, 0                   ; task counter
    MOV BX, 0                   ; task index
    
show_pending_loop:
    CMP BL, task_count
    JGE show_completed_start
    
    MOV SI, BX
    ADD SI, OFFSET task_status
    CMP BYTE PTR [SI], 1
    JNE next_pending
    
    ; display task number
    INC CX
    MOV AX, CX
    CALL print_number
    LEA DX, dot
    MOV AH, 9
    INT 21h
    

    MOV AX, BX
    MOV DL, task_length
    MUL DL
    MOV SI, AX
    ADD SI, OFFSET tasks
    MOV DX, SI
    CALL print_string
    LEA DX, newline
    CALL print_string

next_pending:
    INC BX
    JMP show_pending_loop

show_completed_start:
    LEA DX, completed_header
    CALL print_string
    
    MOV CX, 0                   ; reset counter
    MOV BX, 0                   ; reset index
    
show_completed_loop:
    CMP BL, task_count
    JGE show_tasks_end
    
    ; Check if task is completed
    MOV SI, BX
    ADD SI, OFFSET task_status
    CMP BYTE PTR [SI], 2
    JNE next_completed
    
    ; display task number
    INC CX
    MOV AX, CX
    CALL print_number
    LEA DX, dot
    MOV AH, 9
    INT 21h
    
    MOV AX, BX
    MOV DL, task_length
    MUL DL
    MOV SI, AX
    ADD SI, OFFSET tasks
    MOV DX, SI
    CALL print_string
    LEA DX, newline
    CALL print_string

next_completed:
    INC BX
    JMP show_completed_loop

show_tasks_end:
    CALL pause
    RET
show_tasks ENDP



complete_task PROC
    LEA DX, complete_prompt
    CALL print_string
    
    CALL get_number
    MOV temp_number, AX
    
    ; validate task number (1-based)
    CMP AX, 1
    JL invalid_task_num
    
    ; convert to 0-based and check if it exists
    DEC AX
    CMP AL, task_count
    JGE invalid_task_num
    
    ; check if task is pending
    MOV SI, AX
    ADD SI, OFFSET task_status
    CMP BYTE PTR [SI], 1
    JNE invalid_task_num
    
    ; mark as completed
    MOV BYTE PTR [SI], 2
    
    
    ADD player_xp, 10
    ADD player_coins, 5
    
    LEA DX, task_completed
    CALL print_string
    CALL pause
    RET

invalid_task_num:
    LEA DX, invalid_task
    CALL print_string
    CALL pause
    RET
complete_task ENDP


;  view player stats
view_stats PROC
    LEA DX, stats_header
    CALL print_string
    
    ; display XP
    LEA DX, xp_label
    CALL print_string
    MOV AX, player_xp
    CALL print_number
    
    ; display coins
    LEA DX, coins_label
    CALL print_string
    MOV AX, player_coins
    CALL print_number
    
    ; display stamina
    LEA DX, stamina_label
    CALL print_string
    MOV AL, player_stamina
    MOV AH, 0
    CALL print_number
    
    ; display strength
    LEA DX, strength_label
    CALL print_string
    MOV AL, player_strength
    MOV AH, 0
    CALL print_number
    
    ; display health
    LEA DX, health_label
    CALL print_string
    MOV AL, player_health
    MOV AH, 0
    CALL print_number
    
    CALL pause
    RET
view_stats ENDP



upgrade_stats PROC
    LEA DX, upgrade_header
    CALL print_string
    
    CALL get_choice
    
    CMP AL, '1'
    JE upgrade_stamina
    CMP AL, '2'
    JE upgrade_strength
    CMP AL, '3'
    JE upgrade_health
    JMP upgrade_stats_end

upgrade_stamina:
    CMP player_coins, 10
    JL insufficient_coins
    SUB player_coins, 10
    INC player_stamina
    JMP upgrade_success_msg

upgrade_strength:
    CMP player_coins, 15
    JL insufficient_coins
    SUB player_coins, 15
    INC player_strength
    JMP upgrade_success_msg

upgrade_health:
    CMP player_coins, 10
    JL insufficient_coins
    SUB player_coins, 10
    INC player_health
    JMP upgrade_success_msg

insufficient_coins:
    LEA DX, insufficient
    CALL print_string
    CALL pause
    RET

upgrade_success_msg:
    LEA DX, upgrade_success
    CALL print_string
    LEA DX, remaining_coins
    CALL print_string
    MOV AX, player_coins
    CALL print_number
    CALL pause

upgrade_stats_end:
    RET
upgrade_stats ENDP



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; HELPER FUNCTIONS

show_menu PROC
    LEA DX, menu_title
    CALL print_string
    RET
show_menu ENDP

; get user input
get_choice PROC
    MOV AH, 1
    INT 21h
    MOV choice, AL
    RET
get_choice ENDP

print_string PROC
    MOV AH, 9
    INT 21h
    RET
print_string ENDP

print_number PROC
    ; convert number in AX to string and print
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV CX, 0
    MOV BX, 10
    
convert_loop:
    MOV DX, 0
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE convert_loop
    
print_digits:
    POP DX
    ADD DL, '0'
    MOV AH, 2
    INT 21h
    LOOP print_digits
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
print_number ENDP

get_number PROC
    ; single digit input
    MOV AH, 1
    INT 21h
    SUB AL, '0'
    MOV AH, 0
    RET
get_number ENDP

pause PROC
    LEA DX, press_key
    CALL print_string
    MOV AH, 1
    INT 21h
    RET
pause ENDP



END MAIN ; program finishes here