
/*
*****************************************************************************
**
**      Project     : InkuReg
**
**      Component   : CPU (MSP430F2419)
**
**      Modulename  : System
**
**      Filename    : template.h
**
**      Abstract    : Obsługa wyświetalcza alfanumerycznego LCD
**
**      Date        : 2009-04-16 21:18:33
**
**
*****************************************************************************
*/
/*
**===========================================================================
**  1       GENERAL
**  1.1     Revisions
**
**===========================================================================
*/

/*
**===========================================================================
**  1.3     Re-definition guard
**===========================================================================
*/

/*--- Avoid including this file more than once ---*/
#ifndef _IS_INCLUDED_ALFALCD_H
#define _IS_INCLUDED_ALFALCD_H

/*
**===========================================================================
**  2.      INCLUDE FILES
**  2.1     Standard include files
**===========================================================================
*/

/*
**===========================================================================
**  2.2     Application include files
**===========================================================================
*/

/*
**===========================================================================
**  3.      DECLARATIONS
**  3.1     Global constants
**===========================================================================
*/


/*
**===========================================================================
**  3.2     Global macros
**===========================================================================
*/


/*
**===========================================================================
**  3.3     Global type definitions
**===========================================================================
*/

/*
**===========================================================================
**  3.4     Global variables (defined in some implementation file)
**===========================================================================
*/

/*
**===========================================================================
**  4.      GLOBAL FUNCTIONS (defined in some implementation file)
**===========================================================================
*/
extern void vAlfaLcdSetup(void);
extern void vAlfaLcdOutC(unsigned char ucData);
extern unsigned char ucAlfaLcdInC(void);
extern void vAlfaLcdOutD(unsigned char ucData);
extern void vAlfaLcdInit(void);

#endif /* Match the re-definition guard */
/*
**===========================================================================
** END OF FILE
**===========================================================================
*/ 


