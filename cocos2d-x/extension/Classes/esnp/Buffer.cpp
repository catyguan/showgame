#include "Buffer.h"
#include <string.h>

Buffer::Buffer(void)
{
	buffer = NULL;
	pos = len = glen = 0;
}

Buffer::~Buffer(void)
{
	Clear();	
}

void Buffer::Clear() {
	if(buffer!=NULL && own!=0) {
		delete []buffer;
		buffer = NULL;
		len = 0;
	}
}

void Buffer::Init(int len, int glen) {
	buffer = new uint8_t[len];
	pos = 0;
	this->len = len;
	this->glen = glen;
	dlen = 0;
	own = 1;
}

void Buffer::Init(Buffer* ptr, int pos) {
	buffer = ptr->buffer;
	this->pos = pos;
	this->len = ptr->len;
	this->glen = ptr->glen;
	this->dlen = ptr->dlen;
	own = 0;	
}

int Buffer::Write(char v) {
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

int Buffer::WriteBytes(const char* buf, int c) {
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

int Buffer::Read() {
	if(pos<dlen) {
		uint8_t c = buffer[pos];
		pos++;
		return c;
	}
	return -1;
}

int Buffer::ReadBytes(char* buf, int c) {
	int rm = Remain();
	int l = rm<c?rm:c;
	if(l>0) {
		memcpy_s(buf, c, buffer+pos, l);
	}
	len+=l;
	return l;
}

int Buffer::Remain() {
	int r = this->dlen - this->pos;
	if(r<=0) {
		return 0;
	}
	return r;
}

std::string Buffer::Dump() {
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