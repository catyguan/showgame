#include "CCO4ESNP.h"

#include "cocoa/CCValueSupport.h"
#include "CCEESNP.h"
#include "CCEUtil.h"

// CCO4ESNP
CC_BEGIN_CALLS(CCO4ESNP, CCObject)
	CC_DEFINE_CALL(CCO4ESNP, reset)
	CC_DEFINE_CALL(CCO4ESNP, addHost)
	CC_DEFINE_CALL(CCO4ESNP, send)
	CC_DEFINE_CALL(CCO4ESNP, cancel)
	CC_DEFINE_CALL(CCO4ESNP, runningCount)
CC_END_CALLS(CCO4ESNP, CCObject)

CCValue CCO4ESNP::CALLNAME(reset)(CCValueArray& params)
{
	CCEESNP::sharedESNP()->reset();
	return CCValue::nullValue();
}

CCValue CCO4ESNP::CALLNAME(addHost)(CCValueArray& params)
{
	std::string host = ccvpString(params, 0);
	int port = ccvpInt(params, 1);
	if(host.empty() || port==0) {
		throw new std::string("esnp:addHost(host, port)");
	}
	CCEESNP::sharedESNP()->addHost(host, port);
	return CCValue::nullValue();
}

CCValue CCO4ESNP::CALLNAME(send)(CCValueArray& params)
{
	if(params.size()<1) {
		throw new std::string("esnp:send(msg[, callback, timeoutMS])");		
	}
	CCValue vMsg = params[0];
	CCValue cb = ccvp(params, 1);
	int timeout = ccvpInt(params, 2);

	ESNPMessage* msg = new ESNPMessage();
	if(!CCEESNP::tomsg(vMsg, msg)) {
		delete msg;
		throw new std::string("message invalid");
	}
	int id = CCEESNP::sharedESNP()->process(msg, cb, timeout);
	return CCValue::intValue(id);
}

CCValue CCO4ESNP::CALLNAME(cancel)(CCValueArray& params)
{
	int id = ccvpInt(params, 0);
	bool r = CCEESNP::sharedESNP()->cancel(id);
	return CCValue::booleanValue(r);
}

CCValue CCO4ESNP::CALLNAME(runningCount)(CCValueArray& params)
{
	int r = CCEESNP::sharedESNP()->queryRunningCount();
	return CCValue::intValue(r);
}

