#ifndef  __CCE_SOCKET_H__
#define  __CCE_SOCKET_H__

#include "cocos2d.h"

class CCESocketMessage
{

};

class CCESocketHandler
{
public:
	CCESocketHandler(){};
	virtual ~CCESocketHandler(){};

	virtual void run() = 0;
};

class CCESocket
{
public:
	CCESocket();
	virtual ~CCESocket();

	void createFakeFD();
	bool connect(const char* host,int port,int time);
	bool isOpen(){return m_sockfd!=0;};
	bool isConnect(){return m_connect;};
	bool checkConnect(int time);
	bool write(const char* buf, int len);
	int read(char* buf,int len, int time);
	void close();
	void clear();	

	void wakeup();
protected:
	int m_sockfd;
	bool m_connect;
	int m_fakefd_w;
	int m_fakefd_r;
};

#endif // __CCE_SOCKET_H__

