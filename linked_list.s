# File:     linked_list.s
# Purpose:  Implement an unsorted linked list with ops insert (at head),
#	        print, member, delete, free_list.
# Input:    Single character lower case letters to indicate operators, 
#           followed by arguments needed by operators.
# Output:   Results of operations.

# README:   Input when asked for value must be valid int.
        .text
        .globl    main
main:
        addi      $sp, $sp, -4            # Make additional stack space.
        sw        $ra, 0($sp)             # Save the return address

        li        $s1, 0                  # Head could be put on stack, but we know all subroutines will leave $s1 alone.
com_loop:
        move      $a1, $s1                # Pass $s1 (Head) to $a1 for use by subroutines.
		                                  # $a0 is used by all our syscall subroutines, so $a1 saves some cycle time.
        jal       get_command             # Jump to function that prints get_command function
                                          # and reads a char
        move      $t0, $v0                # Copy return value to safe location

        # MENU SELECTION
        bne       $t0, 'i', p             # If i, insert
        jal       get_value
        move      $a0, $v0
        jal       insert
        move      $s1, $v0                # Update saved value $s1 to new head 
        j         com_loop
p:
        bne       $t0, 'p', m             # If p, print
        jal       print                   
        j         com_loop
m:
        bne       $t0, 'm', d             # If m, member
        jal       get_value
        move      $a0, $v0
        jal       member
        j         com_loop
d:
        bne       $t0, 'd', f             # If d, delete
        jal       get_value
        move      $a0, $v0
        jal       delete
        move      $s1, $v0                # Update saved value $s1 to new head
        j         com_loop
f:
        bne       $t0, 'f', q             # If f, free_list
        jal       free_list
        move      $s1, $v0                # Update saved value $s1 to new head
        j         com_loop        
q:
        bne       $t0, 'q', command_error # If q, quit.
        j         quit					  

command_error:                            # If no valid char was entered, print error message and prompt.
                                          # Note: If return is entered, error message does not print in line.                                 
        la        $a0, cmd_err_p1_msg     # String
        li        $v0, 4                  # Print string code.
        syscall                           # Print first part of error msg.

        move      $a0, $t0                # Char 
        li        $v0, 11                 # Print char code.
        syscall                           # Print incorrect command.

        la        $a0, cmd_err_p2_msg     # String
        li        $v0, 4                  # Print string code.
        syscall                           # Print 2nd part of error msg.

        j         com_loop
quit:
        jal       free_list
        move      $s1, $v0                # Update saved value $s1 to new head

        # Restore the values from the stack, and release the stack space.
        lw        $ra, 0($sp)             # Retrieve return address
        addu      $sp, $sp, 4             # Free stack space.

        # Return -- go to the address left by the caller.  OK for SPIM
        # jr      $ra

        # Exit system call:  SPIM or MARS
        li        $v0, 10
        syscall

        ###############################################################
        # Function:  insert
        # Purpose:   insert val at head of list
        # Args:      $a1: head block of list
        #            $a0: val to insert
        # Ret val:   none
insert: 
        # Put return address on stack
        addi      $sp, $sp, -4            # Make additional stack space.
        sw        $ra, 0($sp)             # Save the return address

        move      $t0, $a0                # move val to a safe location

 		# Allocate memory
        li        $a0, 8                  # Number of bytes to allocate
        li        $v0, 9                  # Code for allocate heap (sbrk)
        syscall                           # Allocate memory, address is $v0.

        # Store int in heap, set pointer
        sw        $t0, 0($v0)             # Load insert value into mem space.
        sw        $a1, 4($v0)             # Set next to previous head.

        # Set head to latest int

        # Restore the values from the stack, and release the stack space.
        lw        $ra, 0($sp)             # Retrieve return address
        addu      $sp, $sp, 4             # Free stack space.

        # Return -- go to the address left by the caller.
        jr        $ra                     # Return.  Int is in $v0.

        ###############################################################
        # Function:  print
        # Purpose:   print list on a single line
        # Args:      $a1: head block of list
        # Ret val:   none
print: 
        # Put return address on stack
        addi      $sp, $sp, -4            # Make additional stack space.
        sw        $ra, 0($sp)             # Save the return address

        move      $t0, $a1                # Move head to t0.

        la        $a0, list_msg           # String prompt
        li        $v0, 4                  # Print string code.
        syscall 

p_loop:
        beq       $t0, 0, p_empty		  # Print until empty
        lw        $a0, 0($t0)             # Place data at head in a0
        li        $v0, 1                  # Print int code.
        syscall                           # Print int.

        la        $a0, space              # String prompt
        li        $v0, 4                  # Print string code.
        syscall   

        lw        $t0, 4($t0)             # Next in list.
        j         p_loop

p_empty:
        la        $a0, newln              # String
        li        $v0, 4                  # Print string code.
        syscall 						  # Newline printed.

        # Restore the values from the stack, and release the stack space.
        lw        $ra, 0($sp)             # Retrieve return address
        addu      $sp, $sp, 4             # Free stack space.

        # Return -- go to the address left by the caller.
        jr        $ra                     # Return.  Int is in $v0.

        ###############################################################
        # Function:  member
        # Purpose:   search list for val
        # Args:      $a1: head block of list
        #            $a0: val to search for
        # Ret val:   none
member: 
        # Put return address on stack
        addi      $sp, $sp, -4            # Make additional stack space.
        sw        $ra, 0($sp)             # Save the return address

        move      $t0, $a1                # Point t0 to head
        move      $t1, $a0                # Move int to safe location

        move      $a0, $t1                # Place data at head in a0
        li        $v0, 1                  # Print int code.
        syscall                           # Print int to be found.
m_loop:	
		beq       $t0, 0, m_loop_exit     # Branch if list is empty
		
		lw        $t2, 0($t0)
		beq       $t1, $t2, m_found
        
        lw        $t0, 4($t0)             # Next in list.
        j         m_loop
m_loop_exit:
        la        $a0, nfound_msg         # String
        li        $v0, 4                  # Print string code.
        syscall  

        j         m_finish
m_found:
		la        $a0, found_msg          # String
        li        $v0, 4                  # Print string code.
        syscall          
m_finish:
        # Restore the values from the stack, and release the stack space.
        lw        $ra, 0($sp)             # Retrieve return address
        addu      $sp, $sp, 4             # Free stack space.

        # Return -- go to the address left by the caller.
        jr        $ra                     # Return.  Int is in $v0.

        ###############################################################
        # Function:  delete
        # Purpose:   delete the first occurence of val to a safe location
        # Args:      $a1: head block of list
        #            $a0: val to delete
        # Ret val:   none
delete: 
        # Put return address on stack
        addi      $sp, $sp, -4            # Make additional stack space.
        sw        $ra, 0($sp)             # Save the return address

        li        $t3, 0                  # Set $t3 to NULL - it is prev_p
        move      $t0, $a1                # Point t0 to head
        move      $t7, $a1                # Keep track of head

        move      $t1, $a0                # Move int to safe location

d_loop:	
        beq       $t0, 0, d_loop_exit     # Exit loop if end of list
        lw        $t2, 0($t0)		      # Load int at $t0
        beq       $t1, $t2, d_found       # Break if found
        
        move      $t3, $t0				  # If not found, set next. $t3 is prev_p
        lw        $t0, 4($t0)             # Load pointer to next int.
        j         d_loop

d_loop_exit:                
        move      $a0, $t1                # Place data at head in a0
        li        $v0, 1                  # Print int code.
        syscall  

        la        $a0, nfound_msg         # String
        li        $v0, 4                  # Print string code.
        syscall  

        j         d_finish                # Skip delete - int wasn't found.
d_found:
        beq       $t3, 0, d_headp         # Special case if at head.

        lw        $t4, 4($t0)             # Load curr_p->next
        sw        $t4, 4($t3)             # Set prev_p->next to curr_p->next

        j         d_finish
d_headp:
        lw        $t4, 4($t0)             # Set head to curr_p->next
        move      $t7, $t4                # Set new head.
d_finish:
        move      $v0, $t7                # Return head.

        # Restore the values from the stack, and release the stack space.
        lw        $ra, 0($sp)             # Retrieve return address
        addu      $sp, $sp, 4             # Free stack space.

        # Return -- go to the address left by the caller.
        jr        $ra                     # Return.  Head is in $v0.

        ###############################################################
        # Function:  free_list
        # Purpose:   free the list - returns null pointer for use as head.
        # Args:      none
        # Ret val:   $v0: NULL head pointer
free_list: 
        # Put return address on stack
        addi      $sp, $sp, -4            # Make additional stack space.
        sw        $ra, 0($sp)             # Save the return address

        # Print newline
        la        $a0, newln              # String
        li        $v0, 4                  # Print string code.
        syscall                           # Print prompt

        li        $v0, 0                  # Set head to NULL.

        # Restore the values from the stack, and release the stack space.
        lw        $ra, 0($sp)             # Retrieve return address
        addu      $sp, $sp, 4             # Free stack space.

        # Return -- go to the address left by the caller.
        jr        $ra                     # Return.

        ###############################################################
        # Function:  get_command
        # Purpose:   get a single character command from stdin
        # Args:      none
        # Ret val:   $v0: a char as command
get_command: 
        # Put return address on stack
        addi      $sp, $sp, -4            # Make additional stack space.
        sw        $ra, 0($sp)             # Save the return address

        la        $a0, gc_msg             # String prompt
        li        $v0, 4                  # Print string code.
        syscall                           # Print prompt

        li        $v0, 12                 # Code for read char. 4 for int.
        syscall                           # Read char, char is in $v0.

        # Restore the values from the stack, and release the stack space.
        lw        $ra, 0($sp)             # Retrieve return address
        addu      $sp, $sp, 4             # Free stack space.

        # Return -- go to the address left by the caller.
        jr        $ra                     # Return.  Char is in $v0.

        ###############################################################
        # Function:  get_value
        # Purpose:   get an int
        # Args:      none
        # Ret val:   $v0: an int
        # Note:      will throw exception if invalid input is given.
get_value:
		# Put return address on stack
        addi      $sp, $sp, -4            # Make additional stack space.
        sw        $ra, 0($sp)             # Save the return address

        # Print message
        la        $a0, gv_msg             # String prompt
        li        $v0, 4                  # Print string code.
        syscall                           # Print prompt

        # Read int for input and store in $t0                          
        li        $v0, 5                  # Code for read int.
        syscall                           # Read int, int is in $v0.

        # Restore the values from the stack, and release the stack space.
        lw        $ra, 0($sp)             # Retrieve return address
        addu      $sp, $sp, 4             # Free stack space.

        # Return -- go to the address left by the caller.
        jr        $ra                     # Return.  Char is in $v0.
        

        #==============================================================
        .data
        
newln: .asciiz "\n"
space: .asciiz " "
list_msg: .asciiz "\nlist = "
gc_msg: .asciiz "Please enter a command (i, p, m, d, f, q): "
gv_msg: .asciiz "\nPlease enter a value: "
found_msg: .asciiz " is in the list\n"
nfound_msg: .asciiz " is not in the list\n"
cmd_err_p1_msg: .asciiz "\nThere is no "
cmd_err_p2_msg: .asciiz " command. \nPlease try again.\n"

