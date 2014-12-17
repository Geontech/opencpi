#include <string.h>
#include "OcpiOsEther.h"
#include "OcpiOsMisc.h"
#include "OcpiContainerManager.h"
#include "OcpiContainerErrorCodes.h"
#include "OcpiUtilMisc.h"
// This is the "driver" for remote containers, which finds them, constructs them, and 
// in general manages them.  It is an object managed by the Container::Manager class.
// It acts as the factory for Remote containers.

// This is similar to simulation HDL containers in that they are discovered by UDP,
// but different, in that one UDP endpoint sources multiple containers

// Summary of what the application class does:
/*
containermanager->findcontainers
-- so this is about search
container->nthContainer
container->createApplication
-- can be local until other stuff
containerapplication->start - generic just starts workers one by one - no args
containerapplication->stop - generic just stops workers one by one - no args
containerapplication->isdone - -generic just queries workers one by one - no args
containerapplication->createworker - generic: container->loadartifact, artifact->create worker
 -- passes the xml, slave reference (must be local...), params
containerapplication->setApplication() - doesn't need to be remoted
containerworker->setProperty
worker->getPort
worker->wait
worker->getProperty
worker->setProperty
worker->setupProperty
port->connecct
port->connectURL
port->connectExternal

*/
namespace OC = OCPI::Container;
namespace OU = OCPI::Util;
namespace OA = OCPI::API;
namespace OL = OCPI::Library;
namespace OE = OCPI::OS::Ether;
namespace OS = OCPI::OS;
namespace OCPI {
  namespace Remote {
    bool g_suppressRemoteDiscovery = false;
    extern const char *remote;
const unsigned RETRIES = 3;
const unsigned DELAYMS = 500;
const char *remote = "remote";
class Container;
class Artifact : public OC::ArtifactBase<Container,Artifact> {
  friend class Container;
  Artifact(Container &c, OL::Artifact &lart, const OA::PValue *props)
    : OC::ArtifactBase<Container,Artifact>(c, *this, lart, props) {
  }
  virtual ~Artifact() {}
};
class ExternalPort;
class Worker;
class Port : public OC::PortBase<Worker, Port, ExternalPort> {
  Port( Worker& w, const OU::Port & pmd, const OU::PValue *params)
    :  OC::PortBase< Worker, Port, ExternalPort>
       (w, *this, pmd, pmd.m_provider,
	(1 << OCPI::RDT::ActiveFlowControl) | (1 << OCPI::RDT::ActiveMessage), params) {
  }

  ~Port() {
  }
};
class Application;
class Worker
  : public OC::WorkerBase<Application,Worker,Port> {
  friend class Application;
  Worker(Application & app, Artifact *art, const char *name,
	 ezxml_t impl, ezxml_t inst, OC::Worker */*slave*/, const OU::PValue *wParams)
    : OC::WorkerBase<Application,Worker,Port>(app, *this, art, name, impl, inst, wParams) {
  }
  virtual ~Worker() {}
  OC::Port &createPort(const OU::Port&, const OU::PValue *params) {
    return *(OC::Port*)NULL;
  }
  void controlOperation(OU::Worker::ControlOperation) {}
  OC::Port &createInputPort(OU::PortOrdinal portId,      
			    size_t bufferCount,
			    size_t bufferSize, 
			    const OU::PValue *params = NULL)
    throw (OU::EmbeddedException) {
    return *(OC::Port*)NULL;
  }
  OC::Port &createOutputPort(OU::PortOrdinal portId,     
			     size_t bufferCount,
			     size_t bufferSize, 
			     const OU::PValue *props = NULL)
    throw ( OU::EmbeddedException ) {
    return *(OC::Port*)NULL;
  }
  void setPropertyValue(const OA::Property &p, const OU::Value &v) {}

  void read(size_t offset, size_t nBytes, void *p_data) {}
  void write(size_t offset, size_t nBytes, const void* p_data ) {}
  void setPropertyBytes(const OA::PropertyInfo &info, size_t offset,
			const uint8_t *data, size_t nBytes) const {};
  void setProperty8(const OA::PropertyInfo &info, uint8_t data) const {}
  void setProperty16(const OA::PropertyInfo &info, uint16_t data) const {}
  void setProperty32(const OA::PropertyInfo &info, uint32_t data) const {}
  void setProperty64(const OA::PropertyInfo &info, uint64_t data) const {}
  void getPropertyBytes(const OA::PropertyInfo &info, size_t offset,
			uint8_t *data, size_t nBytes) const {}
  uint8_t getProperty8(const OA::PropertyInfo &info) const { return 0; }
  uint16_t getProperty16(const OA::PropertyInfo &info) const { return 0; }
  uint32_t getProperty32(const OA::PropertyInfo &info) const  { return 0; }
  uint64_t getProperty64(const OA::PropertyInfo &info) const  { return 0; }
      
  void prepareProperty(OU::Property&,
		       volatile void *&writeVaddr,
		       const volatile void *&readVaddr) {}
  // These property access methods are called when the fast path
  // is not enabled, either due to no MMIO or that the property can
  // return errors. 
#undef OCPI_DATA_TYPE_S
#define OCPI_DATA_TYPE(sca,corba,letter,bits,run,pretty,store)		\
  void set##pretty##Property(unsigned ordinal, const run val) const {}	\
  void set##pretty##SequenceProperty(const OA::Property &p,const run *vals, \
				     size_t length) const {}
  // Set a string property value
  // ASSUMPTION:  strings always occupy at least 4 bytes, and
  // are aligned on 4 byte boundaries.  The offset calculations
  // and structure padding are assumed to do this.
#define OCPI_DATA_TYPE_S(sca,corba,letter,bits,run,pretty,store)	\
  void set##pretty##Property(unsigned ordinal, const run val) const {}	\
  void set##pretty##SequenceProperty(const OA::Property &p,const run *vals, \
				     size_t length) const {}
  OCPI_PROPERTY_DATA_TYPES
#undef OCPI_DATA_TYPE_S
#undef OCPI_DATA_TYPE
  // Get Scalar Property
#define OCPI_DATA_TYPE(sca,corba,letter,bits,run,pretty,store)		\
  run get##pretty##Property(unsigned ordinal) const { return 0; }       \
  unsigned get##pretty##SequenceProperty(const OA::Property &p,		\
					 run *vals,			\
					 size_t length) const { return 0; }
  // ASSUMPTION:  strings always occupy at least 4 bytes, and
  // are aligned on 4 byte boundaries.  The offset calculations
  // and structure padding are assumed to do this.
#define OCPI_DATA_TYPE_S(sca,corba,letter,bits,run,pretty,store)	\
  void get##pretty##Property(unsigned ordinal, char *cp,		\
			     size_t length) const {}			\
  unsigned get##pretty##SequenceProperty				\
  (const OA::Property &p, char **vals, size_t length, char *buf,	\
   size_t space) const { return 0; }

  OCPI_PROPERTY_DATA_TYPES
#undef OCPI_DATA_TYPE_S
#undef OCPI_DATA_TYPE
#define OCPI_DATA_TYPE_S OCPI_DATA_TYPE
};
class Application
  : public OC::ApplicationBase<Container,Application,Worker> {
  friend class Container;
  Application(Container &c, const char *name, const OU::PValue *params)
    : OC::ApplicationBase<Container,Application,Worker>(c, *this, name, params) {
  }
  virtual ~Application() {
  }
  OC::Worker &
  createWorker(OC::Artifact *art, const char *appInstName,
	       ezxml_t impl, ezxml_t inst, OC::Worker *slave,
	       const OU::PValue *wParams) {
    return *new Worker(*this, art ? static_cast<Artifact*>(art) : NULL,
		       appInstName ? appInstName : "unnamed-worker", impl, inst, slave, wParams);
  }
};

class Driver;
class Client;
extern const char *remote;
class Container
  : public OC::ContainerBase<Driver,Container,Application,Artifact> {
  Client &m_client;
public:
  Container(Client &client, const char *name,
	    const char *model, const char *os, const char *osVersion, const char *platform,
	    const OA::PValue* /*params*/)
    throw ( OU::EmbeddedException )
    : OC::ContainerBase<Driver,Container,Application,Artifact>(*this, name),
      m_client(client) {
    m_model = model;
    m_os = os;
    m_osVersion = osVersion;
    m_platform = platform;
  }
  virtual ~Container()
  throw () {
  }
  OA::ContainerApplication*
  createApplication(const char *name, const OU::PValue *props)
    throw (OU::EmbeddedException) {
    return new Application(*this, name, props);
  }
  bool needThread() { return false; }
  OC::Artifact &
  createArtifact(OCPI::Library::Artifact &lart, const OA::PValue *artifactParams) {
    return *new Artifact(*this, lart, artifactParams);
  }
};
// The "client" class that knows how to talk to some remote containers.
// There is no parent-child relationship since containers are always
// the children of container drivers.
class Client 
  : public OU::Child<Driver,Client,remote> {
  friend class Driver;
protected:
  Client(Driver &d, const char *name, const char *host, const char *port, std::string &error)
    : OU::Child<Driver,Client,remote>(d, *this, name) {
  }
};

// The driver class owns the containers (like all container driver classes)
// and also owns the clients of those containers.
class Driver : public OC::DriverBase<Driver, Container, remote>,
	       public OU::Parent<Client> {
  //      OCPI::DataTransport::TransportGlobal *m_tpg_events, *m_tpg_no_events;
  //      unsigned m_count;
public:
  static pthread_key_t s_threadKey;
  Driver() throw() {
    ocpiCheck(pthread_key_create(&s_threadKey, NULL) == 0);
    ocpiDebug("Registering the Remote Container driver");
  }
  OC::Container *
  probeContainer(const char *which, std::string &error, const OA::PValue *params)
    throw ( OU::EmbeddedException ) {
    throw OU::Error("Remote containers may only be discovered, not probed: \"%s\"", which);
  }
  // Try a discovery (send and receive) on a socket from an interface
  bool
  trySocket(std::set<std::string> &servers, OE::Interface &ifc, OE::Socket &s,
	    OE::Address &addr, bool discovery, const char **exclude, std::string &error) {
    // keep track of different addresses discovered when we broadcast.
    std::set<OE::Address,OE::Address::Compare> addrs;
    OE::Packet sendFrame;
    strcpy((char *)sendFrame.payload, "discover");
    unsigned count = 0;
    for (unsigned n = 0; error.empty() && n < RETRIES; n++) {
      if (!s.send(sendFrame, strlen((const char*)sendFrame.payload), addr, 0, &ifc, error))
	break;
      OE::Packet recvFrame;
      OE::Address devAddr;
      size_t length;

      OS::Timer timer(0, DELAYMS * 1000000);
      while (s.receive(recvFrame, length, DELAYMS, devAddr, error)) {
	if (addr.isBroadcast()) {
	  if (!addrs.insert(devAddr).second) {
	    ocpiDebug("Received redundant ethernet discovery response");
	    continue;
	  }
	} else if (devAddr != addr) {
	  ocpiInfo("Received ethernet discovery response from wrong address");
	  continue;
	}
	char *response = (char *)recvFrame.payload;
	if (strlen(response) >= length) {
	  ocpiInfo("Discovery response invalid from %s: strlen %zu length %zu",
		   devAddr.pretty(), strlen(response), length);
	  continue;
	}
	ocpiDebug("Discovery response is:\n%s\n-- end of discovery", response);
	char *cp = strchr(response, '\n');
	char *port = strchr(response, ':');
	if (!cp || !port || cp < port)
	  goto bad;
	*cp = '\0';
	{ 
	  std::string serverName(response);
	  *port++ = '\0';
	  if (exclude)
	    for (const char **ap = exclude; *ap; ap++) {
	      if (!strcasecmp(serverName.c_str(), *ap) ||
		  !strcasecmp(response, *ap)) {
		ocpiInfo("Container server host %s specifically excluded/ignored", *ap);
		goto next;
	      }
	    }
	  if (!servers.insert(serverName).second)
	    continue;
	  char *end;
	  for (*cp++ = '\0'; *cp; cp = end) {
	    if (!(end = strchr(cp, '\n')))
	      goto bad;
	    char *p = end;
	    *end++ = '\0';
	    const unsigned NARGS = 5;
	    char *args[NARGS];
	    for (unsigned n = NARGS; n; args[--n] = p--) {
	      *p = 0;
	      while (p > cp && p[-1] != ':')
		p--;
	    }
	    if (p >= cp)
	      goto bad;
	    std::string name;
	    OU::format(name, "remote:%s:%s", response, args[0]);
	    if (exclude)
	      for (const char **ap = exclude; *ap; ap++)
		if (!strcasecmp(name.c_str(), *ap)) {
		  ocpiInfo("Remote container %s specifically excluded/ignored", *ap);
		  goto cskip;
		}
	    {
	      Client *client = OU::Parent<Client>::findChildByName(serverName.c_str());
	      if (!client) {
		client = new Client(*this, serverName.c_str(), response, port, error);
		if (error.length()) {
		  delete client;
		  return true;
		}
	      }
	      ocpiDebug("Creating remote container: \"%s\", model %s, os %s, version %s, platform %s",
			name.c_str(), args[1], args[2], args[3], args[4]);
	      Container &c = *new Container(*client, name.c_str(),
					    args[1], args[2], args[3], args[4], NULL);
	      count++;
	    }
	  cskip:;
	  }
	}
	continue;
      bad:
	ocpiInfo("Invalid response during container server discovery from %s",
		 devAddr.pretty());
      next:;
      }
      if (!timer.expired())
	OS::sleep(2);
    }
    if (error.size())
      ocpiInfo("error on interface '%s' when probing for %s: %s",
	       ifc.name.c_str(), addr.pretty(), error.c_str());
    else if (!count && !addr.isBroadcast())
      ocpiInfo("no network probe response on '%s' from '%s' after %u attempts %ums apart",
	       ifc.name.c_str(), addr.pretty(), RETRIES, DELAYMS);
    return count;
  }
  // Find container servers on this interface, perhaps at one specific address
  unsigned
  tryIface(std::set<std::string> &servers, OE::Interface &ifc, OE::Address &devAddr,
	   const char **exclude, bool discovery, std::string &error) {
    unsigned count = 0;
    OE::Interface i("udp", error);
    if (error.length())
      ocpiInfo("Could not open udp interface for discovery: %s", error.c_str());
    else {
      OE::Socket s(i, discovery ? ocpi_discovery : ocpi_master, NULL, 0, error);
      if (error.length())
	ocpiInfo("Could not open socket for udp discovery: %s", error.c_str());
      else {
	count = trySocket(servers, ifc, s, devAddr, discovery, exclude, error);
	if (error.length())
	  ocpiInfo("Error in container server discovery for \"%s\" interface: %s",
		   ifc.name.c_str(), error.c_str());
      }
    }
    return count;
  }
  // Per driver discovery routine to create devices
  // In this case we "discover" container servers, each of which serves us 
  // whatever containers are local to that server/system
  unsigned
  search(const OA::PValue* props, const char **exclude, bool discoveryOnly)
    throw ( OU::EmbeddedException ) {
    if (g_suppressRemoteDiscovery)
      return 0;
    std::string error;
    unsigned count = 0;
    OE::IfScanner ifs(error);
    if (error.size())
      return 0;
    const char *ifName = NULL;
    OU::findString(props, "interface", ifName);
    OE::Interface eif;
    ocpiDebug("Searching for container servers in interfaces");
    std::set<std::string> servers;
    while (ifs.getNext(eif, error, ifName)) {
      if (eif.name == "udp") // the udp pseudo interface is not used for discovery
	continue;
      ocpiDebug("RemoteDriver: Considering interface \"%s\", addr 0x%x",
		eif.name.c_str(), eif.ipAddr.addrInAddr());
      if (eif.up && eif.connected && eif.ipAddr.addrInAddr()) {
	OE::Address bcast(true, 17171);
	count += tryIface(servers, eif, bcast, exclude, discoveryOnly, error);
	if (error.size()) {
	  ocpiDebug("Error during container server discovery on '%s': %s",
		    eif.name.c_str(), error.c_str());
	  error.clear();
	}
      } else
	ocpiDebug("In RemoteDriver.cxx Interface '%s' is %s and %s",
		  eif.name.c_str(), eif.up ? "up" : "down",
		  eif.connected ? "connected" : "not connected");
      if (ifName)
	break;
    }
    if (error.size())
      ocpiInfo("Error during container server discovery on '%s': %s",
	       eif.name.c_str(), error.c_str());
    return count;
  }
  ~Driver() throw ( ) {
    // Force containers to shutdown before we remove transport globals.
    OU::Parent<Container>::deleteChildren();
    //      if ( m_tpg_no_events ) delete m_tpg_no_events;
    //      if ( m_tpg_events ) delete m_tpg_events;
    ocpiCheck(pthread_key_delete(s_threadKey) == 0);
  }
};
    pthread_key_t Driver::s_threadKey;
    // Register this driver
    OC::RegisterContainerDriver<Driver> driver;
  }
}