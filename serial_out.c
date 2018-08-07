#include "xiomodule.h"
#include "robo_control.h"
#include "serial_out.h"

void sendByte ( u32 byte )
{
	/* ------------------------------
	 * -- Your code here
	 * ------------------------------
	 */
	u32 u32TxData = 0;
	/* Write the received data to GPO2. Set bit8 to ´1´.
	 * GPO2 has 9bits. bit7to0:data and bit8:data_ready.*/
	/* First Set the state as sendback FALSE so that until completion
	 * of receiving, sending is blocked  */
	/* The below 2 lines of code is just to debug by printing on LED on board*/
	 tmp++;
	XIOModule_DiscreteWrite(&ioModule, GPO1, tmp);

   	while (!(0 == txBusy));//txBusy is set to 0 by ISR;sendBack is set to 0 when rx is happening, setting this also is done inside ISR. So we can put this part inside a loop.

		txBusy = 1;
		u32TxData = byte | (1 << 8);
		XIOModule_DiscreteWrite(&ioModule, GPO2, u32TxData);
}

void sendData ( u32 u32TxData)
{
	/* ------------------------------
	 * -- Your code here
	 * ------------------------------
	 */
	u8* byte;
	u8 bytePos = 0;
	//int delay=0;
	byte = &u32TxData;
	for (bytePos = 0; bytePos < 4; bytePos++ )
	{
		/* This code is wrong;
		 *byte = u32TxData >> bytePos*8;
		 */
		sendByte(*byte++);
		//for (delay=0; delay<5000; delay++);
	}
}

