/*******************************************************************************
	Code
*******************************************************************************/

/*******************************************************************************
	Include files
*******************************************************************************/

#include "serv.h"

#include <stdio.h> // printf
#include <string.h>
#include <stdint.h>
#include <stddef.h>

/*******************************************************************************
	Local variables
*******************************************************************************/

/*******************************************************************************
	Local function declarations
*******************************************************************************/

/*******************************************************************************
	Function definitions
*******************************************************************************/

int serv_init( serv_t *const services )
{
	int err = 0;

	if( services == NULL )
	{
		err = 1;
	}

	if( !err )
	{
		memset( services, 0, SERV_SERVICES_MAX );
	}

	return err;
}

int serv_register( serv_t *const services, const serv_t service )
{
	int err = 0;

	if( services == NULL )
	{
		err = 1;
	}

	if( !err )
	{
		for( uint32_t i = SERV_SERVICES_MAX; i > 0; --i )
		{
			uint32_t id = SERV_SERVICES_MAX - i;
			serv_t *s = &services[id];

			if( s == NULL )
			{
				/* Will never reach here */
				err = 1;
			}

			if( !err )
			{
				if( s->servfun == NULL )
				{
					printf( "service register: %d\n", id );
					s->servfun = service.servfun;
					s->arg = service.arg;
					s->next_ms = service.next_ms;
					s->period_ms = service.period_ms;
					break;
				}
			}
		}
	}

	return err;
}

void serv_show( serv_t *const services )
{
	int err = 0;

	if( services == NULL )
	{
		err = 1;
	}

	if( !err )
	{
		for( uint32_t i = SERV_SERVICES_MAX; i > 0; --i )
		{
			uint32_t id = SERV_SERVICES_MAX - i;
			serv_t *s = &services[id];

			if( s != NULL )
			{
				/* Will never reach here */
				printf( "------------------------------------\n" );
				printf( "s[%X].servfun:   %p\n", id, s->servfun );
				printf( "s[%X].arg:       %p\n", id, s->arg );
				printf( "s[%d].next_ms:   %d\n", id, s->next_ms );
				printf( "s[%d].period_ms: %d\n", id, s->period_ms );
			}
		}
	}
}

int serv_handle( serv_t *const services )
{
	int err = 0;

	if( services == NULL )
	{
		err = 1;
	}

	if( !err )
	{
		uint32_t now_ms = os_getTime_ms();

		for( uint32_t i = SERV_SERVICES_MAX; i > 0; --i )
		{
			const uint32_t id = SERV_SERVICES_MAX - i;
			serv_t *s = &services[id];

			if( s == NULL )
			{
				/* Will never reach here */
				err = 1;
			}

			if( !err )
			{
				if( s->next_ms <= now_ms )
				{
					/*  */
					if( s->servfun != NULL )
					{
						s->next_ms = now_ms + s->period_ms;
						s->servfun( s->arg );
					}
				}
			}
		}
	}

	return err;
}
