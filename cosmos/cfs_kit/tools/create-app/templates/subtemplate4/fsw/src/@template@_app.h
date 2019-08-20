/*******************************************************************************
** File: @template@_app.h
**
** Purpose:
**   This file is main hdr file for the @TEMPLATE@ application.
**
**
*******************************************************************************/

#ifndef _@template@_app_h_
#define _@template@_app_h_

/*
**   Include Files:
*/

#include "cfe.h"

/*
**
*/
#define @TEMPLATE@_WAKEUP_TIMEOUT    1000 //milliseconds

/*
** Version numbers
*/
#define @TEMPLATE@_MAJOR_VERSION     1
#define @TEMPLATE@_MINOR_VERSION     0
#define @TEMPLATE@_REVISION          0

/*
** Event message ID's.
*/
#define @TEMPLATE@_INIT_INF_EID      1    /* start up message "informational" */

#define @TEMPLATE@_NOOP_INF_EID      2    /* processed command "informational" */
#define @TEMPLATE@_RESET_INF_EID     3
#define @TEMPLATE@_PROCESS_INF_EID   4
  
#define @TEMPLATE@_MID_ERR_EID       5    /* invalid command packet "error" */
#define @TEMPLATE@_CC1_ERR_EID       6
#define @TEMPLATE@_LEN_ERR_EID       7
#define @TEMPLATE@_PIPE_ERR_EID      8
#define @TEMPLATE@_PER_INFO_EID      9

#define @TEMPLATE@_EVT_COUNT         9    /* count of event message ID's */

/*
** Command packet command codes
*/
#define @TEMPLATE@_NOOP_CC           0    /* no-op command */
#define @TEMPLATE@_RESET_CC          1    /* reset counters */
#define @TEMPLATE@_PROCESS_CC        2    /* Perform Routine Processing */

/*
** Software Bus defines
*/
#define @TEMPLATE@_PIPE_DEPTH        12   /* Depth of the Command Pipe for Application */
#define @TEMPLATE@_LIMIT_HK          2    /* Limit of HouseKeeping Requests on Pipe for Application */
#define @TEMPLATE@_LIMIT_CMD         4    /* Limit of Commands on pipe for Application */

/*
** Type definition
*/
typedef struct
{
  uint32  DataPtOne;
  uint32  DataPtTwo;
  uint32  DataPtThree;
  uint32  DataPtFour;
  uint32  DataPtFive;

} @TEMPLATE@_ExampleDataType_t;


/*************************************************************************/

/*
** Type definition (generic "no arguments" command)
*/
typedef struct
{
  uint8                 CmdHeader[CFE_SB_CMD_HDR_SIZE];

} @TEMPLATE@_NoArgsCmd_t;

/*************************************************************************/

/*
** Type definition (@TEMPLATE@ housekeeping)
*/
typedef struct
{
  uint8                 TlmHeader[CFE_SB_TLM_HDR_SIZE];

  /*
  ** Command interface counters
  */
  uint8                 CmdCounter;
  uint8                 ErrCounter;

} OS_PACK @TEMPLATE@_HkPacket_t;

/*************************************************************************/

/*
** Type definition (@TEMPLATE@ asynchronous telemetry)
*/
typedef struct
{
  uint8                 TlmHeader[CFE_SB_TLM_HDR_SIZE];

  /*
  ** Command interface counters
  */
  uint8                 CmdCounter;
  uint8                 ErrCounter;

} OS_PACK @TEMPLATE@_TlmPacket_t;

/*************************************************************************/

/*
** Type definition (@TEMPLATE@ app global data)
*/
typedef struct
{
  /*
  ** Command interface counters.
  */
  uint8                 CmdCounter;
  uint8                 ErrCounter;

  /*
  ** Housekeeping telemetry packet
  */
  @TEMPLATE@_HkPacket_t         HkPacket;

  /*
  ** Asynchronous telemetry packet
  */
  @TEMPLATE@_TlmPacket_t        TlmPacket;

  /*
  ** Operational data (not reported in housekeeping).
  */
  CFE_SB_MsgPtr_t       MsgPtr;
  CFE_SB_PipeId_t       CmdPipe;
  CFE_SB_PipeId_t       SchPipe;
  
  /*
  ** RunStatus variable used in the main processing loop
  */
  uint32                RunStatus;

  /*
  ** Example Data store variables
  */
  @TEMPLATE@_ExampleDataType_t      WorkingCriticalData; /* Define specific data that can be used during Application execution */

  /*
  ** Initialization data (not reported in housekeeping)
  */
  char                  PipeName[16];
  char                  PipeName2[16];
  uint16                PipeDepth;

  uint8                 LimitHK;
  uint8                 LimitCmd;

  CFE_EVS_BinFilter_t   EventFilters[@TEMPLATE@_EVT_COUNT];

} @TEMPLATE@_AppData_t;

/*************************************************************************/

/*
** Local function prototypes
**
** Note: Except for the entry point (@TEMPLATE@_AppMain), these
**       functions are not called from any other source module.
*/
void    @TEMPLATE@_AppMain(void);
int32   @TEMPLATE@_AppInit(void);
void    @TEMPLATE@_AppPipe(CFE_SB_MsgPtr_t msg);

void    @TEMPLATE@_HousekeepingCmd(CFE_SB_MsgPtr_t msg);

void    @TEMPLATE@_NoopCmd(CFE_SB_MsgPtr_t msg);
void    @TEMPLATE@_ResetCmd(CFE_SB_MsgPtr_t msg);
void    @TEMPLATE@_RoutineProcessingCmd(CFE_SB_MsgPtr_t msg);
void    @TEMPLATE@_PeriodicProcessing(CFE_SB_MsgPtr_t msg);
int32   @TEMPLATE@_RcvMsg(void);
void    @TEMPLATE@_CmdPipe(void);

boolean @TEMPLATE@_VerifyCmdLength(CFE_SB_MsgPtr_t msg, uint16 ExpectedLength);


#endif /* _@template@_app_h_ */

/************************/
/*  End of File Comment */
/************************/



