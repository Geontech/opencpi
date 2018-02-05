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

#include <cstdio>
#include <cassert>
#include <string>
#include "OcpiApi.hh"
#include <iostream>
#include "cv.h"
#include "highgui.h"


namespace OA = OCPI::API;

#define IMAGE_X_SIZE 800
#define IMAGE_Y_SIZE 800

int main(int argc, char **argv) {

  if ( argc != 4 ) {
    printf("Usage: %s, <min throughput: (frames per second)> <max distortion: (%%)> <max memory: (bytes)>\n", argv[0]);
    exit(-1);
  }

  try {

    /* ---- Load the image from file (grayscale) -------------- */
    //    IplImage* inImg = cvLoadImage( argv[1], 0 );
    // Create image with 8U pixel depth, single color channel
    IplImage* img = cvCreateImage(
				  cvSize(IMAGE_X_SIZE,IMAGE_Y_SIZE),
				  IPL_DEPTH_8U, 4
				  );
    // Convert
    //    cvConvertScale(inImg, img);
    CvPoint pnts[] = { {0,0},{0,1500},{1500,1500},{1500,0}, {0,0}};
    CvPoint *poly[1] = {pnts};
    int     np[1]={5};
    cvFillPoly(img,poly,np,1,CV_RGB(128,128,128));

#if 1
    char *appString;
    asprintf(&appString,
	     "<application>\n"
	     "  <instance component='bestfit' selection='throughput > %s' externals='1'/>\n"
	     "</application>\n",
	     argv[1]);
    OA::Application app(appString);
    app.initialize();
    OA::ExternalPort &ep = app.getPort("out");
    app.start();
#else
    // Find a container to run our worker
    // (it returns a pointer since it might return NULL)
    OA::Container *c = OA::ContainerManager::find("rcc");
    assert(c); // we'll always find an rcc container

    // Create an application context on that container (and delete it when we exit)
    // (it returns a pointer since the caller is allowed to delete it)
    OA::ContainerApplication &a = *c->createApplication("bestfit-app");

    // OA::PValue selection[] = {
    //   OA::PVDouble("Appthroughput",atoi(argv[1])),
    //   OA::PVDouble("Appdistortion",atof(argv[2])),
    //   OA::PVDouble("Appmemusage", atoi(argv[3])),
    //   OA::PVString("__ocpi__exp-required", "throughput > Appthroughput"),
    //   OA::PVString("__ocpi__exp-scored 40", "distortion <= Appdistortion"),
    //   OA::PVString("__ocpi__exp-scored 10", "memoryusage <= Appmemusage"),
    //   OA::PVEnd
    // };
    char *s;
    asprintf(&s, "throughput > %s", argv[1]);

    OA::Worker &w = a.createWorker("sinegen_instance", "bestfit", 0,0,s);
    free(s);
    // Get a handle (reference) on the "out" port of the worker
    OA::Port &p = w.getPort("out");

    // Get an external port (that this program can use) connected to the "out" port.
    OA::ExternalPort &ep = p.connectExternal();

    w.start(); // start the worker running
#endif
    OA::ExternalBuffer *b;
    int current_x=0;
#define X_SCALE 10
#define XPOS ((current_x++ + X_SCALE)%IMAGE_X_SIZE)
#define YPOS(y) (y+IMAGE_Y_SIZE/2)
    for (unsigned i = 0; i < 10000; i++) {
      uint16_t *data;
      size_t length;
      uint8_t opcode;
      bool end;

      cvNamedWindow( "Output", CV_WINDOW_AUTOSIZE );
      cvShowImage( "Output", img );

      if ((b = ep.getBuffer((uint8_t*&)data, length, opcode, end))) {
	int l = length/sizeof(uint32_t);
	CvPoint p0 = cvPoint(XPOS,YPOS(data[1]));
	int x,old_x;
	x = old_x = XPOS;
	CvPoint p1 = cvPoint(old_x,YPOS(data[3]));
	for ( int n=1; n<l-1; n++ ) {
	  if ( x < old_x ) {
	    old_x = x;
	    break;
	  }
	  else {
	    cvLine( img, p0, p1, CV_RGB(255,0,0), 2 );
	  }
	  p0 = p1;
	  x = XPOS;
	  p1 = cvPoint(x,YPOS(data[n+1]));

	}
	cvShowImage( "Output", img );
	goto cleanup;
      }
    }
    fprintf(stderr, "Worker never sent anything!\n");

  cleanup:
    // Cleanup
    cvWaitKey(0);
    cvReleaseImage( &img );
    cvDestroyWindow( "Input" );

    // Note that the ContainerApplication object MAY be deleted by the program,
    // hence it is a pointer.  But it doesn't HAVE to be deleted since it will
    // automatically be deleted on exit.
    return 0;

  } catch (std::string &e) {
    fprintf(stderr, "Exception thrown: %s\n", e.c_str());
    return 1;
  }
}
