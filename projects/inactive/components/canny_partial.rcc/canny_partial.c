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
 * THIS FILE WAS ORIGINALLY GENERATED ON Sun May  8 21:34:21 2011 EDT
 * BASED ON THE FILE: canny_partial.xml
 * YOU ARE EXPECTED TO EDIT IT
 *
 * This file contains the RCC implementation skeleton for worker: canny_partial
 */
#include <string.h>
#include <stdlib.h>

#include "canny_partial_Worker.h"

// Algorithm specifics:
typedef unsigned char uchar;
typedef uint8_t Pixel;       // the data type of pixels
typedef uint16_t PixelTemp;  // the data type for intermediate pixel math
#define MAX UINT8_MAX        // the maximum pixel value
#define FRAME_BYTES (p->height * p->width * sizeof(Pixel)) // pixels per frame


typedef struct {
  uint16_t init;
  uint16_t *dx;
  uint16_t *dy;
  unsigned lineAt;
  int mapstep, maxsize;
  int low, high;
  char *buffer;
  uchar* map;
  int* mag_buf[3];
  uchar **stack;
  uchar **stack_top, **stack_bottom;
} CPState;

static size_t sizes[] = {sizeof(CPState), 0 };

CANNY_PARTIAL_METHOD_DECLARATIONS;
RCCDispatch canny_partial = {
  /* insert any custom initializations here */
  .memSizes = sizes,
  CANNY_PARTIAL_DISPATCH
};


// sets up algorithm
static void
cannyInit(CPState *myState,
	  int H, int W,
          double low_thresh, double high_thresh) {

  // sanity checks
  if(low_thresh < 1e-9)
    low_thresh = 10;
  if(high_thresh < 1e-9)
    high_thresh = 100;
  if(low_thresh > high_thresh) {
    double temp = high_thresh;
    high_thresh = low_thresh;
    low_thresh = temp;
  }

  myState->dx = (uint16_t *) malloc( H * W * sizeof(uint16_t) );
  myState->dy = (uint16_t *) malloc( H * W * sizeof(uint16_t) );

  // setting thresholds
  myState->low = (int) low_thresh;
  myState->high = (int) high_thresh;

  myState->buffer = (char *) malloc( (W+2)*(H+2) + (W+2)*3*sizeof(int) );

  myState->mag_buf[0] = (int*)myState->buffer;
  myState->mag_buf[1] = myState->mag_buf[0] + W + 2;
  myState->mag_buf[2] = myState->mag_buf[1] + W + 2;
  myState->map = (uchar*)(myState->mag_buf[2] + W + 2);
  myState->mapstep = W + 2;

  // allocate stack directly
  myState->maxsize = H * W;
  myState->stack = (uchar **) malloc( myState->maxsize*sizeof(uchar) );
  myState->stack_top = myState->stack_bottom = &myState->stack[0];

  memset( myState->mag_buf[0], 0, (W+2)*sizeof(int) );
  memset( myState->map, 1, myState->mapstep );
  memset( myState->map + myState->mapstep*(H + 1), 1, myState->mapstep );
}


static RCCResult start(RCCWorker *self)
{
  CPState *myState = self->memories[0];  
  Canny_partialProperties *p = self->properties;
  if ( myState->init == 0 ) {
    cannyInit(myState, p->height, p->width, p->low_thresh, p->high_thresh);
  }
  myState->init = 1;
  return RCC_OK;
}


static RCCResult release(RCCWorker *self)
{
  CPState *myState = self->memories[0];  
  if ( myState->init ) {
    free( myState->stack );
    free( myState->buffer );
    free( myState->dx );
    free( myState->dy );
  }
  return RCC_OK;
}




// updates data (dx and dy)
static void
updateFrame(CPState *myState,
	    int H, int W, int lines,
            Pixel *src_dx, Pixel *src_dy) {
  ( void )H;
  int i, j;
  for(i = 0; i < lines; i++) {
    int at = (myState->lineAt + i) * W;
    int src_at = i * W;
    for(j = 0; j < W; j++) {
      myState->dx[at+j] = src_dx[src_at+j];
      myState->dy[at+j] = src_dy[src_at+j];
    }
  }
}

// Compute one line of main loop
static void
cannyLoop(CPState* myState, int H, int W, int i) {

  /* sector numbers 
     (Top-Left Origin)

     1   2   3
   *  *  * 
   * * *  
   0*******0
   * * *  
   *  *  * 
   3   2   1
   */

#define CANNY_PUSH(d)    *(d) = (uchar)2, *myState->stack_top++ = (d)
#define CANNY_POP(d)     (d) = *--myState->stack_top
  
  int j;

  // calculate magnitude and angle of gradient, perform non-maxima supression.
  // fill the map with one of the following values:
  //   0 - the pixel might belong to an edge
  //   1 - the pixel can not belong to an edge
  //   2 - the pixel does belong to an edge
  {
    int* _mag = myState->mag_buf[(i > 0) + 1] + 1;
    const short* _dx = (short*)(myState->dx + W*i);
    const short* _dy = (short*)(myState->dy + W*i);
    uchar* _map;
    int x, y;
    int magstep1, magstep2;
    int prev_flag = 0;

    if( i < H )
    {
      _mag[-1] = _mag[W] = 0;

      // Use L1 norm
      for( j = 0; j < W; j++ )
        _mag[j] = abs(_dx[j]) + abs(_dy[j]);
    }
    else
      memset( _mag-1, 0, (W + 2)*sizeof(int) );

    // at the very beginning we do not have a complete ring
    // buffer of 3 magnitude rows for non-maxima suppression
    if( i == 0 )
      return;

    _map = myState->map + myState->mapstep*i + 1;
    _map[-1] = _map[W] = 1;

    _mag = myState->mag_buf[1] + 1; // take the central row
    _dx = (short*)(myState->dx + W*(i-1));
    _dy = (short*)(myState->dy + W*(i-1));

    magstep1 = (int)(myState->mag_buf[2] - myState->mag_buf[1]);
    magstep2 = (int)(myState->mag_buf[0] - myState->mag_buf[1]);

    for( j = 0; j < W; j++ )
    {
#define CANNY_SHIFT 15
#define TG22  (int)(0.4142135623730950488016887242097*(1<<CANNY_SHIFT) + 0.5)

      x = _dx[j];
      y = _dy[j];
      int s = x ^ y;
      int m = _mag[j];

      x = abs(x);
      y = abs(y);
      if( m > myState->low )
      {
        int tg22x = x * TG22;
        int tg67x = tg22x + ((x + x) << CANNY_SHIFT);

        y <<= CANNY_SHIFT;

        if( y < tg22x )
        {
          if( m > _mag[j-1] && m >= _mag[j+1] )
          {
            if( m > myState->high && !prev_flag && _map[j-myState->mapstep] != 2 )
            {
              CANNY_PUSH( _map + j );
              prev_flag = 1;
            }
            else
              _map[j] = (uchar)0;
            continue;
          }
        }
        else if( y > tg67x )
        {
          if( m > _mag[j+magstep2] && m >= _mag[j+magstep1] )
          {
            if( m > myState->high && !prev_flag && _map[j-myState->mapstep] != 2 )
            {
              CANNY_PUSH( _map + j );
              prev_flag = 1;
            }
            else
              _map[j] = (uchar)0;
            continue;
          }
        }
        else
        {
          s = s < 0 ? -1 : 1;
          if( m > _mag[j+magstep2-s] && m > _mag[j+magstep1+s] )
          {
            if( m > myState->high && !prev_flag && _map[j-myState->mapstep] != 2 )
            {
              CANNY_PUSH( _map + j );
              prev_flag = 1;
            }
            else
              _map[j] = (uchar)0;
            continue;
          }
        }
      }
      prev_flag = 0;
      _map[j] = (uchar)1;
    }

    // scroll the ring buffer
    _mag = myState->mag_buf[0];
    myState->mag_buf[0] = myState->mag_buf[1];
    myState->mag_buf[1] = myState->mag_buf[2];
    myState->mag_buf[2] = _mag;
  }
}

static void
cannyEnd(CPState *myState, int H, int W, Pixel *dst) {

  // now track the edges (hysteresis thresholding)
  while( myState->stack_top > myState->stack_bottom )
  {
    uchar* m;

    CANNY_POP(m);

    if( !m[-1] )
      CANNY_PUSH( m - 1 );
    if( !m[1] )
      CANNY_PUSH( m + 1 );
    if( !m[-myState->mapstep-1] )
      CANNY_PUSH( m - myState->mapstep - 1 );
    if( !m[-myState->mapstep] )
      CANNY_PUSH( m - myState->mapstep );
    if( !m[-myState->mapstep+1] )
      CANNY_PUSH( m - myState->mapstep + 1 );
    if( !m[myState->mapstep-1] )
      CANNY_PUSH( m + myState->mapstep - 1 );
    if( !m[myState->mapstep] )
      CANNY_PUSH( m + myState->mapstep );
    if( !m[myState->mapstep+1] )
      CANNY_PUSH( m + myState->mapstep + 1 );
  }

  // the final pass, form the final image
  int i, j;
  for( i = 0; i < H; i++ )
  {
    const uchar* _map = myState->map + myState->mapstep*(i+1) + 1;
    uchar* _dst = dst + i*W;

    for( j = 0; j < W; j++ )
      _dst[j] = (uchar)-(_map[j] >> 1);
  }

}

/*
 * Methods to implement for worker canny_partial, based on metadata.
*/

static RCCResult run(RCCWorker *self,
                     RCCBoolean timedOut,
                     RCCBoolean *newRunCondition) {
  ( void ) timedOut;
  ( void ) newRunCondition;
  Canny_partialProperties *p = self->properties;
  RCCPort *in_dx = &self->ports[CANNY_PARTIAL_IN_DX],
          *in_dy = &self->ports[CANNY_PARTIAL_IN_DY],
          *out = &self->ports[CANNY_PARTIAL_OUT];
  const RCCContainer *c = &self->container;
  CPState * myState = (CPState*)self->memories[0];

  if ( (in_dx->input.length>0) && (in_dx->input.length>FRAME_BYTES) ) {
    return RCC_ERROR;
  }
  if ( (in_dy->input.length>0) && (in_dy->input.length>FRAME_BYTES) ) {
    return RCC_ERROR;
  }

  // Run Canny edge detection
  int lines = in_dx->input.length / p->width;
  int lineEnd = myState->lineAt + lines;
  updateFrame(myState, p->height, p->width, lines,
              in_dx->current.data, in_dy->current.data);

  c->advance( in_dx, FRAME_BYTES );
  c->advance( in_dy, FRAME_BYTES );

  // loop
  while(myState->lineAt < (unsigned)lineEnd) {
    cannyLoop(myState, p->height, p->width, myState->lineAt++);
  }

  // finish
  if(myState->lineAt == p->height - 1) {
    cannyLoop(myState, p->height, p->width, myState->lineAt++);
    cannyLoop(myState, p->height, p->width, myState->lineAt++);
    cannyEnd(myState, p->height, p->width, out->current.data);

    out->output.u.operation = in_dx->input.u.operation;
    out->output.length = FRAME_BYTES;
    return RCC_ADVANCE;
  }
  return RCC_OK;
}
