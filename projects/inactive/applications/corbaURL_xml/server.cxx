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

#include <iostream>
#include <CORBA.h>
#include "OcpiApi.hh"
#include "hello.hh"

using namespace std;

CORBA::ORB *our_orb;
class Hello_i : public POA_Hello {
  void send(const char* mesg) {
    cerr << "CORBA Server received message: " << mesg << endl;
    cerr.flush();
    our_orb->shutdown(false);
  }
};

int main(int argc, char** argv) {
  try {
    // Start CORBA
    CORBA::ORB_var orb = CORBA::ORB_init(argc, argv);
    our_orb = orb;
    CORBA::Object_var obj = orb->resolve_initial_references("RootPOA");
    PortableServer::POA_var poa = PortableServer::POA::_narrow(obj);
    PortableServer::POAManager_var pman = poa->the_POAManager();
    pman->activate();

    // Make servant, make and activate the object
    Hello_i my_servant;
    Hello_var my_object = my_servant._this();

    // Tell the world about the server object
    CORBA::String_var ior = orb->object_to_string(my_object);

    // Use OpenCPI utility to generate a pretty URL
    std::string url;
    OCPI::API::ior2corbaloc((char*)ior, url);

    cout << url;
    cout << endl;
    cout.flush();
    orb->run();
  }
  catch(CORBA::SystemException& ex) {
    cerr << "Caught CORBA::" << ex._name() << endl;
  }
  catch(CORBA::Exception& ex) {
    cerr << "Caught CORBA::Exception: " << ex._name() << endl;
  }
  catch(std::string & ex) {
    cerr << "Caught std::string Exception: " << ex << endl;
  }
  catch(...) {
    cerr << "Caught unknown exception" << endl;
  }

  return 0;
}
