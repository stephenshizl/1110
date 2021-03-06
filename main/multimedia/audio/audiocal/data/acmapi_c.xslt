<?xml version="1.0" encoding="utf-16"?>

<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text" encoding="us-ascii"/>
  <xsl:template match="/CALIBRATION_DATABASE">
    <![CDATA[/** 
\file ***************************************************************************
*
*                                    A C M    A P I
*
*DESCRIPTION
* This file implements functions required to get/set data into calibration data 
tables in.voccal.c/sndcal.c.
*
*Copyright (c) 2008 by QUALCOMM, Incorporated.  All Rights Reserved.
*******************************************************************************
*/
/* <EJECT> */
/**
\file ***************************************************************************
*
*                      EDIT HISTORY FOR FILE
*
*  This section contains comments describing changes made to this file.
*  Notice that changes are listed in reverse chronological order.
*   
*  $Header: //depot/asic/msmshared/services/avs/acmapi.c#1 $ $DateTime: 2007/01/19 21:12:52 $ $Author: adiseshu $
*
*when         who     what, where, why<br>
*--------   ---     ----------------------------------------------------------<br>
*01/25/08   mas    created  file<br>
*
*******************************************************************************
*/

/*
      --------------------
      |include files     |
      --------------------
*/

#include <stdlib.h>  /* needed for malloc() and free()*/
#include <string.h>  /* needed for memcpy, memset, and memmove*/
#include "acmapi.h"
#include "voc.h"
#define MSG_MED(a,b,c,d)  
#ifdef FEATURE_AVS_DYNAMIC_CALIBRATION]]>
    <xsl:text>&#xa;acm_guid build_guid = </xsl:text>
    <!--<xsl:variable name="file_guid"  select="/CALIBRATION_DATABASE/CALFILE_INFO/GUID"/>-->
    <!--will have to come back here to modify the guid string to guid in struct format-->
    <xsl:call-template name="guid_to_string">
      <xsl:with-param name="guid" select="/CALIBRATION_DATABASE/CALFILE_INFO/GUID/text()"/>
    </xsl:call-template>
    <xsl:text>; &#xa;</xsl:text>
    <xsl:text>&#xa;acm_guid calunitlist[CALUNIT_MAX]= { &#xa;</xsl:text>
    <xsl:call-template name="process_cal_guid"/>
    <xsl:text>&#xa;}; &#xa;</xsl:text>
    <![CDATA[ 
#ifdef FEATURE_AUDFMT_IIR_FILTER
  /* Audio format IIR turning filter
  **
  ** The maximum filter is 4
  **This is defined in voccal.c. since it is not externized, redifined here.
  */
  #define VOC_CAL_AUDFMT_IIR_FILTER_NUM 4
#endif
/**
* FUNCTION acmapi_get_calunit_from_guid
*
* DESCRIPTION : finds matching Calunit from map for paased guid
*
* DEPENDENCIES: None 
*
* RETURN VALUE: acm_calunit_enum
* if matching guid found in map enum elelment if found 
* else CALUNIT_UNKNOWN
*
* SIDE EFFECTS: None
*/
acm_calunit_enum acmapi_get_calunit_from_guid
(
  acm_guid *guid
)
{
  /*initialize calunit*/
  acm_calunit_enum calunit = CALUNIT_UNKNOWN;
  int i=0;
  if ( guid == NULL )
  {
    return calunit;
  }
  /*try to match with calunit list we have*/
  for(i=0;i<CALUNIT_MAX;i++)
  {
    if( memcmp((void *)&calunitlist[i],(void *)guid,ACM_GUID_SIZE) == 0)
    {
      /*found. break here.*/
      calunit = (acm_calunit_enum) i;
      break;
    }
  }
  return calunit;
}

/*=============================================================
 FUNCTION acmapi_check_build_guid

 DESCRIPTION : Helper function to compares a build guid with the given guid. 

 DEPENDENCIES: None 

 RETURN VALUE: acm_error_code
ACM_ERR_NONE if success
 ACM_ERR_CALFILE_MISMATCH if build guid doesn't matches
 
 SIDE EFFECTS: None
 ============================================================*/
acm_error_code acmapi_check_build_guid
(
  acm_guid *guid
)
{
  if ( guid == NULL )
  {
    return ACM_ERR_UNKNOWN;
  }
  /*Compare with build guid. */
  if( memcmp((void *)&build_guid,(void *)guid,ACM_GUID_SIZE) == 0 )
  {
    return ACM_ERR_NONE;
  }
  else
  {
    return ACM_ERR_CALFILE_MISMATCH;
  }
}


/**
* FUNCTION acmapi_get_feature_info
*
* DESCRIPTION : returns a byte array indicating TRUE if feature is enabled and FALSE if 
* feature is disabled. 
*
* This function should be generated automatically from audio cal xml file in future
*
* DEPENDENCIES: None 
*
* RETURN VALUE: acm_error_code
* ACM_ERR_NONE if success
* ACM_ERR_CALFILE_MISMATCH if build guid doesn't matches
*
* SIDE EFFECTS: None
*/
acm_error_code acmapi_get_feature_info
(
  byte *req_buf_ptr,
  uint32* req_buf_length,
  byte **resp_buf_ptr,
  uint32 *resp_buf_length
)
{
  int i=0;
  /*  
    * This is count of various FEATURES used in audio calibration database.
    * List is taken manually from audio calibration file, which is inturn taken 
    * from voccal.c/h and sndcal.c/h
    */
  int feature_count = ]]><xsl:value-of select="count(FEATURE_LIST/FEATURE)"/><![CDATA[;
  byte *feature_buf_ptr;
  acm_guid guid;
  acm_error_code retval = ACM_ERR_UNKNOWN;
  acm_cmd_struct_header cmd_header;
  memcpy((void *)&guid,req_buf_ptr,ACM_GUID_SIZE);
  req_buf_ptr +=ACM_GUID_SIZE;
  *req_buf_length -= ACM_GUID_SIZE;
  retval = acmapi_check_build_guid(&guid);
  if ( retval != ACM_ERR_NONE )
  {
    return retval;
  }
  /*Calculate command buffer size. one byte will be used to represent if a 
     feature is enabled/disbled*/
  *resp_buf_length = sizeof(byte)*feature_count + sizeof(acm_cmd_struct_header);
  /*allocate memory and set header information*/
  feature_buf_ptr = (byte *)malloc(*resp_buf_length);
  cmd_header.cmd_buf_length = sizeof(byte)*feature_count;
  cmd_header.cmd_id = CMD_SET_FEATURE_INFO;
  memcpy(feature_buf_ptr,(void *)&cmd_header,sizeof(acm_cmd_struct_header));
  /*calculate offset*/
  i = sizeof(acm_cmd_struct_header); ]]>
    <xsl:apply-templates select="FEATURE_LIST"/>
    <![CDATA[   *resp_buf_ptr = feature_buf_ptr;
    return ACM_ERR_NONE;
} ]]>
    <xsl:apply-templates  select="CALUNITS"/>
    <![CDATA[
/**
* FUNCTION acmapi_get_volume_levels_calunit_size
*
* DESCRIPTION : calculates volume levels calunit size. 
*
* DEPENDENCIES: None 
*
* RETURN VALUE: acm_error_code
* ACM_ERR_UNKNOWN
* ACM_ERR_NONE if success
* ACM_ERR_UNEXPECTED_BUF_SIZE if buffer size doesnot matches with expected structure size
*
* SIDE EFFECTS: None
*/
acm_error_code acmapi_get_volume_levels_calunit_size
(
  audio_filter_indices_struct *audio_filter_indices_ptr,
  uint32 *volume_level_size
)
{
  snd_cal_control_type *audio_config_ptr;
  snd_cal_return_type retVal;
  snd_gen_cal_type *gen_cal_ptr;

  *volume_level_size = 0 ;
  retVal = snd_cal_get_audio_control((snd_device_type)audio_filter_indices_ptr->snd_device,
                                        (snd_method_type)audio_filter_indices_ptr->snd_method,&audio_config_ptr);

  if ( retVal == SND_CAL_FAILED || audio_config_ptr == NULL)
  {
    MSG_MED("acmapi_get_volume_levels_calunit_size: snd_cal_get_audio_control failed", 0,0,0);
    return ACM_ERR_UNKNOWN;
  }

  /*default size for all snd_gen_type s*/
  *volume_level_size += sizeof(uint32); /*device_vol*/
  *volume_level_size += sizeof(uint32); /*generator*/
  *volume_level_size += sizeof(uint32); /*generator*/
  *volume_level_size += sizeof(uint16); /*num_levels*/
  *volume_level_size += sizeof(uint16); /*num_scale*/
  gen_cal_ptr = audio_config_ptr->gen_cal;
  if( gen_cal_ptr == NULL )
  {
    MSG_MED("acmapi_get_volume_levels_calunit_size: gen_cal is NULL", 0,0,0);
    return ACM_ERR_UNKNOWN;
  }
  if ( gen_cal_ptr->generator == SND_GEN_VOC 
#if defined(FEATURE_AUDIO_FORMAT) || defined(FEATURE_MIDI_OUT)  
  || gen_cal_ptr->generator == SND_GEN_MIDI
#endif  
  )
  {
    *volume_level_size += sizeof(uint32); /*pcm_path*/
    *volume_level_size += sizeof(uint16); /*warmup_time_ms*/
    *volume_level_size += sizeof(uint16); /*pad_mask + one byte padding*/
    /*level data*/
    *volume_level_size += sizeof(snd_gen_level_voc_type) * (gen_cal_ptr->num_levels + 1) ;
  }
  else if( gen_cal_ptr->generator == SND_GEN_RING)
  {
    /*level data*/
    *volume_level_size += sizeof(uint16) * (gen_cal_ptr->num_levels + 1) ;
  }
  return ACM_ERR_NONE;
}

/**
* FUNCTION : acmapi_get_volume_levels_data
*
* DESCRIPTION : copies volume levels  data from buffer to structure
*
* DEPENDENCIES: None 
*
* RETURN VALUE: acm_error_code
* ACM_ERR_UNKNOWN
* ACM_ERR_NONE if success
* ACM_ERR_UNEXPECTED_BUF_SIZE if buffer size doesnot matches with expected structure size
*
* SIDE EFFECTS: Modifies calibration table
* increments the buffer pointer by number of bytes read into buffer
*/
acm_error_code acmapi_get_volume_levels_data
(
  snd_cal_control_type *audio_config_ptr,
  byte **snd_cal_calunit_resp_buf_ptr
)
{
  snd_gen_cal_type *gen_cal = NULL;
  snd_gen_voc_cal_type *voc_gen_cal_ptr = NULL;
  snd_gen_ring_cal_type *ring_gen_cal_ptr = NULL;

  uint8 level_idx = 0 ;

  *(*snd_cal_calunit_resp_buf_ptr) =  (uint32) audio_config_ptr->device_vol;
  *snd_cal_calunit_resp_buf_ptr += sizeof(uint32) ;

  *(*snd_cal_calunit_resp_buf_ptr) = (uint32) audio_config_ptr->generator;
  *snd_cal_calunit_resp_buf_ptr += sizeof(uint32) ;

  gen_cal = audio_config_ptr->gen_cal;
  if( gen_cal == NULL )
  {
    MSG_MED("acmapi_get_volume_levels_data: gen_cal is NULL", 0,0,0);
    return ACM_ERR_UNKNOWN;
  }

  *(*snd_cal_calunit_resp_buf_ptr)  = (uint32) gen_cal->generator;
  *snd_cal_calunit_resp_buf_ptr += sizeof(uint32) ;

  *(*snd_cal_calunit_resp_buf_ptr)  = gen_cal->num_levels;
  *snd_cal_calunit_resp_buf_ptr += sizeof(uint16) ; 

  *(*snd_cal_calunit_resp_buf_ptr)  = gen_cal->num_scale;
  *snd_cal_calunit_resp_buf_ptr += sizeof(uint16) ;

  if ( gen_cal->generator == SND_GEN_VOC
#if defined(FEATURE_AUDIO_FORMAT) || defined(FEATURE_MIDI_OUT)  
  || gen_cal->generator == SND_GEN_MIDI
#endif  
)
  {
     voc_gen_cal_ptr = (snd_gen_voc_cal_type *)audio_config_ptr->gen_cal;
    if ( voc_gen_cal_ptr->level_data == NULL )
    {
      MSG_MED("acmapi_get_volume_levels_data: level_data is NULL", 0,0,0);
      return ACM_ERR_UNKNOWN;
    }
    *(*snd_cal_calunit_resp_buf_ptr) = (uint32)voc_gen_cal_ptr->pcm_path;
    *snd_cal_calunit_resp_buf_ptr += sizeof(uint32);
    *(*snd_cal_calunit_resp_buf_ptr) = voc_gen_cal_ptr->warmup_time_ms;
    *snd_cal_calunit_resp_buf_ptr += sizeof(uint16);
    *(*snd_cal_calunit_resp_buf_ptr) = voc_gen_cal_ptr->pad_mask;
    *snd_cal_calunit_resp_buf_ptr += sizeof(uint16);/*sizeof(pad_mask) + one byte padding*/

    for(level_idx=0; level_idx <= voc_gen_cal_ptr->num_levels; level_idx++)
    {
      memcpy(*snd_cal_calunit_resp_buf_ptr,
                      &voc_gen_cal_ptr->level_data[level_idx], sizeof(snd_gen_level_voc_type));
      *snd_cal_calunit_resp_buf_ptr += sizeof(snd_gen_level_voc_type);
    }
  }  
  else if( gen_cal->generator == SND_GEN_RING)
  {
    ring_gen_cal_ptr = (snd_gen_ring_cal_type *)audio_config_ptr->gen_cal;
    if ( ring_gen_cal_ptr->level_data == NULL )
    {
      MSG_MED("acmapi_get_volume_levels_data: level_data is NULL", 0,0,0);
      return ACM_ERR_UNKNOWN;
    }
    for(level_idx=0; level_idx <= ring_gen_cal_ptr->num_levels; level_idx++)
    {      
      *(*snd_cal_calunit_resp_buf_ptr) = ring_gen_cal_ptr->level_data[level_idx];
      *snd_cal_calunit_resp_buf_ptr += sizeof(uint16);
    }
  }
  return ACM_ERR_NONE;
}

/**
* FUNCTION : acmapi_set_volume_levels_data
*
* DESCRIPTION : copies volume levels data from filter structure to buffer
*
* DEPENDENCIES: None 
*
* RETURN VALUE: acm_error_code
* ACM_ERR_UNKNOWN
* ACM_ERR_NONE if success
* ACM_ERR_UNEXPECTED_BUF_SIZE if buffer size doesnot matches with expected structure size
*
* SIDE EFFECTS: Modifies calibration table
* increments the buffer pointer by number of bytes read from buffer
* decrements the remaining buffer length by number of bytes read from buffer
*/
acm_error_code acmapi_set_volume_levels_data
(
  snd_cal_control_type *audio_config_ptr,
  byte **buf_ptr,
  uint32 *remaining_buf_length_ptr
)
{
  snd_gen_cal_type *gen_cal = NULL;
  snd_gen_voc_cal_type *voc_gen_cal_ptr = NULL;
  snd_gen_ring_cal_type *ring_gen_cal_ptr = NULL;

  uint8 level_idx = 0 ;

  /*We need to copy level data only. All other variables cannot be modified*/
  /*Skip buffer till level data*/
  
  /*audio_config_ptr->device_vol*/
  *buf_ptr += sizeof(uint32);
  *remaining_buf_length_ptr -= sizeof(uint32);

  /*audio_config_ptr->generator*/
  *buf_ptr += sizeof(uint32);   
  *remaining_buf_length_ptr -= sizeof(uint32);

  gen_cal = audio_config_ptr->gen_cal;
  if( gen_cal == NULL )
  {
    MSG_MED("acmapi_set_volume_levels_data: gen_cal is NULL", 0,0,0);
    return ACM_ERR_UNKNOWN;
  }
  
  /*audio_config_ptr->gen_cal->generator*/
  *buf_ptr += sizeof(uint32);    
  *remaining_buf_length_ptr -= sizeof(uint32);

  /*audio_config_ptr->gen_cal->num_levels*/
  *buf_ptr += sizeof(uint16); 
  *remaining_buf_length_ptr -= sizeof(uint16);

  /*audio_config_ptr->gen_cal->num_scale*/
  *buf_ptr += sizeof(uint16); 
  *remaining_buf_length_ptr -= sizeof(uint16);

  if ( gen_cal->generator == SND_GEN_VOC 
#if defined(FEATURE_AUDIO_FORMAT) || defined(FEATURE_MIDI_OUT)  
  || gen_cal->generator == SND_GEN_MIDI
#endif  
  )
  {
    voc_gen_cal_ptr = (snd_gen_voc_cal_type *)audio_config_ptr->gen_cal;
    if ( voc_gen_cal_ptr->level_data == NULL )
    {
      MSG_MED("acmapi_set_volume_levels_data: level_data is NULL", 0,0,0);
      return ACM_ERR_UNKNOWN;
    }
    /*voc_gen_cal_ptr->pcm_path*/
    *buf_ptr += sizeof(uint32);
    *remaining_buf_length_ptr -= sizeof(uint32);
    /*voc_gen_cal_ptr->warmup_time_ms=(uint16)*(*buf_ptr);*/
    *buf_ptr += sizeof(uint16);
    *remaining_buf_length_ptr -= sizeof(uint16);
    /*voc_gen_cal_ptr->pad_mask = (uint8)*(*buf_ptr);*/
    *buf_ptr += sizeof(uint16); /*sizeof(pad_mask) + one byte padding;    */
    *remaining_buf_length_ptr -= sizeof(uint16); /*sizeof(pad_mask) + one byte padding;*/
      for(level_idx=0; level_idx <= voc_gen_cal_ptr->num_levels; level_idx++)
      {
        memcpy(&voc_gen_cal_ptr->level_data[level_idx],*buf_ptr,sizeof(snd_gen_level_voc_type));
        *buf_ptr += sizeof(snd_gen_level_voc_type);
        *remaining_buf_length_ptr -= sizeof(snd_gen_level_voc_type);
      }
  }
  else if( gen_cal->generator == SND_GEN_RING)
  {
    ring_gen_cal_ptr = (snd_gen_ring_cal_type *)audio_config_ptr->gen_cal;
    if ( ring_gen_cal_ptr->level_data == NULL )
    {
      MSG_MED("acmapi_set_volume_levels_data: level_data is NULL", 0,0,0);
      return ACM_ERR_UNKNOWN;
    }
      for(level_idx=0; level_idx <= ring_gen_cal_ptr->num_levels; level_idx++)
      {
        ring_gen_cal_ptr->level_data[level_idx] = *(*buf_ptr);
        *buf_ptr += sizeof(uint16);
        *remaining_buf_length_ptr -= sizeof(uint16);
      }
  }
  return ACM_ERR_NONE;
}

/**
* FUNCTION : acmapi_get_gains_calunit_size
*
* DESCRIPTION : calculates gains calunit size
*
* DEPENDENCIES: None 
*
* RETURN VALUE: acm_error_code
* ACM_ERR_UNKNOWN
* ACM_ERR_NONE if success
* ACM_ERR_UNEXPECTED_BUF_SIZE if buffer size doesnot matches with expected structure size
*
* SIDE EFFECTS: None
*/
uint32  acmapi_get_gains_calunit_size(void)
{
  uint32 req_buf_length = 0 ;
  req_buf_length += sizeof(uint16); /* TX Voice Volume*/
  req_buf_length += sizeof(uint16); /* TX DTMF gain*/
  req_buf_length += sizeof(uint16); /* CODEC TX gain*/
  req_buf_length += sizeof(uint16); /* CODEC RX gain*/
  req_buf_length += sizeof(uint16); /* CODEC ST gain*/
  MSG_MED("acmapi: returning gains CalUnit Size as %d", req_buf_length,0,0);
  return req_buf_length;
}

/**
* FUNCTION : acmapi_get_codec_st_gain
*
* DESCRIPTION : copies CODEC ST gain from buffer to structure
*
* DEPENDENCIES: None 
*
* RETURN VALUE: acm_error_code
* ACM_ERR_UNKNOWN
* ACM_ERR_NONE if success
* ACM_ERR_UNEXPECTED_BUF_SIZE if buffer size doesnot matches with expected structure size
*
* SIDE EFFECTS: Modifies calibration table
* increments the buffer pointer by number of bytes read into buffer
*/
acm_error_code  acmapi_get_codec_st_gain
(
  uint16 *codec_st_gain_ptr,
  byte **buf_ptr
)
{
  /*copy CODEC RX gaindata*/
  memcpy(*buf_ptr, codec_st_gain_ptr, sizeof(uint16));
  *buf_ptr += sizeof(uint16);
  return ACM_ERR_NONE;
}

/**
* FUNCTION : acmapi_set_codec_st_gain
*
* DESCRIPTION : copies CODEC STgain from buffer to structure
*
* DEPENDENCIES: None 
*
* RETURN VALUE: acm_error_code
* ACM_ERR_UNKNOWN
* ACM_ERR_NONE if success
* ACM_ERR_UNEXPECTED_BUF_SIZE if buffer size doesnot matches with expected structure size
*
* SIDE EFFECTS: Modifies calibration table
* increments the buffer pointer by number of bytes read
* decrements remaining buffer length by numbr of bytes read
*/
acm_error_code  acmapi_set_codec_st_gain
(
uint16 *codec_st_gain_ptr,
byte **buf_ptr,
uint32 *remaining_buf_length_ptr
)
{
  /*Check we have enough buffer*/
  if( *remaining_buf_length_ptr < sizeof(uint16))
  {
     return ACM_ERR_UNEXPECTED_BUF_SIZE;
  }
  /*copy CODEC ST gain data*/
  memcpy(codec_st_gain_ptr, *buf_ptr,sizeof(uint16));
  *buf_ptr += sizeof(uint16);
  *remaining_buf_length_ptr -=sizeof(uint16);
  return ACM_ERR_NONE;
}
/**
* FUNCTION : acmapi_get_codec_rx_gain
*
* DESCRIPTION : copies CODEC RX gain from buffer to structure
*
* DEPENDENCIES: None 
*
* RETURN VALUE: acm_error_code
* ACM_ERR_UNKNOWN
* ACM_ERR_NONE if success
* ACM_ERR_UNEXPECTED_BUF_SIZE if buffer size doesnot matches with expected structure size
*
* SIDE EFFECTS: Modifies calibration table
* increments the buffer pointer by number of bytes read into buffer
*/
acm_error_code  acmapi_get_codec_rx_gain
(
  uint16 *codec_rx_gain_ptr,
  byte **buf_ptr
)
{
  /*copy CODEC RX gaindata*/
  memcpy(*buf_ptr, codec_rx_gain_ptr, sizeof(uint16));
  *buf_ptr += sizeof(uint16);
  return ACM_ERR_NONE;
}

/**
* FUNCTION : acmapi_set_codec_rx_gain
*
* DESCRIPTION : copies CODEC RX gain from buffer to structure
*
* DEPENDENCIES: None 
*
* RETURN VALUE: acm_error_code
* ACM_ERR_UNKNOWN
* ACM_ERR_NONE if success
* ACM_ERR_UNEXPECTED_BUF_SIZE if buffer size doesnot matches with expected structure size
*
* SIDE EFFECTS: Modifies calibration table
* increments the buffer pointer by number of bytes read
* decrements remaining buffer length by numbr of bytes read
*/
acm_error_code  acmapi_set_codec_rx_gain
(
uint16 *codec_rx_gain_ptr,
byte **buf_ptr,
uint32 *remaining_buf_length_ptr
)
{
  /*Check we have enough buffer*/
  if( *remaining_buf_length_ptr < sizeof(uint16))
  {
     return ACM_ERR_UNEXPECTED_BUF_SIZE;
  }
  /*copy CODEC RX gain data*/
  memcpy(codec_rx_gain_ptr, *buf_ptr,sizeof(uint16));
  *buf_ptr += sizeof(uint16);
  *remaining_buf_length_ptr -=sizeof(uint16);
  return ACM_ERR_NONE;
}
/**
* FUNCTION : acmapi_get_codec_tx_gain
*
* DESCRIPTION : copies CODEC TX gain from buffer to structure
*
* DEPENDENCIES: None 
*
* RETURN VALUE: acm_error_code
* ACM_ERR_UNKNOWN
* ACM_ERR_NONE if success
* ACM_ERR_UNEXPECTED_BUF_SIZE if buffer size doesnot matches with expected structure size
*
* SIDE EFFECTS: Modifies calibration table
* increments the buffer pointer by number of bytes read into buffer
*/
acm_error_code  acmapi_get_codec_tx_gain
(
  uint16 *codec_tx_gain_ptr,
  byte **buf_ptr
)
{
  /*copy CODEC TX gaindata*/
  memcpy(*buf_ptr, codec_tx_gain_ptr, sizeof(uint16));
  *buf_ptr += sizeof(uint16);
  return ACM_ERR_NONE;
}

/**
* FUNCTION : acmapi_set_codec_tx_gain
*
* DESCRIPTION : copies CODEC TX gain from buffer to structure
*
* DEPENDENCIES: None 
*
* RETURN VALUE: acm_error_code
* ACM_ERR_UNKNOWN
* ACM_ERR_NONE if success
* ACM_ERR_UNEXPECTED_BUF_SIZE if buffer size doesnot matches with expected structure size
*
* SIDE EFFECTS: Modifies calibration table
* increments the buffer pointer by number of bytes read
* decrements remaining buffer length by numbr of bytes read
*/
acm_error_code  acmapi_set_codec_tx_gain
(
uint16 *codec_tx_gain_ptr,
byte **buf_ptr,
uint32 *remaining_buf_length_ptr
)
{
  /*Check we have enough buffer*/
  if( *remaining_buf_length_ptr < sizeof(uint16))
  {
     return ACM_ERR_UNEXPECTED_BUF_SIZE;
  }
  /*copy CODEC TX gain data*/
  memcpy(codec_tx_gain_ptr, *buf_ptr,sizeof(uint16));
  *buf_ptr += sizeof(uint16);
  *remaining_buf_length_ptr -=sizeof(uint16);
  return ACM_ERR_NONE;
}
/**
* FUNCTION : acmapi_get_tx_dtmf_gain
*
* DESCRIPTION : copies TX DTMF gain from buffer to structure
*
* DEPENDENCIES: None 
*
* RETURN VALUE: acm_error_code
* ACM_ERR_UNKNOWN
* ACM_ERR_NONE if success
* ACM_ERR_UNEXPECTED_BUF_SIZE if buffer size doesnot matches with expected structure size
*
* SIDE EFFECTS: Modifies calibration table
* increments the buffer pointer by number of bytes read into buffer
*/
acm_error_code  acmapi_get_tx_dtmf_gain
(
  uint16 *tx_dtmf_gain_ptr,
  byte **buf_ptr
)
{
  /*copy TX DTMF gain data*/
  memcpy(*buf_ptr, tx_dtmf_gain_ptr, sizeof(uint16));
  *buf_ptr += sizeof(uint16);
  return ACM_ERR_NONE;
}

/**
* FUNCTION : acmapi_set_tx_dtmf_gain
*
* DESCRIPTION : copies TX DTMF gain from buffer to structure
*
* DEPENDENCIES: None 
*
* RETURN VALUE: acm_error_code
* ACM_ERR_UNKNOWN
* ACM_ERR_NONE if success
* ACM_ERR_UNEXPECTED_BUF_SIZE if buffer size doesnot matches with expected structure size
*
* SIDE EFFECTS: Modifies calibration table
* increments the buffer pointer by number of bytes read
* decrements remaining buffer length by numbr of bytes read
*/
acm_error_code  acmapi_set_tx_dtmf_gain
(
uint16 *tx_dtmf_gain_ptr,
byte **buf_ptr,
uint32 *remaining_buf_length_ptr
)
{
  /*Check we have enough buffer*/
  if( *remaining_buf_length_ptr < sizeof(uint16))
  {
     return ACM_ERR_UNEXPECTED_BUF_SIZE;
  }
  /*copy TX DTMF gain data*/
  memcpy(tx_dtmf_gain_ptr, *buf_ptr,sizeof(uint16));
  *buf_ptr += sizeof(uint16);
  *remaining_buf_length_ptr -=sizeof(uint16);
  return ACM_ERR_NONE;
}
/**
* FUNCTION : acmapi_get_tx_gain
*
* DESCRIPTION : copies TX Voice Volume from buffer to structure
*
* DEPENDENCIES: None 
*
* RETURN VALUE: acm_error_code
* ACM_ERR_UNKNOWN
* ACM_ERR_NONE if success
* ACM_ERR_UNEXPECTED_BUF_SIZE if buffer size doesnot matches with expected structure size
*
* SIDE EFFECTS: Modifies calibration table
* increments the buffer pointer by number of bytes read into buffer
*/
acm_error_code  acmapi_get_tx_gain
(
  uint16 *tx_gain_ptr,
  byte **buf_ptr
)
{
  /*copy TX Voice Volume data*/
  memcpy(*buf_ptr, tx_gain_ptr, sizeof(uint16));
  *buf_ptr += sizeof(uint16);
  return ACM_ERR_NONE;
}

/**
* FUNCTION : acmapi_set_tx_gain
*
* DESCRIPTION : copies TX Voice Volume from buffer to structure
*
* DEPENDENCIES: None 
*
* RETURN VALUE: acm_error_code
* ACM_ERR_UNKNOWN
* ACM_ERR_NONE if success
* ACM_ERR_UNEXPECTED_BUF_SIZE if buffer size doesnot matches with expected structure size
*
* SIDE EFFECTS: Modifies calibration table
* increments the buffer pointer by number of bytes read
* decrements remaining buffer length by numbr of bytes read
*/
acm_error_code  acmapi_set_tx_gain
(
uint16 *tx_gain_ptr,
byte **buf_ptr,
uint32 *remaining_buf_length_ptr
)
{
  /*Check we have enough buffer*/
  if( *remaining_buf_length_ptr < sizeof(uint16))
  {
     return ACM_ERR_UNEXPECTED_BUF_SIZE;
  }
  /*copy TX Voice Volume data*/
  memcpy(tx_gain_ptr, *buf_ptr,sizeof(uint16));
  *buf_ptr += sizeof(uint16);
  *remaining_buf_length_ptr -=sizeof(uint16);
  return ACM_ERR_NONE;
}

#endif /*FEATURE_AVS_DYNAMIC_CALIBRATION*/]]>
  </xsl:template>

  <!-- FEATURE_LIST Template-->
  <xsl:template match="FEATURE_LIST">
    <xsl:for-each select="FEATURE">
      <xsl:text>&#xa;#ifdef </xsl:text>
      <xsl:value-of select="text()"/>
<![CDATA[    feature_buf_ptr[i++] = TRUE;
#else
    feature_buf_ptr[i++] = FALSE;
#endif ]]>
    </xsl:for-each>
  </xsl:template>

  <!-- CALUNIT Template-->
  <xsl:template name="process_cal_guid">
    <xsl:for-each select="//CALUNIT">
      <xsl:text>&#xa;&#x20;&#x20;/* </xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>*/&#xa;&#x20;&#x20;</xsl:text>
      <xsl:call-template name="guid_to_string">
        <xsl:with-param name="guid" select="@GUID"/>
      </xsl:call-template>
      <xsl:if test="position()!=last()">
        <xsl:text>,</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- GUID to String conversion template-->
  <xsl:template name="guid_to_string">
    <xsl:param name="guid"/>
    <xsl:text>{0x</xsl:text>
    <xsl:value-of select="substring-before($guid,'-')"/>
    <xsl:variable name="guid2">
      <xsl:value-of select="substring-after($guid,'-')"/>
    </xsl:variable>
    <xsl:text>,0x</xsl:text>
    <xsl:value-of select="substring-before($guid2,'-')"/>
    <xsl:variable name="guid3">
      <xsl:value-of select="substring-after($guid2,'-')"/>
    </xsl:variable>
    <xsl:text>,0x</xsl:text>
    <xsl:value-of select="substring-before($guid3,'-')"/>
    <xsl:variable name="guid4">
      <xsl:value-of select="translate(substring-after($guid3,'-'),'-','')"/>
    </xsl:variable>
    <xsl:text>,{0x</xsl:text>
    <xsl:value-of select="substring($guid4,1,2)"/>
    <xsl:text>,0x</xsl:text>
    <xsl:value-of select="substring($guid4,3,2)"/>
    <xsl:text>,0x</xsl:text>
    <xsl:value-of select="substring($guid4,5,2)"/>
    <xsl:text>,0x</xsl:text>
    <xsl:value-of select="substring($guid4,7,2)"/>
    <xsl:text>,0x</xsl:text>
    <xsl:value-of select="substring($guid4,9,2)"/>
    <xsl:text>,0x</xsl:text>
    <xsl:value-of select="substring($guid4,11,2)"/>
    <xsl:text>,0x</xsl:text>
    <xsl:value-of select="substring($guid4,13,2)"/>
    <xsl:text>,0x</xsl:text>
    <xsl:value-of select="substring($guid4,15,2)"/>
    <xsl:text>}</xsl:text>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <!-- Process CALUNITS Template -->
  <xsl:template match="CALUNITS">
    <!--Process calunits -->
    <xsl:call-template name="process_calunits"/>
  </xsl:template>

  <xsl:template name="process_calunits">
    <xsl:for-each select="*[not(@name='Sound Calibration')]
                           [not(@name='Gains')]">
      <xsl:call-template name="FEATURISATION"/>
      <xsl:if test="name(current()) = 'CALUNIT'">
        <xsl:for-each select="*">
          <xsl:call-template name="FEATURISATION"/>
          <xsl:if test="name(current()) = 'ELEMENT'">
            <xsl:call-template name="process_cal_element"/>
          </xsl:if>
        </xsl:for-each>
        <xsl:variable name="fn_name" select="
          translate(translate(@name, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
          'abcdefghijklmnopqrstuvwxyz'),' ', '_')"/>

        <!-- get calunit size function -->
        <xsl:text>&#xa;/**&#xa;* FUNCTION : acmapi_get_</xsl:text>
        <xsl:copy-of select="$fn_name"/>
        <xsl:text>_size 
*
* DESCRIPTION : calculate </xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text> calunit size. 
*
* DEPENDENCIES: None
*
* RETURN VALUE: uint32 size - size of the calunit
*
* SIDE EFFECTS: None
*/
uint32 acmapi_get_</xsl:text>
        <xsl:copy-of select="$fn_name"/>
        <xsl:text>_calunit_size(void)&#xa;{ &#xa;</xsl:text>
        <xsl:text>&#xa;&#x20;&#x20;uint32 req_buf_length = 0 ;</xsl:text>
        <xsl:for-each select=".//ELEMENT">
          <xsl:if test="name(parent::node())= 'FEATURE_IF'">
            <xsl:text>&#xa;#ifdef </xsl:text>
            <xsl:value-of select="parent::node()/@name"/>
          </xsl:if>
          <xsl:text>&#xa;&#x20;&#x20;req_buf_length += acmapi_get_</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>_size();</xsl:text>
          <xsl:if test="name(parent::node())= 'FEATURE_IF'">
            <xsl:text>&#xa;#endif /* </xsl:text>
            <xsl:value-of select="parent::node()/@name"/>
            <xsl:text> */</xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:text>&#xa;&#x20;&#x20;return req_buf_length;</xsl:text>
        <xsl:text>&#xa;} &#xa;</xsl:text>
      </xsl:if>
      <xsl:if test="name(current()) = 'ELEMENT'">
        <xsl:call-template name="process_cal_element"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="process_cal_element">
    <xsl:variable name="datatype">
      <xsl:value-of select="@datatype"/>
    </xsl:variable>
    <xsl:variable name="struct_ptr">
      <xsl:value-of select="concat(substring-after(
                                  substring-before(
                                  @datatype,'_type'),'qdsp_cmd_'),
                                  '_ptr')"/>
    </xsl:variable>

    <!-- get size function -->
    <xsl:call-template name="get_size_fn_header"/>
    <xsl:apply-templates select="//STRUCTTYPE[@name=$datatype]" mode="calc_size"/>
    <xsl:text>&#xa;} &#xa;</xsl:text>


    <!-- get function -->
    <xsl:call-template name="get_fn_header"/>
    <xsl:text>&#xa;acm_error_code  acmapi_get_</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>&#xa;( &#xa;&#x20;&#x20;</xsl:text>
    <xsl:value-of select="@datatype"/>
    <xsl:text> *</xsl:text>
    <xsl:value-of select="$struct_ptr"/>
    <xsl:text>, &#xa;&#x20;&#x20;byte **buf_ptr&#xa;)</xsl:text>
    <xsl:text>&#xa;{ &#xa;</xsl:text>
    <xsl:apply-templates select="//STRUCTTYPE[@name=$datatype]" mode="get_func"/>
    <xsl:text>&#xa;} &#xa;</xsl:text>

    <!-- set function -->
    <xsl:call-template name="set_fn_header"/>
    <xsl:text>&#xa;acm_error_code  acmapi_set_</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>&#xa;( &#xa;&#x20;&#x20;</xsl:text>
    <xsl:value-of select="@datatype"/>
    <xsl:text> *</xsl:text>
    <xsl:value-of select="$struct_ptr"/>
    <xsl:text>, &#xa;&#x20;&#x20;byte **buf_ptr,&#xa;&#x20;&#x20;uint32 *remaining_buf_length_ptr&#xa;)</xsl:text>
    <xsl:text>&#xa;{ &#xa;</xsl:text>
    <xsl:apply-templates select="//STRUCTTYPE[@name=$datatype]" mode="set_func"/>
    <xsl:text>&#xa;} &#xa;</xsl:text>
  </xsl:template>

  <!-- get function generation template -->
  <xsl:template match="//STRUCTTYPE" mode="get_func">
    <xsl:for-each select="STRUCT_ELEMENT[@vartype='PTR']">
      <xsl:text>&#xa;&#x20;&#x20;uint32 </xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>_size = 0;</xsl:text>
    </xsl:for-each>
    <xsl:variable name="struct_ptr">
      <xsl:value-of select="concat(substring-after(substring-before(@name,'_type'),'qdsp_cmd_'),'_ptr')"/>
    </xsl:variable>
    <xsl:variable name="struct_type">
      <xsl:value-of select="@name"/>
    </xsl:variable>

    <xsl:if test="count(STRUCT_ELEMENT[@vartype='PTR']) = 0">
      <xsl:text>&#x20;&#x20;memcpy(*buf_ptr, (void *)</xsl:text>
      <xsl:value-of select="$struct_ptr"/>
      <xsl:text>, sizeof(</xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>));</xsl:text>
      <xsl:text>&#xa;&#x20;&#x20;*buf_ptr += sizeof(</xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>);</xsl:text>
    </xsl:if>

    <xsl:if test="count(STRUCT_ELEMENT[@vartype='PTR']) > 0">
      <xsl:for-each select="STRUCT_ELEMENT">
        <!-- either its a element array or a pointer to struct -->
        <xsl:if test="@vartype = 'PTR'">
          <xsl:variable name="var_name">
            <xsl:value-of select="@name"/>
          </xsl:variable>
          <xsl:text>&#xa;&#x20;&#x20;</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>_size = sizeof(</xsl:text>
          <xsl:value-of select="@datatype"/>
          <xsl:text>) * </xsl:text>
          <xsl:variable name="arr_name">
            <xsl:value-of select="//DATAUNIT[@datatype=$struct_type]//DATAELEMENTPTR[@name=$var_name]/@value"/>
          </xsl:variable>
          <xsl:variable name ="data_ele" select="//DATAELEMENTARRAY[@name=$arr_name]"/>
          <!-- one element is enough to get the size of array -->
          <xsl:value-of select="count($data_ele[1]//DATAELEMENT)"/>
          <xsl:text>; </xsl:text>
          <xsl:text>&#xa;&#x20;&#x20;memcpy(*buf_ptr, (void *)</xsl:text>
          <xsl:value-of select="$struct_ptr"/>
          <xsl:text>-&gt;</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>, </xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>_size);</xsl:text>
          <xsl:text>&#xa;&#x20;&#x20;*buf_ptr += </xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>_size;</xsl:text>
        </xsl:if>
        <xsl:if test="count(@vartype)=0">
          <xsl:text>&#xa;&#x20;&#x20;memcpy(*buf_ptr, (void *)&amp;</xsl:text>
          <xsl:value-of select="$struct_ptr"/>
          <xsl:text>-&gt;</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>, sizeof(</xsl:text>
          <xsl:value-of select="@datatype"/>
          <xsl:text>));</xsl:text>
          <xsl:text>&#xa;&#x20;&#x20;*buf_ptr += sizeof(</xsl:text>
          <xsl:value-of  select="@datatype"/>
          <xsl:text>)</xsl:text>
          <xsl:if test="@datatype='boolean'">
            <!-- add padding bytes -->
            <xsl:text> + sizeof(boolean)</xsl:text>
          </xsl:if>
          <xsl:text>;</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>
    <xsl:text>&#xa;&#x20;&#x20;return ACM_ERR_NONE;</xsl:text>
  </xsl:template>

  <!--print get size funtion header -->
  <xsl:template name="get_size_fn_header">
    <xsl:text>&#xa;/**&#xa;* FUNCTION : acmapi_get_</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>_size
*
* DESCRIPTION : calculate </xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text> size.
*
* DEPENDENCIES: None
*
* RETURN VALUE: uint32 size - size of the filter
*
* SIDE EFFECTS: None
*/
uint32 acmapi_get_</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>_size(void)&#xa;{ &#xa;</xsl:text>
  </xsl:template>

  <!--print get function header -->
  <xsl:template name="get_fn_header">
    <xsl:text>&#xa;/**&#xa;* FUNCTION : acmapi_get_</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text> 
*
* DESCRIPTION : copies </xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text> data from filter structure to buffer 
*
* DEPENDENCIES: None
*
* RETURN VALUE: acm_error_code
* ACM_ERR_UNKNOWN
* ACM_ERR_NONE if success
* ACM_ERR_UNEXPECTED_BUF_SIZE if buffer size doesnot matches with expected structure size
*
* SIDE EFFECTS: Modifies calibration table
* increments the buffer pointer by number of bytes read from buffer
* decrements the remaining buffer length by number of bytes read from buffer
*/</xsl:text>
  </xsl:template>

  <!--print set function header -->
  <xsl:template name="set_fn_header">
    <xsl:text>&#xa;/**&#xa;* FUNCTION : acmapi_set_</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text> 
*
* DESCRIPTION : copies </xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text> data from buffer to filter structure 
*
* DEPENDENCIES: None
*
* RETURN VALUE: acm_error_code
* ACM_ERR_UNKNOWN
* ACM_ERR_NONE if success
* ACM_ERR_UNEXPECTED_BUF_SIZE if buffer size doesnot matches with expected structure size
*
* SIDE EFFECTS: Modifies calibration table
* increments the buffer pointer by number of bytes wrote to buffer
*/</xsl:text>
  </xsl:template>

  <!-- set function generation template -->
  <xsl:template match="//STRUCTTYPE" mode="set_func">
    <xsl:for-each select="STRUCT_ELEMENT[@vartype='PTR']">
      <xsl:text>&#xa;&#x20;&#x20;uint32 </xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>_size = 0;</xsl:text>
    </xsl:for-each>
    <xsl:text>&#xa;&#x20;&#x20;if( *remaining_buf_length_ptr &lt; sizeof(</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>))
  {
    return ACM_ERR_UNEXPECTED_BUF_SIZE;
  }
</xsl:text>
    <xsl:variable name="struct_ptr">
      <xsl:value-of select="concat(substring-after(substring-before(@name,'_type'),'qdsp_cmd_'),'_ptr')"/>
    </xsl:variable>
    <xsl:variable name="struct_type">
      <xsl:value-of select="@name"/>
    </xsl:variable>

    <xsl:if test="count(STRUCT_ELEMENT[@vartype='PTR']) = 0">
      <xsl:text>&#x20;&#x20;memcpy(</xsl:text>
      <xsl:value-of select="$struct_ptr"/>
      <xsl:text>, *buf_ptr, sizeof(</xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>));</xsl:text>
      <xsl:text>&#xa;&#x20;&#x20;*buf_ptr += sizeof(</xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>);</xsl:text>
      <xsl:text>&#xa;&#x20;&#x20;*remaining_buf_length_ptr -= sizeof(</xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>);</xsl:text>
    </xsl:if>

    <xsl:if test="count(STRUCT_ELEMENT[@vartype='PTR']) > 0">
      <!--Do an element by element copy-->
      <xsl:for-each select="STRUCT_ELEMENT">
        <!-- either its a element array or a pointer to struct -->
        <xsl:if test="@vartype = 'PTR'">
          <xsl:variable name="var_name">
            <xsl:value-of select="@name"/>
          </xsl:variable>
          <xsl:text>&#xa;&#x20;&#x20;</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>_size = sizeof(</xsl:text>
          <xsl:value-of select="@datatype"/>
          <xsl:text>) * </xsl:text>
          <xsl:variable name="arr_name">
            <xsl:value-of select="//DATAUNIT[@datatype=$struct_type]//DATAELEMENTPTR[@name=$var_name]/@value"/>
          </xsl:variable>
          <xsl:variable name ="data_ele" select="//DATAELEMENTARRAY[@name=$arr_name]"/>
          <!-- one element is enough to get the size of array -->
          <xsl:value-of select="count($data_ele[1]//DATAELEMENT)"/>
          <xsl:text>; </xsl:text>
          <xsl:text>&#xa;&#x20;&#x20;memcpy((void *)</xsl:text>
          <xsl:value-of select="$struct_ptr"/>
          <xsl:text>-&gt;</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>, *buf_ptr, </xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>_size);</xsl:text>
          <xsl:text>&#xa;&#x20;&#x20;*buf_ptr += </xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>_size;</xsl:text>
          <xsl:text>&#xa;&#x20;&#x20;*remaining_buf_length_ptr -= </xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>_size;</xsl:text>
        </xsl:if>
        <xsl:if test="count(@vartype)=0">
          <xsl:text>&#xa;&#x20;&#x20;memcpy((void *)&amp;</xsl:text>
          <xsl:value-of select="$struct_ptr"/>
          <xsl:text>-&gt;</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>, *buf_ptr, sizeof(</xsl:text>
          <xsl:value-of select="@datatype"/>
          <xsl:text>));</xsl:text>
          <xsl:text>&#xa;&#x20;&#x20;*buf_ptr += sizeof(</xsl:text>
          <xsl:value-of select="@datatype"/>
          <xsl:text>)</xsl:text>
          <xsl:if test="@datatype='boolean'">
            <!-- add padding bytes -->
            <xsl:text> + sizeof(boolean)</xsl:text>
          </xsl:if>
          <xsl:text>;</xsl:text>
          <xsl:text>&#xa;&#x20;&#x20;*remaining_buf_length_ptr -= sizeof(</xsl:text>
          <xsl:value-of select="@datatype"/>
          <xsl:text>)</xsl:text>
          <xsl:if test="@datatype='boolean'">
            <!-- add padding bytes -->
            <xsl:text> + sizeof(boolean)</xsl:text>
          </xsl:if>
          <xsl:text>;</xsl:text>
        </xsl:if>
      </xsl:for-each>

    </xsl:if>
    <xsl:text>&#xa;&#x20;&#x20;return ACM_ERR_NONE;</xsl:text>
  </xsl:template>

  <!-- calc size function generation template -->
  <xsl:template match="//STRUCTTYPE" mode="calc_size">
    <xsl:text>&#xa;&#x20;&#x20;uint32 req_buf_length = 0 ;</xsl:text>
    <xsl:variable name="struct_ptr">
      <xsl:value-of select="concat(substring-after(substring-before(@name,'_type'),'qdsp_cmd_'),'_ptr')"/>
    </xsl:variable>
    <xsl:variable name="struct_type">
      <xsl:value-of select="@name"/>
    </xsl:variable>

    <xsl:if test="count(STRUCT_ELEMENT[@vartype='PTR']) = 0">
      <xsl:text>&#xa;&#x20;&#x20;req_buf_length += sizeof(</xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>);</xsl:text>
    </xsl:if>

    <xsl:if test="count(STRUCT_ELEMENT[@vartype='PTR']) > 0">
      <!--Do an element by element copy-->
      <xsl:for-each select="STRUCT_ELEMENT">
        <!-- either its a element array or a pointer to struct -->
        <xsl:if test="@vartype = 'PTR'">
          <xsl:variable name="var_name">
            <xsl:value-of select="@name"/>
          </xsl:variable>
          <xsl:variable name="arr_name">
            <xsl:value-of select="//DATAUNIT[@datatype=$struct_type]//DATAELEMENTPTR[@name=$var_name]/@value"/>
          </xsl:variable>
          <xsl:variable name ="data_ele" select="//DATAELEMENTARRAY[@name=$arr_name]"/>
          <xsl:text>&#xa;&#x20;&#x20;req_buf_length += sizeof(</xsl:text>
          <xsl:value-of select="@datatype"/>
          <xsl:text>) * </xsl:text>
          <!-- one element is enough to get the size of array -->
          <xsl:value-of select="count($data_ele[1]//DATAELEMENT)"/>
          <xsl:text>; </xsl:text>
        </xsl:if>
        <xsl:if test="count(@vartype)=0">
          <xsl:text>&#xa;&#x20;&#x20;req_buf_length += sizeof(</xsl:text>
          <xsl:value-of select="@datatype"/>
          <xsl:text>);</xsl:text>
          <!-- add padding bytes -->
          <xsl:if test="@datatype='boolean'">
            <!-- add padding bytes -->
            <xsl:text>&#xa;&#x20;&#x20;req_buf_length += sizeof(boolean);  /* add padding byte */</xsl:text>
          </xsl:if>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>
    <xsl:text>&#xa;&#x20;&#x20;return req_buf_length;</xsl:text>
  </xsl:template>

  <!-- Process FEATURISATION template -->
  <xsl:template name="FEATURISATION">
    <xsl:if test="name(current()) = 'FEATURISATION'">
      <xsl:apply-templates select="FEATURE_IF"/>
      <xsl:apply-templates select="FEATURE_IF_BINARY"/>
      <xsl:apply-templates select="FEATURE_ELIF"/>
      <xsl:apply-templates select="FEATURE_ELIF_BINARY"/>
      <xsl:apply-templates select="FEATURE_ELSE"/>
      <xsl:text>#endif/* </xsl:text>
      <xsl:value-of select="child::*/attribute::name"/>
      <xsl:variable name="OPR">
        <xsl:value-of select="child::FEATURE_IF_BINARY/BINARY_OPERATION/@opr"/>
      </xsl:variable>
      <xsl:for-each select="child::FEATURE_IF_BINARY/BINARY_OPERATION/OPERAND">
        <xsl:text>(</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>)</xsl:text>
        <xsl:if test="position() != last()">
          <xsl:if test="string($OPR)=string('OR')">
            <xsl:text disable-output-escaping="yes"> || </xsl:text>
          </xsl:if>
          <xsl:if test="string($OPR)=string('AND')">
            <xsl:text disable-output-escaping="yes"> &amp;&amp; </xsl:text>
          </xsl:if>
        </xsl:if>
      </xsl:for-each>
      <xsl:text> */&#xa;</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- FEATURE_IF Template -->
  <xsl:template match="FEATURE_IF">
    <xsl:text>&#xa;#ifdef </xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:call-template name="process_calunits"/>
  </xsl:template>

  <!-- FEATURE_ELIF Template -->
  <xsl:template match="FEATURE_ELIF">
    <xsl:text>&#xa;#elif </xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:call-template name="process_calunits"/>
  </xsl:template>

  <!-- FEATURE_IF_BINARY Template -->
  <xsl:template match="FEATURE_IF_BINARY">
    <xsl:text>&#xa;#if </xsl:text>
    <xsl:call-template name="BINARY_OPERATION"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:call-template name="process_calunits"/>
  </xsl:template>

  <!-- FEATURE_ELIF_BINARY Template -->
  <xsl:template match="FEATURE_ELIF_BINARY">
    <xsl:text>&#xa;#elif </xsl:text>
    <xsl:call-template name="BINARY_OPERATION"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:call-template name="process_calunits"/>
  </xsl:template>

  <!-- BINARY_OPERATION Template -->
  <xsl:template name="BINARY_OPERATION">
    <xsl:for-each select="*">
      <xsl:if test="name(current()) = 'BINARY_OPERATION'">
        <xsl:variable name="OPR">
          <xsl:value-of select="@opr"/>
        </xsl:variable>
        <!-- Go for operands now -->
        <xsl:for-each select="OPERAND">
          <xsl:text>defined(</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>)</xsl:text>
          <xsl:if test="position() != last()">
            <xsl:if test="string($OPR)=string('OR')">
              <xsl:text disable-output-escaping="yes"> || </xsl:text>
            </xsl:if>
            <xsl:if test="string($OPR)=string('AND')">
              <xsl:text disable-output-escaping="yes"> &amp;&amp; </xsl:text>
            </xsl:if>
          </xsl:if>
        </xsl:for-each>
        <!-- place the operator before any embedded binary opr -->
        <xsl:if test="count(current()/child::BINARY_OPERATION) > 0">
          <xsl:if test="string(@opr)=string('OR')">
            <xsl:text disable-output-escaping="yes"> || </xsl:text>
          </xsl:if>
          <xsl:if test="string(@opr)=string('AND')">
            <xsl:text disable-output-escaping="yes"> &amp;&amp; </xsl:text>
          </xsl:if>
        </xsl:if>
        <!-- Recursive Call -->
        <xsl:call-template name="BINARY_OPERATION"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- FEATURE_ELSE Template -->
  <xsl:template match="FEATURE_ELSE">
    <xsl:text>#else </xsl:text>
    <xsl:text>&#xa;</xsl:text>
    <xsl:call-template name="process_calunits"/>
  </xsl:template>

</xsl:stylesheet> 