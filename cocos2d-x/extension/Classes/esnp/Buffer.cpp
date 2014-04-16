#include "Buffer.h"
#include <string.h>

ESNPBuffer::ESNPBuffer(void)
{
	buffer = NULL;
	pos = dlen = len = glen = 0;
}

ESNPBuffer::~ESNPBuffer(void)
{
	Clear();	
}

void ESNPBuffer::Reset()
{
	pos = 0;
	dlen = 0;
}

void ESNPBuffer::Clear() {
	if(buffer!=NULL && own!=0) {
		delete []buffer;
		buffer = NULL;
		len = 0;
	}
}

void ESNPBuffer::Init(int len, int glen) {
	buffer = new uint8_t[len];
	pos = 0;
	this->len = len;
	this->glen = glen;
	dlen = 0;
	own = 1;
}

void ESNPBuffer::Init(ESNPBuffer* ptr, int pos) {
	buffer = ptr->buffer;
	this->pos = pos;
	this->len = ptr->len;
	this->glen = ptr->glen;
	this->dlen = ptr->dlen;
	own = 0;	
}

int ESNPBuffer::Write(char v) {
	if(pos+1>=len) {
		if(own==0) {
			return 0;
		}
		uint8_t* tmp = new uint8_t[len+glen];
		if(buffer!=NULL) {			
			memcpy_s(tmp, len+glen, buffer, pos);	
			if(own!=0) {
				delete []buffer;			
			}
		}
		buffer = tmp;
		len+=glen;
	}
	buffer[pos] = v;
	pos++;
	if(pos>dlen)dlen=pos;
	return 1;
}

int ESNPBuffer::WriteBytes(const char* buf, int c) {
	if(pos+c>=len) {
		if(own==0) {
			return 0;
		}
		int llen = len+glen;
		while(llen<pos+c) {
			llen += glen;
		}
		uint8_t* tmp = new uint8_t[llen];
		if(buffer!=NULL) {			
			memcpy_s(tmp, pos, buffer, llen);
			if(own!=0) {
				delete []buffer;			
			}
		}
		buffer = tmp;
		len = llen;
	}
	memcpy_s(buffer+pos, len, buf, c);
	pos+=c;
	if(pos>dlen)dlen=pos;
	return c;
}

int ESNPBuffer::Read() {
	if(pos<dlen) {
		uint8_t c = buffer[pos];
		pos++;
		return c;
	}
	return -1;
}

int ESNPBuffer::ReadBytes(char* buf, int c) {
	int rm = Remain();
	int l = rm<c?rm:c;
	if(l>0) {
		memcpy_s(buf, c, buffer+pos, l);
	}
	len+=l;
	return l;
}

int ESNPBuffer::Remain() {
	int r = this->dlen - this->pos;
	if(r<=0) {
		return 0;
	}
	return r;
}

int ESNPBuffer::Rewrite(int p, const char* buf, int c) {
	if(p+c>=len) {
		return -1;
	}
	memcpy_s(buffer+p, len, buf, c);
	return c;
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