#include "main.h"
#include "../Classes/AppDelegate.h"
#include "CCEGLView.h"

#include "CCFileSystemWin32.h"
#include "CCEUtil.h"
#include "CCEConfig.h"

#ifdef _DEBUG
#include "guicon.h"
#include <crtdbg.h>
#endif

USING_NS_CC;

int APIENTRY _tWinMain(HINSTANCE hInstance,
                       HINSTANCE hPrevInstance,
                       LPTSTR    lpCmdLine,
                       int       nCmdShow)
{
    UNREFERENCED_PARAMETER(hPrevInstance);
    UNREFERENCED_PARAMETER(lpCmdLine);

	// create console
	#ifdef _DEBUG
	RedirectIOToConsole();
	#endif

    // create the application instance
    AppDelegate app;
    CCEGLView* eglView = CCEGLView::sharedOpenGLView();
	if(eglView==NULL) {
		return -1;
	}
    // eglView->setFrameSize(2048, 1536);
	// eglView->setFrameZoomFactor(0.2f);

	const char* fileName;
	std::string strFileName;
	char buf[1024];
	DWORD len = 0;
	if(true) {
		len = ::GetCurrentDirectoryA(256,buf);
		buf[len] = 0;
		CCEConfig::set("dir", CCValue::stringValue(buf));
		strFileName = std::string(buf)+"\\mgr.ini";
		fileName = strFileName.c_str();
	}
	int frameWidth = ::GetPrivateProfileIntA("view","width", 480, fileName);
	int frameHeight = ::GetPrivateProfileIntA("view","height", 320, fileName);
	len = ::GetPrivateProfileStringA("view","zoom","1.0",buf,1024,fileName);
	buf[len] = 0;
	float zoomFactor = (float) atof(buf);

	eglView->setFrameSize(frameWidth, frameHeight);
	if(zoomFactor!=1) {
		eglView->setFrameZoomFactor(zoomFactor);
	}

	int debugMode = ::GetPrivateProfileIntA("debug","enable",1, fileName);
	CCEConfig::set("debug", CCValue::booleanValue(debugMode!=0));

	int designWidth = ::GetPrivateProfileIntA("view","design_width",0, fileName);
	CCEConfig::set("design_width", CCValue::intValue(designWidth));
	int designHeight = ::GetPrivateProfileIntA("view","design_height",0, fileName);
	CCEConfig::set("design_height", CCValue::intValue(designHeight));
	int designPolicy = ::GetPrivateProfileIntA("view","design_policy",0, fileName);
	CCEConfig::set("design_policy", CCValue::intValue(designPolicy));

	len = ::GetPrivateProfileStringA("app", "id", "", buf, 1024, fileName);
	buf[len] = 0;
	CCEConfig::set("appid", CCValue::stringValue(buf));
	len = ::GetPrivateProfileStringA("app", "luapath", "", buf, 1024, fileName);
	buf[len] = 0;
	CCEConfig::set("luapath", CCValue::stringValue(buf));

	if(true) {
		len = ::GetPrivateProfileStringA("app", "device_id", "", buf, 1024, fileName);
		buf[len] = 0;
		std::string did = buf;
		if(did.size()==0) {
			len = ::GetCurrentDirectoryA(256,buf);
			buf[len] = 0;
			WIN32_FIND_DATAA ffd ;
			HANDLE hFind = FindFirstFileA(buf, &ffd);
			did = StringUtil::format("WS_%d_%d", ffd.ftCreationTime.dwHighDateTime, ffd.ftCreationTime.dwLowDateTime);
		}
		CCEConfig::set("device_id", CCValue::stringValue(did));
	}

	// remove Resources
	// len = ::GetPrivateProfileStringA("app", "resources", "", buf, 1024*2, fileName);
	// buf[len] = 0;
	// CCEConfig::set("resources", CCValue::stringValue(buf));

	if(true) {
		// upgrade
		len = ::GetPrivateProfileStringA("upgrade", "url", "", buf, 1024*2, fileName);
		buf[len] = 0;
		CCEConfig::set("upgrade_url", CCValue::stringValue(buf));

		len = ::GetPrivateProfileStringA("upgrade", "host", "", buf, 1024*2, fileName);
		buf[len] = 0;
		CCEConfig::set("upgrade_host", CCValue::stringValue(buf));

		len = ::GetPrivateProfileStringA("upgrade", "version", "", buf, 1024*2, fileName);
		buf[len] = 0;
		CCEConfig::set("upgrade_version", CCValue::stringValue(buf));
	}
    
	// config file system
	CCFileSystemWin32 fs;
	if(true) {
		len = ::GetPrivateProfileStringA("app", "path", "", buf, 1024, fileName);
		buf[len] = 0;
		std::string basedir;
		std::string bindir = CCEConfig::get("dir").stringValue();
		if(strlen(buf)==0) {
			basedir =  bindir;
		} else {
			basedir = buf;
			StringUtil::replaceAll(basedir, "DIR", bindir);
		}	
		if(true) {
			std::string dirvar = basedir + "\\Resources\\";
			fs.addSearchPath(kResource, dirvar.c_str(), false);
		}
		if(true) {
			std::string dirvar = basedir + "\\AppData\\";
			fs.addSearchPath(kAppData, dirvar.c_str(), false);
		}
		if(true) {
			std::string dirvar = basedir + "\\TmpData\\";
			fs.addSearchPath(kTemp, dirvar.c_str(), false);
		}		
		if(true) {
			std::string dirvar = basedir + "\\Upgrade\\Scripts\\";
			fs.addSearchPath(kLua, dirvar.c_str(), false);
			CCLOG("luapath => %s", dirvar.c_str());
		}
		if(true) {
			std::string dirvar = basedir + "\\Scripts\\";
			fs.addSearchPath(kLua, dirvar.c_str(), true);
			CCLOG("luapath => %s", dirvar.c_str());
		}
	}

	if(true) {		
		std::string basedir = CCEConfig::get("dir").stringValue();
		std::string luapath = CCEConfig::get("luapath").stringValue();	
		std::string delim(",");
		std::vector<std::string> plist;
		StringUtil::split(luapath, delim, &plist);

		std::vector<std::string>::const_iterator it = plist.begin();
		for(;it!=plist.end();it++) {
			std::string dir = *it;
			if(dir.size()>0) {
				StringUtil::replaceAll(dir, "DIR", basedir);
				dir = dir + "\\";
				fs.addSearchPath(kLua, dir.c_str(), true);
				CCLOG("luapath => %s", dir.c_str());
			}
		}
	}
	fs.install();

    return CCApplication::sharedApplication()->run();
}
