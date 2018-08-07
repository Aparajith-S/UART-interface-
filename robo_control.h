#ifndef __ROBO_CONTROL_H__
#define __ROBO_CONTROL_H__

/*	######################################
 *	#                                    #
 *	#               Defines              #
 *	#                                    #
 *	######################################
 */

// Number of Engines
#define ENGINE_COUNT	6

// IO Module Channels
#define INT_TX_ACK		( XPAR_IOMODULE_INTC_MAX_INTR_SIZE - 1 - XPAR_IOMODULE_0_SYSTEM_INTC_INTERRUPT_1_INTR )
#define INT_RX_REQ		( XPAR_IOMODULE_INTC_MAX_INTR_SIZE - 1 - XPAR_IOMODULE_0_SYSTEM_INTC_INTERRUPT_0_INTR )
#define GPO_SEVEN_SEG	1
#define GPO_TX_DATA		2
#define GPO_RX_ACK		3
#define GPI_SWITCH		1
#define GPI_RX_DATA		2

// Masks
#define MASK_ENGINE		0xfc
#define MASK_CMD		0x03

// Commands
#define CMD_DECR		0x01
#define CMD_INC			0x02
#define CMD_INIT		0x03

/* GPO */
#define GPI1 1
#define GPO1 1
#define GPO2 2
#define GPO3 3


/*	######################################
 *	#                                    #
 *	#           Global Variables         #
 *	#                                    #
 *	######################################
 */

/* UART Receive Data */
u32 u32RxData;
u32 tmp;

// Angles of Engines
float engines[ENGINE_COUNT];

// IO Module for GPI, GPO, Interrupt
XIOModule ioModule;
extern u8 u8EngineNr;

// State Update
u8 collisionState;
u8 sendBack;
u8 txBusy;

// TX Acknowledge
u8 txAck;

/*	######################################
 *	#                                    #
 *	#              Functions             #
 *	#                                    #
 *	######################################
 *
 *	------------------------------
 *	-- isrTxAck
 *	------------------------------
 *
 * 	- interrupt service routine that is called on serial transmit interrupt (acknowledge)
 * 	- resets hw register for transmitting data
 */

void isrTxAck ( void );

/*	------------------------------
 *	-- isrRxReq
 *	------------------------------
 *
 *	- interrupt service routine that is called on serial receive interrupt (request)
 *	- reads data from hw register
 *	- updates roboter state
 *	- gives acknowledge to serial receiving unit
 */

void isrRxReq ( void );

/*	------------------------------
 *	-- ackTimeout
 *	------------------------------
 *
 * 	dummy function to be able to write the same register twice, without optimizing away
 * 	the first write operation
 */

void ackTimeout ( void );

#endif // __ROBO_CONTROL_H__
