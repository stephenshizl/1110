;*====*====*====*====*====*====*====*====*====*====*====*====*====*====
;
;                     TCXO SHUTDOWN  AND CLOCK SWITCHING
;
; GENERAL DESCRIPTION
; Contains assembly code to shutdwon TCXO for NOR/PSRAM configuration
; and clock switching for both NOR/PSRAM and NAND/SDRAM configurations.
;
; EXTERNALIZED FUNCTIONS
;   config_pcollapse
;     prepares various registers to power saving mode, turns off TCXO
;     and shuts down the digital core power.
;
;
; IMPORTANT NOTE
;
;   The assembly code in this file is hand coded to get optimal clock
;   switching performance. The code has been written to load the clock
;   switching code into cache and the registers have been hand picked
;   to make sure that no external access occurs during clock switching.
;   It is very important that this code is left unmodified to ensure
;   proper operation. There is no user modifiable code in this file.
;
; INITIALIZATION AND SEQUENCING REQUIREMENTS
;   None.
;
;
; Copyright (c) 1998,1999 by QUALCOMM, Incorporated. All Rights Reserved
; Copyright (c) 2000-2006 by QUALCOMM, Incorporated.
;               All Rights Reserved
;*====*====*====*====*====*====*====*====*====*====*====*====*====*====


;*====*====*====*====*====*====*====*====*====*====*====*====*====*====
;
;                           EDIT HISTORY FOR FILE
;  This section contains comments describing changes made to the module.
;  Notice that changes are listed in reverse chronological order.
;
;  8/11/04 bgc Changed ref clock and removed wait loop for 32kHz sleep.
;
;*====*====*====*====*====*====*====*====*====*====*====*====*====*====


;======================================================================
;
;                          MODULE INCLUDES
;
;======================================================================

#include "customer.h"
#include "msm.h"
#include "mpmc.h"
#include "boot_sleep_macros.s"

;=======================================================================
;
;                          MODULE EXPORTS
;
;=======================================================================

; Export the symbols __main and _main to prevent the linker from
; including the standard runtime library and startup routine.

       EXPORT  config_pcollapse
;=======================================================================
;
;                          MODULE DEFINES
;
;=======================================================================

; Number of HCLK cycles to pause after switching the MCLK.  This
; value corresponds to a duration of 5 microseconds when the HCLK
; is 73 MHz.

CLOCK_SWITCH_PAUSE    EQU   360

;=======================================================================
;
;                          MODULE PROCEDURES
;
;=======================================================================

    AREA    BOOT_PREPARE_TCXO_OFF, CODE, READONLY , ALIGN=5
    CODE32

;=======================================================================
; CONFIG_PCOLLAPSE
;
; DESCRIPTION
;   Function to turn off TCXO, switch the micro clock off
;   and shut down the digital core power.
;
; SIDE FFECTS
; None
;=======================================================================

config_pcollapse
; ======================================================================
; Save the registers
; ======================================================================
;    stmfd sp!, {r4-r12,lr} don't do this because of L4 context save


; ======================================================================
; Pre-fetch the code for tcxo sutdown to cache
; ======================================================================
;  N/A
; ======================================================================
;Power down ARM
; ======================================================================
    ldr r2, =0x1
    ldr r1, =0x0
    
    ldr r9, =HWIO_ADDR(MICRO_CLK_OFF)
;;; (r9 reserved for MICRO_CLK_OFF)

    str   r2, [r9]
    str   r1, [r9]
;;; (r9 is free to be reused)
; ======================================================================
;MCLK is no longer oscillating, so the uP will halt.  MCLK will start
;oscillating again as soon as the next non-masked interrupt fires.
;---------------------------------------------------------------------
;---------------------------------------------------------------------
;An interrupt has fired!  Restore MCLK to its pre-sleep rate, and
;return to the caller (which should free interrupts, allowing the
;interrupt to be vectored).
;


; ======================================================================
; restore the registers and return
; ======================================================================
;    ldmfd sp!, {r4-r12,lr}
    bx    lr
    END
