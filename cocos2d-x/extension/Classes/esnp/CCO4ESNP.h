#ifndef  __CCO_ESNP_H__
#define  __CCO_ESNP_H__

#include "cocos2d.h"

USING_NS_CC;

class CCO4ESNP : public CCObject
{
	// cc_call
	CC_DECLARE_CALLS_BEGIN
	CC_DECLARE_CALL(reset)
	CC_DECLARE_CALL(addHost)
	CC_DECLARE_CALL(send)
	CC_DECLARE_CALL(cancel)
	CC_DECLARE_CALL(cancelTag)
	CC_DECLARE_CALL(runningCount)	
	CC_DECLARE_CALLS_END
};

#endif