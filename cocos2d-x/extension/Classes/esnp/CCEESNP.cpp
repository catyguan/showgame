#include "CCEESNP.h"
#include "CCEConfig.h"
#include "CCEUtil.h"
#include "cocoa\CCValueSupport.h"
#include "..\CCEUtil.h"
#include "Coder.h"

#if defined(_WIN32)
#define F64D "%I64d"
#define F64U "%I64u"
#else
#define F64D "%lld"
#define F64U "%llu"
#endif

USING_NS_CC;

// util
char endframe[] = {0,0,0,0};
int encode(ESNPBuffer* buf, ESNPMessage* msg)
{
	char h[4];
	buf->Reset();
	if(true) {
		ESNPCoder::header(h, MT_MESSAGE_ID, 8);
		buf->WriteBytes(h, 4);
		ESNPCoder::writeFixUint64(buf, msg->mid);
	}
	if(msg->smid>0) {
		ESNPCoder::header(h, MT_SOURCE_MESSAGE_ID, 8);
		buf->WriteBytes(h, 4);
		ESNPCoder::writeFixUint64(buf, msg->smid);
	}
	if(!msg->service.empty()) {
		int p = buf->Reserve(4);
		int sz = 0;
		sz += ESNPCoder::writeInt32(buf, ADDRESS_SERVICE);
		sz += ESNPCoder::writeLenString(buf, msg->service);
		ESNPCoder::header(h, MT_ADDRESS, sz);
		buf->Rewrite(p, h, 4);
	}
	if(!msg->method.empty()) {
		int p = buf->Reserve(4);
		int sz = 0;
		sz += ESNPCoder::writeInt32(buf, ADDRESS_OP);
		sz += ESNPCoder::writeLenString(buf, msg->method);
		ESNPCoder::header(h, MT_ADDRESS, sz);
		buf->Rewrite(p, h, 4);
	}
	if(msg->type!=0) {
		ESNPCoder::header(h, MT_FLAG, 1);
		buf->WriteBytes(h, 4);
		ESNPCoder::writeInt32(buf, msg->type);
	}
	if(msg->resp) {
		ESNPCoder::header(h, MT_FLAG, 1);
		buf->WriteBytes(h, 4);
		ESNPCoder::writeInt32(buf, FLAG_RESP);
	}
	if(!msg->headers.empty()) {
		CCValueMapIterator it = msg->headers.begin();
		for(;it!=msg->headers.end();it++) {			
			int p = buf->Reserve(4);
			int sz = 0;
			sz += ESNPCoder::writeLenString(buf, it->first);
			sz += ESNPCoder::writeVar(buf, (CCValue&) it->second);
			ESNPCoder::header(h, MT_HEADER, sz);
			buf->Rewrite(p, h, 4);
		}
	}
	if(!msg->values.empty()) {
		CCValueMapIterator it = msg->values.begin();
		for(;it!=msg->values.end();it++) {
			int p = buf->Reserve(4);
			int sz = 0;
			sz += ESNPCoder::writeLenString(buf, it->first);
			sz += ESNPCoder::writeVar(buf, (CCValue&) it->second);
			ESNPCoder::header(h, MT_DATA, sz);
			buf->Rewrite(p, h, 4);
		}
	}
	if(!msg->error.empty()) {
		int p = buf->Reserve(4);
		int sz = 0;
		sz += ESNPCoder::writeString(buf, msg->error);
		ESNPCoder::header(h, MT_ERROR, sz);
		buf->Rewrite(p, h, 4);
	}
	// end frame
	buf->WriteBytes(endframe, 4);
	return buf->WritePos();
}

bool decode(ESNPBuffer* buf, ESNPMessage* msg) {
	for(;;) {
		int mt, sz;
		int p = buf->ReadPos();
		if(!ESNPCoder::header(buf, &mt, &sz)) {
			buf->ResetRead(p);
			return false;
		}
		switch(mt) {
		case MT_END:
			return true;
		case MT_MESSAGE_ID:
			msg->mid = ESNPCoder::readFixUint64(buf, NULL);			
			break;
		case MT_SOURCE_MESSAGE_ID:
			msg->smid = ESNPCoder::readFixUint64(buf, NULL);
			break;
		case MT_ADDRESS: {
				int addrt = ESNPCoder::readInt32(buf,NULL);
				std::string s = ESNPCoder::readLenString(buf, NULL);
				switch(addrt) {
				case ADDRESS_SERVICE:
					msg->service = s;
					break;
				case ADDRESS_OP:
					msg->method = s;
					break;
				}
			}
			break;
		case MT_FLAG: {
				int32_t flag = ESNPCoder::readInt32(buf, NULL);
				switch(flag) {
				case FLAG_RESP:
					msg->resp = true;
					break;
				case FLAG_REQUEST:
				case FLAG_INFO:
				case FLAG_EVENT:
					msg->type = flag;
					break;
				}
			}
			break;
		case MT_HEADER: {
				std::string key = ESNPCoder::readLenString(buf, NULL);
				CCValueBuilder sb;
				ESNPCoder::readVar(buf, &sb, NULL);
				CCValue root;
				sb.build(&root);
				msg->headers[key] = root;
			}
			break;
		case MT_DATA: {
				std::string key = ESNPCoder::readLenString(buf, NULL);
				CCValueBuilder sb;
				ESNPCoder::readVar(buf, &sb, NULL);
				CCValue root;
				sb.build(&root);
				msg->values[key] = root;
			}
			break;
		case MT_ERROR: {
				msg->error = ESNPCoder::readStringL(buf, sz, NULL);
			}
			break;
		default:
			// skip unknow frame
			buf->SkipRead(sz);
			break;
		}
	}
}

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
	m_lastTick = 0;

	m_wbuf.Init(1024, 1024);
	m_rbuf.Init(1024, 1024);
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
	th->run(mstick);
}

void CCEESNP::run(long mstick) {
	m_lastTick = mstick;
	if(m_socket!=NULL) {
		if(!m_connected && m_canconn && !m_hosts.empty()) {
			int idx = m_hostIdx++;
			idx = idx % m_hosts.size();
			ESNPHost o = m_hosts[idx];
			m_canconn = false;
			m_socket->open(o.host.c_str(), o.port, 5000);
		}
		CCEAsynSocket::appRunnable(m_socket, mstick);
	}
	if(m_reqs.size()>0) {
		std::vector<ESNPReq*>::iterator it = m_reqs.begin();
		for(;it!=m_reqs.end();) {
			ESNPReq* req = *it;
			// timeout?
			if(req->timeout>0) {
				if(mstick-req->tick>req->timeout) {
					// timeout
					CCLOG("esnp message[%d] tiemout", req->id);
					if(req->callback.canCall()) {						
						CCValueMap res;
						res["id"] = CCValue::intValue(req->id);
						res["messageId"] = CCValue::stringValue(midStr(req->mid));
						res["error"] = CCValue::stringValue("timeout");
						CCValueArray ps;
						ps.push_back(CCValue::booleanValue(false));
						ps.push_back(CCValue::mapValue(res));
						req->callback.call(ps,false);
					}
					delreq(req);
					it = m_reqs.erase(it);
					continue;
				}
			}
			// send?
			if(m_connected && !req->send) {
				if(req->message!=NULL) {
					int sz = encode(&m_wbuf, req->message);
					m_socket->write(req->id, (const char *) m_wbuf.Buffer(), sz);
				}
				req->send = true;
			}
			it++;
		}
	}
}

std::string CCEESNP::midStr(uint64_t id) {
	return StringUtil::format(F64U, id);
}

CCValue CCEESNP::toval(ESNPMessage* msg) {
	CCValueMap m;
	if(msg->mid!=0) {
		m["messageId"] = CCValue::stringValue(midStr(msg->mid));
	}
	if(msg->smid!=0) {
		m["sourceMessageId"] = CCValue::stringValue(midStr(msg->smid));
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
		m["values"] = CCValue::mapValue(msg->values);
	}
	if(!msg->error.empty()) {
		m["error"] = CCValue::stringValue(msg->error);
	}
	return CCValue::mapValue(m);
}

bool CCEESNP::tomsg(CCValue& val, ESNPMessage* msg) {
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
	msg->smid = 0;
	it = m->find("sourceMessageId");
	if(it!=m->end()) {
		std::string s = it->second.stringValue();
		if(!s.empty()) {
			sscanf(s.c_str(), F64U, &msg->smid);
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
	msg->resp = false;
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
	it = m->find("error");
	if(it!=m->end()) {
		msg->error = it->second.stringValue();
	}
	return true;
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
	if(m_socket!=NULL) {
		m_socket->close();
	}
	m_hosts.clear();
	m_hostIdx = 0;
	m_midSeq = 0;
	cleanReqs();
	m_dispatcher.cleanup();
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
			if(req->mid==msg->smid) {
				CCLOG("response -> " F64U, msg->smid);
				
				int reqid = req->id;
				uint64_t reqmid = req->mid;
				CCValue cb = req->callback;
				cb.retain();
				
				m_reqs.erase(it);
				delreq(req);
				
				if(cb.canCall()) {
					CCValueArray ps;
					if(msg->error.empty()) {
						ps.push_back(CCValue::booleanValue(true));
						ps.push_back(toval(msg));
					} else {
						CCValueMap res;
						res["id"] = CCValue::intValue(reqid);
						res["messageId"] = CCValue::stringValue(midStr(reqmid));
						res["error"] = CCValue::stringValue(msg->error);
						ps.push_back(CCValue::booleanValue(false));
						ps.push_back(CCValue::mapValue(res));
					}
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
		if(m_midSeq==0)m_midSeq++;
		msg->mid = m_midSeq;
	}

	ESNPReq* req = new ESNPReq();
	req->id = id;
	req->mid = msg->mid;
	req->message = msg;
	req->tick = m_lastTick;
	req->timeout = timeout;
	req->callback = callback;
	req->callback.retain();
	req->send = false;
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
	cleanReqs();
	m_dispatcher.cleanup();	
}

void CCEESNP::cleanReqs() {
	if(m_reqs.size()>0) {
		std::vector<ESNPReq*>::const_iterator it = m_reqs.begin();
		for(;it!=m_reqs.end();it++) {
			delreq(*it);
		}
		m_reqs.clear();
	}
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
			m_rbuf.WriteBytes(ev->getData(), ev->getSize());
			if(decode(&m_rbuf, &m_reading)) {
				m_rbuf.Optimize();
				if(m_handler!=NULL) {
					m_handler->handleIncome(&m_reading);
				} else {
					defaultDispatch(&m_reading);
				}
				// reset m_reading
				m_reading.method.clear();				
				m_reading.mid =0;
				m_reading.resp = false;
				m_reading.service.clear();
				m_reading.smid = 0;
				m_reading.type = 0;
				m_reading.headers.clear();
				m_reading.values.clear();
			}
			return true;
		}
	}
	return false;
}
