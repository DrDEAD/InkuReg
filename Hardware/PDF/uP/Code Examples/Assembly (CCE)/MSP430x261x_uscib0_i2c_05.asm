;*******************************************************************************
;   MSP430x261x Demo - USCI_B0 I2C Slave TX single bytes to MSP430 Master
;
;   Description: This demo connects two MSP430's via the I2C bus. The master
;   reads from the slave. This is the slave code. The TX data begins at 0
;   and is incremented each time it is sent. An incoming start condition
;   is used as a trigger to increment the outgoing data. The master checks the
;   data it receives for validity. If it is incorrect, it stops communicating
;   and the P1.0 LED will stay on. The USCI_B0 TX interrupt is used to know
;   when to TX.
;   ACLK = n/a, MCLK = SMCLK = default DCO = ~1.045MHz
;
;                                 /|\  /|\
;           MSP430F261x/241x      10k  10k     MSP430F261x/241x
;                    slave         |    |        master
;              -----------------   |    |  -----------------
;            -|XIN  P3.1/UCB0SDA|<-|---+->|P3.1/UCB0SDA  XIN|-
;             |                 |  |      |                 | 32kHz
;            -|XOUT             |  |      |             XOUT|-
;             |     P3.2/UCB0SCL|<-+----->|P3.2/UCB0SCL     |
;             |                 |         |             P1.0|--> LED
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
StopWDT     mov.w   #WDTPW+WDTHOLD,&WDTCTL  ; Stop WDT
SetupP3     bis.b   #06h,&P3SEL             ; Assign I2C pins to USCI_B0
SetupUCB0   bis.b   #UCSWRST,&UCB0CTL1      ; Enable SW reset
            mov.b   #UCMODE_3+UCSYNC,&UCB0CTL0
                                            ; I2C Slave, synchronous mode
            mov.w   #048h,&UCB0I2COA        ; Own Address is 048h
            bic.b   #UCSWRST,&UCB0CTL1      ; Clear SW reset, resume operation
            bis.b   #UCSTTIE,&UCB0I2CIE     ; Enable STT interrupt
            bis.b   #UCB0TXIE,&IE2          ; Enable TX interrupt

            mov.b   #0ffh,R5                ; Use R5 to hold TX data

Main        bis.b   #LPM0+GIE,SR            ; Enter LPM0, enable interrupts
            jmp     Main                    ; Repeat
;-------------------------------------------------------------------------------
USCIAB0TX_ISR;      USCI_B0 Data ISR
;-------------------------------------------------------------------------------
            mov.b   R5,&UCB0TXBUF           ; TX data in R5
            bic.w   #LPM0,0(SP)             ; Clear LPM0
            reti
;-------------------------------------------------------------------------------
USCIAB0RX_ISR;      USCI_B0 State ISR
;-------------------------------------------------------------------------------
            bic.b   #UCSTTIFG,&UCB0STAT     ; Clear start condition int flag
            inc.b   R5                      ; Increment data
            reti
;-------------------------------------------------------------------------------
;			Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect	".int22"        ; USCI_B0 I2C Data Int Vector
            .short	USCIAB0TX_ISR
            .sect	".int23"        ; USCI_B0 I2C Sate Int Vector
            .short	USCIAB0RX_ISR
            .sect	".reset"	           	; POR, ext. Reset,Watchdog
            .short  RESET  
            .end
