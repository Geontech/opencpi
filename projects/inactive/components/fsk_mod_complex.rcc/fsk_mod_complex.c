/*
 * This file is protected by Copyright. Please refer to the COPYRIGHT file
 * distributed with this source distribution.
 *
 * This file is part of OpenCPI <http://www.opencpi.org>
 *
 * OpenCPI is free software: you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) any
 * later version.
 *
 * OpenCPI is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
 * A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * THIS FILE WAS ORIGINALLY GENERATED ON Mon Aug  6 05:50:19 2012 PDT
 * BASED ON THE FILE: fsk_mod_complex.xml
 * YOU ARE EXPECTED TO EDIT IT
 *
 * This file contains the RCC implementation skeleton for worker: fsk_mod_complex
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "signal_utils.h"
#include "fsk_mod_complex_Worker.h"

typedef struct {
  double accum;
} State;
static size_t sizes[] = {sizeof(State), 0 };

FSK_MOD_COMPLEX_METHOD_DECLARATIONS;
RCCDispatch fsk_mod_complex = {
  /* insert any custom initializations here */
  .memSizes = sizes,
  FSK_MOD_COMPLEX_DISPATCH
};

/*
 * Methods to implement for worker fsk_mod_complex, based on metadata.
 */

static void
doFsk( State *myState,  Fsk_mod_complexInData *inData,  Fsk_mod_complexOutIq  *outData, unsigned dlen )
{

  unsigned len = byteLen2Real(dlen);
  unsigned int i;
  unsigned rval, ival;
  for ( i=0; i<len; i++ ) {
    myState->accum += Uscale( inData->real[i] );
    {
      const double
	pi_2 = 0x3fff,
	one  = 0x3fff;
      int16_t rdiv = 0, idiv = 0, angle;
      if (myState->accum > pi_2) {
	rval = 0;
	ival = one;
	angle = pi_2;
      } else if (myState->accum < -pi_2) {
	rval = 0;
	ival = -one;
	angle = -pi_2;
      } else {
	rval = one;
	ival = 0;
	angle = 0;
      }

      unsigned count;
      for ( count = 0; count < 12; count++) {
	static int16_t angles[] = {
	  0x2000, 0x12e4, 0x09fb, 0x0511, 0x028b, 0x0146, 0x00a3, 0x0051, 0x0029, 0x0014, 0x000a, 0x0005
	};
	int16_t mask = -1 << (16 - count);
	rdiv = (rdiv & mask) | ((rval >> count) & ~mask);
	idiv = (idiv & mask) | ((ival >> count) & ~mask);
	if (myState->accum > angle) {
	  angle -= angles[count];
	  rval += idiv;
	  ival -= rdiv;
	} else {
	  angle += angles[count];
	  rval -= idiv;
	  ival += rdiv;
	}
      }
      if (myState->accum) {
	outData->data[i].I = Scale( one );
	outData->data[i].Q = 0;
      } else {
	outData->data[i].I = Scale( rval );
	outData->data[i].Q = Scale( ival );
      }
    }
  }

}


static RCCResult
run(RCCWorker *self, RCCBoolean timedOut, RCCBoolean *newRunCondition) {
  (void)timedOut;(void)newRunCondition;

  State *myState = self->memories[0];  

  RCCPort
    *in = &self->ports[FSK_MOD_COMPLEX_IN],
    *out = &self->ports[FSK_MOD_COMPLEX_OUT];
 
  Fsk_mod_complexInData *inData = in->current.data;
  Fsk_mod_complexOutIq  *outData = out->current.data;

  if ((in->input.length*2) > out->current.maxLength ) {
    self->container.setError("output buffer too small: need %zu have %zu", in->input.length*2, out->current.maxLength);
    return RCC_ERROR;
  }

  switch( in->input.u.operation ) {

  case FSK_MOD_COMPLEX_IN_DATA:
    {
#ifndef NDEBUG
      printf("%s got %zu bytes of data\n", __FILE__,  in->input.length);
#endif
      doFsk( myState, inData, outData, in->input.length );
      // output is complex, input is real
      out->output.length = in->input.length*2;
    }
    break;

  case FSK_MOD_COMPLEX_IN_SYNC:
  case FSK_MOD_COMPLEX_IN_TIME:
    self->container.send( out, &in->current, in->input.u.operation, in->input.length);
    return RCC_OK;
    break;

  };


 out->output.u.operation = in->input.u.operation;
 return RCC_ADVANCE;
}
