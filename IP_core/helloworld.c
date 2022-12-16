/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xil_io.h"


int main()
{
	int ready;
	int start;
	int block_type_00;
	int block_type_01;
	int block_type_10;
	int block_type_11;
	int gr;
	int ch;
	int i;

	init_platform();
    Xil_DCacheDisable();
    Xil_ICacheDisable();
    printf("\n");

    printf("\n\rPROGRAM POCINJE\r\n");

    for (i = 0; i < 1152 ; i++){
    	Xil_Out32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + i*4, 0x40000000);
    	//printf("BRAM[%d]: %x\n", i, Xil_In32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR+ i*4));
    }

    for (i = 0; i < 1152 ; i++){
        	Xil_Out32(XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR + i*4, 0x40000000);
        	//printf("BRAM[%d]: %x\n", i, Xil_In32(XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR+ i*4));
    }

    printf("\n\rUPISAO U BRAM\r\n");

    Xil_Out32(XPAR_IMDCT_0_S00_AXI_BASEADDR + 4, 0 );
	Xil_Out32(XPAR_IMDCT_0_S00_AXI_BASEADDR + 8, 0 );
	Xil_Out32(XPAR_IMDCT_0_S00_AXI_BASEADDR + 12, 0 );
	Xil_Out32(XPAR_IMDCT_0_S00_AXI_BASEADDR + 16, 0 );
	Xil_Out32(XPAR_IMDCT_0_S00_AXI_BASEADDR + 20, 0 );
	Xil_Out32(XPAR_IMDCT_0_S00_AXI_BASEADDR + 24, 0 );

    block_type_00 = Xil_In32(XPAR_IMDCT_0_S00_AXI_BASEADDR + 4);
    printf("block_type_00 is: %d \n", block_type_00 );

    block_type_01 = Xil_In32(XPAR_IMDCT_0_S00_AXI_BASEADDR + 8);
    printf("block_type_01 is: %d \n", block_type_01 );

    block_type_10 = Xil_In32(XPAR_IMDCT_0_S00_AXI_BASEADDR + 12);
    printf("block_type_10 is: %d \n", block_type_10 );

    block_type_11 = Xil_In32(XPAR_IMDCT_0_S00_AXI_BASEADDR + 16);
    printf("block_type_11 is: %d \n", block_type_11 );

    gr = Xil_In32(XPAR_IMDCT_0_S00_AXI_BASEADDR + 20 );
    printf("gr is: %d \n", gr );

    ch = Xil_In32(XPAR_IMDCT_0_S00_AXI_BASEADDR + 24 );
    printf("ch is: %d \n", ch );

    Xil_Out32(XPAR_IMDCT_0_S00_AXI_BASEADDR , 1 );
    start = Xil_In32(XPAR_IMDCT_0_S00_AXI_BASEADDR);
    printf("start is: %d \n", start );

    ready = Xil_In32(XPAR_IMDCT_0_S00_AXI_BASEADDR + 28 );
    printf("ready is: %d\n", ready );

    Xil_Out32(XPAR_IMDCT_0_S00_AXI_BASEADDR , 0 );

    start = Xil_In32(XPAR_IMDCT_0_S00_AXI_BASEADDR );
    printf("start is: %d \n", start );
    ready = Xil_In32(XPAR_IMDCT_0_S00_AXI_BASEADDR + 28);
    printf("ready is: %d\n", ready );

	printf("\n\rOBRADA\r\n");

    printf("\n\rCITA IZ BRAM-a\r\n");
    printf("\n\rBRAM-a 0\r\n");

    for (i = 0; i < 1152; i++){
    	printf("BRAM[%d]: %x\n", i+1, Xil_In32(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR+ i*4));
    }
/*
    printf("\n\rBRAM-a 1\r\n");

    for (i = 0; i < 1152; i++){
    	printf("BRAM[%d]: %x\n", i+1, Xil_In32(XPAR_AXI_BRAM_CTRL_1_S_AXI_BASEADDR+ i*4));
    }
*/
    start = Xil_In32(0x43C00000 );
    printf("start is: %d \n", start );
    ready = Xil_In32(0x43C00000 + 28);
    printf("ready is: %d\n", ready );

    printf("\n\rKRAJ PROGRAMA\r\n");

    cleanup_platform();
    return 0;
}

