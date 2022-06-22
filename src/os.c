/*******************************************************************************
	Code
*******************************************************************************/

/*******************************************************************************
	Include files
*******************************************************************************/

#include "os.h"

#include <pthread.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>

/*******************************************************************************
	Local variables
*******************************************************************************/

volatile static uint32_t msTicks = 0;

/*******************************************************************************
	Local function declarations
*******************************************************************************/

static void *sysTick( void *threadid );

/*******************************************************************************
	Function definitions
*******************************************************************************/

void os_init( void )
{
	/* Reset the clock */
	msTicks = 0U;

	/* Create new thread */
	pthread_t thread;
	long t;
	int rc = pthread_create( &thread, NULL, sysTick, ( void * )t );

	if( rc )
	{
		/* Fail */
		return -1;
	}

	/* Success */
	return 0;
}

void os_run( void )
{
	/* Loop forever */
	while( 1 )
	{
	}
}

int os_createTask( void *taskFun )
{
	/* Create new thread */
	pthread_t thread;
	long t;
	int err = pthread_create( &thread, NULL, taskFun, ( void * )t );
}

int os_sleep_ms( uint32_t  ms )
{
	usleep( 1000 * ms );
}
uint32_t os_getTime_ms( void )
{
	return msTicks;
}

static void *sysTick( void *threadid )
{
	while( 1 )
	{
		msTicks++;
		usleep( 1000U );
	}

	pthread_exit( NULL );
}
