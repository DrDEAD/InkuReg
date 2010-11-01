
/*
*****************************************************************************
**
**      Project     : InkuReg
**
**      Component   : CPU (MSP430F2149)
**
**      Modulename  : System
**
**      Filename    : AlfaLcd.c
**
**      Abstract    : Obs³uga wyœwietalcza alfanumerycznego LCD
**
**
**
**      Date        : 2009-04-16 21:18:33
**
**
**
*****************************************************************************
*/
/*
**===========================================================================
**  1       GENERAL
**  1.1     Revisions
**
**  
**
**===========================================================================
*/

/*
**===========================================================================
**  2.      INCLUDE FILES
**  2.1     Standard include files
**===========================================================================
*/
#include <msp430.h>
/*
**===========================================================================
**  2.2     Application include files
**===========================================================================
*/

/*
**---------------------------------------------------
**  FreeRTOS modules header files 
**  Include the header files used by the application
**---------------------------------------------------
*/

/*
**===========================================================================
**  3.      DECLARATIONS
**  3.1     Internal constants
**===========================================================================
*/
/* Definicje pinów uP pod³¹czonych do LCD */
#define LCD_E			0			// Numer pinu E (0-7)
#define LCD_E_PORT		P2 			// Port pinu E
#define LCD_RW			1			// Numer pinu RW (0-7)
#define LCD_RW_PORT		P2			// Port pinu RW
#define LCD_RS			2			// Numer pinu RS (0-7)
#define LCD_RS_PORT		P2			// Port pinu RS
#define LCD_DATA		2			// Numer bitu 0 4-ro bitowej linii danych (0-3)
#define LCD_DATA_PORT	P1			// Port linii danych

/*
**===========================================================================
**  3.2     Internal macros
**===========================================================================
*/
/* Makra rejstrów dla portów */ 
#define PDIR(x) 	_PDIR(x)
#define POUT(x)		_POUT(x)
#define PIN(x)		_PIN(x)
#define PSEL(x)		_PSEL(x)
#define PREN(x)		_PREN(x)
#define PIFG(x)		_PIFG(x)
#define PIE(x)		_PIE(x)
#define PIES(x)		_PIES(x)

#define _PDIR(x)	x##DIR
#define _POUT(x)	x##OUT
#define _PIN(x)		x##IN
#define _PSEL(x)	x##SEL
#define _PREN(x)	x##REN
#define _PIFG(x)	x##IFG
#define _PIE(x)		x##IE
#define _PIES(x)	x##IES
/*
**===========================================================================
**  3.3     Internal type definitions
**===========================================================================
*/

/*
**===========================================================================
**  3.4     Global variables (declared as 'extern' in some header file)
**===========================================================================
*/

/*
**===========================================================================
**  3.5     Internal function prototypes (defined in Section 5)
**===========================================================================
*/
static void vprvDelay(void);
static void vprvEpulse(void);
static void vprvOut(unsigned char ucData);
static unsigned char ucprvIn(void);
static void vprvSpecialOut(unsigned char ucData);
static void vprvWaitAccept(void);
/*
**===========================================================================
**  3.6     Internal variables
**===========================================================================
*/

/*
**===========================================================================
**  4.      GLOBAL FUNCTIONS (declared as 'extern' in some header file)
**===========================================================================
*/

unsigned char ucAlfaLcdInC ( void )
/*
**---------------------------------------------------------------------------
**
**  Abstract:
**      User application
**
**  Parameters:
**      None
**
**  Returns:
**      None
**
**---------------------------------------------------------------------------
*/
{
    /*
    **---------------------------------
    ** Your application code goes here
    **---------------------------------
    */
    unsigned char ucTemp;
    
	PDIR(LCD_DATA_PORT) &= ~(0x0F<<LCD_DATA);	// DATA - INPUT
	POUT(LCD_RS_PORT) &= ~(1<<LCD_RS);			// RS = 0
	POUT(LCD_RW_PORT) |= (1<<LCD_RW);			// RW = 1
	ucTemp = ucprvIn();							// Odczytanie linii 4p
	return(ucTemp);
} /* ucAlfaLcdInC */

void vAlfaLcdOutC ( unsigned char ucData )
/*
**---------------------------------------------------------------------------
**
**  Abstract:
**      User application
**
**  Parameters:
**      None
**
**  Returns:
**      None
**
**---------------------------------------------------------------------------
*/
{
    /*
    **---------------------------------
    ** Your application code goes here
    **---------------------------------
    */
	PDIR(LCD_DATA_PORT) |= (0x0F<<LCD_DATA);	// DATA - OUTPUT
	POUT(LCD_RS_PORT) &= ~(1<<LCD_RS);			// RS = 0
	POUT(LCD_RW_PORT) &= ~(1<<LCD_RW);			// RW = 0
	vprvOut(ucData);							// Zapisanie linii 4p
} /* vAlfaLcdOutC */

void vAlfaLcdOutD ( unsigned char ucData )
/*
**---------------------------------------------------------------------------
**
**  Abstract:
**      User application
**
**  Parameters:
**      None
**
**  Returns:
**      None
**
**---------------------------------------------------------------------------
*/
{
    /*
    **---------------------------------
    ** Your application code goes here
    **---------------------------------
    */
	PDIR(LCD_DATA_PORT) |= (0x0F<<LCD_DATA);	// DATA - OUTPUT
	POUT(LCD_RS_PORT) |= (1<<LCD_RS);			// RS = 1
	POUT(LCD_RW_PORT) &= ~(1<<LCD_RW);			// RW = 0
	vprvOut(ucData);							// Zapisanie linii 4p
} /* vAlfaLcdOutD */

void vAlfaLcdSetup ( void )
/*
**---------------------------------------------------------------------------
**
**  Abstract:
**      User application
**
**  Parameters:
**      None
**
**  Returns:
**      None
**
**---------------------------------------------------------------------------
*/
{
    /*
    **-----------------------------
    ** Initialise used peripherals 
    **-----------------------------
    */
	PDIR(LCD_E_PORT) |= (1<<LCD_E);			// E - OUTPUT
	PDIR(LCD_RW_PORT) |= (1<<LCD_RW);		// RW - OUTPUT
	PDIR(LCD_RS_PORT) |= (1<<LCD_RS);		// RS - OUTPUT
	POUT(LCD_E_PORT) &= ~(1<<LCD_E);		// E = 0
} /* vAlfaLcdSetup */

void vAlfaLcdInit ( void )
/*
**---------------------------------------------------------------------------
**
**  Abstract:
**      User application
**
**  Parameters:
**      None
**
**  Returns:
**      None
**
**---------------------------------------------------------------------------
*/
{
    /*
    **---------------------------------
    ** Your application code goes here
    **---------------------------------
    */
	vprvSpecialOut(0x20);
	vprvWaitAccept();
} /* vAlfaLcdInit */

/*
**===========================================================================
**  5.      INTERNAL FUNCTIONS (declared in Section 3.5)
**===========================================================================
*/
/* Delay wymagany przez sterownik LCD */
static void vprvDelay(void)
{
	asm ("	nop");
}/* vprvDelay */

/* Impuls L-H-L na linii E */
static void vprvEpulse(void)
{
	POUT(LCD_E_PORT) |= (1<<LCD_E);			// E = 1
	vprvDelay();
	POUT(LCD_E_PORT) &= ~(1<<LCD_E);		// E = 0
}/* vprvEpulse */

/* Wystawienie pó³bajtów na liniê danych */
static void vprvOut(unsigned char ucData)
{
	POUT(LCD_DATA_PORT) &= ((ucData>>(4-LCD_DATA))|(0xFF&~(0xF0>>(4-LCD_DATA))));	// Wyzerój zera starszego pó³bajtu
	POUT(LCD_DATA_PORT) |= ((ucData>>(4-LCD_DATA))&(0xF0>>(4-LCD_DATA)));			// Ustaw jednynki starszego pó³bajtu
	vprvEpulse();
	POUT(LCD_DATA_PORT) &= ((ucData<<(LCD_DATA))|(0xFF&~(0x0F<<(LCD_DATA))));		// Wyzerój zera m³odszego pó³bajtu
	POUT(LCD_DATA_PORT) |= ((ucData<<(LCD_DATA))&(0x0F<<(LCD_DATA)));				// Ustaw jednynki m³odszego pó³bajtu
	vprvEpulse();
}/* vprvOut */

/* Odebranie pó³bajtów z linii danych */
static unsigned char ucprvIn(void)
{
	unsigned char ucTemp, ucTemp4p;
	POUT(LCD_E_PORT) |= (1<<LCD_E);				// E = 1
	vprvDelay();
	ucTemp = PIN(LCD_DATA_PORT)<<(4-LCD_DATA);
	POUT(LCD_E_PORT) &= ~(1<<LCD_E);			// E = 0
	// Tu mo¿e te¿ potrzebny jest delay?
	POUT(LCD_E_PORT) |= (1<<LCD_E);				// E = 1
	vprvDelay();
	ucTemp4p = PIN(LCD_DATA_PORT)>>LCD_DATA;
	POUT(LCD_E_PORT) &= ~(1<<LCD_E);			// E = 0
	ucTemp |= ucTemp4p;							// Ustaw jedynki
	ucTemp &= ucTemp4p | 0xF0;					// Kasuj zera
	return (ucTemp);
}/* ucprvIn */

/* Do inicjalizacji */
static void vprvSpecialOut(unsigned char ucData)
{
	PDIR(LCD_DATA_PORT) |= (0x0F<<LCD_DATA);	// DATA - OUTPUT
	POUT(LCD_RS_PORT) &= ~(1<<LCD_RS);			// RS = 0
	POUT(LCD_RW_PORT) &= ~(1<<LCD_RW);			// RW = 0
	POUT(LCD_DATA_PORT) &= ((ucData>>(4-LCD_DATA))|(0xFF&~(0xF0>>(4-LCD_DATA))));	// Wyzerój zera starszego pó³bajtu
	POUT(LCD_DATA_PORT) |= ((ucData>>(4-LCD_DATA))&(0xF0>>(4-LCD_DATA)));			// Ustaw jednynki starszego pó³bajtu
	vprvEpulse();
}/* vprvSpecialOut */

/* Czekanie na gotowoœæ */
static void vprvWaitAccept(void)
{
	volatile unsigned char ucStatus;
	
	do
	{
		ucStatus = ucAlfaLcdInC();
	}/* do */
	while ((ucStatus & 0x80) == 0x80);
}/* WaitAccept */
		
/*
**===========================================================================
** END OF FILE
**===========================================================================
*/ 


