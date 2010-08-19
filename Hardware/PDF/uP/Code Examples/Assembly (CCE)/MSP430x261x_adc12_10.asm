;*******************************************************************************
;   MSP430x261x Demo - ADC12, Sample A10 Temp and Convert to oC and oF
;
;   Description: A single sample is made on A10 with reference to internal
;   1.5V Vref. Software sets ADC12SC to start sample and conversion - ADC12SC
;   automatically cleared at EOC. ADC12 internal oscillator times sample
;   and conversion. In Mainloop MSP430 waits in LPM0 to save power until
;   ADC10 conversion complete, ADC12_ISR will force exit from any LPMx in
;   Mainloop on reti. Result is converted to Temperature represented as
;   BCD 0000 - 0145 representing oC saved at 01100h and 0000 - 0292
;   representing oF saved at 01102h.
;   ACLK = 32kHz, MCLK = SMCLK = default DCO 1048576Hz, ADC12CLK = ADC12OSC
;
;   Uncalibrated temperature measured from device to devive will vary do to
;   slope and offset variance from device to device - please see datasheet.
;
;                MSP430F241x
;                MSP430F261x
;             -----------------
;         /|\|              XIN|-
;          | |                 | 32kHz
;          --|RST          XOUT|-

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
            mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
            mov.w   #SHT0_8+REFON+ADC12ON,&ADC12CTL0 ; 1.5v ref.
            mov.w   #13600,&TACCR0          ; Delay to allow Ref to settle
            bis.w   #CCIE,&TACCTL0          ; Compare-mode interrupt.
            mov.w   #TACLR+MC_1+TASSEL_2,&TACTL; up mode, SMCLK
            bis.w   #LPM0+GIE,SR            ; Enter LPM0, enable interrupts
            bic.w   #CCIE,&TACCTL0          ; Disable timer interrupt
            dint                            ; Disable Interrupts
            mov.w   #SHP,&ADC12CTL1         ; Enable sample timer
            mov.b   #SREF_1+INCH_10,&ADC12MCTL0 ; A10, internal reference
            bis.w   #0001h,&ADC12IE         ; Enable interrupt
                                            ;
Mainloop    bis.w   #ENC+ADC12SC,&ADC12CTL0 ; Start sampling/conversion
            bis.w   #CPUOFF+GIE,SR          ; LPM0, ADC10_ISR will force exit
            calla   #Trans2TempC            ; Transform voltage to temperature
            calla   #BIN2BCD4               ; R13 = TempC = 0000 - 0145 BCD
            mov.w   R13,&0200h              ; 0200h = temperature oC
            calla   #Trans2TempF            ; Transform voltage to temperature
            calla   #BIN2BCD4               ; R13 = TempF = 0000 - 0292 BCD
            mov.w   R13,&0202h              ; 0202h = temperature oF
            jmp     Mainloop                ; << breakpoint here
                                            ;
;-------------------------------------------------------------------------------
Trans2TempC;Subroutine coverts R12 = R12/4096*423-278
;           oC = ((x/4096)*1500mV)-986mV)*1/3.55mV = x*423/4096 - 278
;           Input:  R12  0000 - 0FFFh, R11 working register
;           Output: R12  0000 - 091h
;-------------------------------------------------------------------------------
;            mov.w   &ADC12MEM0,R12          ; Clear IFG flag (not needed)
            mov.w   R12,&MPY                ;
            mov.w   #423,&OP2               ; C
            mov.w   &RESHI,R12              ;
            mov.w   &RESLO,R11              ;
            rlc.w   R11                     ; /4096
            rlc.w   R12                     ;
            rlc.w   R11                     ;
            rlc.w   R12                     ;
            rlc.w   R11                     ;
            rlc.w   R12                     ;
            rlc.w   R11                     ;
            rlc.w   R12                     ;
            sub.w   #278,R12                ; C
            reta                            ; CPU-X
                                            ;
;-------------------------------------------------------------------------------
Trans2TempF;Subroutine coverts R12 = R12/4096*761-468
;           oF = ((x/4096*1500mV)-923mV)*1/1.97mV = x*761/4096 - 468
;           Input:  R12  0000 - 0FFFh, R11 working register
;           Output: R12  0000 - 0262
;-------------------------------------------------------------------------------
            mov.w   &ADC12MEM0,R12          ; Clear IFG flag
            mov.w   R12,&MPY                ;
            mov.w   #761,&OP2               ; F
            mov.w   &RESHI,R12              ;
            mov.w   &RESLO,R11              ;
            rlc.w   R11                     ; /4096
            rlc.w   R12                     ;
            rlc.w   R11                     ;
            rlc.w   R12                     ;
            rlc.w   R11                     ;
            rlc.w   R12                     ;
            rlc.w   R11                     ;
            rlc.w   R12                     ;
            sub.w   #468,R12                ; F
            reta                            ; CPU-X
                                            ;
;-------------------------------------------------------------------------------
BIN2BCD4  ; Subroutine converts binary number R12 -> Packed 4-digit BCD R13
;           Input:  R12  0000 - 0FFFh, R15 working register
;           Output: R13  0000 - 4095
;-------------------------------------------------------------------------------
            mov.w   #16,R15                 ; Loop Counter
            clr.w   R13                     ; 0 -> RESULT LSD
BIN1        rla.w   R12                     ; Binary MSB to carry
            dadd.w  R13,R13                 ; RESULT x2 LSD
            dec.w   R15                     ; Through?
            jnz     BIN1                    ; Not through
            reta                            ; CPU-X
                                            ;
;-------------------------------------------------------------------------------
TA0_ISR;    ISR for CCR0
;-------------------------------------------------------------------------------
            clr.w   &TACTL                  ; clear Timer_A control registers
            bic.w   #LPM0,0(SP)             ; Exit LPMx, interrupts enabled
            reti                            ;
;-------------------------------------------------------------------------------
ADC12_ISR;  ADC12MEM0 -> R12, exit any LPMx mode
;           Output: R12  0000 - 0FFFh
;-------------------------------------------------------------------------------
            mov.w   &ADC12MEM0,R12          ; Clear IFG flag
            mov.w   #GIE,0(SP)              ; Enable Int. exit LPMx on reti
            reti                            ;
                                            ;
;-------------------------------------------------------------------------------
;			Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect	".int25"          ; Timer_A0 Vector
            .short	TA0_ISR
            .sect	".int21"            ; ADC12 Vector
            .short	ADC12_ISR
            .sect	".reset"            ; POR, ext. Reset
            .short	RESET
            .end
