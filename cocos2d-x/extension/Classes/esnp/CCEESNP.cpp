#include "CCEESNP.h"
#include "CCEConfig.h"
#include "CCEUtil.h"
#include "cocoa\CCValueSupport.h"
#include "..\CCEUtil.h"

#if defined(_WIN32)
#define F64D "%I64d"
#define F64U "%I64u"
#else
#define F64D "%lld"
#define F64U "%llu"
#endif

USING_NS_CC;

// CCEESNP
CCEESNP g_sharedESNP;
CCEESNP::CCEESNP()
{
	m_idSeq = 0;
	m_midSeq = 0;
	m_socket = NULL;
	m_handler = NULL;
	m_hostIdx = 0;
	m_canconn = false;
	m_connected = false;
}

CCEESNP::~CCEESNP()
{	
	
}

CCEESNP* CCEESNP::sharedESNP()
{	
	return &g_sharedESNP;
}

void CCEESNP::purgeSharedESNP()
{
	g_sharedESNP.cleanup();
}

void CCEESNP::appRunnable(void* data, long mstick) {
	CCEESNP* th = (CCEESNP*) data;
	if(th->m_socket!=NULL) {		
		if(!th->m_connected && th->m_canconn && !th->m_hosts.empty()) {
			int idx = th->m_hostIdx++;
			idx = idx % th->m_hosts.size();
			ESNPHost o = th->m_hosts[idx];
			th->m_canconn = false;
			th->m_socket->open(o.host.c_str(), o.port, 5000);
		}
		CCEAsynSocket::appRunnable(th->m_socket, mstick);
	}
}

CCValue CCEESNP::toval(ESNPMessage* msg) {
	CCValueMap m;
	if(msg->mid!=0) {
		std::string s = StringUtil::format(F64U, msg->mid);
		m["messageId"] = CCValue::stringValue(s);
	}
	if(!msg->service.empty()) {
		m["service"] = CCValue::stringValue(msg->service);
	}
	if(!msg->method.empty()) {
		m["method"] = CCValue::stringValue(msg->method);
	}
	if(msg->type!=0) {
		m["type"] = CCValue::intValue(msg->type);
	}
	if(msg->resp) {
		m["resp"] = CCValue::booleanValue(msg->resp);
	}
	if(!msg->headers.empty()) {
		m["headers"] = CCValue::mapValue(msg->headers);
	}
	if(!msg->values.empty()) {
		m["values"] = CCValue::mapValue(msg->headers);
	}
	return CCValue::mapValue(m);
}

bool CCEESNP::tomsg(CCValue val, ESNPMessage* msg) {
	CCValueMap* m = val.mapValue();
	if(m==NULL) {
		return false;
	}
	CCValueMapIterator it;
	msg->mid =0;
	it = m->find("messageId");
	if(it!=m->end()) {
		std::string s = it->second.stringValue();
		if(!s.empty()) {
			sscanf(s.c_str(), F64U, &msg->mid);
		}
	}
	it = m->find("service");
	if(it!=m->end()) {
		msg->service = it->second.stringValue();
	}
	it = m->find("method");
	if(it!=m->end()) {
		msg->method = it->second.stringValue();
	}
	msg->type = 0;
	it = m->find("type");
	if(it!=m->end()) {
		msg->type = it->second.intValue();
	}
	it = m->find("resp");
	if(it!=m->end()) {
		msg->resp = it->second.booleanValue();
	}
	it = m->find("headers");
	if(it!=m->end()) {
		CCValueMap* hs = it->second.mapValue();
		if(hs!=NULL) {
			msg->headers = *hs;
		}
	}
	it = m->find("values");
	if(it!=m->end()) {
		CCValueMap* vs = it->second.mapValue();
		if(vs!=NULL) {
			msg->values = *vs;
		}
	}
	return false;
}

bool CCEESNP::start() {
	if(m_socket==NULL) {
		m_socket = new CCEAsynSocket();
		m_socket->setHandler(this);
		if(!m_socket->start()) {
			return false;
		}
		m_canconn = true;
	}
	return true;
}

void CCEESNP::reset() {
	if(m_socket!=NULL && m_connected) {
		m_socket->close();
	}
}

void CCEESNP::stop() {
	cleanup();
}

CCValue CCEESNP::getDispatcher() {
	return m_dispatcher;
}

void CCEESNP::setDispatcher(CCValue dispatcher) {
	m_dispatcher = dispatcher;
	m_dispatcher.retain();
}

void CCEESNP::defaultDispatch(ESNPMessage* msg) {
	if(msg->resp) {
		std::vector<ESNPReq*>::const_iterator it = m_reqs.begin();
		for(;it!=m_reqs.end();it++) {
			ESNPReq* req = (*it);
			if(req->mid==msg->mid) {
				CCLOG("response -> " F64U, msg->mid);
				CCValue cb = req->callback;
				cb.retain();
				m_reqs.erase(it);
				delreq(req);
				if(cb.canCall()) {
					CCValueArray ps;
					ps.push_back(toval(msg));
					cb.call(ps, false);
					return;
				}
				break;
			}			
		}
		CCLOG("no callback, discard -> " F64U, msg->mid);
		return;
	}
	// not response, dispatcher it
	if(m_dispatcher.canCall()) {
		CCValueArray ps;
		ps.push_back(toval(msg));
		m_dispatcher.call(ps, false);
		return;
	}
	CCLOG("no dispatcher, discard -> " F64U, msg->mid);
}

void CCEESNP::setHandler(CCEESNPHandler* handler) {
	m_handler = handler;
}

void CCEESNP::addHost(std::string host, int port) {
	ESNPHost o;
	o.host = host;
	o.port = port;
	m_hosts.push_back(o);
}

int CCEESNP::process(ESNPMessage* msg, CCValue callback, int timeout)
{
	if(m_socket==NULL) {
		CCLOG("ESNP not start!!!");
		return 0;
	}

	m_idSeq++;
	if(m_idSeq>1000000) {
		m_idSeq = 1;
	}
	int id = m_idSeq;
		
	if(msg->mid==0) {
		m_midSeq++;
		msg->mid = m_midSeq;
	}

	ESNPReq* req = new ESNPReq();
	req->id = id;
	req->mid = msg->mid;
	req->message = msg;
	req->timeout = timeout;
	req->callback = callback;
	req->callback.retain();
	m_reqs.push_back(req);

	return id;
}

void CCEESNP::delreq(ESNPReq* req)
{
	if(req!=NULL) {
		if(req->message!=NULL) {
			delete req->message;
		}		
		req->callback.cleanup();
		delete req;
	}
}

void CCEESNP::cleanup()
{
	m_canconn = false;
	if(m_socket!=NULL) {
		m_socket->close();
		m_socket->stop();
		delete m_socket;
		m_socket = NULL;
	}
	if(m_reqs.size()>0) {
		std::vector<ESNPReq*>::const_iterator it = m_reqs.begin();
		for(;it!=m_reqs.end();it++) {
			delreq(*it);
		}
		m_reqs.clear();
	}
	m_dispatcher.cleanup();
}

int CCEESNP::queryRunningCount()
{
	return m_reqs.size();
}

bool CCEESNP::cancel(int reqId)
{
	ESNPReq* req = NULL;
	std::vector<ESNPReq*>::iterator it = m_reqs.begin();
	for(;it!=m_reqs.end();it++) {
		if((*it)->id==reqId) {
			req = (*it);
			m_reqs.erase(it);
			break;
		}
	}
	if(req!=NULL) {
		delreq(req);
		return true;
	}
	return false;
}

bool CCEESNP::handleUpstream(CCEAsynSocketEvent* e) {
	CCLOG("esnp event - %s", e->debugString().c_str());
	if(true) {
		CCEAsynSocketEventOpen* ev = dynamic_cast<CCEAsynSocketEventOpen*>(e);
		if(ev!=NULL) {
			m_connected = ev->isOpen();
			m_canconn = true;
			return true;
		}
	}
	if(true) {
		CCEAsynSocketEventRead* ev = dynamic_cast<CCEAsynSocketEventRead*>(e);
		if(ev!=NULL) {
			return true;
		}
	}
	return false;
}
