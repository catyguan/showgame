#ifndef  __CCE_ESNP_H__
#define  __CCE_ESNP_H__

#include <stdint.h>
#include "cocos2d.h"
#include "../CCEAsynSocket.h"
#include "Buffer.h"

USING_NS_CC;

typedef struct _ESNPMessage {
	uint64_t mid;
	uint64_t smid;
	std::string service;
	std::string method;	
	
	int type;		// 0-none 4-req 5-message 6-event
	bool resp;
	CCValueMap headers;
	CCValueMap values;
} ESNPMessage;

typedef struct _ESNPReq {
	int id;
	uint64_t mid;
	ESNPMessage* message;
	long tick;
	int timeout;	// MS
	CCValue callback;
	bool send;
} ESNPReq;

typedef struct _ESNPHost {
	std::string host;
	int port;
} ESNPHost;

class CCEESNPHandler
{
public:
	virtual bool handleIncome(ESNPMessage* e) = 0;
};

class CCEESNP : public CCEAsynSocketHandler
{
public:
	CCEESNP();
	~CCEESNP();

public:
	static CCEESNP* sharedESNP(void);
	static void purgeSharedESNP(void);

	static void CALLBACK appRunnable(void* data, long mstick);
	static std::string midStr(uint64_t id);
	static CCValue toval(ESNPMessage* msg);
	static bool tomsg(CCValue& val, ESNPMessage* msg);
	
	bool start();
	void reset();
	void stop();
	
	CCValue getDispatcher();
	void setDispatcher(CCValue dispatcher);
	void defaultDispatch(ESNPMessage* msg);
	void setHandler(CCEESNPHandler* handler);

	void addHost(std::string host, int port);
	int process(ESNPMessage* msg, CCValue callback, int timeout);
	int queryRunningCount();	
	bool cancel(int reqId);

	virtual bool handleUpstream(CCEAsynSocketEvent* e);

protected:	
	void delreq(ESNPReq* req);

	void run(long mstick);
	void cleanup();
	void cleanReqs();

protected:
	int m_idSeq;
	uint64_t m_midSeq;

	std::vector<ESNPHost> m_hosts;
	int m_hostIdx;
	bool m_canconn;
	bool m_connected;

	long m_lastTick;
	std::vector<ESNPReq*> m_reqs;
	CCEAsynSocket* m_socket;
	CCEESNPHandler* m_handler;
	CCValue m_dispatcher;

	ESNPBuffer m_wbuf;
	ESNPBuffer m_rbuf;
	ESNPMessage m_reading;
};

#endif // __CCE_ESNP_H__

