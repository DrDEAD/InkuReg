//******************************************************************************
//  MSP430x26x Demo - Timer_A, Toggle P1.1/TA0, Up/Down Mode, DCO SMCLK
//
//  Description: Toggle P1.1 using hardware TA0 output. Timer_A is configured
//  for up/down mode with CCR0 defining period, TA0 also output on P1.1. In
//  this example, CCR0 is loaded with 250 and TA0 will toggle P1.1 at
//  TACLK/2*250. Thus the output frequency on P1.1 will be the TACLK/1000.
//  No CPU or software resources required.
//  As coded with TACLK = SMCLK, P1.1 output frequency is ~1.045M/1000.
//  SMCLK = MCLK = TACLK = default DCO ~1.045MHz
//
//                MSP430F261x/241x
//            -----------------
//        /|\|              XIN|-
//         | |                 |
//         --|RST          XOUT|-
//           |                 |
//           |         P1.1/TA0|--> SMCLK/1000
//
//  B. Nisarga
//  Texas Instruments Inc.
//  September 2007
//  Built with CCE Version: 3.2.0 and IAR Embedded Workbench Version: 3.42A
//******************************************************************************

#include  <msp430x26x.h>

void main(void)
{
  WDTCTL = WDTPW + WDTHOLD;                 // Stop WDT
  P1DIR |= 0x02;                            // P1.1 output
  P1SEL |= 0x02;                            // P1.1 option select
  CCTL0 = OUTMOD_4;                         // CCR0 toggle mode
  CCR0 = 250;
  TACTL = TASSEL_2 + MC_3;                  // SMCLK, up-downmode

  _BIS_SR(CPUOFF);                          // CPU off
}
