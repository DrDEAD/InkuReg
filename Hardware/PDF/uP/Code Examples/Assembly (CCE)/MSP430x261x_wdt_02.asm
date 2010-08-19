;*******************************************************************************
;   MSP430x261x Demo - WDT, Toggle P1.0, Interval Overflow ISR, 32kHz ACLK
;
;   Description: Toggle P1.0 using software timed by WDT ISR. Toggle rate is
;   exactly 250ms based on 32kHz ACLK WDT clock source. In this example the
;   WDT is configured to divide 32768 watch-crystal(2^15) by 2^13 with an ISR
;   triggered @ 4Hz.
;   ACLK = LFXT1 = 32768Hz, MCLK = SMCLK = default DCO ~1.045MHz
;   //* External watch crystal installed on XIN XOUT is required for ACLK *//
;
;              MSP430F261x/241x
;             -----------------
;         /|\|              XIN|-
;          | |                 | 32kHz
;          --|RST          XOUT|-
;            |                 |
;            |             P1.0|-->LED
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
SetupWDT    mov.w   #WDT_ADLY_250,&WDTCTL   ; WDT 250ms, ACLK, interval timer
            bis.b   #WDTIE,&IE1             ; Enable WDT interrupt
SetupP1     bis.b   #001h,&P1DIR            ; P1.0 output
                                            ;
Mainloop    bis.w   #LPM3+GIE,SR            ; Enter LPM3, interrupts enabled
            nop                             ; Required only for debugger
                                            ;
;-------------------------------------------------------------------------------
WDT_ISR;    Toggle P1.0
;-------------------------------------------------------------------------------
            xor.b   #001h,&P1OUT            ; Toggle P1.0
            reti                            ;
                                            ;
;-------------------------------------------------------------------------------
;			Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect	".reset"	            ; MSP430 RESET Vector
            .short  RESET					;
            .sect	".int26"	            ; WDT Vector
            .short  WDT_ISR                 ;
            .end
