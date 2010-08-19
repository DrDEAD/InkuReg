;*******************************************************************************
;   MSP430x261x Demo - Configure RST/NMI as NMI
;
;   Description: Configure RST/NMI as NMI, hi/lo edge. Flash P1.0 inside of
;   NMI_ISR if NMI occurs. General enable interrupt in status register does
;   not need to be set for NMI. NMIIE does need to be re-set, as NMI_ISR
;   automatically clears NMI enable to prevent unintentional stack overflow
;   that could result from, bounce or uncontrolled NMI's.
;   ACLK = n/a, MCLK = SMCLK = DCO ~1.045MHz
;
;                MSP430F241x
;                MSP430F261x
;             -----------------
;         /|\|              XIN|-
;          | |                 |
;          --|RST/NMI      XOUT|-
;            |                 |
;
;  JL Bile
;  Texas Instruments Inc.
;  June 2008
;  Built Code Composer Essentials: v3 FET
;*******************************************************************************
 .cdecls C,LIST, "msp430x26x.h"
;-------------------------------------------------------------------------------
			.text	;Program Start
;-------------------------------------------------------------------------------
RESET       mov.w   #0850h,SP         ; Initialize stackpointer
SetupWDT    mov.w   #WDTPW+WDTHOLD+WDTNMI+WDTNMIES,&WDTCTL ; WDT off NMI hi/lo
            bis.b   #01h,&P1DIR             ; P1.0 = output
            bic.b   #01h,&P1OUT             ; P1.0 = reset
            bis.b   #NMIIE,&IE1             ; Enable NMI
                                            ;
Mainloop    jmp     Mainloop                ; Endless Loop
                                            ;
;-------------------------------------------------------------------------------
NMI_ISR   ; Flash P1.0
;-------------------------------------------------------------------------------
            bis.b   #01h,&P1OUT             ; P1.0 = set
Wait        push.w  #020000                 ; Delay value --> TOS
Wait1       dec.w   0(SP)                   ; Decrement TOS
            jnz     Wait1                   ; Delay over?
            incd.w  SP                      ; Clean up stack
            bic.b   #01h,&P1OUT             ; P1.0 = reset
            bic.b   #NMIIFG,&IFG1           ; reclear NMI flag in case bounce
            bis.b   #NMIIE,&IE1             ; Re-enable NMI interrupt
            reti                            ; Done
                                            ;
;-------------------------------------------------------------------------------
;			Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect	".int30"              ; NMI vector
            .short  NMI_ISR
            .sect	".reset"	           ; POR, ext. Reset, Watchdog
            .short  RESET
            .end
            