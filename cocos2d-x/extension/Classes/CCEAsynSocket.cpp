#include "CCEAsynSocket.h"

#include "CCEAppUtil.h"

USING_NS_CC;

// CCEAsynSocketEvent
std::string CCEAsynSocketEvent::format(const char* format, ...)
{	
	va_list ap;
	char text[1024] = {0,};
	va_start(ap, format);
	vsnprintf(text, 1024, format, ap);
	va_end(ap);
	return std::string( text );
}

// Commands
class OpenCommand : public CCEThreadCommand
{
public:
	OpenCommand(const char* hostname,int p,int tm) {
		host = hostname;
		port = p;
		timeout = tm;
	}
	virtual ~OpenCommand(){};
	
	std::string host;
	int port;
	int timeout;
};

class SendCommand : public CCEThreadCommand
{
public:
	SendCommand(int i, const char* b, int l) {
		id = i;
		buf = new char[l];
		memcpy(buf,b,l);
		len = l;
	}
	virtual ~SendCommand(){
		if(buf!=NULL)delete buf;
	};
	
	int id;
	char* buf;
	int len;
};


class CloseCommand : public CCEThreadCommand
{
public:
	CloseCommand() { }
	virtual ~CloseCommand(){}
};


// CCEAsynSocket
CCEAsynSocket::CCEAsynSocket()
	: m_handler(NULL)
	, m_socketOpen(false)
	, m_readBuffer(NULL)
	, m_readBufferSize(4*1024)
{
	pthread_mutex_init(&m_thisLock,NULL);
	pthread_mutex_init(&m_eventLock,NULL);
}

CCEAsynSocket::~CCEAsynSocket()
{
	pthread_mutex_destroy(&m_thisLock);
	pthread_mutex_destroy(&m_eventLock);
	std::list<CCEAsynSocketEvent*>::const_iterator it;
	while(m_events.size()>0) {
		it = m_events.begin();
		delete *it;
		m_events.erase(it);
	}
	if(m_readBuffer!=NULL)delete m_readBuffer;
}

bool CCEAsynSocket::isOpen()
{
	bool r = false;
	pthread_mutex_lock(&m_thisLock);	
	r = m_socketOpen;
	pthread_mutex_unlock(&m_thisLock); 
	return r;
}

bool CCEAsynSocket::open(const char* hostname, int p, int timeout)
{
	OpenCommand* cmd = new OpenCommand(hostname,p, timeout);
	sendCommand(cmd);
	return true;
}

bool CCEAsynSocket::write(int id, const char* buf, int len)
{
	if(!isOpen()) {
		return false;
	}
	SendCommand* cmd = new SendCommand(id, buf,len);
	sendCommand(cmd);
	return true;
}

void CCEAsynSocket::close()
{
	if(isOpen()) {	
		CloseCommand* cmd = new CloseCommand();
		sendCommand(cmd);
	}
}

void CCEAsynSocket::addTimeout(std::string name,void* data, long tm)
{
	CCEAsynSocketTimeoutItem item;
	item.name = name;
	item.data = data;
	item.time = CCEAppUtil::timeTick()+tm;
	m_timeoutItems.push_back(item);
}

void CCEAsynSocket::removeTimeout(const char* name)
{
	std::list<CCEAsynSocketTimeoutItem>::const_iterator it,cur;
	for(it=m_timeoutItems.begin();it!=m_timeoutItems.end();) {
		cur = it;
		it++;
		if(cur->name.compare(name)==0) {
			m_timeoutItems.erase(cur);
		}
	}
}
		
CCEAsynSocketHandler* CCEAsynSocket::getHandler()
{
	return m_handler;
}

CCEAsynSocketHandler* CCEAsynSocket::setHandler(CCEAsynSocketHandler* handler)
{
	CCEAsynSocketHandler* r = m_handler;
	m_handler = handler;
	return r;
}
	
void CCEAsynSocket::appRunnable(void* data, long mstick)
{
	CCEAsynSocket* sock = (CCEAsynSocket*) data;
	sock->mainProcessEvents();
}

void CCEAsynSocket::mainProcessEvents()
{
	if(true) {
		CCEAsynSocketEvent* event;
		std::list<CCEAsynSocketEvent*>::const_iterator it;

		while(true) {
			pthread_mutex_lock(&m_eventLock);	
			if(m_events.size()>0) {
				it = m_events.begin();
				event = *it;
				m_events.erase(it);
			} else {
				event = NULL;
			}
			pthread_mutex_unlock(&m_eventLock); 
			if(event==NULL)return;		
			if(m_handler!=NULL) {
				m_handler->handleUpstream(event);
			}
			delete event;
		}
	}

	if(true) {
		long now = CCEAppUtil::timeTick();
		std::list<CCEAsynSocketTimeoutItem>::const_iterator it,cur;
		for(it=m_timeoutItems.begin();it!=m_timeoutItems.end();) {
			cur = it;
			it++;
			if(cur->time<now) {
				if(m_handler!=NULL) {
					CCEAsynSocketEventTimeout tmev = CCEAsynSocketEventTimeout(cur->name, cur->data);
					tmev.bind(this);		
					m_handler->handleUpstream(&tmev);
				}
				m_timeoutItems.erase(cur);
			}
		}
	}
}

void CCEAsynSocket::wakeup()
{
	if(m_socket.isOpen()) {
		m_socket.wakeup();
	}
}

void CCEAsynSocket::run()
{
	m_socket.createFakeFD();
	while(isLive()) {
		if(!processCommands(m_socket.isOpen()?0:100)) {
			break;
		}
		threadCheckServer();
	}
	threadCloseSocket();
	
}

void CCEAsynSocket::cleanup()
{
	m_socket.clear();
	CCEThread::cleanup();
}

bool CCEAsynSocket::processCommand(CCEThreadCommand* th)
{
	if(true) {
		OpenCommand* cmd = dynamic_cast<OpenCommand*>(th);
		if(cmd!=NULL) {
			threadConnect(cmd->host.c_str(), cmd->port, cmd->timeout);
			return true;
		}
	}
	if(true) {
		SendCommand* cmd = dynamic_cast<SendCommand*>(th);
		if(cmd!=NULL) {
			threadServerWrite(cmd->id, cmd->buf, cmd->len);
			return true;
		}
	}
	if(true) {
		CloseCommand* cmd = dynamic_cast<CloseCommand*>(th);
		if(cmd!=NULL) {
			threadCloseSocket();
			return true;
		}
	}
	return CCEThread::processCommand(th);
}

void CCEAsynSocket::threadConnectEvent() {
	if(m_socket.isConnect()) {
		pthread_mutex_lock(&m_thisLock);	
		m_socketOpen = true;
		pthread_mutex_unlock(&m_thisLock); 

		CCEAsynSocketEventOpen* ev = new CCEAsynSocketEventOpen(true,true);
		threadSendEvent(ev);
	} else if(!m_socket.isOpen()) {
		CCEAsynSocketEventOpen* ev = new CCEAsynSocketEventOpen(false, true);
		threadSendEvent(ev);
	}	
}

void CCEAsynSocket::threadConnect(const char* host, int port, int tm)
{
	if(m_socket.isOpen()) {
		threadCloseSocket();
	}
	m_checkNum = 0;
	m_timeout = tm;
	if(m_socket.connect(host, port,10)) {
		threadConnectEvent();
	}
	
}

void CCEAsynSocket::threadCheckServer()
{	
	if(!m_socket.isOpen()) {
		return;
	}
	if(!m_socket.isConnect()) {
		if(!m_socket.checkConnect(10)) {
			m_checkNum++;
			if(m_checkNum*10<m_timeout) {
				return;
			}
			m_socket.close();
		}
		threadConnectEvent();
		return;
	}
	while(threadServerRead()) {
	}
}

bool CCEAsynSocket::threadServerWrite(int id, const char* buf,int len)
{
	if(!m_socket.isConnect()) {
		if(id>0) {
			CCEAsynSocketEventWrite* ev = new CCEAsynSocketEventWrite(id, false);
			threadSendEvent(ev);
		}
		return false;
	}
	if(m_socket.write(buf,len)) {
		if(id>0) {
			CCEAsynSocketEventWrite* ev = new CCEAsynSocketEventWrite(id, true);
			threadSendEvent(ev);
		}
		return true;
	} else {
		if(id>0) {
			CCEAsynSocketEventWrite* ev = new CCEAsynSocketEventWrite(id, false);
			threadSendEvent(ev);
		}
		if(!m_socket.isOpen()) {
			threadCloseSocket();
		}
		return false;
	}
}

bool CCEAsynSocket::threadServerRead()
{
	if(!m_socket.isConnect()) {
		return false;
	}

	if(m_readBuffer==NULL) {
		m_readBuffer = new char[m_readBufferSize];
	}

	int r = 0;
	r = m_socket.read(m_readBuffer, m_readBufferSize, 10);
	if(r<=0) {
		if(!m_socket.isOpen()) {
			threadCloseSocket();
		}
		return false;
	}
	if(r==0) {
		return false;
	}
	CCEAsynSocketEventRead* ev = new CCEAsynSocketEventRead(m_readBuffer, r);
	threadSendEvent(ev);
	return true;
}

void CCEAsynSocket::threadCloseSocket()
{
	bool old = false;
	pthread_mutex_lock(&m_thisLock);	
	old = m_socketOpen;
	m_socketOpen = false;
	pthread_mutex_unlock(&m_thisLock); 

	if(m_socket.isOpen()) {		
		m_socket.close();
	}
	if(old) {
		CCEAsynSocketEventOpen* ev = new CCEAsynSocketEventOpen(false,false);
		threadSendEvent(ev);
	}
}

void CCEAsynSocket::threadSendEvent(CCEAsynSocketEvent* ev)
{
	ev->bind(this);

	pthread_mutex_lock(&m_eventLock);	
	m_events.push_back(ev);
	pthread_mutex_unlock(&m_eventLock); 
}