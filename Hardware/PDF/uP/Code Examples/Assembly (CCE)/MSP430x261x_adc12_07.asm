;*******************************************************************************
;   MSP430x261x Demo - ADC12, Repeated Single Channel Conversions
;
;   This example shows how to perform repeated conversions on a single channel
;   using "repeat-single-channel" mode.  AVcc is used for the reference and
;   repeated conversions are performed on Channel A0. Each conversion result
;   is stored in ADC12MEM0 and is moved to a RAM location.  The conversion
;   results are moved to RAM addresses 0x1100 - 0x110E.  Test by applying a
;   voltage to channel A0, then running. To view the conversion results, open a
;   memory window in debugger and view the contents of addresses 0x1100 -
;   0x110E after stopping program execution. Remember the conversion results
;   are 12-bits so you must set the memory window to 16-bit mode.
;
;                MSP430F241x
;                MSP430F261x
;              ---------------
;             |            XIN|-
;      Vin -->|P6.0/A0        | 32kHz
;             |           XOUT|-
;
;  JL Bile
;  Texas Instruments Inc.
;  June 2008
;  Built Code Composer Essentials: v3 FET
;*******************************************************************************
 .cdecls C,LIST, "msp430x26x.h"

Results     .equ     01100h                  ; Begining of Results table

;-------------------------------------------------------------------------------
			.text	;Program Start
;-------------------------------------------------------------------------------
RESET       mov.w   #0850h,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop watchdog
            bis.b   #01h,&P6SEL             ; Enable A/D channel A0
                                            ;
SetupADC12  mov.w   #SHT0_8+MSC+ADC12ON,&ADC12CTL0
                                            ; Turn on ADC12, use int. osc.
                                            ; Extend sampling period to avoid
                                            ; overflow
                                            ; Set MSC so conversions triggered
                                            ; automatically
            mov.w   #SHP+CONSEQ_2,&ADC12CTL1
                                            ; Use sampling timer, set mode
            mov.w   #01h,&ADC12IE           ; Enable ADC12IFG.0 for ADC12MEM0
            clr.w   R5                      ; Clear results table pointer
                                            ;
Mainloop    bis.w   #ENC,&ADC12CTL0         ; Enable conversions
            bis.w   #ADC12SC,&ADC12CTL0     ; Start conversions
            bis.w   #CPUOFF+GIE,SR          ; Hold in LPM0, Enable interrupts
            nop                             ; Need only for debug
                                            ;
;-------------------------------------------------------------------------------
ADC12_ISR   ; Interrupt Service Routine for ADC12
;-------------------------------------------------------------------------------
            mov.w   &ADC12MEM0,Results(R5)  ; Move result, IFG is reset
            incd.w  R5                      ; Increment results table pointer
            and.w   #0Eh,R5                 ; Modulo pointer
            reti                            ;
;-------------------------------------------------------------------------------
;			Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect	".int21"             ; ADC12 Vector
            .short	ADC12_ISR
            .sect	".reset"            ; POR, ext. Reset
            .short	RESET
            .end
      