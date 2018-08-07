#ifndef __SERIAL_OUT_H__
#define __SERIAL_OUT_H__

/*	------------------------------
 *	-- sendByte
 *	------------------------------
 *
 * 	- writes request + byte into hw register
 *	- waits for acknowledge
 */

void sendByte ( u32 byte );

/*	------------------------------
 *	-- sendData
 *	------------------------------
 *
 * 	- sends 32 bit float values (order: 0 to 5)
 *	- considers byte order:
 *		- least significant byte
 *		- ...
 *		- most significant byte
 */

void sendData ( u32 u32TxData );

#endif // __SERIAL_OUT_H__
