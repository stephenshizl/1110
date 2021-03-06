<?xml version="1.0" encoding="utf-16"?>

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method="text" encoding="us-ascii"/>
  <xsl:template match="/CALIBRATION_DATABASE">
    <![CDATA[
#ifndef SNDCAL_H
#define SNDCAL_H
/*===========================================================================

             S O U N D   C A L I B R A T I O N   D A T A B A S E
    S T O R A G E   A N D   R E T R I E V A L   H E A D E R    F I L E

DESCRIPTION
  This header file contains all the definitions necessary to access the
  raw data contained in the audio calibration database.
  
Copyright (c) 1999-2002 by QUALCOMM, Incorporated.  All Rights Reserved.
===========================================================================*/

#include "comdef.h"             /* Definitions for byte, word, etc.          */
#include "snddev.h"             /* Definitions for audio devices and methods */
#include "sndgen.h"             /* Definitions for HW sound generators       */
#include "voc.h"                /* Vocoder interface definition              */

/* ===========================================================================
**
**                           D E F I N I T I O N S
**  
** =========================================================================*/
/* To build a version for use in setting volume levels, define this symbol.
** When defined, the volume tables will be placed in RAM where values can
** be modified using the DM.
*/
#ifdef FEATURE_AVS_DYNAMIC_CALIBRATION
#define VOL_MEMORY
#else
#define VOL_MEMORY   const     /* Normally, tables are in ROM  */
#endif

/* Function return values
*/
typedef enum {
  SND_CAL_SUCCESS,
  SND_CAL_FAILED
} snd_cal_return_type;

    ]]>
    <xsl:apply-templates select="TYPES/INTERNAL_DATATYPES[@filename='snd_cal']"/>
    <![CDATA[
/* Data structure to contain all calibration data for one audio device
*/
typedef snd_cal_control_type 
        snd_cal_device_calibration_type[SND_METHOD_MAX];  
/* ===========================================================================
**
**                 F U N C T I O N   D E F I N I T I O N S
**  
** =========================================================================*/
/*===========================================================================

FUNCTION snd_cal_get_audio_control

DESCRIPTION
  Get the pointer to the audio calibration data according to this
  [device, method]
  
DEPENDENCIES
  None.

RETURN VALUE
  SND_CAL_SUCCESS - data retrieved successfully
  SND_CAL_FAILED  - could not get data

SIDE EFFECTS
  None.

===========================================================================*/
extern snd_cal_return_type snd_cal_get_audio_control (
  snd_device_type      device,         /* device                             */
  snd_method_type      method,         /* method                             */
  snd_cal_control_type **audio_config  /* pointer of pointer to audio_config */
);

#endif /* SNDCAL_H */ 
]]>
  </xsl:template>

  <!-- INCLUDES Template -->
  <xsl:template match="TYPES/HEADER_INCLUDES[@filename='snd_cal']">
    <xsl:for-each select="INCLUDE">
      <xsl:text>&#xa;#include "</xsl:text>
      <xsl:value-of select="text()"/>
      <xsl:text>"</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <!-- TYPES Template -->
  <xsl:template match="TYPES/INTERNAL_DATATYPES[@filename='snd_cal']">
    <xsl:call-template name="process_types"/>
  </xsl:template>

  <xsl:include href="hdr_tmpl.xslt"/>
  
</xsl:stylesheet>
