;*******************************************************************************
;   MSP430x261x Demo - USCI_B0 I2C Master RX single bytes from MSP430 Slave
;
;   Description: This demo connects two MSP430's via the I2C bus. The master
;   reads from the slave. This is the master code. The data from the slave
;   transmitter begins at 0 and increments with each transfer. The received
;   data is in R5 and is checked for validity. If the received data is
;   incorrect, the CPU is trapped and the P1.0 LED will stay on. The USCI_B0
;   RX interrupt is used to know when new data has been received.
;   ACLK = n/a, MCLK = SMCLK = BRCLK = default DCO = ~1.045MHz
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
SetupP1     bic.b   #01h,&P1OUT             ; P1.0 = 0
            bis.b   #01h,&P1DIR             ; P1.0 output
SetupP3     bis.b   #06h,&P3SEL             ; Assign I2C pins to USCI_B0
SetupUCB0   bis.b   #UCSWRST,&UCB0CTL1      ; Enable SW reset
            mov.b   #UCMST+UCMODE_3+UCSYNC,&UCB0CTL0
                                            ; I2C Master, synchronous mode
            mov.b   #UCSSEL_2+UCSWRST,&UCB0CTL1
                                            ; Use SMCLK, keep SW reset
            mov.b   #12,&UCB0BR0            ; fSCL = SMCLK/12 = ~100kHz
            mov.b   #00,&UCB0BR1
            mov.w   #048h,&UCB0I2CSA        ; Slave Address is 048h
            bic.b   #UCSWRST,&UCB0CTL1      ; Clear SW reset, resume operation
            bis.b   #UCB0RXIE,&IE2          ; Enable RX interrupt

            clr.b   R6                      ; Uses R6 to check incoming data

Main        bit.b   #UCTXSTP,&UCB0CTL1      ; Ensure stop condition got sent
            jc      Main
            bis.b   #UCTXSTT,&UCB0CTL1      ; I2C start condition
Main_1      bit.b   #UCTXSTT,&UCB0CTL1      ; Start condition sent?
            jc      Main_1
            bis.b   #UCTXSTP,&UCB0CTL1      ; I2C stop condition
            bis.b   #LPM0+GIE,SR            ; Enter LPM0, enable interrupts
            cmp.b   R5,R6                   ; Test received data
            jne     Trap                    ; Trap CPU if wrong
            inc.b   R6                      ; Increment correct RX value
            jmp     Main                    ; Repeat

Trap        bis.b   #01h,&P1OUT             ; P1.0 = 1
            jmp     $                       ; Trap CPU
;-------------------------------------------------------------------------------
USCIAB0TX_ISR;      USCI_B0 Data ISR
;-------------------------------------------------------------------------------
            mov.b   &UCB0RXBUF,R5           ; RX data in R5
            bic.w   #LPM0,0(SP)             ; Clear LPM0
            reti
;-------------------------------------------------------------------------------
;			Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect     ".int22"        ; USCI_B0 I2C Data Int Vector
            .short   USCIAB0TX_ISR
            .sect	".reset"            ; POR, ext. Reset, Watchdog
            .short  RESET
            .end

