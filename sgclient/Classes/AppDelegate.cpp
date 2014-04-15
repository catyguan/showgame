#include "AppDelegate.h"
#include "AppMacros.h"
#include "CCEConfig.h"
#include "CCELuaApplication.h"
#include "CCEDirector.h"
#include "SimpleAudioEngine.h"
#include "CCEAppUtil.h"
#include "CCEUtil.h"
#include "CCEHttpClient.h"
#include "esnp\CCEESNP.h"

#include "CCEFSLuaLoader.h"
static CCEFSLuaLoader fsLoader;

USING_NS_CC;

AppDelegate::AppDelegate() {
	m_started = false;
}	

AppDelegate::~AppDelegate() 
{
	CCEESNP::purgeSharedESNP();
	CCEHttpClient::purgeSharedHttpClient();	
	CCEDirector::purgeSharedDirector();
	CCEApplication::purgeSharedApp();	
	CocosDenshion::SimpleAudioEngine::end();
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground() {
    CCDirector::sharedDirector()->stopAnimation();

    // if you use SimpleAudioEngine, it must be pause
    // SimpleAudioEngine::sharedEngine()->pauseBackgroundMusic();
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground() {
    CCDirector::sharedDirector()->startAnimation();

    // if you use SimpleAudioEngine, it must resume here
    // SimpleAudioEngine::sharedEngine()->resumeBackgroundMusic();
}

#include "CCO4File.h"
#include "CCO4HttpClient.h"
#include "CCO4Audio.h"
#include "CCEDEVScene.h"

CCObject* MGRCreateObject(const char* type, CCValue& cfg);
bool AppDelegate::applicationDidFinishLaunching() {

    // initialize director
    CCDirector* pDirector = CCDirector::sharedDirector();
    CCEGLView* pEGLView = CCEGLView::sharedOpenGLView();

    pDirector->setOpenGLView(pEGLView);

    // Set view resolution	
	if(true) {
		CCSize frameSize = pEGLView->getFrameSize();
		CCEAppConfig cfg;
		CCEAppUtil::readConfig(&cfg);
		int w, h,p;
		w = cfg.designWidth;
		if(w==0)w=frameSize.width;
		h = cfg.designHeight;
		if(h==0)h=frameSize.height;
		p = cfg.designPolicy;
		if(p==0)p=2;
		CCLOG("designMode: %d x %d - %d", w, h, p);
		pEGLView->setDesignResolutionSize(w, h, ResolutionPolicy(p));
	}

    // turn on display FPS
	pDirector->setDisplayStats(CCEConfig::isDebug());

    // set FPS. the default value is 1.0/60 if you don't call this
    pDirector->setAnimationInterval(1.0 / 60);

	// create luahost
	CCELuaApplication* luaHost = new CCELuaApplication();
	luaHost->open();
	luaHost->install();
	if(CCEConfig::isDebug()) {
		luaHost->enablePrintLog();
	}
	addRunnable(0, CCELuaApplication::appRunnable, luaHost);

	// init	
	if(true) {
		CCEDirector* director = new CCEDirector(luaHost);
		director->install();
		luaHost->addObject("director", director);
	}
	if(true) {
		CCO4File* o = new CCO4File();
		luaHost->addObject("file", o);
		o->release();
	}

	if(true) {
		CCO4Audio* o = new CCO4Audio();
		luaHost->addObject("audio", o);
		o->release();
	}

	if(true) {
		CCEHttpClient* hc = CCEHttpClient::sharedHttpClient();		
		addRunnable(1, CCEHttpClient::appRunnable, hc);

		CCO4HttpClient* o = new CCO4HttpClient();
		luaHost->addObject("httpclient", o);
		o->release();
	}
	if(true) {
		CCEESNP* ep = CCEESNP::sharedESNP();
		addRunnable(2, CCEESNP::appRunnable, ep);
		ep->addHost("172.19.16.78", 1080);
		if(!ep->start()) {
			return false;
		}
	}
	if(true) {
		luaHost->addCreateObjectFunction(&MGRCreateObject);
	}

	CCScene* scene = createRootScene();	
	CCDirector::sharedDirector()->runWithScene(scene);

	return true;
}

CCScene* AppDelegate::createRootScene()
{
	return CCEDEVScene::create(AppDelegate::doStartApp, this);
}

#include "SimpleAudioEngine.h"

void AppDelegate::resetCloseApplication()
{
	CCLOG("reset closing application");

	m_started = false;	

	CocosDenshion::SimpleAudioEngine::sharedEngine()->stopAll();

	CCDirector* d = CCDirector::sharedDirector();
	d->popToRootScene();	
	CCScene* scene = createRootScene();
	d->replaceScene(scene);

	CCELuaApplication* luaHost = CCELuaApplication::sharedLuaHost();
	luaHost->close();
	luaHost->open();
	if(CCEConfig::isDebug()) {
		luaHost->enablePrintLog();
	}
}

void AppDelegate::doStartApp(void* data)
{
	AppDelegate* th = (AppDelegate*) data;
	if(th->m_started) {
		th->resetApplication();
	} else {
		th->startApplication();
	}
}

void AppDelegate::startApplication()
{
	m_started = true;

	CCEAppConfig cfg;
	CCEAppUtil::readConfig(&cfg);

	CCLOG("start LuaApp:%s", cfg.appId.c_str());

	CCELuaApplication* luaHost = CCELuaApplication::sharedLuaHost();
	fsLoader.bind(luaHost);
	
	std::list<std::string> bootList;
	bootList.push_back("bma.c2dx.app.Bootstrap");

	std::list<std::string> pathList;
	luaHost->createApp(cfg.appId.c_str(),pathList, bootList);	
		
	CCValueArray ps;
	luaHost->pcall("_API_application_startup",ps,ps);	
}