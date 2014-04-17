#include "Buffer.h"
#include <string.h>

ESNPBuffer::ESNPBuffer(void)
{
	buffer = NULL;
	len = glen = 0;
	rpos = wpos = dlen = 0;
}

ESNPBuffer::~ESNPBuffer(void)
{
	Clear();	
}

void ESNPBuffer::Reset()
{
	rpos = wpos = dlen = 0;
}

void ESNPBuffer::ResetRead(int p) {
	if(p>dlen || p<0) {
		rpos = dlen;
	} else {
		rpos = p;
	}
}

void ESNPBuffer::Clear() {
	Reset();
	if(buffer!=NULL && own!=0) {
		delete []buffer;
		buffer = NULL;
		len = 0;
	}
}

void ESNPBuffer::Init(int len, int glen) {
	buffer = new uint8_t[len];
	Reset();
	this->len = len;
	this->glen = glen;
	own = 1;
}

void ESNPBuffer::Init(ESNPBuffer* ptr, int wpos, int rpos) {
	buffer = ptr->buffer;
	this->wpos = wpos;
	this->rpos = rpos;
	this->len = ptr->len;
	this->glen = ptr->glen;
	this->dlen = ptr->dlen;
	own = 0;	
}

int ESNPBuffer::Write(char v) {
	if(!CheckBuf(1)) {
		return 0;
	}
	buffer[wpos] = v;
	wpos++;
	if(wpos>dlen)dlen=wpos;
	return 1;
}

int ESNPBuffer::Reserve(int c) {	
	if(!CheckBuf(c)) {
		return -1;
	}
	int r = wpos;
	wpos+=c;
	return r;
}

bool ESNPBuffer::CheckBuf(int c) {	
	if(wpos+c>=len) {
		if(own==0) {
			return false;
		}
		int llen = len+glen;
		while(llen<wpos+c) {
			llen += glen;
		}
		uint8_t* tmp = new uint8_t[llen];
		if(buffer!=NULL) {			
			memcpy(tmp, buffer, dlen);
			delete []buffer;			
		}
		buffer = tmp;
		len = llen;
	}
	return true;
}

int ESNPBuffer::WriteBytes(const char* buf, int c) {
	if(!CheckBuf(c)) {
		return 0;
	}
	memcpy(buffer+wpos, buf, c);
	wpos+=c;
	if(wpos>dlen)dlen=wpos;
	return c;
}

int ESNPBuffer::Read() {
	if(rpos<dlen) {
		uint8_t c = buffer[rpos];
		rpos++;
		return c;
	}
	return -1;
}

int ESNPBuffer::ReadBytes(char* buf, int c) {
	int rm = Remain();
	int l = rm<c?rm:c;
	if(l>0) {
		memcpy(buf, buffer+rpos, l);
	}
	rpos+=l;
	return l;
}

int ESNPBuffer::Remain() {
	int r = this->dlen - this->rpos;
	if(r<=0) {
		return 0;
	}
	return r;
}

int ESNPBuffer::Rewrite(int p, const char* buf, int c) {
	if(p+c>=len) {
		return -1;
	}
	memcpy(buffer+p, buf, c);
	if(p+c>dlen)dlen=p+c;
	return c;
}

int ESNPBuffer::SkipRead(int sz) {
	if(sz+rpos>dlen) {
		rpos = dlen;
		return -1;
	}
	rpos+=sz;
	return sz;
}

void ESNPBuffer::Optimize() {
	if(rpos<=0)return;
	memcpy(buffer, buffer+rpos, dlen-rpos);
	wpos-=rpos;
	dlen-=rpos;
	rpos=0;	
}

std::string ESNPBuffer::Dump() {
	const static char bin2hex_lookup[] = "0123456789abcdef";
    unsigned int t=0,i=0,leng=dlen;
    std::string r;
    r.reserve(leng*2);
    for(i=0; i<leng; i++)
    {
        r += bin2hex_lookup[ buffer[i] >> 4 ];
        r += bin2hex_lookup[ buffer[i] & 0x0f ];
    }
    return r;
}