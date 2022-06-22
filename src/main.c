/******************************************************************************
	Includes
******************************************************************************/

#include "os.h"
#include "serv.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/******************************************************************************
	Code
******************************************************************************/

serv_t g_services[SERV_SERVICES_MAX];

void serviceFunC( void *arg )
{
	printf( "[%d]: I am a %s service!\n", os_getTime_ms(), ( char * )arg );
}

/******************************************************************************/


int task1( void *args )
{
	while( 1 )
	{
		printf( "Period1: %d\n", os_getTime_ms() );
		os_sleep_ms( 3000 );
	}
}

int task2( void *args )
{
	int err = serv_init( g_services );

	if( !err )
	{
		serv_t service;
		service.servfun = serviceFunC;
		service.arg = "slow";
		service.period_ms = 1000;
		service.next_ms = 0;
		err = serv_register( g_services, service );
	}

	if( !err )
	{
		serv_t service;
		service.servfun = serviceFunC;
		service.arg = "quick";
		service.period_ms = 250;
		service.next_ms = 5000;
		err = serv_register( g_services, service );
	}

	//serv_show( g_services );

	while( 1 )
	{
		if( !err )
		{
			err = serv_handle( g_services );
			os_sleep_ms( 1 );
		}


		if( err )
		{
			exit( 1 );
		}
	}
}

int main( int argc, char *argv[] )
{
	/* Initialize the board */
	os_init();

	os_createTask( task1 );
	os_createTask( task2 );

	os_run();

	/* Will never reach here. Will never return... */
	return 0;
}
