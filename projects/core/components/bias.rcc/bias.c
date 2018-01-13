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
 * THIS FILE WAS ORIGINALLY GENERATED ON Thu Dec 22 11:48:34 2011 EST
 * BASED ON THE FILE: bias.xml
 * YOU ARE EXPECTED TO EDIT IT
 *
 * This file contains the RCC implementation skeleton for worker: bias
 */
#include "bias_Worker.h"

BIAS_METHOD_DECLARATIONS;
RCCDispatch bias = {
 /* insert any custom initializations here */
 BIAS_DISPATCH
};

/*
 * Methods to implement for worker bias, based on metadata.
 */

static RCCResult
run(RCCWorker *self, RCCBoolean timedOut, RCCBoolean *newRunCondition) {
 (void)timedOut;(void)newRunCondition;
 RCCPort
   *in = &self->ports[BIAS_IN],
   *out = &self->ports[BIAS_OUT];
 BiasProperties *props = self->properties;
 uint32_t
   *inData = in->current.data,
   *outData = out->current.data;

 if (in->input.length > out->current.maxLength) {
   self->errorString = "output buffer too small";
   return RCC_ERROR;
 }
#if 0 // we want all the bias workers to pass all data
 if (in->input.length % sizeof(uint32_t)) {
   self->errorString = "input message size not a multiple of data type";
   return RCC_ERROR;
 }
#endif
 for (unsigned n = (in->input.length + sizeof(uint32_t) - 1) / sizeof(uint32_t); n; n--)
   *outData++ = *inData++ + props->biasValue;
 out->output.length = in->input.length;
 out->output.u.operation = in->input.u.operation;
 return RCC_ADVANCE;
}
