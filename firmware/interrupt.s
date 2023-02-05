; ---------------------------------------------------------------------------
; interrupt.s
; up5k_6502 IRQ and NMI routines
; based on example code from https://cc65.github.io/doc/customizing.html
; 03-05-19 E. Brombaugh
; ---------------------------------------------------------------------------
;
; Interrupt handler.

.export   _irq_int, _nmi_int

.segment  "CODE"

; ---------------------------------------------------------------------------
; Non-maskable interrupt (NMI) service routine

_nmi_int:  RTI                    ; Return from all NMI interrupts

; ---------------------------------------------------------------------------
; Maskable interrupt (IRQ) service routine

_irq_int:           
           PHA                    ; Save accumulator contents to stack
           TXA                    ; Save X register contents to stack
           PHA
		   TYA                    ; Save Y register to stack
		   PHA
		   
; ---------------------------------------------------------------------------
; check for BRK instruction

           TSX                    ; Transfer stack pointer to X
           LDA $104,X             ; Load status register contents (SP + 4)
           AND #$10               ; Isolate B status bit
           BNE break              ; If B = 1, BRK detected

; ---------------------------------------------------------------------------

           ;RTI
           BEQ irq_exit           ; no - skip to exit
		   
; ---------------------------------------------------------------------------
; Restore state and exit ISR

irq_exit:  PLA                    ; Restore Y register contents
		   TAY
           PLA                    ; Restore X register contents
           TAX
           PLA                    ; Restore accumulator contents
           RTI                    ; Return from all IRQ interrupts

; ---------------------------------------------------------------------------
; BRK detected, stop

break:     JMP break              ; If BRK is detected, something very bad
                                  ;   has happened, so loop here forever
