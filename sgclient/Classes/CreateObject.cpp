#include "CCEApplication.h"
#include "cocoa\CCValueSupport.h"

CCObject* MGRCreateObject(const char* type, CCValue& params)
{
	if(strcmp(type,"testScene1")==0) {
		/*std::string text = ccvpString(params, 0);
		CCPoint pos = ccvpPoint(params, 1);
		CCScene* s = CCScene::create();
		CCLayer* layer = CCLayer::create();
		s->addChild(layer);

		CCLabelTTF* label = CCLabelTTF::create(text.c_str(), "Arial", 24);
		label->setPosition(pos);
		layer->addChild(label);

		return s;*/
	}
	return NULL;
}
