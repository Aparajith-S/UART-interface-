/*
 * Copyright (c) 2009 Xilinx, Inc.  All rights reserved.
 *
 * Xilinx, Inc.
 * XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS" AS A
 * COURTESY TO YOU.  BY PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
 * ONE POSSIBLE   IMPLEMENTATION OF THIS FEATURE, APPLICATION OR
 * STANDARD, XILINX IS MAKING NO REPRESENTATION THAT THIS IMPLEMENTATION
 * IS FREE FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE RESPONSIBLE
 * FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE FOR YOUR IMPLEMENTATION.
 * XILINX EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH RESPECT TO
 * THE ADEQUACY OF THE IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO
 * ANY WARRANTIES OR REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
 * FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.
 *5
 */

/*
 * helloworld.c: simple test application
 */

#include <stdio.h>
#include <math.h>
#include "platform.h"
#include "xparameters.h"
#include "xiomodule.h"
#include "state.h"
#include "serial_out.h"
#include "seven_segment.h"
#include "robo_control.h"
u32 u32RxData;
u8 u8RxDone;
u8 u8EngineNr = 0;
void isrTxAck ( void )
{
	/* ------------------------------
	 * -- Your code here
	 * ------------------------------
	 */
	/* Once data tx done, hw raises interrupt data_sent ie isrTxack
		- isrTxack sets bit8 as 0. */
	u32RxData = u32RxData & (0xFFFFFEFF);
	XIOModule_DiscreteWrite(&ioModule, GPO2, u32RxData);
	txBusy = 0;
	return;
}

/* Reads UART Data  from GPI1.*/
void isrRxReq ( void )
{
	/* ------------------------------
	 * -- Your code here
	 * ------------------------------
	 */
	/* Set the state as sendback FALSE so that until completion
	 * of receiving, sending is blocked  */
	sendBack = 0;
	u32RxData = XIOModule_DiscreteRead(&ioModule, GPI_RX_DATA);
	/* After reading write 1 to 8th bit of GPO3 and
	immediate 0 - to acknowledge receive data.*/
	XIOModule_DiscreteWrite(&ioModule, GPO3, 1);
	XIOModule_DiscreteWrite(&ioModule, GPO3, 0);
	u8RxDone = 1;
	/* Set state so that now send can start. */
	sendBack = 1;
	return;
}

void ackTimeout ( void )
{
	u8 i = 0;
	for (i=0;i<1;) i++;
}
void computeEngineNr()
{
	switch (u8EngineNr)
	{
		case 0x06:
		case 0x05:
			u8EngineNr = 1;
		break;

		case 0x0A:
		case 0x09:
			u8EngineNr = 2;
		break;

		case 0x12:
		case 0x11:
			u8EngineNr = 3;
		break;

		case 0x22:
		case 0x21:
			u8EngineNr = 4;
		break;

		case 0x42:
		case 0x41:
			u8EngineNr = 5;
		break;

		case 0x82:
		case 0x81:
			u8EngineNr = 6;
		break;

		default:
			u8EngineNr = 0;
	}
}

int main ()
{
	tmp = 0;
	u8 u8EngineCmd = 0;
	int motorIndex = 0;

    init_platform();

    // Initialize
    XIOModule_Initialize(&ioModule, XPAR_IOMODULE_0_DEVICE_ID);

    // Register Interrupthandler
    microblaze_register_handler(XIOModule_DeviceInterruptHandler, XPAR_IOMODULE_0_DEVICE_ID);

    // Connect/Enable ISR for Seven Segment Display
	XIOModule_Connect(&ioModule, INT_TX_ACK, (XInterruptHandler) isrTxAck, XPAR_IOMODULE_0_DEVICE_ID);
	XIOModule_Enable(&ioModule, INT_TX_ACK);

	// Connect/Enable ISR for Seven Segment Display
	XIOModule_Connect(&ioModule, INT_RX_REQ, (XInterruptHandler) isrRxReq, XPAR_IOMODULE_0_DEVICE_ID);
	XIOModule_Enable(&ioModule, INT_RX_REQ);

    // enable Interrupts
    microblaze_enable_interrupts();

    // main loop
    while (1)
    {
    	// Update Seven Segment Display
    	updateSevenSegment();

    	if (1 == u8RxDone)
    	{
    		u8EngineCmd = u32RxData & 0x03;
    		u8EngineNr = u32RxData;
    		computeEngineNr();

    		if(u8EngineNr>0 && u8EngineNr<7)
    	    u8EngineNr-- ;
    		else
    	    {;}

    		updateState(u8EngineNr, u8EngineCmd);
    		u8RxDone = 0;
    	}
    	// Send back Data (if needed)
    	if (1 == sendBack)
    	{
			for(motorIndex = 0; motorIndex < ENGINE_COUNT; motorIndex++)
			{
				sendData((u32)engines[motorIndex]);
			}
			sendBack = 0;

    	}

    	updateSevenSegment();
    }

    cleanup_platform();

    return 0;
}
