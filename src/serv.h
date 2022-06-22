/******************************************************************************
	Code
******************************************************************************/

#ifndef SERV_H_ONLY_ONE_INCLUDE_SAFETY
#define SERV_H_ONLY_ONE_INCLUDE_SAFETY

#ifdef __cplusplus
extern "C"
{
#endif

/*******************************************************************************
	Include files
*******************************************************************************/

#include <stdint.h>

/*******************************************************************************
	Definition files
*******************************************************************************/

#define SERV_SERVICES_MAX 10U

typedef void *( *serv_fun_t )( void *arg );

typedef struct
{
	serv_fun_t servfun;
	void *arg;
	uint32_t period_ms;
	uint32_t next_ms; // Next time to run
} serv_t;

/******************************************************************************
Function declarations
******************************************************************************/

int serv_init( serv_t *const services );
int serv_register( serv_t *const services, const serv_t service );
void serv_show( serv_t *const services );
int serv_handle( serv_t *const services );

#ifdef __cplusplus
}
#endif

#endif /* SERV_H_ONLY_ONE_INCLUDE_SAFETY */
