/******************************************************************************
	Code
******************************************************************************/

#ifndef OS_H_ONLY_ONE_INCLUDE_SAFETY
#define OS_H_ONLY_ONE_INCLUDE_SAFETY

#ifdef __cplusplus
extern "C"
{
#endif

/*******************************************************************************
	Include files
*******************************************************************************/

#include <stdint.h>

/******************************************************************************
	Function declarations
******************************************************************************/

void os_init( void );
void os_run( void );
int os_createTask( void *taskFun );
int os_sleep_ms( uint32_t ms );
uint32_t os_getTime_ms( void );

#ifdef __cplusplus
}
#endif

#endif /* OS_H_ONLY_ONE_INCLUDE_SAFETY */
